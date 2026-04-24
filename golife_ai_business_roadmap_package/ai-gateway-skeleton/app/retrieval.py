from __future__ import annotations

from collections import Counter
from typing import Any


DOMAIN_KEYWORDS = {
    "money": ["spent", "gasto", "coffee", "cafe", "paid", "eur", "budget", "expense"],
    "pantry": ["fridge", "pantry", "rice", "meal", "cook", "grocery", "expires", "vence"],
    "wardrobe": ["shirt", "jacket", "jeans", "clothes", "wardrobe", "buy clothes"],
    "habit": ["habit", "workout", "sleep", "meditate", "water", "journal"],
    "planning": ["week", "calendar", "plan", "schedule", "tomorrow"],
    "task": ["task", "finish", "todo", "call", "send", "write", "report"],
}


def classify_text_domain(text: str, hints: dict[str, Any] | None = None) -> tuple[str, str, float, str]:
    text_lower = text.lower()
    if hints and hints.get("domain"):
        domain = str(hints["domain"])
        return domain, f"{domain}_captured", 0.9, "The caller provided an explicit domain hint."

    scores = {
        domain: sum(1 for keyword in keywords if keyword in text_lower)
        for domain, keywords in DOMAIN_KEYWORDS.items()
    }
    domain, score = max(scores.items(), key=lambda item: item[1])

    if score == 0:
        return "task", "task_captured", 0.45, "No strong keyword match. Defaulting to task."

    event_type_map = {
        "money": "expense_logged",
        "pantry": "pantry_item_captured",
        "wardrobe": "purchase_intent_captured",
        "habit": "habit_logged",
        "planning": "plan_captured",
        "task": "task_captured",
    }
    return (
        domain,
        event_type_map[domain],
        min(0.55 + score * 0.1, 0.95),
        f"Matched {score} keyword(s) for the {domain} domain.",
    )


def dominant_domain(events: list[dict[str, Any]], fallback: str) -> str:
    domains = [str(event.get("domain", fallback)) for event in events]
    if not domains:
        return fallback
    return Counter(domains).most_common(1)[0][0]


def build_life_context(events: list[dict[str, Any]], domain: str, limit: int = 5) -> list[str]:
    matching = [event for event in events if str(event.get("domain")) == domain]
    selected = matching[:limit] or events[: min(len(events), limit)]
    context: list[str] = []
    for event in selected:
        payload = event.get("payload") or {}
        label = (
            payload.get("title")
            or payload.get("name")
            or payload.get("item")
            or payload.get("amount")
            or event.get("event_type")
        )
        context.append(f"{event.get('domain')}:{event.get('event_type')}:{label}")
    return context
