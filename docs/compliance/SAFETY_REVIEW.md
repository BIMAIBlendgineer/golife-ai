# GoLife AI Safety Review

## Safety Scope

GoLife AI prioritizes planning, reflection, and small daily actions. It must avoid presenting itself as a source of medical, legal, or regulated financial advice.

## Implemented Controls

- Guardrails in `services/ai_gateway/app/guardrails.py`
- Structured rejection for privacy violations and blocked requests
- Structured rejection for unsafe freeform capture, proof-parse, and task-rewrite inputs
- Safety event ingestion into `services/web_backend`
- Admin safety page and operational review surface
- Runtime feature flags for risky AI capabilities
- Local mobile capture parser drops obviously unsafe crisis or clinical text instead of creating normal drafts

## Protected Areas

- Regulated financial advice
- Medical diagnosis or treatment guidance
- Legal advice
- Destructive actions without confirmation

## Release Notes

- Task rewrite respects privacy gating before AI execution
- Mission generation records safety-related operational metadata
- Admin only receives operational audit records, not full user prompts
- Reflection-style adversarial normalization now also protects classify, parse, proof-parse, and task-rewrite gateway surfaces
- Mobile offline capture no longer turns crisis or clinical text into ordinary local entities

## Residual Risks

- Guardrails are still largely lexical and heuristic
- Adversarial coverage is broader now, but still not a full policy engine or jailbreak-resistant system
- Cross-domain reasoning may still produce overly broad suggestions if evidence is sparse

## Required Next Hardening

- Stronger policy engine
- Safer refusal phrasing catalog
- Model/profile-level safety tuning per capability
- Product-level crisis UX for local-only or offline capture surfaces if those flows are expanded
