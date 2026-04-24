# DDD — Reorganización del monorepo

## Bounded Context
Reorganización del monorepo

## Entidades candidatas
- apps/mobile_flutter
- apps/admin_next
- services/ai_gateway
- services/web_backend
- docs
- packages/contracts
- README raíz
- CI actualizado
- docs/archive
- REPO_REORGANIZATION_MAP

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
