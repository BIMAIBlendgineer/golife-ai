# DDC — OpenRouter + PostgreSQL

## Contratos mínimos
- services/ai_gateway/.env
- OPENROUTER_API_KEY
- AI_GATEWAY_ENABLE_MOCK=false
- web_backend con Postgres
- /health mock_mode=false
- /v1/missions/daily
- admin ai-costs provider=openrouter
- fallback probado

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
