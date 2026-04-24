# DDC — Captura multi-evento

## Contratos mínimos
- CaptureParser
- varias entidades por frase
- confirmación
- edición
- privacidad por item
- tests obligatorios

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
