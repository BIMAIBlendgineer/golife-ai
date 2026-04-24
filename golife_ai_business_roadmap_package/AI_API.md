# GoLife AI API

## Endpoints

- `GET /health`
- `POST /ai/classify-event`
- `POST /ai/daily-plan`
- `POST /ai/task-diagnosis`
- `POST /ai/spending-insight`
- `POST /ai/pantry-plan`
- `POST /ai/wardrobe/no-buy`
- `POST /ai/feedback`

## Contract rules

- responses must validate against Pydantic JSON schemas
- every recommendation includes evidence
- every recommendation includes uncertainty
- every AI response includes `trace`
- destructive or hard-to-reverse actions require confirmation
- blocked or refused outputs still return a valid structured payload

## Primary request shape

All AI endpoints share the same core envelope:

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

## Primary response shape

```json
{
  "recommendations": [],
  "risks": [],
  "blocked_items": [],
  "trace": {},
  "mock": false
}
```

## Schema inventory

Static schema snapshots live in `schemas/`.
The runtime source of truth lives in `ai-gateway-skeleton/app/schemas.py`.

## Client rule

The mobile app never calls OpenRouter directly. All AI traffic goes through the gateway.
