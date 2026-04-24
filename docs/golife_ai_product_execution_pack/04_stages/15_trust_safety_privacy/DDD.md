# DDD — Trust, safety y privacidad

## Bounded Context
Trust, safety y privacidad

## Entidades candidatas
- permisos por evento
- cifrado
- export
- delete all
- policy engine
- rechazo estructurado
- tests adversariales

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
