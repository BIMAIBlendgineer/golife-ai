# UI Admin Next.js — diseño

## Estados globales

- LIVE DATA
- LIVE — NO INGESTION YET
- FALLBACK SNAPSHOT
- BACKEND OFFLINE

## Navegación

- Dashboard
- Users
- Usage
- AI Costs
- Missions
- Feedback
- Safety
- Feature Flags
- Models
- Support
- System Health

## Componentes

- PageShell
- PageHeader
- MetricCard
- DataTable
- StatusPill
- ErrorBanner
- CostPanel
- SafetyPanel
- MissionQualityPanel
- FeatureFlagToggle
- ModelSettingsPanel

## Métricas

- DAU
- WAU
- Useful Missions / Active User / Week
- Mission completion rate
- Usefulness rate
- Rejection rate
- Capture events per active user
- Fallback rate
- AI latency
- AI cost per active user
- Safety intervention rate
- Privacy concern rate

## Reglas

- Nunca mostrar payload sensible.
- Toda página debe mostrar fuente de datos.
- Toda métrica debe mostrar timestamp.
- PATCH no puede parecer exitoso offline.
- Fallback debe ser explícito.
