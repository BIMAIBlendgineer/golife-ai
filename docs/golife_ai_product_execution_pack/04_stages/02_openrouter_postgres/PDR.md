# PDR — OpenRouter + PostgreSQL

## Objetivo
Implementar OpenRouter + PostgreSQL como una etapa verificable del producto GoLife AI.

## Problema
El usuario necesita que esta capacidad reduzca fricción, mejore claridad y alimente LifeGraph.

## Requisitos funcionales
- services/ai_gateway/.env
- OPENROUTER_API_KEY
- AI_GATEWAY_ENABLE_MOCK=false
- web_backend con Postgres
- /health mock_mode=false
- /v1/missions/daily
- admin ai-costs provider=openrouter
- fallback probado

## Requisitos no funcionales
- Privacidad explícita.
- Tests.
- Telemetría cuando aplique.
- Fallback.
- Documentación.
- No introducir payload sensible innecesario.

## Criterios de aceptación
- Flujo funcional de extremo a extremo.
- Tests verdes.
- UI usable.
- Contratos documentados.
- No rompe CI.
