# F04_16 Admin Auth Hardening

## Phase

- Roadmap phase: F16 logging/security posture continuation
- Branch: `hardening/traceability-safety-pass`
- Date: 2026-05-03

## Objective

Reduce the gap between the admin UI login scaffold and the actual security posture without pretending the product already has SSO or RBAC.

## Scope

- `services/web_backend/app/settings.py`
- `services/web_backend/app/schemas.py`
- `services/web_backend/app/main.py`
- `services/web_backend/tests/test_admin_api.py`
- `apps/admin_next/app/login/actions.ts`
- `apps/admin_next/app/login/page.tsx`
- `apps/admin_next/lib/types.ts`
- `apps/admin_next/messages/en.json`

## Changes

- Added shared operator-secret support to the backend and admin web scaffold. Preferred env name: `ADMIN_OPERATOR_SECRET`; admin web also accepts `GOLIFE_ADMIN_OPERATOR_SECRET` as fallback.
- Backend auth status now reports:
  - `token_only_scaffold` when no operator secret is configured;
  - `token_plus_operator_secret` when the additional operator secret is configured.
- Tightened backend `production` settings validation so admin auth is not considered production-ready without an operator secret.
- Hardened the admin web login action to require the configured operator secret and compare it with `timingSafeEqual`.
- Updated the login page to render a password field when the operator secret mode is active and to show an inline error on invalid secret attempts.

## Verification

Executed local gates:

- `cd services/web_backend`
- `python -m compileall app tests`
- `python -m pytest -q tests/test_admin_api.py -k "privacy_security_audit_and_quality_routes_exist or auth_status_reports_operator_secret_mode"`
  - Result: `2 passed`
- `cd ../../apps/admin_next`
- `npm run lint`
  - Result: pass
- `npm run typecheck`
  - Result: pass
- `npm run build`
  - Result: pass

## Risks

- This is still not enterprise authentication; it is a stronger admin gate layered on top of backend tokens.
- SSO, RBAC, identity provider integration, session revocation, and audit actor federation remain future work.

## Rollback

- Revert the auth-hardening commit or restore the touched backend and admin files.
