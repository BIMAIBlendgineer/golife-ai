# DDC — Reorganización del monorepo

## Contratos mínimos
- apps/mobile_flutter
- apps/admin_next
- services/ai_gateway
- services/web_backend
- docs
- packages/contracts
- README raíz
- CI actualizado
- docs/archive
- REPO_REORGANIZATION_MAP

## Reglas
- IDs estables.
- Fechas ISO-8601.
- Payload mínimo.
- Trace para IA.
- Metadata operacional sin contenido sensible.

## Ejemplo
```json
{
  "id": "example",
  "user_id": "local-user",
  "created_at": "2026-04-25T10:00:00Z"
}
```
