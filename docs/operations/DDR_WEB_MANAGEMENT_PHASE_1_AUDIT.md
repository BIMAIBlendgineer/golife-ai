# DDR Web Management Phase 1 Audit

Date: 2026-04-26
Branch: `codex/premium-web-management`

## Decision

Phase 1 delivers documentation only. No application code is changed in this phase.

## Why

The current repo already has meaningful admin surfaces and telemetry ingestion. Building premium management without auditing the real contracts would create duplicate routes, conflicting models, and incorrect assumptions about what is already in `main`.

## What was verified

- Existing admin route family is rooted in current product surfaces and must be preserved.
- Forbidden route families are still unused and remain prohibited:
  - `/control`
  - `/admin`
  - `/studio`
- Current admin is localized and server-side.
- Current backend exposes only the existing operational pages plus routing/model/OpenRouter controls.
- Premium gaps are real in organizations, plans, BYOK, xInsightAI, billing, storage, privacy, security, audit, quality, incidents, and HomeMemory aggregates.
- PR `#3` HomeMemory is not merged into `main`, so premium admin cannot assume item-level HomeMemory data exists in production branch state.

## Delivery rule for next phases

Implementation must follow this order:

1. premium design system over current route family
2. scalable users surface
3. organizations and plans
4. BYOK and xInsightAI separation
5. billing and storage
6. privacy, security, and audit
7. aggregate-only HomeMemory admin
8. quality and incidents
9. auth scaffold
10. scale guards and final validation

## Constraints carried forward

- No forbidden routes or folders.
- No client-side secret exposure.
- No raw sensitive telemetry in admin views or audit records.
- No HomeMemory personal content in web management.
- Preserve i18n for the current locale set.
- Prefer additive refactors over route churn.

## Residual risk after audit

- The current admin still exposes list-scale limitations and raw email in user rows until later phases land.
- The backend currently has no audit log, so new admin writes must not expand until audit instrumentation is introduced.
- HomeMemory admin work remains blocked on `main` dependency unless implemented as aggregate-only fallback-safe metadata.
