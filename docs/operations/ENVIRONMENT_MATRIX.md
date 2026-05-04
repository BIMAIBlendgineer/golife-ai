# Environment Matrix

This matrix documents runtime configuration without embedding secrets.

## AI Gateway

| Variable | Dev / example | Production rule | Notes |
| --- | --- | --- | --- |
| `AI_GATEWAY_ENV` | `dev` | must be `production` in deploy | alias also accepted as `environment` or `ENVIRONMENT` |
| `LLM_PROVIDER` | `openrouter` | `openrouter` | current live provider |
| `AI_GATEWAY_ENABLE_MOCK` | allowed in dev | must be `false` | production validator blocks `true` |
| `OPENROUTER_API_KEY` | optional in dev | required for single-key mode | never log or commit |
| `OPENROUTER_BASE_URL` | OpenRouter default | same unless explicitly changed | default is checked |
| `OPENROUTER_DEFAULT_MODEL` | `google/gemini-2.0-flash-001` | set externally if changed | reflected in telemetry |
| `OPENROUTER_FALLBACK_MODEL` | optional | optional | not a license to use mock |
| `OPERATIONAL_BACKEND_ENABLED` | `true` or `false` locally | enabled only if backend is live | AI Gateway can run without it for smoke |
| `OPERATIONAL_BACKEND_BASE_URL` | `http://127.0.0.1:8010` | external service URL | used for metadata-only operational ingestion |
| `OPERATIONAL_BACKEND_INGESTION_TOKEN` | local dev token | must be non-dev if enabled in production | never log |
| `ROUTING_CONTROL_ENABLED` | often `true` in examples | `false` for single-key or `true` only with live control plane | production should not be ambiguous |
| `ROUTING_BACKEND_BASE_URL` | local backend URL | required only for control-plane mode | ignored in single-key mode |
| `ROUTING_BACKEND_INTERNAL_TOKEN` | dev default in examples | must be non-dev in production | production validator blocks dev default |
| `CRISIS_RESOURCES_REGION` | `global` | set to intended region | affects safety resources |
| `CRISIS_RESOURCES_CATALOG_PATH` | optional sample file | required only if custom catalog is expected | `/ready` checks existence when configured |

## Web Backend

| Variable | Dev / example | Production rule | Notes |
| --- | --- | --- | --- |
| `ENVIRONMENT` | `dev` | must be `production` | activates production validation |
| `ADMIN_TOKEN` | local token | non-dev, minimum 24 chars | required by admin panel |
| `ADMIN_OPERATOR_SECRET` | optional in dev | required, minimum 12 chars | token-only mode is not enterprise-ready |
| `INGESTION_TOKEN` | local token | non-dev, minimum 24 chars | used by AI Gateway operational ingestion |
| `INTERNAL_SERVICE_TOKEN` | local token | non-dev, minimum 24 chars | used by AI routing control plane |
| `OPENROUTER_KEYS_MASTER_KEY` | local placeholder | real key, minimum 32 chars | encrypts stored key material |
| `OPERATIONAL_DATABASE_URL` | optional | use real DB if available | preferred for production |
| `OPERATIONAL_DATABASE_PATH` | `.runtime/web_backend.db` | fallback only if file-based deploy is intended | local/dev default |
| `SEED_DEMO_DATA` | `false` | must remain `false` | production should not seed demo data |
| `MOBILE_GATEWAY_BASE_URL` | local gateway URL | production gateway URL | returned by runtime-config endpoint |
| `MOBILE_RUNTIME_CONFIG_TTL_SECONDS` | `21600` | tune operationally | mobile cache TTL |

## Admin Next

| Variable | Dev / example | Production rule | Notes |
| --- | --- | --- | --- |
| `GOLIFE_ADMIN_API_BASE_URL` | `http://127.0.0.1:8010` | required | points to web backend |
| `GOLIFE_ADMIN_API_TOKEN` | local admin token | required and non-dev | must match backend admin token |

Admin UI behavior:

- `live`: backend reachable with live data
- `fallback`: backend answered through snapshot/fallback path
- `offline`: backend unreachable
- release-supported admin locales: `en`, `es`
- enterprise auth is not part of this release unless real OIDC/SSO is added separately

## Mobile Flutter

| Variable / define | Dev / example | Production rule | Notes |
| --- | --- | --- | --- |
| `GOLIFE_AI_GATEWAY_BASE_URL` | `http://127.0.0.1:8000` | required | compile-time define used by app |
| `GOLIFE_RUNTIME_CONFIG_BASE_URL` | `http://127.0.0.1:8010` | required | compile-time define used by runtime config client |

Release-supported mobile locales:

- `en`
- `es`

Known release gap:

- checked CI does not yet validate Android, iOS, or desktop runner projects because they are not part of this repo baseline
