# Test OpenRouter

- [x] Crear `services/ai_gateway/.env`
- [x] Poner `OPENROUTER_API_KEY`
- [x] `AI_GATEWAY_ENABLE_MOCK=false`
- [x] Levantar `web_backend` con Postgres
- [x] Levantar `ai_gateway`
- [x] `GET /health` -> `mock_mode=false`
- [x] `POST /v1/missions/daily`
- [x] Confirmar `3` misiones
- [x] Confirmar `ai_invocations` en Postgres
- [x] Confirmar `/admin/ai-costs` con provider `openrouter`
- [x] Probar fallback y relleno de plan via smoke + tests de routing
