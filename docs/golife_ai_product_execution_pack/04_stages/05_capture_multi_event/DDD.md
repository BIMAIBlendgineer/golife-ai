# DDD — Captura multi-evento

## Bounded Context
Captura multi-evento

## Entidades candidatas
- CaptureParser
- varias entidades por frase
- confirmación
- edición
- privacidad por item
- tests obligatorios

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
