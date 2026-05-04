# AI Gateway API

Base service: `services/ai_gateway`

The AI Gateway is the production AI surface for GoLife AI. It enforces privacy gating, safety checks, provider abstraction, and operational telemetry.

## Common behavior

- JSON API over HTTP
- correlation id accepted via `x-correlation-id` or `x-request-id`
- response echoes `x-correlation-id`
- production must not run with mock enabled
- operational telemetry is metadata-only

## `GET /health`

- Purpose: lightweight runtime snapshot
- Success: `200`
- Key fields:
  - `status`
  - `configured_provider`
  - `active_provider`
  - `mock_mode`
  - routing and config-source fields from provider health
- Privacy: no secrets returned
- Tests: `services/ai_gateway/tests/test_api.py`

## `GET /ready`

- Purpose: production-aware readiness check
- Success:
  - `200` when ready
  - `503` in production when not ready
- Key checks:
  - provider is real
  - mock mode disabled
  - AI configuration present
  - crisis catalog exists when configured
- Tests: `services/ai_gateway/tests/test_api.py`

## `POST /v1/missions/daily`

- Purpose: generate up to three daily mission suggestions from privacy-filtered evidence
- Request model: `SuggestionRequest`
- Minimum payload:

```json
{
  "user_id": "local-user",
  "locale": "en",
  "scope": "daily",
  "life_events": [],
  "privacy_settings": {
    "ai_enabled": true,
    "allowed_domains": ["task"],
    "allow_cross_domain_patterns": true
  },
  "domain_summaries": [],
  "constraints": {},
  "max_suggestions": 3
}
```

- Success: `200` with `SuggestionResponse`
- Trace highlights:
  - `mission_memory`
  - `learning_keys_by_suggestion_id`
  - `feedback_learning.candidate_biases`
- Errors:
  - `503` when AI is temporarily unavailable
- Privacy:
  - caller should send only AI-allowed events
  - gateway preserves trace, not raw secret config
- Telemetry:
  - usage event
  - AI invocation
  - mission audits
  - safety events when applicable
  - model settings snapshot
- Tests:
  - `tests/test_api.py`
  - `tests/test_openrouter_routing.py`
  - `tests/test_openrouter_normalization.py`

## `POST /v1/events/classify`

- Purpose: classify one freeform capture into a target domain and event type
- Request model: `EventClassificationRequest`
- Success: `200` with `EventClassificationResponse`
- Safety behavior:
  - blocks unsafe crisis/clinical text with structured `422`
- Privacy:
  - honors `privacy_settings.ai_enabled`
- Telemetry:
  - usage event
  - AI invocation
  - safety events on rejection
- Tests: `tests/test_api.py`

## `POST /v1/events/parse`

- Purpose: parse one freeform capture into one or more structured event drafts
- Request model: `EventParseRequest`
- Success: `200` with `EventParseResponse`
- Safety behavior:
  - blocks unsafe crisis/clinical text with structured `422`
- Telemetry:
  - usage event
  - AI invocation
  - safety events on rejection
- Tests: `tests/test_api.py`

## `POST /v1/proofs/parse`

- Purpose: parse proof or receipt text into HomeMemory-friendly fields
- Request model: `ProofParseRequest`
- Success: `200` with `ProofParseResponse`
- Safety behavior:
  - blocks unsafe crisis/clinical text with structured `422`
- Privacy:
  - operational telemetry excludes raw proof text
- Tests: `tests/test_api.py`

## `POST /v1/tasks/rewrite`

- Purpose: rewrite a task into clearer, smaller steps
- Request model: `TaskRewriteRequest`
- Success: `200` with `TaskRewriteResponse`
- Errors:
  - `422` for safety rejection
  - `503` when AI is unavailable
- Privacy:
  - task text is subject to privacy and safety constraints
- Telemetry:
  - usage event
  - AI invocation
  - safety events on rejection
- Tests: `tests/test_api.py`

## `POST /v1/reflection/check`

- Purpose: check reflection text for supportive vs clinical/crisis handling
- Request model: `ReflectionSafetyRequest`
- Success: `200` with `ReflectionSafetyResponse`
- Safety behavior:
  - returns structured categorization and support resources
- Privacy:
  - admin receives metadata-only telemetry
- Tests: `tests/test_api.py`

## `POST /v1/feedback`

- Purpose: store mission feedback and emit operational feedback audit metadata
- Request model: `MissionFeedbackRequest`
- Success: `200` with `MissionFeedbackResponse`
- Behavior:
  - stores metadata-only mission feedback
  - derives or reuses a stable mission-pattern learning key
  - feeds later mission ranking without storing raw note text in operational surfaces
- Privacy:
  - feedback notes stay redacted from operational admin surfaces
- Telemetry:
  - usage event
  - feedback audit
- Tests: `tests/test_api.py`

## Related domain suggestion routes

The gateway also exposes domain-targeted suggestion routes:

- `POST /v1/finance/reflect`
- `POST /v1/pantry/rescue`
- `POST /v1/closet/decision`

These follow the same `SuggestionRequest` / `SuggestionResponse` pattern and share the same provider, safety, and telemetry posture.
