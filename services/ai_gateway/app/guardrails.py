from collections.abc import Iterable
import unicodedata

from fastapi import HTTPException

from app.crisis_resources import resolve_crisis_resources
from app.i18n import normalize_locale, resolve_reflection_messages
from app.schemas import (
    AISuggestion,
    LifeEvent,
    ReflectionSafetyRequest,
    ReflectionSafetyResponse,
    SuggestionRequest,
    TaskRewriteRequest,
)

REGULATED_FINANCE_TERMS = (
    "invest",
    "stock",
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
    "うつ",
    "不安障害",
    "診断",
    "治疗",
    "診療",
    "抑郁",
    "焦虑症",
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
    "死にたい",
    "自殺",
    "消えたい",
    "伤害自己",
    "伤害我自己",
    "自杀",
    "不想活了",
    "想死",
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
    normalized_text = _normalize_text(text)
    tokens = normalized_text.split()
    joined_tokens = _joined_windows(tokens)
    matched: list[str] = []
    for term in terms:
        normalized_term = _normalize_text(term)
        compact_term = normalized_term.replace(" ", "")
        if normalized_term in normalized_text or compact_term in joined_tokens:
            matched.append(term)
    return matched


def filter_ai_events(request: SuggestionRequest) -> tuple[list[LifeEvent], list[dict[str, str]]]:
    if not request.privacy_settings.ai_enabled:
        return [], [
            {"event_id": event.event_id, "reason": "ai_disabled"}
            for event in request.life_events
        ]

    allowed_domains = set(request.privacy_settings.allowed_domains or request.allowed_domains)
    allowed_events: list[LifeEvent] = []
    filtered: list[dict[str, str]] = []

    for event in request.life_events:
        if event.privacy_level != "ai_allowed":
            filtered.append({"event_id": event.event_id, "reason": "privacy_level"})
            continue
        if allowed_domains and event.domain not in allowed_domains:
            filtered.append({"event_id": event.event_id, "reason": "domain_not_allowed"})
            continue
        allowed_events.append(event)

    return allowed_events, filtered


def enforce_task_rewrite_privacy(request: TaskRewriteRequest) -> None:
    if request.privacy_level != "ai_allowed":
        raise HTTPException(
            status_code=403,
            detail="Task rewrite requires privacy_level=ai_allowed.",
        )


def sanitize_suggestions(
    suggestions: Iterable[AISuggestion],
    *,
    max_items: int,
) -> tuple[list[AISuggestion], list[dict[str, str]]]:
    accepted: list[AISuggestion] = []
    rejected: list[dict[str, str]] = []

    for suggestion in suggestions:
        text = f"{suggestion.title} {suggestion.body}".lower()
        if not suggestion.evidence:
            rejected.append(
                {"suggestion_id": suggestion.suggestion_id, "reason": "missing_evidence"}
            )
            continue
        if any(term in text for term in REGULATED_FINANCE_TERMS):
            rejected.append(
                {"suggestion_id": suggestion.suggestion_id, "reason": "regulated_advice"}
            )
            continue
        if any(term in text for term in MEDICAL_TERMS):
            rejected.append(
                {"suggestion_id": suggestion.suggestion_id, "reason": "medical_content"}
            )
            continue

        merged_actions = list(dict.fromkeys(
            [*suggestion.forbidden_actions, "external_action_without_confirmation"]
        ))
        accepted.append(
            suggestion.model_copy(
                update={
                    "requires_confirmation": True,
                    "forbidden_actions": merged_actions,
                }
            )
        )

        if len(accepted) >= max_items:
            break

    return accepted, rejected


def assess_reflection_safety(
    request: ReflectionSafetyRequest,
    *,
    region: str = "global",
    catalog_path: str | None = None,
) -> ReflectionSafetyResponse:
    locale = normalize_locale(request.locale)
    messages = resolve_reflection_messages(locale)

    matched_crisis = _match_terms(request.text, CRISIS_TERMS)
    if matched_crisis:
        resources = resolve_crisis_resources(
            region=region,
            catalog_path=catalog_path,
        )
        return ReflectionSafetyResponse(
            safe=False,
            category="crisis",
            message=messages["crisis"],
            resources=resources,
            trace={
                "policy": "reflection_safety",
                "matched_terms": matched_crisis,
                "reason": "crisis_language",
                "region": region,
                "locale": locale,
            },
        )

    matched_clinical = _match_terms(request.text, EMOTIONAL_CLINICAL_TERMS)
    if matched_clinical:
        return ReflectionSafetyResponse(
            safe=False,
            category="clinical",
            message=messages["clinical"],
            trace={
                "policy": "reflection_safety",
                "matched_terms": matched_clinical,
                "reason": "clinical_language",
                "region": region,
                "locale": locale,
            },
        )

    return ReflectionSafetyResponse(
        safe=True,
        category="supportive",
        message=messages["supportive"],
        trace={
            "policy": "reflection_safety",
            "matched_terms": [],
            "reason": "supportive_reflection",
            "region": region,
            "locale": locale,
        },
    )
