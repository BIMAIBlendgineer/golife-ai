# Deploy Environment Contract

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `8`
Status: `documented and test-backed`

## Goal

Capture the production environment contract that prevents mock or dev-token drift across AI Gateway, Web Backend, Admin, and Mobile.

## Canonical code sources

- `services/ai_gateway/app/settings.py`
- `services/web_backend/app/settings.py`
- `docs/operations/ENVIRONMENT_MATRIX.md`

## Production invariants

### AI Gateway

- `environment` must resolve to `production`
- `AI_GATEWAY_ENABLE_MOCK` must be `false`
- production must have either:
  - `OPENROUTER_API_KEY`, or
  - a valid routing control plane configuration
- `ROUTING_BACKEND_INTERNAL_TOKEN` must not be the dev default in production

### Web Backend

- `ENVIRONMENT=production`
- `ADMIN_TOKEN`, `INGESTION_TOKEN`, and `INTERNAL_SERVICE_TOKEN` must not use dev defaults
- `ADMIN_TOKEN`, `INGESTION_TOKEN`, and `INTERNAL_SERVICE_TOKEN` must be at least 24 characters in production
- `ADMIN_OPERATOR_SECRET` must be configured and at least 12 characters
- `OPENROUTER_KEYS_MASTER_KEY` must not use the dev default and must be at least 32 characters

### Admin Next

- `GOLIFE_ADMIN_API_BASE_URL` must point at the real backend
- `GOLIFE_ADMIN_API_TOKEN` must be real and must match the backend admin token

### Mobile Flutter

- `GOLIFE_AI_GATEWAY_BASE_URL` must point at the real gateway
- `GOLIFE_RUNTIME_CONFIG_BASE_URL` must point at the real backend runtime-config endpoint

## Smoke commands

```powershell
cd services/ai_gateway
python -m pytest -q

cd ..\\web_backend
python -m pytest -q
```

Operational endpoint smoke after deploy:

```text
GET /health
GET /ready
GET /admin/auth/status
GET /public/mobile/runtime-config
```

## Test evidence already present in repo

### AI Gateway

- production rejects mock mode
- production rejects missing live AI configuration
- production rejects the default routing token
- `/ready` fails if production resolves to mock
- `/ready` succeeds when production has a real provider configuration

### Web Backend

- production rejects default tokens
- production rejects a weak or default master key
- production accepts strong non-dev tokens

## Release rule

If any production deploy would silently degrade to mock or use a dev token, that deploy must be treated as failed.

## Follow-up update required

When the final Android app is prepared for store rollout, `ENVIRONMENT_MATRIX.md` must reflect the current mobile locale set and the Android release contract.

## Gate decision

- Environment contract gate: passed in documentation and tests
- Deployment target smoke: still required against the real deployed services
