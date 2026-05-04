# ADR-005 Admin And Mobile Fallback Visibility

- Status: `accepted`, `implemented`
- Date: `2026-05-04`

## Context

Fallback behavior is allowed in this product for development, offline UX, and degraded runtime handling. What is not allowed is presenting fallback behavior as if it were live premium AI or live backend data.

The product thesis depends on trust: missions, evidence, and operational state must be explicit about whether they are live, degraded, or local.

## Evidence

- [F03 AI Gateway production runtime closeout](../../operations/F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md)
- mobile fallback visibility test:
  - `apps/mobile_flutter/test/golife_app_test.dart`
- admin fallback/runtime surfaces:
  - `apps/admin_next/lib/api.ts`
  - `apps/admin_next/components/page-shell.tsx`
  - `apps/admin_next/components/premium/source-state-badge.tsx`
- mobile runtime labels:
  - `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`
  - `apps/mobile_flutter/lib/core/i18n/app_localized_values.dart`

## Decision

Fallback remains allowed, but it must be visible.

Implemented behavior:

- admin exposes explicit `live`, `fallback`, and `offline` source states
- mobile exposes explicit degraded labels such as `No connection`, `AI temporarily unavailable`, and `Using local fallback`
- trace metadata keeps `clientFallback`, `fallbackReason`, and `mock` visibility

## Alternatives Considered

- Hide degraded state for a smoother UX:
  - rejected because it undermines operator and user trust
- Remove fallback entirely:
  - rejected because offline and degraded use still matter for the product
- Expose only raw technical error codes:
  - rejected because the product also needs user-readable and operator-readable state

## Consequences Positive

- users and operators can distinguish live from degraded behavior
- fallback can remain part of the product without pretending to be premium live AI
- operational debugging becomes easier

## Consequences Negative

- surfaces need ongoing discipline so new pages and flows preserve the same visibility rules
- degraded state messaging must stay localized and product-appropriate

## Residual Risks

- future routes could regress if they bypass the shared fallback/source-state patterns
- mobile degraded UX for crisis or support escalation is still intentionally limited

## Affected Files

- `apps/admin_next/lib/api.ts`
- `apps/admin_next/components/page-shell.tsx`
- `apps/admin_next/components/premium/premium-topbar.tsx`
- `apps/admin_next/components/premium/source-state-badge.tsx`
- `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`
- `apps/mobile_flutter/lib/core/i18n/app_localized_values.dart`
- `apps/mobile_flutter/test/golife_app_test.dart`

## Tests And Gates

- `cd apps/admin_next && npm run lint`
- `cd apps/admin_next && npm run typecheck`
- `cd apps/admin_next && npm run build`
- `cd apps/mobile_flutter && flutter test`

## Reversibility

Reversible by removing the visibility surfaces, but that would intentionally reintroduce misleading degraded behavior and should be treated as a trust regression.
