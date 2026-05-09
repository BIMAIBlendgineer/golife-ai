# 00 — Source Basis / Base verificada

## Alcance inspeccionado

Este pack se basa en inspección de código y documentación del repositorio `BIMAIBlendgineer/golife-ai` y, de forma contextual, patrones ya existentes en el ecosistema XAIBIM.

## Evidencias verificadas en GoLife AI

### Producto

El README define GoLife AI como sistema local-first de decisiones diarias basado en:

- `LifeGraph`
- tres misiones diarias
- evidencia y trazabilidad
- filtros de privacidad antes de IA
- feedback y aprendizaje
- app móvil Flutter
- AI Gateway
- web backend/admin
- contratos compartidos

Archivo observado:

```text
README.md
```

### Mobile Flutter

El proyecto móvil usa Flutter y depende de:

- `sqflite`
- `flutter_secure_storage`
- `encrypt`
- `shared_preferences`
- `go_router`
- `http`
- `intl`
- `flutter_localizations`

Archivo observado:

```text
apps/mobile_flutter/pubspec.yaml
```

La app inicializa `GoLifeApp` desde:

```text
apps/mobile_flutter/lib/main.dart
apps/mobile_flutter/lib/app/golife_app.dart
```

`GoLifeApp` construye:

- `GoLifeController`
- `ResilientLocalStore`
- `SqliteLocalStore`
- `MemoryLocalStore`
- `HttpAiGatewayClient`
- `LifeGraphRepository.seeded`
- `RuntimeConfigClient`

### Rutas móviles actuales

Archivo observado:

```text
apps/mobile_flutter/lib/app/router/app_router.dart
```

Rutas existentes:

```text
/dashboard
/capture
/week
/habits
/tasks
/money
/pantry
/closet
/everyday
/journal
/calendar
/recipes
/homememory
/copilot
/settings
```

### Controller

Archivo observado:

```text
apps/mobile_flutter/lib/features/app_state/golife_controller.dart
```

Entidades gestionadas actualmente:

```text
DailyMission
DailyRisk
MissionFeedback
GoTask
Habit
ExpenseRecord
PantryItem
PurchaseIntention
WeekPlan
JournalEntry
QuickNote
CalendarItem
RecipeRescue
OwnedItem
PurchaseProof
WarrantyRecord
MaintenanceReminder
ClaimDraft
EvidenceAttachment
```

### Storage

Archivo observado:

```text
apps/mobile_flutter/lib/core/storage/sqlite_local_store.dart
```

Base actual:

```text
golife_ai.db
_databaseVersion = 4
```

Tablas actuales observadas o inferidas desde creación/métodos:

```text
key_value
life_events
mission_feedback
missions
daily_risks
tasks
habits
expenses
pantry_items
purchase_intentions
week_plans
journal_entries
quick_notes
calendar_items
recipe_rescues
owned_items
purchase_proofs
warranty_records
maintenance_reminders
claim_drafts
evidence_attachments
```

### AI Gateway

Archivos observados:

```text
services/ai_gateway/pyproject.toml
services/ai_gateway/app/main.py
services/ai_gateway/app/schemas.py
services/ai_gateway/app/use_cases.py
services/ai_gateway/app/graphs/golife_graph.py
services/ai_gateway/app/guardrails.py
```

Dependencias del AI Gateway:

```text
fastapi
uvicorn
pydantic
pydantic-settings
httpx
langgraph
langchain
```

Endpoints actuales observados:

```text
GET  /health
GET  /ready
POST /v1/suggestions/generate
POST /v1/missions/daily
POST /v1/events/classify
POST /v1/events/parse
POST /v1/proofs/parse
POST /v1/tasks/rewrite
POST /v1/finance/reflect
POST /v1/pantry/rescue
POST /v1/closet/decision
POST /v1/feedback
POST /v1/reflection/check
```

### Contratos AI actuales

Archivo observado:

```text
services/ai_gateway/app/schemas.py
```

Contratos relevantes:

```text
PrivacySettings
Domain
LifeEvent
SuggestionEvidence
MissionRanking
AISuggestion
SuggestionRequest
SuggestionResponse
EventClassificationRequest
EventClassificationResponse
EventParseRequest
EventParseResponse
ProofParseRequest
ProofParseResponse
TaskRewriteRequest
TaskRewriteResponse
MissionFeedbackRequest
MissionFeedbackResponse
ReflectionSafetyRequest
ReflectionSafetyResponse
```

### Dominios AI actuales

```text
task
habit
week
finance
pantry
wardrobe
mission
system
```

### Guardrails

Archivo observado:

```text
services/ai_gateway/app/guardrails.py
```

Comportamientos verificados:

- `filter_ai_events` bloquea eventos si `ai_enabled=false`.
- Filtra eventos cuyo `privacy_level != ai_allowed`.
- Filtra eventos cuyo dominio no está permitido.
- `sanitize_suggestions` fuerza `requires_confirmation=True`.
- Añade `external_action_without_confirmation` como forbidden action.
- Existen protecciones para capture, proof parsing, task rewrite y reflection safety.

### Web backend / Admin

Archivos observados:

```text
services/web_backend/pyproject.toml
services/web_backend/app/main.py
services/web_backend/app/routing.py
apps/admin_next/package.json
apps/admin_next/lib/types.ts
```

Backend operativo:

- FastAPI
- PostgreSQL vía psycopg
- tokens admin/ingestion/internal
- OpenRouter key management
- runtime config móvil
- dashboard
- users
- organizations
- billing
- storage
- privacy
- security
- audit
- HomeMemory
- quality
- incidents
- usage
- AI costs
- missions
- feedback
- safety
- feature flags
- model routing

Capacidades de routing actuales:

```text
daily_plan
task_rewrite
semantic_classify
weekly_summary
```

## Conclusión de base

GoLife AI ya contiene suficientes piezas para implementar MindFlow Core y EcoShop Domain sin crear repositorio nuevo.
