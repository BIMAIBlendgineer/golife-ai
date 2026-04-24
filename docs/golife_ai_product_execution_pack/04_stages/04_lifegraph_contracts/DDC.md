# DDC — LifeGraph y contratos

## Contratos mínimos
- packages/contracts
- LifeEvent
- schemas
- DTOs
- privacy levels
- migraciones SQLite
- validación CI

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
