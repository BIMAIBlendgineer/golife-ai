# F04 11 Admin Export Delete Workflow

Date: `2026-05-04`
Executor: `Codex`
Base branch: `main`
Base SHA: `32fed4212178d015314afe27976be4f979be73bd`

## Objective

Close the remaining data/persistence/export-delete gap in backend and admin. The support queue should not be read-only observability; it should execute real operational work on backend metadata.

## Scope

- `services/web_backend/app/main.py`
- `services/web_backend/app/repository.py`
- `services/web_backend/app/schemas.py`
- `services/web_backend/tests/test_admin_api.py`
- `apps/admin_next/app/support/export-delete/page.tsx`
- `apps/admin_next/app/support/export-delete/actions.ts`
- `apps/admin_next/app/support/export-delete/[requestId]/bundle/route.ts`
- `apps/admin_next/lib/api.ts`
- `apps/admin_next/lib/types.ts`
- `apps/admin_next/messages/en.json`
- `docs/operations/SUPPORT_PROCESS.md`
- `docs/compliance/PRIVACY_REVIEW.md`

## Changes

- Added a real export bundle for `export` requests:
  - `GET /admin/support/export-delete/{request_id}/bundle`
  - generates a metadata-only JSON package with backend operational records for the user
  - includes SHA-256 checksum and per-collection record counts
- Added explicit resolution for `export` requests:
  - `POST /admin/support/export-delete/{request_id}/resolve`
- Added real operational delete for `delete` requests:
  - `POST /admin/support/export-delete/{request_id}/execute-delete`
  - removes backend operational records by `user_id`
- Added admin audit entries for:
  - bundle download
  - request resolution
  - delete execution
- The admin UI at `/support/export-delete` is no longer read-only:
  - export bundle download for `export`
  - explicit resolve action for `export`
  - real operational delete action for `delete`

## Validation

- `cd services/web_backend && python -m pytest -q tests/test_admin_api.py`
  - result: `22 passed`
- `cd services/web_backend && python -m pytest -q`
  - result: `25 passed`
- `cd apps/admin_next && npm run lint`
  - result: pass
- `cd apps/admin_next && npm run typecheck`
  - result: pass
- `cd apps/admin_next && npm run build`
  - result: pass

## Residual risks

- the export bundle covers backend operational metadata only; full local LifeGraph export remains the mobile protected export responsibility
- this delete flow does not touch local device data or external third-party systems
- admin auth remains the repo hardening level, not enterprise SSO/RBAC

## Canonical follow-up docs

- [Data map](../compliance/DATA_MAP.md)
- [Privacy review](../compliance/PRIVACY_REVIEW.md)
- [Support process](SUPPORT_PROCESS.md)
- [Admin operations](../admin/ADMIN_OPERATIONS.md)

## Rollback

- revert the commit for this phase
- restore affected backend/admin routes if returning to a read-only support queue
