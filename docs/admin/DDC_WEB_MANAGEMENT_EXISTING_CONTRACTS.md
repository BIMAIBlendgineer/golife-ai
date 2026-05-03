# DDC Web Management Existing Contracts

Date: 2026-04-26
Branch: `codex/premium-web-management`

## Source systems

Current management data is composed from:

1. `services/web_backend` admin endpoints
2. `services/web_backend` internal ingestion endpoints
3. `services/ai_gateway` operational telemetry emitters
4. `apps/admin_next/lib/fallback-data.ts` fallback snapshots

## Existing admin routes and fetch functions

Current `apps/admin_next/lib/api.ts` functions:

- `getBackendHealth()` -> `GET /health`
- `getDashboard()` -> `GET /admin/dashboard`
- `getUsers()` -> `GET /admin/users`
- `getUser(userId)` -> `GET /admin/users/{user_id}`
- `getUsage()` -> `GET /admin/usage`
- `getAICosts()` -> `GET /admin/ai-costs`
- `getMissions()` -> `GET /admin/missions`
- `getFeedback()` -> `GET /admin/feedback`
- `getSafety()` -> `GET /admin/safety`
- `getFeatureFlags()` -> `GET /admin/feature-flags`
- `updateFeatureFlag(key, enabled)` -> `PATCH /admin/feature-flags/{key}`
- `getModelSettings()` -> `GET /admin/models`
- `getSupportRequests()` -> `GET /admin/support/export-delete`
- `getOpenRouterKeys()` -> `GET /admin/openrouter/keys`
- `getOpenRouterKeyEvents()` -> `GET /admin/openrouter/key-events`
- `getRoutingProfiles()` -> `GET /admin/routing-profiles`
- `getModelCatalog()` -> `GET /admin/model-catalog`
- `getModelSelections()` -> `GET /admin/model-selections`

The admin API wrapper is `server-only`, which is the correct boundary for keeping tokens out of client bundles.

## Existing backend admin contracts

Current routes exposed by `services/web_backend/app/main.py`:

- `GET /health`
- `GET /public/mobile/runtime-config`
- `GET /admin/dashboard`
- `GET /admin/users`
- `GET /admin/users/{user_id}`
- `GET /admin/usage`
- `GET /admin/ai-costs`
- `GET /admin/missions`
- `GET /admin/feedback`
- `GET /admin/safety`
- `GET /admin/feature-flags`
- `PATCH /admin/feature-flags/{flag_key}`
- `GET /admin/models`
- `GET /admin/support/export-delete`
- `GET /admin/openrouter/keys`
- `POST /admin/openrouter/keys`
- `PATCH /admin/openrouter/keys/{key_id}`
- `POST /admin/openrouter/keys/{key_id}/disable`
- `GET /admin/openrouter/key-events`
- `GET /admin/routing-profiles`
- `PATCH /admin/routing-profiles/{capability}`
- `GET /admin/model-catalog`
- `POST /admin/model-catalog/refresh`
- `GET /admin/model-selections`

## Existing backend internal ingestion contracts

Current internal routes exposed by `services/web_backend/app/main.py`:

- `GET /internal/ai-routing/config`
- `POST /internal/ai-routing/selection-refresh`
- `POST /internal/openrouter-key-events`
- `POST /internal/usage-events`
- `POST /internal/ai-invocations`
- `POST /internal/mission-audits`
- `POST /internal/feedback-audits`
- `POST /internal/safety-events`
- `POST /internal/model-settings`

These are the current operational sources for the admin console.

## Existing schema coverage

Current backend/admin schema coverage in `services/web_backend/app/schemas.py`:

- `DashboardMetrics`
- `AdminUser`
- `UsageSnapshot`
- `AICostSnapshot`
- `MissionAuditRecord`
- `FeedbackAuditRecord`
- `SafetyAuditRecord`
- `FeatureFlag`
- `ModelSettingsSnapshot`
- `SupportRequest`
- `AdminHealth`
- `UsageEventRecord`
- `AIInvocationRecord`
- `MissionAuditUpsert`
- `FeedbackAuditUpsert`
- `SafetyAuditUpsert`
- `OpenRouterApiKeyRecord`
- `OpenRouterApiKeyCreate`
- `OpenRouterApiKeyPatch`
- `RoutingProfile`
- `RoutingProfilePatch`
- `ModelCatalogEntry`
- `ModelSelectionSnapshot`
- `OpenRouterKeyEventRecord`
- `OpenRouterKeyEventUpsert`
- `InternalRoutingConfig`
- `MobileRuntimeConfig`

Missing schema families for premium scope:

- organizations
- plans
- BYOK keys
- xInsightAI usage and credit ledgers
- billing accounts
- storage usage summaries
- privacy requests/data map
- security summaries/events
- audit logs
- incidents
- quality summaries
- paginated DTOs
- HomeMemory aggregate summaries
- admin auth scaffold status

## Existing fallback data coverage

Current fallback coverage in `apps/admin_next/lib/fallback-data.ts` exists for:

- dashboard
- users
- usage
- ai-costs
- missions
- feedback
- safety
- feature flags
- model settings
- support requests
- OpenRouter global keys
- routing profiles
- model catalog
- model selections

Missing fallback families for premium scope:

- organizations
- plans
- billing
- storage
- privacy
- security
- audit
- BYOK
- xInsightAI
- quality
- incidents
- HomeMemory aggregate
- auth scaffold status

## Current contract weaknesses

### Scale weaknesses

- `GET /admin/users`, `GET /admin/usage`, `GET /admin/ai-costs`, `GET /admin/feedback`, and `GET /admin/safety` return full lists with no `limit`, `offset`, `total`, or `next_offset`.
- Existing UI pages render whole lists directly into tables.
- There is no page-size control or filter persistence.

### Privacy weaknesses

- `AdminUser` currently includes raw `email` instead of masked email for list surfaces.
- Existing user detail scope is not yet split into usage/privacy/support/risk summaries.
- There is no dedicated privacy route or data-map route.

### Security weaknesses

- There is no centralized admin audit log for writes.
- There is no `/security` route surfacing production guardrails or auth readiness.
- There is no login/logout scaffold.

### Commercial-model weaknesses

- There is no distinction in contracts between platform-managed OpenRouter usage, BYOK, and xInsightAI billing.
- There is no organization/plan layer to hang billing policy on.

### HomeMemory dependency weakness

- Admin cannot safely expose HomeMemory data yet because `main` does not include PR `#3`.
- Any future `/homememory` route must be aggregate-only and dependency-aware.

## Current telemetry posture

Observed from `services/ai_gateway/app/operational_payloads.py` and `services/web_backend/app/repository.py`:

- feedback reasons are reduced to a metadata marker instead of storing private free text
- reflection safety telemetry records metadata only
- OpenRouter secrets are encrypted server-side and only `last4` is exposed in admin contracts

This is a good base and must be preserved during premium expansion.
