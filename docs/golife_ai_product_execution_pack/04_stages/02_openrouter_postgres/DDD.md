# DDD — OpenRouter + PostgreSQL

## Bounded Context
OpenRouter + PostgreSQL

## Entidades candidatas
- services/ai_gateway/.env
- OPENROUTER_API_KEY
- AI_GATEWAY_ENABLE_MOCK=false
- web_backend con Postgres
- /health mock_mode=false
- /v1/missions/daily
- admin ai-costs provider=openrouter
- fallback probado

## Servicios de dominio
- Normalizer.
- Validator.
- PrivacyGuard.
- LifeGraphWriter.
- RiskDetector.
- MissionActionHandler.
- TelemetryReporter.

## Eventos
- entity_created
- entity_updated
- entity_completed
- risk_detected
- mission_generated
- mission_actioned
- feedback_recorded

## Invariantes
- Todo dato sensible respeta privacy_level.
- Toda acción relevante genera LifeEvent.
- Toda recomendación IA requiere evidencia o incertidumbre explícita.
