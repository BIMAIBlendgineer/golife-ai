# F04 Adversarial Input Surfaces

Date: `2026-05-04`
Executor: Codex
Branch: `hardening/f04-adversarial-input-surfaces`
Base SHA: `79e1d35d69eb0103502a6f798361083002ee396c`

## Objective

Close the next safety hardening gap after `reflection/check`:

- expand adversarial coverage to other freeform AI gateway inputs
- prevent local mobile fallback parsing from treating crisis or clinical text as a normal capture draft

## Scope

- `services/ai_gateway/app/guardrails.py`
- `services/ai_gateway/app/main.py`
- `services/ai_gateway/app/operational_payloads.py`
- `services/ai_gateway/tests/test_api.py`
- `apps/mobile_flutter/lib/features/capture/capture_parser.dart`
- `apps/mobile_flutter/test/features/capture/capture_parser_test.dart`

## Implementation

### Gateway

- Extracted shared text-safety assessment so the same crisis and clinical matching used by `reflection/check` can also gate:
  - `/v1/events/classify`
  - `/v1/events/parse`
  - `/v1/proofs/parse`
  - `/v1/tasks/rewrite`
- Added structured `422` rejections with:
  - machine-readable `code`
  - `input_surface`
  - `category`
  - localized message
  - crisis resources when applicable
  - `redirect_endpoint=/v1/reflection/check`
- Added safety telemetry for blocked inputs so operational audit records:
  - usage event
  - failed invocation
  - safety batch with rule and severity
  - model settings snapshot

### Mobile

- Added a minimal local safety cut in `CaptureParser`.
- Crisis or clinical text now returns no drafts instead of being converted into normal local task, pantry, or finance entities during offline or degraded parsing.
- The mobile parser uses the same style of normalization hardening as the gateway:
  - accent folding
  - punctuation splitting
  - basic leetspeak substitutions
  - letter-spaced token collapse

## Validation

Gateway:

- `cd services/ai_gateway && python -m pytest -q tests/test_api.py`
  - Result: `63 passed`
- `cd services/ai_gateway && python -m pytest -q`
  - Result: `79 passed`

Mobile:

- `cd apps/mobile_flutter && flutter analyze`
  - Result: green
- `cd apps/mobile_flutter && flutter test`
  - Result: green

Focused coverage added:

- capture classify rejects crisis text with structured safety telemetry
- capture parse rejects letter-spaced clinical language
- proof parse rejects crisis text before parsing
- task rewrite rejects crisis text and records safety metadata
- local mobile capture parser blocks crisis and clinical phrases from producing drafts

## Operational Effect

- Freeform capture, proof, and task-rewrite surfaces no longer rely on downstream heuristics after unsafe text has already entered the normal planning path.
- Admin operational audit still receives metadata only; raw blocked text is not copied into telemetry payloads.
- Offline mobile fallback becomes more honest by refusing unsafe capture text instead of converting it into ordinary entities.

## Residual Risks

- The policy remains lexical and heuristic. It is broader now, but it is not a model-level safety system.
- Mobile local blocking is intentionally minimal and does not yet provide an in-app crisis redirect UI on the capture screen.
- Device-specific runner validation is still pending if Android, iOS, or desktop projects are added to the repo.

## Next Useful Gap

- Learning and memory over persisted data, with explicit validation that feedback and stored evidence improve later daily decisions without violating privacy boundaries.

## Rollback

- Revert the commit for this block.
- Restore:
  - `services/ai_gateway/app/guardrails.py`
  - `services/ai_gateway/app/main.py`
  - `services/ai_gateway/app/operational_payloads.py`
  - `services/ai_gateway/tests/test_api.py`
  - `apps/mobile_flutter/lib/features/capture/capture_parser.dart`
  - `apps/mobile_flutter/test/features/capture/capture_parser_test.dart`
