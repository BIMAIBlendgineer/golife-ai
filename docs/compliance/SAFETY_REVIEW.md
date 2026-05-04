# GoLife AI Safety Review

## Safety scope

GoLife AI prioritizes planning, reflection, and small daily actions. It must avoid presenting itself as a source of medical, legal, or regulated financial advice.

## Implemented controls

- guardrails in `services/ai_gateway/app/guardrails.py`
- structured rejection for privacy violations and blocked requests
- structured `422` rejection for unsafe freeform capture, proof-parse, and task-rewrite inputs
- safety event ingestion into `services/web_backend`
- admin safety page and operational review surface
- runtime feature flags for risky AI capabilities
- local mobile capture parser drops obvious crisis or clinical text instead of creating normal drafts

## Covered surfaces

- `reflection/check`
- `events/classify`
- `events/parse`
- `proofs/parse`
- `tasks/rewrite`
- mobile capture parser fallback

## Protected areas

- regulated financial advice
- medical diagnosis or treatment guidance
- legal advice
- destructive actions without confirmation

## Release notes

- task rewrite respects privacy gating before AI execution
- mission generation records safety-related operational metadata
- admin receives operational audit records, not full user prompts
- reflection-style adversarial normalization now also protects classify, parse, proof-parse, and task-rewrite gateway surfaces
- mobile offline capture no longer turns crisis or clinical text into ordinary local entities

## Residual risks

- guardrails remain lexical and heuristic
- adversarial coverage is broader now, but still not a full policy engine or jailbreak-resistant system
- cross-domain reasoning may still produce overly broad suggestions if evidence is sparse

## Required next hardening

- stronger policy engine
- safer refusal phrasing catalog
- model/profile-level safety tuning per capability
- product-level crisis UX for local-only or offline capture surfaces if those flows are expanded

## Release boundary

Current safety is real and implemented, but it is still not a strong policy-engine posture.

Until a centralized policy engine exists, the product should describe safety as:

- broader than the original reflection-only scope
- metadata-only in telemetry
- tested and implemented
- still rule-based rather than fully policy-driven

See also [Safety policy](../security/SAFETY_POLICY.md).
