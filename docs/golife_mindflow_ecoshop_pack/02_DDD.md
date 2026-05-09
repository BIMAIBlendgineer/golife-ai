# 02 — DDD: Domain-Driven Design

## 1. Bounded Contexts

```text
GoLife AI
├─ MindFlow Context
├─ Daily Mission Context
├─ EcoShop Context
├─ HomeMemory Context
├─ Privacy Context
├─ Evidence Context
├─ AI Gateway Context
├─ Admin/Ops Context
└─ Billing/Usage Context
```

## 2. MindFlow Context

### Responsabilidad

Convertir información dispersa en carga mental estructurada y decisiones accionables.

### Entidades

```text
MentalLoadItem
DecisionCard
ReminderCandidate
OpenLoop
DecisionFeedback
```

### Value Objects

```text
UrgencyScore
EffortScore
ConfidenceScore
PrivacySummary
EvidenceRef
ActionContract
```

### Agregados

```text
MentalLoadGraph
DecisionPlan
```

### Eventos de dominio

```text
CaptureParsed
MentalLoadItemCreated
DecisionCardGenerated
DecisionAccepted
DecisionPostponed
DecisionCompleted
DecisionRejected
ReminderCandidateConfirmed
```

## 3. Daily Mission Context

### Responsabilidad

Generar hasta 3 misiones diarias seguras, explicables y priorizadas.

### Entidades actuales

```text
DailyMission
DailyRisk
MissionFeedback
```

### Cambio

`DailyMission` pasa a ser un tipo de `DecisionCard` o una vista especializada.

```text
DailyMission ⊂ DecisionCard
```

No eliminar el modelo existente en V1. Mantener compatibilidad y mapear.

## 4. EcoShop Context

### Responsabilidad

Optimizar compras desde necesidad real, contexto local y evidencia.

### Entidades

```text
ShoppingNeed
ShoppingList
ShoppingListItem
ProductEvidenceCard
SustainabilityClaim
PriceEvidence
```

### Estados

```text
draft
confirmed
shopping_list
purchased
dismissed
```

### Regla principal

No existe claim comercial fuerte sin evidencia.

```text
best_price=true → requiere source + checked_at + merchant + price
sustainable=true → requiere certification/source + methodology/status
```

## 5. HomeMemory Context

### Responsabilidad

Gestionar memoria de objetos, compras, garantías, recibos, mantenimiento y claims.

### Entidades actuales

```text
OwnedItem
PurchaseProof
WarrantyRecord
MaintenanceReminder
ClaimDraft
EvidenceAttachment
```

### Integración nueva

HomeMemory debe emitir:

```text
WarrantyExpiringDetected
MaintenanceDueDetected
ClaimCandidateDetected
PurchaseProofParsed
OwnedItemCreated
```

Estos eventos alimentan MindFlow.

## 6. Privacy Context

### Responsabilidad

Autorizar qué datos pueden salir del dispositivo o entrar en IA.

### Value Objects actuales

```text
PrivacySettings
PrivacyLevel
DataPermission
DomainKey
```

### Regla

Privacidad se evalúa antes de IA, no después.

```text
LifeEvent → filter_ai_events → AI payload
```

## 7. Evidence Context

### Responsabilidad

Registrar evidencia de por qué se recomienda una acción.

### Entidades

```text
EvidenceRef
EvidencePack
EvidenceSource
PrivacyEvidence
```

### Niveles

```text
local_event
user_confirmed
parsed_document
external_source
insufficient_verified_data
```

## 8. AI Gateway Context

### Responsabilidad

Orquestar IA, fallback, guardrails y normalización.

### Subdominios

```text
Capture Parser
MindFlow Parser
Decision Planner
Shopping Planner
Proof Parser
Task Rewriter
Safety Guardrails
Model Routing
```

## 9. Admin/Ops Context

### Responsabilidad

Observabilidad, coste, calidad, seguridad, privacidad, feature flags y soporte.

### Entidades actuales observadas

```text
DashboardMetrics
UserManagementRow
UserUsageSummary
UserPrivacySummary
PrivacyDataMap
SecuritySummary
AuditLogRow
HomeMemorySummary
QualitySummary
IncidentRow
UsageSnapshot
AICostSnapshot
MissionAuditRecord
FeedbackAuditRecord
SafetyAuditRecord
FeatureFlag
ModelSettingsSnapshot
RoutingProfile
ModelCatalogEntry
ModelSelectionSnapshot
```

## 10. Lenguaje ubicuo

| Término | Definición |
|---|---|
| Capture Inbox | Superficie donde el usuario descarga información libre. |
| Mental Load Item | Unidad de carga mental estructurada. |
| Open Loop | Elemento pendiente que consume atención. |
| Decision Card | Recomendación accionable, explicable y confirmable. |
| Shopping Need | Necesidad de compra derivada de contexto. |
| Product Evidence Card | Evidencia sobre producto, precio, fuente o sostenibilidad. |
| Privacy-before-AI | Filtrado de datos antes del modelo. |
| Evidence-first | Ningún claim sin soporte verificable. |
| HomeMemory | Memoria local de objetos, pruebas, garantías y claims. |

## 11. Mapa de agregados

```text
LifeGraph
└─ LifeEvent[]

MentalLoadGraph
├─ MentalLoadItem[]
├─ OpenLoop[]
└─ DecisionCard[]

ShoppingContext
├─ ShoppingNeed[]
├─ ShoppingList[]
└─ ProductEvidenceCard[]

HomeMemory
├─ OwnedItem[]
├─ PurchaseProof[]
├─ WarrantyRecord[]
├─ MaintenanceReminder[]
├─ ClaimDraft[]
└─ EvidenceAttachment[]
```

## 12. Invariantes

### INV-001

Toda `DecisionCard` debe tener `confirmation_required=true`.

### INV-002

Toda recomendación de compra debe declarar `evidence_status`.

### INV-003

Si `privacy_level != ai_allowed`, el dato no puede salir en payload IA.

### INV-004

`JournalEntry`, `QuickNote`, `PurchaseProof` y `Finance` son sensibles por defecto.

### INV-005

No existe acción externa sin confirmación humana.

### INV-006

Un `ShoppingNeed` no puede convertirse en compra automática.

### INV-007

Un claim de sostenibilidad sin fuente debe marcarse como `insufficient_verified_data`.

### INV-008

El sistema debe poder degradar a fallback local sin perder captura.

## 13. Anti-corruption layer

### Mobile ↔ AI Gateway

Usar DTOs explícitos:

```text
MindFlowParseRequestDto
MindFlowParseResponseDto
DecisionPlanDto
ShoppingPlanDto
ProductEvidenceDto
```

### Mobile ↔ LocalStore

Guardar modelos locales; no guardar respuesta cruda IA como estado principal sin normalización.

### Admin ↔ AI Gateway

Admin recibe metadata operacional, no contenido personal crudo.

## 14. Domain Events recomendados

```text
UserCapturedFreeText
CaptureDraftConfirmed
LifeEventPersisted
MentalLoadItemPersisted
DecisionPlanRequested
DecisionCardShown
DecisionCardAccepted
DecisionCardCompleted
ShoppingNeedDetected
ShoppingListGenerated
ProductEvidenceInsufficient
HomeMemoryWarrantyExpiring
PrivacyFilterApplied
AIProviderFallbackUsed
SafetyInterventionRaised
```
