# ADR-001 AI Gateway Production Anti-Mock

- Status: `accepted`, `implemented`
- Date: `2026-05-04`

## Context

The AI Gateway originally allowed development mock behavior to remain reachable through configuration defaults and silent provider fallbacks. That made it possible for production to appear healthy while returning non-live AI output.

The product thesis requires daily decisions to be driven by real evidence and a real provider path, not by invisible mock behavior.

## Evidence

- [F03 AI Gateway production runtime closeout](../../operations/F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md)
- merged PR `#7`
- files:
  - `services/ai_gateway/app/settings.py`
  - `services/ai_gateway/app/providers/factory.py`
  - `services/ai_gateway/app/providers/openrouter.py`
  - `services/ai_gateway/app/main.py`

## Decision

Production must fail fast instead of degrading to mock.

Implemented rules:

- `AI_GATEWAY_ENABLE_MOCK=true` is invalid in production
- production must have either a real OpenRouter key path or a real routing-control path
- default development routing tokens are invalid in production
- provider construction may return mock only in development or test
- `/ready` must fail when the gateway is not truly production-ready

## Alternatives Considered

- Remove mocks entirely:
  - rejected because development, tests, and offline UX still need controlled mocks
- Allow mock in production but expose it in `/health`:
  - rejected because observability alone is not a sufficient safety barrier
- Rely on deploy discipline only:
  - rejected because the risk is too easy to misconfigure silently

## Consequences Positive

- production cannot silently serve mock missions
- `/ready` becomes a real operational gate instead of a cosmetic endpoint
- deploy-time mistakes are rejected earlier and more explicitly

## Consequences Negative

- production startup is stricter and will fail until env configuration is correct
- local smoke and deploy docs must stay synchronized with the validator

## Residual Risks

- deploy environments still have to mirror the validated external env values
- single-key production local smoke is validated; multi-key control-plane production still needs intentional live wiring when used

## Affected Files

- `services/ai_gateway/app/settings.py`
- `services/ai_gateway/app/providers/factory.py`
- `services/ai_gateway/app/providers/openrouter.py`
- `services/ai_gateway/app/main.py`
- `services/ai_gateway/tests/test_api.py`
- `services/ai_gateway/tests/test_openrouter_normalization.py`
- `services/ai_gateway/tests/test_openrouter_routing.py`

## Tests And Gates

- `cd services/ai_gateway && python -m pytest -q`
- local production smoke:
  - `/health`
  - `/ready`
  - `POST /v1/missions/daily`
- `gitleaks git`

## Reversibility

Reversible by reverting the anti-mock hardening commits, but that would intentionally reopen a closed release risk and should be treated as a regression.
