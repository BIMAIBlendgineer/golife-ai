# GoLife AI Safety Review

## Safety scope

GoLife AI prioritizes planning, reflection, and small daily actions. It must avoid presenting itself as a source of medical, legal, or regulated financial advice.

## Implemented controls

- centralized policy engine in `services/ai_gateway/app/policy_engine.py`
- guardrail adapters in `services/ai_gateway/app/guardrails.py`
- structured rejection for privacy violations and blocked requests
- structured `422` rejection for unsafe freeform capture, proof-parse, and task-rewrite inputs
- structured policy metadata on input and reflection safety decisions
- mission-output policy review before unsafe suggestions are returned
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
- `missions/daily` output review
- mobile capture parser fallback

## Protected areas

- regulated financial advice
- medical diagnosis or treatment guidance
- legal advice
- destructive actions without confirmation
- prompt injection or policy-bypass attempts
- secret or credential exposure

## Release notes

- task rewrite respects privacy gating before AI execution
- mission generation records safety-related operational metadata
- admin receives operational audit records, not full user prompts
- reflection-style adversarial normalization now also protects classify, parse, proof-parse, and task-rewrite gateway surfaces
- mobile offline capture no longer turns crisis or clinical text into ordinary local entities
- policy decisions now include `policy_id` and `policy_version`
- mission output is rejected if it crosses regulated or unsafe language boundaries

## Residual risks

- the policy engine is versioned and centralized, but its rules are still lexical and heuristic
- adversarial coverage is broader now, but it is still not a jailbreak-resistant system
- cross-domain reasoning may still produce overly broad suggestions if evidence is sparse

## Required next hardening

- safer refusal phrasing catalog
- model/profile-level safety tuning per capability
- broader multilingual adversarial corpus
- product-level crisis UX for local-only or offline capture surfaces if those flows are expanded

## Release boundary

Current safety is real and implemented, including a centralized policy engine, but it is still not a strong learned policy or DLP posture.

The product should describe safety as:

- broader than the original reflection-only scope
- centralized and versioned
- metadata-only in telemetry
- tested and implemented
- still rule-based rather than fully adaptive or jailbreak-resistant

See also [Safety policy](../security/SAFETY_POLICY.md).
