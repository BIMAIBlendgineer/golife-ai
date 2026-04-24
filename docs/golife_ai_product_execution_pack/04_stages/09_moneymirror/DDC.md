# DDC — MoneyMirror

## Contratos mínimos
- CRUD gastos
- categorías
- monto/moneda
- microgastos
- recibos
- relación pantry
- safety financiero

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
