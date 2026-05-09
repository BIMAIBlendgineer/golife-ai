# 05 — Especificación técnica end-to-end

## 1. Arquitectura objetivo

```text
Flutter Mobile
├─ UI: Today / Capture / Decisions / Shopping / Memory
├─ GoLifeController
├─ LocalStore SQLite v5
├─ AiGatewayClient
└─ RuntimeConfigClient

AI Gateway
├─ FastAPI
├─ Pydantic schemas
├─ LangGraph: golife_graph
├─ LangGraph: mindflow_graph
├─ LangGraph: shopping_graph
├─ Guardrails
└─ Provider routing

Web Backend/Admin
├─ Runtime config
├─ Feature flags
├─ Usage/cost
├─ Safety/privacy
├─ Quality metrics
└─ Evidence quality
```

## 2. Flujo Capture → Decision

```text
User free text
→ CaptureScreen
→ MindFlowParser local
→ optional /v1/mindflow/inbox/parse
→ CaptureDraftItem[]
→ user confirms drafts
→ LifeEvent[]
→ MentalLoadItem[]
→ /v1/mindflow/decisions/daily
→ DecisionCard[]
→ Today dashboard
```

## 3. Flujo Pantry → EcoShop

```text
PantryItem + ExpenseRecord + RecipeRescue
→ ShoppingNeed
→ /v1/shopping/list/optimize
→ ShoppingPlan
→ ShoppingScreen
→ user confirms list
→ optional HomeMemory after purchase
```

## 4. Flujo Purchase Proof → HomeMemory → MindFlow

```text
Receipt text/photo manually entered
→ /v1/proofs/parse
→ PurchaseProof
→ OwnedItem
→ WarrantyRecord
→ MaintenanceReminder
→ MentalLoadItem
→ DecisionCard
```

## 5. Feature flags

Mobile debe leer runtime config desde:

```text
GET /public/mobile/runtime-config
```

Agregar flags:

```json
{
  "mindflow_core_enabled": true,
  "mindflow_decision_cards_enabled": true,
  "mindflow_reminder_candidates_enabled": false,
  "shopping_domain_enabled": true,
  "shopping_product_evidence_enabled": false,
  "shopping_external_sources_enabled": false,
  "sustainability_claims_enabled": false
}
```

## 6. Backward compatibility

No eliminar:

```text
DailyMission
AISuggestion
CaptureDraftItem
LifeEvent
GoTask
PantryItem
PurchaseIntention
OwnedItem
PurchaseProof
```

Crear adaptadores:

```text
AISuggestion → DecisionCard
DailyMission → DecisionCard
CaptureDraftItem → MentalLoadItem
PantryItem → ShoppingNeed
PurchaseIntention → ShoppingNeed
```

## 7. Error handling

Si falla AI Gateway:

```text
- usar parser local
- generar decision cards locales básicas
- marcar trace.clientFallback=true
- no bloquear captura
- mostrar banner gateway degraded
```

## 8. Seguridad

- Todo endpoint nuevo recibe `PrivacySettings`.
- Todo output nuevo incluye `trace`.
- Todo claim EcoShop incluye evidencia o `insufficient_verified_data`.
- Todo action contract requiere confirmación.

## 9. Observabilidad

Registrar metadata, no contenido sensible:

```text
decision_generated
decision_accepted
decision_completed
decision_rejected
shopping_need_detected
shopping_plan_generated
product_evidence_insufficient
privacy_filter_applied
```

## 10. Performance

| Operación | Objetivo |
|---|---:|
| local parse | < 500 ms |
| semantic parse | < 4 s |
| decision plan | < 6 s |
| shopping plan | < 6 s |
| UI navigation | < 100 ms perceived |
