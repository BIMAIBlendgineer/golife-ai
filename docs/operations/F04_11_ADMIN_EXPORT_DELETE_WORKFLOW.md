# F04 11 Admin Export Delete Workflow

Fecha: 2026-05-04
Ejecutor: Codex
Rama base: `main`
SHA base: `32fed4212178d015314afe27976be4f979be73bd`

## Objetivo

Cerrar el gap restante del bloque Data/Persistencia/Export-Delete en backend/admin: la cola de soporte ya no debía ser solo observabilidad, sino ejecutar trabajo real sobre los metadatos operacionales del backend.

## Alcance

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

## Cambios

- Se añadió bundle real de export para solicitudes `export`:
  - `GET /admin/support/export-delete/{request_id}/bundle`
  - genera un paquete JSON metadata-only con los registros operacionales del usuario en `web_backend`
  - incluye checksum SHA-256 y recuentos por colección
- Se añadió resolución explícita para solicitudes `export`:
  - `POST /admin/support/export-delete/{request_id}/resolve`
- Se añadió borrado operacional real para solicitudes `delete`:
  - `POST /admin/support/export-delete/{request_id}/execute-delete`
  - elimina registros por `user_id` de `admin_users`, `user_profiles`, `usage_events`, `ai_invocations`, `ai_usage_ledger`, `mission_audit_records`, `feedback_audit_records` y `safety_events`
- Se añadió auditoría admin para:
  - descarga de bundle
  - resolución de solicitud
  - ejecución de borrado operacional
- La UI admin de `/support/export-delete` dejó de ser solo lectura:
  - botón de descarga de bundle para `export`
  - botón de resolución manual para `export`
  - botón de borrado operacional real para `delete`

## Verificación

- `cd services/web_backend && python -m pytest -q tests/test_admin_api.py`
  - Resultado: `22 passed`
- `cd services/web_backend && python -m pytest -q`
  - Resultado: `25 passed`
- `cd apps/admin_next && npm run lint`
  - Resultado: pass
- `cd apps/admin_next && npm run typecheck`
  - Resultado: pass
- `cd apps/admin_next && npm run build`
  - Resultado: pass

## Riesgos restantes

- El bundle de export cubre solo metadatos operacionales del backend; el LifeGraph local completo sigue siendo responsabilidad del export protegido en mobile.
- El borrado ejecutado aquí no toca datos locales del dispositivo ni otros sistemas externos potenciales.
- La autenticación admin sigue siendo el hardening actual del repo, no SSO/RBAC enterprise.

## Rollback

- Revertir el commit de esta fase.
- Restaurar las rutas admin/backend afectadas si se decide volver a una cola solo observacional.
