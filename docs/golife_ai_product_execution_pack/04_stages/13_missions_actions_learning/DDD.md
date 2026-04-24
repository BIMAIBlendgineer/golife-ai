# DDD — Misiones accionables

## Bounded Context
Misiones accionables

## Entidades candidatas
- acción sobre tarea
- acción sobre hábito
- acción sobre pantry
- acción sobre closet
- feedback implícito
- avoid repetition

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
