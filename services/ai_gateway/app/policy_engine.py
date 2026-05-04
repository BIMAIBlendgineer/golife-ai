from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass, field
import re
import unicodedata
from typing import Any, Literal

from app.crisis_resources import resolve_crisis_resources
from app.i18n import normalize_locale, resolve_reflection_messages
from app.schemas import AISuggestion, ReflectionSafetyResponse

PolicyAction = Literal[
    "allow",
    "reject_422",
    "degrade",
    "require_confirmation",
    "local_only",
    "metadata_only",
]

POLICY_VERSION = "2026-05-04.2"
INPUT_POLICY_ID = "golife_input_policy"
OUTPUT_POLICY_ID = "golife_output_policy"
REFLECTION_POLICY_ID = "golife_reflection_policy"

REGULATED_FINANCE_TERMS = (
    "invest",
    "stock market",
    "shares",
    "crypto",
    "etf",
    "portfolio",
    "mutual fund",
)
MEDICAL_TERMS = (
    "diagnose",
    "diagnosis",
    "medication",
    "therapy",
    "treatment plan",
    "disorder",
)
LEGAL_TERMS = (
    "lawsuit",
    "sue",
    "attorney",
    "legal claim",
    "legal strategy",
    "demanda",
    "abogado",
)
UNSAFE_CLAIM_TERMS = (
    "guaranteed",
    "guarantee approval",
    "100 percent",
    "100% safe",
    "risk free",
)
EMOTIONAL_CLINICAL_TERMS = (
    "depressed",
    "depression",
    "anxiety disorder",
    "panic disorder",
    "diagnostico",
    "diagnosis",
    "diagnosticar",
    "terapia",
    "therapy",
    "tratamiento",
    "treatment",
    "medicacion",
    "saude mental",
    "depressao",
    "ansiedade",
    "\u3046\u3064",
    "\u4e0d\u5b89\u969c\u5bb3",
    "\u8a3a\u65ad",
    "\u6cbb\u7642",
    "\u8a3a\u7642",
    "\u6291\u90c1",
    "\u7126\u8651\u75c7",
)
CRISIS_TERMS = (
    "suicide",
    "suicidal",
    "kill myself",
    "end my life",
    "self harm",
    "harm myself",
    "quiero morir",
    "quitarme la vida",
    "suicid",
    "hacerme dano",
    "lastimarme",
    "matarme",
    "me matar",
    "nao quero viver",
    "quero morrer",
    "me machucar",
    "\u6b7b\u306b\u305f\u3044",
    "\u81ea\u6bba",
    "\u6d88\u3048\u305f\u3044",
    "\u4f24\u5bb3\u81ea\u5df1",
    "\u4f24\u5bb3\u6211\u81ea\u5df1",
    "\u81ea\u6740",
    "\u4e0d\u60f3\u6d3b\u4e86",
    "\u60f3\u6b7b",
)
PROMPT_INJECTION_TERMS = (
    "ignore policies",
    "ignore previous instructions",
    "ignore safety",
    "reveal the system prompt",
    "print the api key",
    "show the token",
    "developer message",
    "system prompt",
    "ignora las politicas",
    "ignora politicas",
    "ignora las instrucciones",
)
MINOR_SENSITIVE_TERMS = (
    "minor diagnosis",
    "child diagnosis",
    "family medical record",
)

SECRET_PATTERNS = (
    re.compile(r"\bsk-[a-z0-9]{8,}\b", re.IGNORECASE),
    re.compile(r"authorization\s*:\s*bearer", re.IGNORECASE),
    re.compile(r"client[_\s-]?secret", re.IGNORECASE),
    re.compile(r"api[_\s-]?key", re.IGNORECASE),
    re.compile(r"begin\s+private\s+key", re.IGNORECASE),
)

LEET_TRANSLATION = str.maketrans(
    {
        "0": "o",
        "1": "i",
        "3": "e",
        "4": "a",
        "5": "s",
        "7": "t",
        "@": "a",
        "$": "s",
        "!": "i",
    }
)


@dataclass
class PolicyDecision:
    action: PolicyAction
    policy_id: str
    policy_version: str
    category: str
    reason: str
    message: str
    safe: bool
    resources: list[dict[str, Any]] = field(default_factory=list)
    extra_trace: dict[str, Any] = field(default_factory=dict)

    def trace(self, *, locale: str, region: str) -> dict[str, Any]:
        return {
            "policy": self.policy_id,
            "policy_id": self.policy_id,
            "policy_version": self.policy_version,
            "reason": self.reason,
            "category": self.category,
            "locale": locale,
            "region": region,
            **self.extra_trace,
        }


def _normalize_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value.translate(LEET_TRANSLATION))
    ascii_only = "".join(
        character for character in normalized if not unicodedata.combining(character)
    )
    tokenized = "".join(
        character.lower() if character.isalnum() else " "
        for character in ascii_only
    )
    tokens = tokenized.split()
    collapsed_tokens: list[str] = []
    single_letter_run = ""
    for token in tokens:
        if len(token) == 1 and token.isalpha():
            single_letter_run += token
            continue
        if single_letter_run:
            collapsed_tokens.append(single_letter_run)
            single_letter_run = ""
        collapsed_tokens.append(token)
    if single_letter_run:
        collapsed_tokens.append(single_letter_run)
    return " ".join(collapsed_tokens)


def _joined_windows(tokens: list[str]) -> set[str]:
    windows: set[str] = set(tokens)
    for size in range(2, min(4, len(tokens)) + 1):
        for index in range(len(tokens) - size + 1):
            windows.add("".join(tokens[index : index + size]))
    return windows


def _match_terms(text: str, terms: tuple[str, ...]) -> list[str]:
    lowered_text = text.lower()
    normalized_text = _normalize_text(text)
    tokens = normalized_text.split()
    joined_tokens = _joined_windows(tokens)
    matched: list[str] = []
    for term in terms:
        lowered_term = term.lower()
        if lowered_term in lowered_text:
            matched.append(term)
            continue
        normalized_term = _normalize_text(term)
        compact_term = normalized_term.replace(" ", "")
        if normalized_term in normalized_text or compact_term in joined_tokens:
            matched.append(term)
    return matched


def _contains_secret_pattern(text: str) -> bool:
    lowered = text.lower()
    return any(pattern.search(lowered) for pattern in SECRET_PATTERNS)


def _localized_policy_message(locale: str, key: str) -> str:
    normalized_locale = normalize_locale(locale)
    translations = {
        "prompt_injection": {
            "en": "GoLife rejected this request because it looked like an instruction-injection attempt.",
            "es": "GoLife rechazo esta solicitud porque parecia un intento de inyeccion de instrucciones.",
        },
        "secret_exposure": {
            "en": "GoLife rejected this request because it appeared to contain a secret or credential.",
            "es": "GoLife rechazo esta solicitud porque parecia contener un secreto o una credencial.",
        },
        "legal_advice": {
            "en": "GoLife cannot provide legal advice or legal strategy.",
            "es": "GoLife no puede dar asesoria legal ni estrategia legal.",
        },
    }
    locale_map = translations.get(key, {})
    return locale_map.get(normalized_locale, locale_map.get("en", "Policy blocked the request."))


class PolicyEngine:
    def evaluate_reflection_text(
        self,
        text: str,
        *,
        locale: str,
        region: str = "global",
        catalog_path: str | None = None,
    ) -> ReflectionSafetyResponse:
        normalized_locale = normalize_locale(locale)
        messages = resolve_reflection_messages(normalized_locale)

        matched_crisis = _match_terms(text, CRISIS_TERMS)
        if matched_crisis:
            resources = resolve_crisis_resources(
                region=region,
                catalog_path=catalog_path,
            )
            decision = PolicyDecision(
                action="reject_422",
                policy_id=REFLECTION_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="crisis",
                reason="crisis_language",
                message=messages["crisis"],
                safe=False,
                resources=[dict(resource) for resource in resources],
                extra_trace={"matched_terms": matched_crisis},
            )
            return ReflectionSafetyResponse(
                safe=False,
                category="crisis",
                message=decision.message,
                resources=resources,
                trace=decision.trace(locale=normalized_locale, region=region),
            )

        matched_clinical = _match_terms(text, EMOTIONAL_CLINICAL_TERMS)
        if matched_clinical:
            decision = PolicyDecision(
                action="reject_422",
                policy_id=REFLECTION_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="clinical",
                reason="clinical_language",
                message=messages["clinical"],
                safe=False,
                extra_trace={"matched_terms": matched_clinical},
            )
            return ReflectionSafetyResponse(
                safe=False,
                category="clinical",
                message=decision.message,
                trace=decision.trace(locale=normalized_locale, region=region),
            )

        decision = PolicyDecision(
            action="allow",
            policy_id=REFLECTION_POLICY_ID,
            policy_version=POLICY_VERSION,
            category="supportive",
            reason="supportive_reflection",
            message=messages["supportive"],
            safe=True,
            extra_trace={"matched_terms": []},
        )
        return ReflectionSafetyResponse(
            safe=True,
            category="supportive",
            message=decision.message,
            trace=decision.trace(locale=normalized_locale, region=region),
        )

    def evaluate_input_text(
        self,
        text: str,
        *,
        locale: str,
        input_surface: str,
        region: str = "global",
        catalog_path: str | None = None,
    ) -> PolicyDecision:
        reflection_response = self.evaluate_reflection_text(
            text,
            locale=locale,
            region=region,
            catalog_path=catalog_path,
        )
        if not reflection_response.safe:
            return PolicyDecision(
                action="reject_422",
                policy_id=INPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category=reflection_response.category,
                reason=str(reflection_response.trace.get("reason", "unsafe_input")),
                message=reflection_response.message,
                safe=False,
                resources=[resource.model_dump() for resource in reflection_response.resources],
                extra_trace={
                    "matched_terms": reflection_response.trace.get("matched_terms", []),
                    "input_surface": input_surface,
                },
            )

        normalized_locale = normalize_locale(locale)
        matched_prompt_injection = _match_terms(text, PROMPT_INJECTION_TERMS)
        if matched_prompt_injection:
            return PolicyDecision(
                action="reject_422",
                policy_id=INPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="prompt_injection",
                reason="prompt_injection_language",
                message=_localized_policy_message(normalized_locale, "prompt_injection"),
                safe=False,
                extra_trace={
                    "matched_terms": matched_prompt_injection,
                    "input_surface": input_surface,
                },
            )

        if _contains_secret_pattern(text):
            return PolicyDecision(
                action="reject_422",
                policy_id=INPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="secret_exposure",
                reason="secret_exposure",
                message=_localized_policy_message(normalized_locale, "secret_exposure"),
                safe=False,
                extra_trace={
                    "matched_terms": [],
                    "input_surface": input_surface,
                },
            )

        return PolicyDecision(
            action="allow",
            policy_id=INPUT_POLICY_ID,
            policy_version=POLICY_VERSION,
            category="supportive",
            reason="input_allowed",
            message="Input allowed.",
            safe=True,
            extra_trace={"input_surface": input_surface, "matched_terms": []},
        )

    def evaluate_suggestion(
        self,
        suggestion: AISuggestion,
    ) -> PolicyDecision:
        joined_text = " ".join(
            [
                suggestion.title,
                suggestion.body,
                *[item.claim for item in suggestion.evidence],
            ]
        )
        normalized_text = _normalize_text(joined_text)

        if not suggestion.evidence:
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="output_safety",
                reason="missing_evidence",
                message="Suggestion was missing evidence.",
                safe=False,
            )
        if _match_terms(normalized_text, REGULATED_FINANCE_TERMS):
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="regulated_finance",
                reason="regulated_financial_advice",
                message="Suggestion looked like regulated financial advice.",
                safe=False,
            )
        if _match_terms(normalized_text, MEDICAL_TERMS):
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="medical",
                reason="medical_content",
                message="Suggestion looked like medical advice.",
                safe=False,
            )
        if _match_terms(normalized_text, LEGAL_TERMS):
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="legal",
                reason="legal_content",
                message="Suggestion looked like legal advice.",
                safe=False,
            )
        if _match_terms(normalized_text, UNSAFE_CLAIM_TERMS):
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="unsafe_claim",
                reason="unsafe_claim_language",
                message="Suggestion used unsafe or overconfident claim language.",
                safe=False,
            )
        if _contains_secret_pattern(joined_text):
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="secret_exposure",
                reason="secret_exposure",
                message="Suggestion appeared to contain a secret or credential.",
                safe=False,
            )
        if _match_terms(normalized_text, MINOR_SENSITIVE_TERMS):
            return PolicyDecision(
                action="reject_422",
                policy_id=OUTPUT_POLICY_ID,
                policy_version=POLICY_VERSION,
                category="sensitive_minors",
                reason="sensitive_minors_content",
                message="Suggestion crossed a sensitive minors or family-content boundary.",
                safe=False,
            )

        return PolicyDecision(
            action="require_confirmation",
            policy_id=OUTPUT_POLICY_ID,
            policy_version=POLICY_VERSION,
            category="output_safe",
            reason="requires_confirmation",
            message="Suggestion allowed with confirmation and metadata-only telemetry.",
            safe=True,
        )


policy_engine = PolicyEngine()
