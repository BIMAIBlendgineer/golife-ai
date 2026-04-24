# Prompt — Implementar AI Gateway

Crea `services/ai_gateway` con:

- FastAPI;
- Pydantic;
- LangGraph;
- provider abstraction;
- OpenRouter provider;
- endpoints mínimos;
- tests.

No requiere conexión real si no hay API key. Debe tener modo mock.

Endpoints:

```text
GET /health
POST /v1/suggestions/generate
POST /v1/tasks/rewrite
POST /v1/missions/daily
POST /v1/finance/reflect
POST /v1/pantry/rescue
POST /v1/closet/decision
```

Cada endpoint debe:

1. validar input;
2. aplicar privacy guardrails;
3. generar salida JSON;
4. incluir trace;
5. no ejecutar acciones externas.

Crea `.env.example`.

Crea tests unitarios con provider mock.
