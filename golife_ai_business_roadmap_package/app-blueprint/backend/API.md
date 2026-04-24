# Backend Blueprint

Use the AI Gateway for all AI behavior. The mobile app must never call a model provider directly.

## Endpoints

- `GET /health`
- `POST /ai/classify-event`
- `POST /ai/daily-plan`
- `POST /ai/task-diagnosis`
- `POST /ai/spending-insight`
- `POST /ai/pantry-plan`
- `POST /ai/wardrobe/no-buy`
- `POST /ai/feedback`

## Gateway guarantees

- all responses are schema-valid
- every recommendation carries evidence
- every recommendation carries uncertainty
- every AI response exposes a trace
- destructive actions require confirmation
- provider failure falls back to safe structured output

## LangGraph flow

1. normalize input
2. classify domain
3. retrieve life context
4. run safety check
5. route to a specialist agent
6. generate recommendation
7. validate schema
8. build explanation
9. persist trace
10. return response

## Request envelope

```json
{
  "user_id": "user-123",
  "privacy": {
    "ai_enabled": true,
    "allowed_domains": ["task", "habit", "money", "pantry"]
  },
  "events": [],
  "constraints": {}
}
```

## Response envelope

```json
{
  "recommendations": [],
  "risks": [],
  "blocked_items": [],
  "trace": {},
  "mock": false
}
```

## First runtime modes

- `OpenRouterProvider` first when configured
- `MockProvider` fallback for tests, local work and provider outages
