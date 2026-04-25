from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from app.schemas import EventClassificationRequest, EventParseRequest


@dataclass(frozen=True)
class ParsedCaptureItem:
    text: str
    domain: str
    event_type: str
    confidence: float
    rationale: str
    hints: dict[str, Any]


def parse_capture_request(request: EventParseRequest) -> list[ParsedCaptureItem]:
    return _parse_text_to_items(request.text)


def classify_capture_request(request: EventClassificationRequest) -> ParsedCaptureItem:
    items = _parse_text_to_items(request.text)
    if items:
        return items[0]
    return ParsedCaptureItem(
        text=request.text,
        domain="task",
        event_type="task_captured",
        confidence=0.62,
        rationale="Defaulted to task because no stronger domain signal was found.",
        hints={},
    )


def _parse_text_to_items(text: str) -> list[ParsedCaptureItem]:
    normalized_text = text.strip()
    if not normalized_text:
        return []

    clauses = _split_into_clauses(normalized_text)
    if not clauses:
        return []
    return [_classify_clause(clause) for clause in clauses]


def _split_into_clauses(text: str) -> list[str]:
    compact = " ".join(text.replace("\n", ", ").replace(";", ", ").split()).strip()
    if not compact:
        return []

    rough_parts: list[str] = []
    for part in compact.split(","):
        rough_parts.extend(_split_on_connector(part))

    cleaned = [_clean_clause(part) for part in rough_parts if _clean_clause(part)]
    return cleaned or [compact]


def _split_on_connector(text: str) -> list[str]:
    lowered = text.lower()
    signal_count = (
        _count_signals(lowered, ["compr", "gaste", "pague", "coffee"])
        + _count_signals(lowered, ["vence", "caduc", "fridge"])
        + _count_signals(lowered, ["debo", "tengo que", "submit"])
        + _count_signals(lowered, ["comprar", "jacket", "ropa"])
    )
    if signal_count < 2 or (" y " not in lowered and " and " not in lowered):
        return [text]
    if " y " in lowered:
        return text.split(" y ")
    return text.split(" and ")


def _count_signals(lowered: str, signals: list[str]) -> int:
    return sum(1 for signal in signals if signal in lowered)


def _clean_clause(text: str) -> str:
    cleaned = text.strip()
    for prefix in ("y ", "and "):
        if cleaned.lower().startswith(prefix):
            return cleaned[len(prefix) :].strip()
    return cleaned


def _classify_clause(clause: str) -> ParsedCaptureItem:
    lowered = clause.lower()
    if _looks_like_finance(lowered):
        return _build_clause(
            clause,
            "finance",
            confidence=0.88,
            rationale="Detected spend, amount, or finance wording.",
        )
    if _looks_like_pantry(lowered):
        return _build_clause(
            clause,
            "pantry",
            confidence=0.86,
            rationale="Detected food, expiry, or pantry rescue wording.",
        )
    if _looks_like_wardrobe(lowered):
        return _build_clause(
            clause,
            "wardrobe",
            confidence=0.82,
            rationale="Detected purchase intention or clothing wording.",
        )
    if _looks_like_habit(lowered):
        return _build_clause(
            clause,
            "habit",
            confidence=0.8,
            rationale="Detected repeated behavior or self-care wording.",
        )
    if _looks_like_week(lowered):
        return _build_clause(
            clause,
            "week",
            confidence=0.76,
            rationale="Detected weekly planning or schedule wording.",
        )
    return _build_clause(
        clause,
        "task",
        confidence=0.72,
        rationale="Defaulted to task because the clause looks actionable.",
    )


def _build_clause(
    clause: str,
    domain: str,
    *,
    confidence: float,
    rationale: str,
) -> ParsedCaptureItem:
    return ParsedCaptureItem(
        text=clause,
        domain=domain,
        event_type=_default_event_type(domain),
        confidence=confidence,
        rationale=rationale,
        hints=_extract_hints(clause, domain),
    )


def _extract_hints(clause: str, domain: str) -> dict[str, Any]:
    hints: dict[str, Any] = {}
    lowered = clause.lower()

    amount = _extract_first_amount(clause)
    if amount is not None:
        hints["amount"] = amount

    if any(signal in lowered for signal in ("eur", "euro")):
        hints["currency"] = "EUR"
    elif "$" in lowered or "usd" in lowered or "dollar" in lowered:
        hints["currency"] = "USD"

    time_hint = _extract_time_hint(lowered)
    if time_hint is not None:
        hints["time_hint"] = time_hint

    if domain == "task" and any(
        signal in lowered for signal in ("debo", "tengo que", "need to")
    ):
        hints["task_intent"] = "required"
    if domain == "habit":
        hints["habit_intent"] = "check_in"
    if domain == "week":
        hints["planning_intent"] = "weekly_focus"
    if domain == "finance":
        hints["finance_intent"] = "expense"
    if domain == "pantry" and any(
        signal in lowered for signal in ("vence", "caduca", "expires")
    ):
        hints["expiry_hint"] = time_hint or "soon"
    if domain == "wardrobe":
        hints["purchase_pause_hours"] = 24

    return hints


def _extract_first_amount(text: str) -> float | None:
    number = []
    started = False
    for char in text:
        if char.isdigit():
            started = True
            number.append(char)
            continue
        if started and char in ",.":
            number.append(".")
            continue
        if started:
            break
    if not number:
        return None
    try:
        return float("".join(number))
    except ValueError:
        return None


def _extract_time_hint(lowered: str) -> str | None:
    for hint in ("today", "tomorrow", "tonight", "manana", "hoy"):
        if hint in lowered:
            return hint
    return None


def _looks_like_finance(lowered: str) -> bool:
    return any(
        signal in lowered
        for signal in (
            "compr",
            "gaste",
            "pague",
            "coffee",
            "cafe",
            "sandwich",
        )
    ) or any(char.isdigit() for char in lowered)


def _looks_like_pantry(lowered: str) -> bool:
    return any(
        signal in lowered
        for signal in (
            "vence",
            "caduca",
            "expires",
            "fridge",
            "lechuga",
            "spinach",
            "pantry",
            "food",
            "rice",
        )
    )


def _looks_like_wardrobe(lowered: str) -> bool:
    return any(
        signal in lowered
        for signal in (
            "jacket",
            "shoes",
            "ropa",
            "closet",
            "buy another",
            "comprar",
            "chaqueta",
        )
    )


def _looks_like_habit(lowered: str) -> bool:
    return any(
        signal in lowered
        for signal in (
            "walk",
            "sleep",
            "meditat",
            "reset",
            "habit",
            "agua",
            "exercise",
        )
    )


def _looks_like_week(lowered: str) -> bool:
    return any(
        signal in lowered
        for signal in (
            "week",
            "monday",
            "friday",
            "calendar",
            "schedule",
            "plan",
            "meeting",
        )
    )


def _default_event_type(domain: str) -> str:
    defaults = {
        "task": "task_captured",
        "habit": "habit_logged",
        "week": "week_note_captured",
        "finance": "expense_logged",
        "pantry": "ingredient_flagged",
        "wardrobe": "purchase_intention",
    }
    return defaults.get(domain, "task_captured")
