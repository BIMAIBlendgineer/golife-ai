from __future__ import annotations

from typing import Any

STATUS_WEIGHTS: dict[str, float] = {
    "useful": 0.8,
    "accepted": 0.65,
    "completed": 1.0,
    "edited": 0.35,
    "rejected": -0.9,
}

REJECTION_REASON_CATEGORIES = {
    "too_hard",
    "not_relevant",
    "not_now",
    "privacy",
    "too_generic",
    "already_done",
    "unknown",
}

EFFORT_FEEDBACK_VALUES = {"low", "balanced", "high", "unknown"}

ALLOWED_RECOMMENDATION_TYPES = {
    "mission",
    "plan_adjustment",
    "task_rewrite",
    "warning",
    "reflection",
}


def normalize_domain_targets(raw_targets: object) -> list[str]:
    domains: list[str] = []
    if isinstance(raw_targets, list):
        for item in raw_targets:
            text = str(item).strip().lower()
            if text and text not in domains:
                domains.append(text)
    return sorted(domains) or ["system"]


def normalize_recommendation_type(raw_value: object) -> str:
    text = str(raw_value or "").strip().lower()
    if text in ALLOWED_RECOMMENDATION_TYPES:
        return text
    return "mission"


def normalize_rejection_reason_category(raw_value: object) -> str:
    text = str(raw_value or "").strip().lower()
    if text in REJECTION_REASON_CATEGORIES:
        return text
    return "unknown"


def normalize_effort_feedback(raw_value: object) -> str:
    text = str(raw_value or "").strip().lower()
    if text in EFFORT_FEEDBACK_VALUES:
        return text
    return "unknown"


def build_learning_key(
    domain_targets: object,
    recommendation_type: object,
) -> str:
    domains = normalize_domain_targets(domain_targets)
    recommendation = normalize_recommendation_type(recommendation_type)
    return f"{recommendation}|{'+'.join(domains)}"


def parse_learning_key(learning_key: object) -> dict[str, Any]:
    if not isinstance(learning_key, str) or "|" not in learning_key:
        fallback_key = build_learning_key([], "mission")
        return {
            "pattern_key": fallback_key,
            "domain_targets": ["system"],
            "recommendation_type": "mission",
        }

    recommendation_type, raw_domains = learning_key.split("|", 1)
    domains = [item for item in raw_domains.split("+") if item] or ["system"]
    return {
        "pattern_key": learning_key.strip(),
        "domain_targets": normalize_domain_targets(domains),
        "recommendation_type": normalize_recommendation_type(recommendation_type),
    }


def resolve_feedback_learning_key(
    *,
    suggestion_id: str,
    domain_targets: object,
    recommendation_type: object,
    trace: object,
) -> tuple[str, str]:
    if isinstance(trace, dict):
        suggestion_keys = trace.get("learning_keys_by_suggestion_id")
        if isinstance(suggestion_keys, dict):
            mapped_key = suggestion_keys.get(suggestion_id)
            if isinstance(mapped_key, str) and mapped_key.strip():
                return mapped_key.strip(), "trace_map"

        trace_key = trace.get("learning_key")
        if isinstance(trace_key, str) and trace_key.strip():
            return trace_key.strip(), "trace"

    return (
        build_learning_key(domain_targets, recommendation_type),
        "derived_pattern",
    )


def feedback_status_weight(status: object) -> float:
    return STATUS_WEIGHTS.get(str(status or "").strip().lower(), 0.0)


def derive_rejection_reason_category(
    *,
    status: object,
    raw_category: object,
    note_text: str,
) -> str | None:
    normalized_status = str(status or "").strip().lower()
    if normalized_status != "rejected":
        return None

    explicit = normalize_rejection_reason_category(raw_category)
    if explicit != "unknown":
        return explicit

    lowered_note = note_text.strip().lower()
    keyword_map = {
        "privacy": ("private", "privacy", "sensitive"),
        "too_hard": ("too hard", "hard", "too much", "exhausting"),
        "not_now": ("later", "not now", "tomorrow", "busy"),
        "already_done": ("already done", "done", "finished"),
        "not_relevant": ("not relevant", "irrelevant", "doesn't fit", "dont fit"),
        "too_generic": ("generic", "vague", "too broad"),
    }
    for category, keywords in keyword_map.items():
        if any(keyword in lowered_note for keyword in keywords):
            return category
    return "unknown"


def derive_effort_feedback(
    *,
    status: object,
    raw_effort_feedback: object,
    rejection_reason_category: str | None,
) -> str:
    explicit = normalize_effort_feedback(raw_effort_feedback)
    if explicit != "unknown":
        return explicit

    normalized_status = str(status or "").strip().lower()
    if normalized_status == "completed":
        return "balanced"
    if normalized_status in {"useful", "accepted", "edited"}:
        return "low"
    if normalized_status == "rejected" and rejection_reason_category == "too_hard":
        return "high"
    return "unknown"


def build_privacy_safe_feedback_summary(
    *,
    status: object,
    domain_targets: object,
    recommendation_type: object,
    rejection_reason_category: str | None,
    effort_feedback: str,
    repeated_flag: bool,
) -> str:
    domains = "+".join(normalize_domain_targets(domain_targets))
    recommendation = normalize_recommendation_type(recommendation_type)
    normalized_status = str(status or "").strip().lower() or "unknown"
    segments = [normalized_status, recommendation, domains]
    if rejection_reason_category and rejection_reason_category != "unknown":
        segments.append(rejection_reason_category)
    if effort_feedback != "unknown":
        segments.append(f"effort:{effort_feedback}")
    if repeated_flag:
        segments.append("repeated")
    return " | ".join(segments)


def summarize_feedback_items(
    items: list[dict[str, object]],
    *,
    user_id: str | None = None,
) -> dict[str, object]:
    by_suggestion: dict[str, dict[str, int]] = {}
    by_domain: dict[str, dict[str, int]] = {}
    by_pattern: dict[str, dict[str, Any]] = {}
    by_recommendation_type: dict[str, dict[str, Any]] = {}
    totals: dict[str, int] = {}
    domain_scores: dict[str, float] = {}
    matching_items = 0
    matching_records: list[dict[str, object]] = []

    for item in items:
        if user_id and str(item.get("user_id", "")) != user_id:
            continue

        matching_items += 1
        matching_records.append(item)
        status = str(item.get("status", "unknown"))
        suggestion_id = str(item.get("suggestion_id", ""))
        domain_targets = normalize_domain_targets(item.get("domain_targets", []))
        recommendation_type = normalize_recommendation_type(
            item.get("recommendation_type")
        )
        rejection_reason_category = normalize_rejection_reason_category(
            item.get("rejection_reason_category")
        )
        effort_feedback = normalize_effort_feedback(item.get("effort_feedback"))
        repeated_flag = bool(item.get("repeated_flag", False))
        learning_key = str(
            item.get("learning_key")
            or build_learning_key(domain_targets, recommendation_type)
        )
        weight = feedback_status_weight(status)

        totals[status] = totals.get(status, 0) + 1

        suggestion_stats = by_suggestion.setdefault(suggestion_id, {})
        suggestion_stats[status] = suggestion_stats.get(status, 0) + 1

        for domain in domain_targets:
            domain_stats = by_domain.setdefault(domain, {})
            domain_stats[status] = domain_stats.get(status, 0) + 1
            domain_scores[domain] = round(domain_scores.get(domain, 0.0) + weight, 4)

        pattern_stats = by_pattern.setdefault(
            learning_key,
            {
                "pattern_key": learning_key,
                "domain_targets": domain_targets,
                "recommendation_type": recommendation_type,
                "item_count": 0,
                "totals": {},
                "positive_count": 0,
                "negative_count": 0,
                "net_score": 0.0,
                "repeated_count": 0,
                "rejection_reason_totals": {},
                "effort_feedback_totals": {},
            },
        )
        pattern_stats["item_count"] += 1
        pattern_totals = pattern_stats["totals"]
        pattern_totals[status] = pattern_totals.get(status, 0) + 1
        if weight > 0:
            pattern_stats["positive_count"] += 1
        elif weight < 0:
            pattern_stats["negative_count"] += 1
        pattern_stats["net_score"] = round(pattern_stats["net_score"] + weight, 4)
        if repeated_flag:
            pattern_stats["repeated_count"] += 1
        if rejection_reason_category != "unknown":
            rejection_totals = pattern_stats["rejection_reason_totals"]
            rejection_totals[rejection_reason_category] = (
                rejection_totals.get(rejection_reason_category, 0) + 1
            )
        if effort_feedback != "unknown":
            effort_totals = pattern_stats["effort_feedback_totals"]
            effort_totals[effort_feedback] = effort_totals.get(effort_feedback, 0) + 1

        recommendation_stats = by_recommendation_type.setdefault(
            recommendation_type,
            {
                "recommendation_type": recommendation_type,
                "item_count": 0,
                "totals": {},
                "positive_count": 0,
                "negative_count": 0,
                "net_score": 0.0,
                "repeated_count": 0,
            },
        )
        recommendation_stats["item_count"] += 1
        recommendation_totals = recommendation_stats["totals"]
        recommendation_totals[status] = recommendation_totals.get(status, 0) + 1
        if weight > 0:
            recommendation_stats["positive_count"] += 1
        elif weight < 0:
            recommendation_stats["negative_count"] += 1
        recommendation_stats["net_score"] = round(
            recommendation_stats["net_score"] + weight,
            4,
        )
        if repeated_flag:
            recommendation_stats["repeated_count"] += 1

    return {
        "user_id": user_id,
        "item_count": matching_items,
        "totals": totals,
        "by_suggestion": by_suggestion,
        "by_domain": by_domain,
        "by_pattern": by_pattern,
        "by_recommendation_type": by_recommendation_type,
        "memory_profile": _build_memory_profile(
            matching_records,
            by_pattern=by_pattern,
            domain_scores=domain_scores,
        ),
    }


def _build_memory_profile(
    matching_records: list[dict[str, object]],
    *,
    by_pattern: dict[str, dict[str, Any]],
    domain_scores: dict[str, float],
) -> dict[str, object]:
    return {
        "memory_version": 1,
        "reinforce_patterns": _sorted_pattern_items(by_pattern, positive=True),
        "avoid_patterns": _sorted_pattern_items(by_pattern, positive=False),
        "reinforce_domains": _sorted_domain_items(domain_scores, positive=True),
        "avoid_domains": _sorted_domain_items(domain_scores, positive=False),
        "recent_feedback": _recent_feedback_items(matching_records),
    }


def _sorted_pattern_items(
    by_pattern: dict[str, dict[str, Any]],
    *,
    positive: bool,
) -> list[dict[str, Any]]:
    items = []
    for pattern_key, stats in by_pattern.items():
        net_score = float(stats.get("net_score", 0.0) or 0.0)
        if positive and net_score <= 0:
            continue
        if not positive and net_score >= 0:
            continue
        items.append(
            {
                "pattern_key": pattern_key,
                "domain_targets": stats.get("domain_targets", ["system"]),
                "recommendation_type": stats.get("recommendation_type", "mission"),
                "item_count": int(stats.get("item_count", 0) or 0),
                "positive_count": int(stats.get("positive_count", 0) or 0),
                "negative_count": int(stats.get("negative_count", 0) or 0),
                "repeated_count": int(stats.get("repeated_count", 0) or 0),
                "net_score": round(net_score, 4),
            }
        )
    return sorted(
        items,
        key=lambda item: (
            abs(float(item["net_score"])),
            int(item["item_count"]),
            item["pattern_key"],
        ),
        reverse=True,
    )[:3]


def _sorted_domain_items(
    domain_scores: dict[str, float],
    *,
    positive: bool,
) -> list[dict[str, Any]]:
    items = []
    for domain, score in domain_scores.items():
        if positive and score <= 0:
            continue
        if not positive and score >= 0:
            continue
        items.append({"domain": domain, "net_score": round(score, 4)})
    return sorted(
        items,
        key=lambda item: abs(float(item["net_score"])),
        reverse=True,
    )[:3]


def _recent_feedback_items(
    matching_records: list[dict[str, object]],
) -> list[dict[str, object]]:
    recent_items = []
    for item in reversed(matching_records[-5:]):
        learning_key = str(item.get("learning_key") or build_learning_key([], "mission"))
        parsed = parse_learning_key(learning_key)
        recent_items.append(
            {
                "status": str(item.get("status", "unknown")),
                "pattern_key": parsed["pattern_key"],
                "domain_targets": parsed["domain_targets"],
                "recommendation_type": parsed["recommendation_type"],
                "notes_present": bool(item.get("notes_present", False)),
                "rejection_reason_category": normalize_rejection_reason_category(
                    item.get("rejection_reason_category")
                ),
                "effort_feedback": normalize_effort_feedback(
                    item.get("effort_feedback")
                ),
                "repeated_flag": bool(item.get("repeated_flag", False)),
                "privacy_safe_summary": str(item.get("privacy_safe_summary", "")),
            }
        )
    return recent_items
