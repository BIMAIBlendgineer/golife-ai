# Safety Policy

## Purpose

GoLife AI supports planning, reflection, and small daily actions. It must not present itself as a provider of medical, legal, or regulated financial advice.

## Engine model

Current runtime uses a centralized policy engine in `services/ai_gateway/app/policy_engine.py`.

Every decision carries:

- `policy_id`
- `policy_version`
- `category`
- `reason`
- metadata-only trace fields

The current action vocabulary is:

- `allow`
- `reject_422`
- `degrade`
- `require_confirmation`
- `local_only`
- `metadata_only`

## Covered surfaces

Current guarded freeform inputs:

- `POST /v1/reflection/check`
- `POST /v1/events/classify`
- `POST /v1/events/parse`
- `POST /v1/proofs/parse`
- `POST /v1/tasks/rewrite`
- `POST /v1/missions/daily` output review
- mobile local capture parser fallback

## Blocking categories

The current rule set blocks or redirects text suggesting:

- crisis or self-harm intent
- clinical diagnosis or treatment framing
- regulated financial advice
- legal advice
- prompt injection or instruction-bypass attempts
- secret or credential exposure
- unsafe claim language
- obfuscated variants using:
  - leetspeak
  - punctuation splitting
  - letter-spaced tokens
  - accent-insensitive equivalents

## Runtime behavior

### Reflection check

Returns a structured response with:

- `safe`
- `category`
- user-facing message
- optional support resources
- policy trace metadata

### Other guarded AI routes

Return structured `422` responses with machine-readable fields such as:

- `code`
- `input_surface`
- `category`
- localized guidance
- crisis resources when applicable
- redirect hint toward `/v1/reflection/check`
- `policy_id`
- `policy_version`

### Mobile fallback

Local capture parsing does not quietly turn obvious crisis or clinical text into ordinary drafts.

### Mission output

Mission suggestions are reviewed before they leave the gateway.

Unsafe outputs are rejected when they:

- have no evidence
- look like regulated financial advice
- look like medical or legal advice
- expose secrets
- use unsafe claim language

## Telemetry

Operational telemetry is metadata-only.

Allowed operational fields include:

- endpoint
- category
- rule
- severity
- latency
- provider and model metadata
- correlation id

Forbidden operational content:

- raw blocked text
- raw reflection entries
- raw claim text
- raw mission feedback notes

## Product boundaries

GoLife AI may:

- suggest small planning actions
- summarize user-approved evidence
- provide supportive and non-clinical reflection checks

GoLife AI may not:

- diagnose, prescribe, or treat
- provide legal advice
- provide regulated financial advice
- perform destructive user actions without confirmation

## Limits

- this policy engine is centralized and versioned, but still rule-based and heuristic
- it is not jailbreak-proof
- it does not guarantee full adversarial coverage

## Operational response

If a safety issue is reported:

1. review the operational metadata in admin
2. avoid copying raw user text into normal support artifacts
3. use feature flags or model/routing controls to reduce exposure if needed
4. document the incident in the quality/security audit trail

## Next hardening

- broader adversarial corpus
- offline evaluation set
- stronger multilingual and output-side evaluation
- crisis UX improvements for local-only capture flows if product scope expands
