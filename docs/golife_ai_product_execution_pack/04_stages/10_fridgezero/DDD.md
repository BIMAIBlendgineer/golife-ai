# DDD — FridgeZero + Recipe Rescue

## Bounded Context
FridgeZero + Recipe Rescue

## Entidades candidatas
- CRUD pantry
- cantidad
- vencimiento
- ubicación
- lista compra
- receta rápida
- marcar usado
- comida rescatada

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
