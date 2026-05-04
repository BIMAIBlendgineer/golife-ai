# ADR-002 Admin Export Delete Workflow

- Status: `accepted`, `implemented`
- Date: `2026-05-04`

## Context

The support queue existed, but export and delete requests were not fully executable from the operational backend and admin surfaces. That left privacy operations partially ceremonial.

The release candidate needed a real workflow that preserves the product boundary:

- local personal graph stays device-local
- backend operations still support metadata-only privacy workflows

## Evidence

- [F04 11 admin export delete workflow](../../operations/F04_11_ADMIN_EXPORT_DELETE_WORKFLOW.md)
- merged PR `#10`
- files:
  - `services/web_backend/app/main.py`
  - `services/web_backend/app/repository.py`
  - `apps/admin_next/app/support/export-delete/page.tsx`

## Decision

Support export/delete must be executable from admin, but only within the operational metadata boundary.

Implemented behavior:

- export requests generate a metadata-only operational bundle
- delete requests execute backend operational deletion by `user_id`
- admin records operator actions for download, resolve, and delete execution
- local mobile LifeGraph export remains a separate device-local flow

## Alternatives Considered

- Keep the queue read-only:
  - rejected because it does not satisfy operational privacy expectations
- Export raw user payloads from the backend:
  - rejected because the product boundary is local-first and admin should not become a raw-user-data console
- Merge mobile local export with backend export into one server-led flow:
  - rejected because the local-first privacy model would be weakened

## Consequences Positive

- support can complete operational export/delete work
- the backend/admin boundary stays metadata-only
- the privacy story becomes more honest and auditable

## Consequences Negative

- users still need the mobile local export for full personal-graph retrieval
- operators must understand that backend delete does not remotely wipe device-local state

## Residual Risks

- device-local data is not erased by the backend delete workflow
- admin authentication is still hardening-grade, not enterprise SSO/RBAC

## Affected Files

- `services/web_backend/app/main.py`
- `services/web_backend/app/repository.py`
- `services/web_backend/app/schemas.py`
- `services/web_backend/tests/test_admin_api.py`
- `apps/admin_next/app/support/export-delete/page.tsx`
- `apps/admin_next/app/support/export-delete/actions.ts`
- `apps/admin_next/app/support/export-delete/[requestId]/bundle/route.ts`
- `apps/admin_next/lib/api.ts`
- `apps/admin_next/lib/types.ts`

## Tests And Gates

- `cd services/web_backend && python -m pytest -q`
- `cd apps/admin_next && npm run lint`
- `cd apps/admin_next && npm run typecheck`
- `cd apps/admin_next && npm run build`
- `gitleaks git`

## Reversibility

Reversible by reverting the workflow implementation, but that would intentionally reopen the privacy-operations gap and return the admin queue to a weaker observational state.
