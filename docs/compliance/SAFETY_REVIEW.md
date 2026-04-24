# GoLife AI Safety Review

## Safety Scope

GoLife AI prioritizes planning, reflection, and small daily actions. It must avoid presenting itself as a source of medical, legal, or regulated financial advice.

## Implemented Controls

- Guardrails in `services/ai_gateway/app/guardrails.py`
- Structured rejection for privacy violations and blocked requests
- Safety event ingestion into `services/web_backend`
- Admin safety page and operational review surface
- Runtime feature flags for risky AI capabilities

## Protected Areas

- Regulated financial advice
- Medical diagnosis or treatment guidance
- Legal advice
- Destructive actions without confirmation

## Release Notes

- Task rewrite respects privacy gating before AI execution
- Mission generation records safety-related operational metadata
- Admin only receives operational audit records, not full user prompts

## Residual Risks

- Guardrails are still largely lexical and heuristic
- Adversarial red-team coverage is limited
- Cross-domain reasoning may still produce overly broad suggestions if evidence is sparse

## Required Next Hardening

- More adversarial tests
- Stronger policy engine
- Safer refusal phrasing catalog
- Model/profile-level safety tuning per capability
