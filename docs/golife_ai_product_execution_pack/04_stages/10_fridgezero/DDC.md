# DDC — FridgeZero + Recipe Rescue

## Contratos mínimos
- CRUD pantry
- cantidad
- vencimiento
- ubicación
- lista compra
- receta rápida
- marcar usado
- comida rescatada

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
