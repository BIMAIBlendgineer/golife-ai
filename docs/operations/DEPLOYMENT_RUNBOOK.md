# Deployment Runbook

## Goal

Deploy GoLife AI without silent mocks, without dev tokens in production, and without confusing fallback telemetry with live runtime.

## Runtime surfaces

- `services/ai_gateway`
- `services/web_backend`
- `apps/admin_next`
- `apps/mobile_flutter`

## Production modes

### Supported production mode A

Single-key AI Gateway:

- AI Gateway runs directly with `OPENROUTER_API_KEY`
- `ROUTING_CONTROL_ENABLED=false`
- useful for initial production deployments and local production smoke

### Supported production mode B

Routing control plane:

- AI Gateway fetches routing config from `services/web_backend`
- requires a live backend with non-dev `INTERNAL_SERVICE_TOKEN`
- only valid if routing keys, profiles, and model selections are real at runtime

## Preflight

Before deploy:

1. AI Gateway production validator must pass.
2. Web backend production validator must pass.
3. Admin must point at the intended backend.
4. `.env` files must remain untracked.
5. `gitleaks git` must be clean.
6. Release checklist must be green.

## AI Gateway deployment

### Required production conditions

- `AI_GATEWAY_ENV=production`
- `AI_GATEWAY_ENABLE_MOCK=false`
- `LLM_PROVIDER=openrouter`
- `OPENROUTER_API_KEY` present for single-key mode or valid routing backend config for control-plane mode
- `ROUTING_BACKEND_INTERNAL_TOKEN` must not be the dev default

### Single-key production

Use:

- `ROUTING_CONTROL_ENABLED=false`

Expected runtime:

- `/health` reports `active_provider=openrouter`
- `mock_mode=false`
- effective routing is single-key / local env

### Control-plane production

Use only when all of the following are true:

- `ROUTING_CONTROL_ENABLED=true`
- `ROUTING_BACKEND_BASE_URL` is live
- `ROUTING_BACKEND_INTERNAL_TOKEN` is non-dev
- `/internal/ai-routing/config` serves real keys and routing profiles

### AI Gateway post-deploy smoke

```bash
curl -s http://<gateway-host>/health
curl -s http://<gateway-host>/ready
```

Then execute one minimal live `POST /v1/missions/daily` request. The response must:

- return `200`
- contain suggestions
- show provider `openrouter`
- not contain `mock: true`
- not depend on hidden client fallback

## Web backend deployment

### Required production conditions

- `ENVIRONMENT=production`
- `ADMIN_TOKEN` non-dev and at least 24 chars
- `INGESTION_TOKEN` non-dev and at least 24 chars
- `INTERNAL_SERVICE_TOKEN` non-dev and at least 24 chars
- `ADMIN_OPERATOR_SECRET` configured
- `OPENROUTER_KEYS_MASTER_KEY` real and at least 32 chars
- real database configured
- `SEED_DEMO_DATA=false`

### Backend post-deploy smoke

```bash
curl -s http://<web-backend-host>/health
```

Admin-only checks:

- `/admin/security/summary`
- `/admin/support/export-delete`
- `/public/mobile/runtime-config`

## Admin Next deployment

Required external vars:

- `GOLIFE_ADMIN_API_BASE_URL`
- `GOLIFE_ADMIN_API_TOKEN`

Expected UI behavior:

- backend state visible as `live`, `fallback`, or `offline`
- support export/delete actions visible
- no fake live state when backend is unreachable
- enterprise auth must remain explicitly out of scope unless a real OIDC/SSO implementation is deployed
- admin UI locale scope for this release is `en` and `es`

## Mobile deployment

Required runtime defines or config source:

- `GOLIFE_AI_GATEWAY_BASE_URL`
- `GOLIFE_RUNTIME_CONFIG_BASE_URL`

Known limitation:

- repo CI validates Flutter on `ubuntu-latest`, but device-specific Android, iOS, and desktop runner validation is still an open release risk
- mobile locale scope for this release is `en` and `es`

## Rollback

### Application rollback

- revert the last release commit or redeploy previous image
- restore previous external environment values

### Configuration rollback

- restore previous external secret set
- re-run `/health` and `/ready`

### Emergency safety rollback

- disable risky routes through feature flags if the backend is live
- if AI Gateway becomes unavailable, prefer explicit degraded state over reenabling mock in production
