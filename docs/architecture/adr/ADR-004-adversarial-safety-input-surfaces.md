# ADR-004 Adversarial Safety Input Surfaces

- Status: `accepted`, `implemented`
- Date: `2026-05-04`

## Context

Reflection safety had already been hardened, but other freeform gateway inputs still accepted the same family of crisis and clinical language, including obfuscated variants. Mobile offline fallback parsing could also still turn that input into normal drafts.

This conflicted with the product boundary that GoLife AI should support daily decisions, not behave like an unconstrained mental-health or professional-advice surface.

## Evidence

- [F04 15B reflection adversarial coverage](../../operations/F04_15B_REFLECTION_ADVERSARIAL_COVERAGE.md)
- [F04 adversarial input surfaces](../../operations/F04_26_ADVERSARIAL_INPUT_SURFACES.md)
- merged PR `#11`

## Decision

Use the existing reflection-style rule-based safety model across the broader set of freeform input surfaces.

Protected surfaces now include:

- `/v1/reflection/check`
- `/v1/events/classify`
- `/v1/events/parse`
- `/v1/proofs/parse`
- `/v1/tasks/rewrite`
- mobile local capture parsing

Implemented behavior:

- detect crisis and clinical language
- detect obfuscation through accent folding, leetspeak substitution, punctuation splitting, and split-token collapse
- return structured `422` rejections for blocked gateway inputs
- record metadata-only safety telemetry
- prevent local mobile fallback from emitting normal drafts for obviously unsafe text

## Alternatives Considered

- Keep the hardening only on reflection:
  - rejected because other freeform surfaces remained exposed
- Depend only on model-provider safety:
  - rejected because local deterministic and fallback flows still need product-level guardrails
- Disable local fallback parsing entirely:
  - rejected because offline capture still has product value for non-unsafe input

## Consequences Positive

- unsafe input is blocked earlier and more consistently
- telemetry remains auditable without storing raw blocked text
- mobile degraded mode is safer and more honest

## Consequences Negative

- the policy remains lexical and heuristic
- mobile local capture blocks unsafe text but does not yet provide a richer in-app crisis redirect UX

## Residual Risks

- this is not a strong policy engine
- a broader adversarial corpus and offline evaluation loop are still needed

## Affected Files

- `services/ai_gateway/app/guardrails.py`
- `services/ai_gateway/app/main.py`
- `services/ai_gateway/app/operational_payloads.py`
- `services/ai_gateway/tests/test_api.py`
- `apps/mobile_flutter/lib/features/capture/capture_parser.dart`
- `apps/mobile_flutter/test/features/capture/capture_parser_test.dart`

## Tests And Gates

- `cd services/ai_gateway && python -m pytest -q`
- `cd apps/mobile_flutter && flutter analyze`
- `cd apps/mobile_flutter && flutter test`
- GitHub Actions `ai-gateway`
- GitHub Actions `flutter`
- `gitleaks git`

## Reversibility

Reversible by reverting the added guardrails and parser hardening, but that would intentionally reopen a closed safety gap and should be treated as a regression.
