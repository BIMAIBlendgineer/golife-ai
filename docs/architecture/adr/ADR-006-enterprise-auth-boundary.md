# ADR-006 Enterprise Auth Boundary

- Status: `accepted`
- Date: `2026-05-04`

## Context

The current admin access hardening uses backend tokens plus an operator-secret gate. That is stronger than the original token-only scaffold, but it is still not the same thing as enterprise identity.

The product must not claim enterprise readiness unless real OIDC or SSO exists.

## Evidence

- `services/web_backend/app/main.py`
- `services/web_backend/app/schemas.py`
- `apps/admin_next/app/login/page.tsx`
- `docs/admin/ADMIN_OPERATIONS.md`
- `docs/decisions/ADR_TOKEN_ONLY_NOT_ENTERPRISE_AUTH.md`

## Decision

For the current release:

- do not claim enterprise auth readiness
- keep the current admin gate described as internal/admin hardening only
- keep release scope explicitly outside enterprise SSO unless a real IdP-backed implementation is added
- only move to enterprise-ready claims after a real OIDC/SSO implementation exists with tests and deploy docs

## Alternatives considered

- call the current operator-secret scaffold enterprise-ready:
  - rejected because it would be false
- build a fake or placeholder SSO adapter without a real provider:
  - rejected because it would create security theater
- remove all current admin hardening until OIDC exists:
  - rejected because the current gate still has practical value for internal operations

## Consequences positive

- product claims stay honest
- release docs and admin UI align with actual security posture
- a future OIDC implementation can be reviewed as a separate hardening change
- this release can close without shipping security theater

## Consequences negative

- enterprise customers still need a future auth phase before strong enterprise claims
- some admin docs must keep repeating the “not enterprise auth” boundary

## Residual risks

- if future UI or release docs forget this boundary, the product can overclaim
- token/operator-secret mode still has narrower identity guarantees than SSO, RBAC, or managed enterprise identity

## Affected files

Current affected surfaces:

- `services/web_backend/app/main.py`
- `services/web_backend/app/schemas.py`
- `apps/admin_next/app/login/page.tsx`
- `docs/admin/ADMIN_OPERATIONS.md`
- `docs/operations/RELEASE_RISK_REGISTER.md`

## Tests and gates

Current gate:

- `cd services/web_backend && python -m pytest -q`
- `cd apps/admin_next && npm run lint && npm run typecheck && npm run build`

Future gate if OIDC is implemented:

- backend auth tests
- admin login flow tests
- deploy env documentation
- `gitleaks git`

## Reversibility

This decision is reversible only by implementing real OIDC/SSO and then updating the runtime, tests, and docs together.
