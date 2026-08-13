from __future__ import annotations

from dataclasses import dataclass, field


PROFESSIONAL_ADVICE_TERMS = {
    "medical": ["diagnose", "diagnosis", "prescription", "treatment", "depression", "anxiety"],
    "legal": ["legal advice", "lawsuit", "contract dispute", "evade taxes", "illegal"],
    "financial": ["invest", "stock tip", "tax strategy", "loan advice", "crypto pick"],
}

DESTRUCTIVE_TERMS = ["delete all", "throw away", "sell everything", "cancel everything", "discard"]


@dataclass
class SafetyDecision:
    allowed: bool = True
    reasons: list[str] = field(default_factory=list)
    requires_confirmation: bool = False


def evaluate_safety(text_fragments: list[str]) -> SafetyDecision:
    joined = " ".join(text_fragments).lower()
    reasons: list[str] = []

    for category, terms in PROFESSIONAL_ADVICE_TERMS.items():
        if any(term in joined for term in terms):
            reasons.append(f"Blocked potential {category} advice request.")

    requires_confirmation = any(term in joined for term in DESTRUCTIVE_TERMS)
    if requires_confirmation:
        reasons.append("Detected a destructive or hard-to-reverse action.")

    return SafetyDecision(
        allowed=not any("Blocked potential" in reason for reason in reasons),
        reasons=reasons,
        requires_confirmation=requires_confirmation,
    )
