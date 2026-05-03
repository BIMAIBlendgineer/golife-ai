# F04_15 Traceability And Safety Pass

## Phase

- Roadmap phase: F15 traceability + F17 safety hardening
- Branch: `hardening/traceability-safety-pass`
- Date: 2026-05-03

## Objective

Close two remaining production-readiness gaps without schema churn:

- propagate a per-request `correlation_id` through AI gateway operational telemetry;
- harden reflection safety normalization against punctuation-separated crisis phrasing.

## Scope

- `services/ai_gateway/app/main.py`
- `services/ai_gateway/app/operational_payloads.py`
- `services/ai_gateway/app/guardrails.py`
- `services/ai_gateway/tests/test_api.py`

## Changes

- Added AI gateway middleware that resolves `x-correlation-id` or `x-request-id`, falls back to generated `corr-*`, stores it on request state, and echoes it back in the response header.
- Injected `correlation_id` into operational `usage_event` and `ai_invocation` metadata for suggestion, classification, parse, proof parse, feedback, task rewrite, reflection safety, and AI unavailable flows.
- Strengthened reflection text normalization so punctuation-delimited variants such as `self-harm` normalize to the same token stream as `self harm`.
- Extended tests to verify:
  - correlation header passthrough on mission and reflection requests;
  - generated response correlation IDs are copied into operational telemetry metadata;
  - hyphenated crisis phrasing is blocked.

## Verification

Executed local gates:

- `cd services/ai_gateway`
- `python -m compileall app tests/test_api.py`
- `python -m pytest -q tests/test_api.py -k "daily_mission_reports_operational_events or classification_and_feedback_report_operational_audits or reflection_check_reports_metadata_only_operational_audit or hyphenated_crisis"`
  - Result: `4 passed`
- `python -m pytest -q tests/test_api.py::test_proof_parse_reports_metadata_only_operational_audit tests/test_api.py::test_task_rewrite_reports_operational_events tests/test_api.py::test_task_rewrite_privacy_rejection_reports_safety tests/test_api.py::test_operational_audit_normalizes_unknown_locale_to_english`
  - Result: `4 passed`
- `python -m bandit -q -r app -s B105,B106`
  - Result: pass

Observed local limitation:

- `python -m pytest -q tests/test_api.py` exceeded the local Python 3.14 timeout budget in this environment, consistent with the previously documented toolchain slowness on this machine. The focused route and guardrail coverage above completed green.

## Risks

- `correlation_id` is persisted today through metadata-bearing operational records only; mission, safety, and feedback tables would need explicit schema work for first-class correlation fields.
- This remains rule-based reflection safety; coverage is stronger, but not a substitute for a richer adversarial corpus.

## Rollback

- Revert this branch commit or restore the four touched files.
