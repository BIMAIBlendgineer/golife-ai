# GoLife AI Web Management Premium Gap Analysis

Date: 2026-04-26
Branch: `codex/premium-web-management`
Base commit: `35bbe53`

## Audit scope

This audit reflects the repo state before premium web management implementation.

Files inspected:

- `apps/admin_next/app`
- `apps/admin_next/components`
- `apps/admin_next/lib/api.ts`
- `apps/admin_next/lib/types.ts`
- `apps/admin_next/lib/fallback-data.ts`
- `apps/admin_next/messages/*`
- `services/web_backend/app/main.py`
- `services/web_backend/app/repository.py`
- `services/web_backend/app/schemas.py`
- `services/ai_gateway/app`

## Current truth

- The admin app already exposes route-level surfaces for dashboard, users, usage, AI costs, OpenRouter global keys, missions, feedback, safety, routing snapshots, feature flags, model settings, routing profiles, model catalog, and support export/delete.
- The backend currently exposes matching `/admin/*` endpoints for those existing surfaces.
- The backend does not yet expose organizations, plans, billing, storage, privacy, security, audit, BYOK, xInsightAI, incidents, quality, or HomeMemory aggregate endpoints.
- Existing `/users`, `/usage`, `/ai-costs`, `/feedback`, and `/safety` contracts are list-only and not paginated.
- Existing admin UI is localized and server-side, but still uses a relatively small design system and simple tables without scalable filters/drawers/pagination.
- Existing telemetry is already safer than earlier versions: feedback reasons are sanitized to `private_note_redacted`, and reflection safety events do not serialize raw reflection text into admin-facing operational records.
- PR `#3` for HomeMemory is not merged into `main`, so admin work must not assume HomeMemory domain tables or mobile-backed data exist on `main`.

## Matrix

| Area | Exists today | Missing for premium | Route | Backend | Risk | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| Users | Basic list, detail page, simple metrics | Pagination, filters, masked email, summary drawers, metadata-safe CSV, privacy/support subviews | `/users` | Existing `/admin/users`, `/admin/users/{user_id}` only | High: list does not scale to thousands of users and exposes plain email in current contracts | P0 |
| Organizations | No | Full org model, membership, org detail, aggregated storage and AI defaults | `/organizations` | No | Medium: cannot operate Family/Team/Enterprise plans cleanly | P0 |
| Usage | Basic list by user | Pagination, filters, page size, endpoint/domain slices, org and locale segmentation | `/usage` | Existing `/admin/usage` only | High: current flat list does not scale | P0 |
| AI Costs | Basic endpoint/provider list | Pagination, anomaly surfacing, margin view, org/user rollups, xInsightAI vs BYOK split | `/ai-costs` | Existing `/admin/ai-costs` only | High: premium billing and cost controls need better resolution | P0 |
| OpenRouter global keys | Existing key CRUD-lite, disable, event list | Better audit, safer actions UX, readiness/security overlays | `/openrouter-keys` | Existing `/admin/openrouter/keys`, `/admin/openrouter/key-events` | Medium: existing surface is useful but not enterprise-grade | P1 |
| OpenRouter BYOK | No | BYOK key ledger, test/rotate/disable, organization binding, last4-only exposure | `/openrouter-byok` | No | High: monetization model cannot be operated without separation | P0 |
| xInsightAI | No | Credit usage, plan usage, charge ledger, margin summary, endpoint/model usage | `/xinsightai` | No | High: product cannot explain internal AI billing without it | P0 |
| Billing | No | Billing accounts, subscription state, invoice placeholders, storage and AI charge visibility | `/billing` | No | High: premium operations incomplete without plan and charge visibility | P1 |
| Storage | No | Storage summary by org/user, encrypted collections, retention risk, HomeMemory metadata impact | `/storage` | No | High: storage is part of product pricing and privacy posture | P1 |
| Support | Existing export/delete queue only | Richer support statuses, filters, routing to privacy/security context, org/user context | `/support/export-delete` | Existing `/admin/support/export-delete` only | Medium: current queue is narrow but usable | P1 |
| Privacy | No dedicated route | Privacy request queue, data map, encrypted collection visibility, retention state | `/privacy` | No | High: privacy is part of core product thesis | P0 |
| Security | No dedicated route | Guardrail state, token status, key rotations, auth mode, production readiness | `/security` | No | High: operators lack a coherent security posture view | P0 |
| Audit | No dedicated route or write audit model | Metadata-only audit log, actor/action filters, safe diffs | `/audit` | No | High: admin write actions are not centrally auditable yet | P0 |
| HomeMemory aggregate | No | Aggregate-only operational view, parser usage, encryption/storage metadata, no personal object data | `/homememory` | No, and PR `#3` not merged | Medium: must remain dependency-aware until HomeMemory lands in `main` | P1 |
| Quality | No dedicated route; partial signals scattered across dashboard, missions, feedback, safety | Consolidated quality KPIs and breakdowns by endpoint/domain/locale | `/quality` | No | Medium: product health exists but is fragmented | P1 |
| Incidents | No | Incident log, severity filters, safe summaries, source tracing | `/incidents` | No | Medium: operational response surface missing | P1 |
| Plans | No | Plan cards, entitlements, user/storage/AI policies, BYOK allowance | `/plans` | No | Medium: needed before billing can be explained consistently | P1 |
| Login/Logout | No | Auth scaffold, auth status, production readiness warnings | `/login`, `/logout` | No | Medium: current token-only mode is implicit and opaque | P2 |

## Current admin strengths

- Server-only API wrapper already protects admin token from client bundles.
- Existing routes align with current operational telemetry and routing control-plane state.
- i18n is already in place for `en`, `es`, `pt-BR`, `ja`, and `zh-Hans`.
- OpenRouter key material is encrypted server-side and only `last4` is returned to the frontend.

## Current admin gaps that matter most

1. Scale guardrails are not present on list surfaces.
2. Commercial separation between global keys, BYOK, and xInsightAI does not exist.
3. Privacy, security, and audit are not first-class surfaces.
4. Design system is consistent enough for a prototype but too thin for a premium operating console.
5. HomeMemory admin must stay aggregate-only and cannot depend on PR `#3` until merged.

## Delivery implication

Implementation should start with:

1. Premium UI system on top of the current route map.
2. `/users` scale upgrade.
3. Organizations/plans.
4. BYOK/xInsightAI separation.
5. Privacy/security/audit.
