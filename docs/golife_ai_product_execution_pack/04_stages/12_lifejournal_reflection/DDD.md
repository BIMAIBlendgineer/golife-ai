# DDD — LifeJournal + Reflection Coach

## Bounded Context
LifeJournal + Reflection Coach

## Entidades candidatas
- JournalEntry
- QuickNote
- estado del día
- reflexión guiada
- resumen semanal
- safety emocional
- privacidad máxima

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
