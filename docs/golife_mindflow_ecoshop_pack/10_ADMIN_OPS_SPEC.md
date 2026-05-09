# 10 — Admin / Ops Spec

## 1. Backend afectados

```text
services/web_backend/app/main.py
services/web_backend/app/schemas.py
services/web_backend/app/repository.py
services/web_backend/app/routing.py
services/web_backend/tests/
```

## 2. Admin frontend afectados

```text
apps/admin_next/lib/types.ts
apps/admin_next/lib/api.ts
apps/admin_next/app/
apps/admin_next/messages/
```

## 3. Nuevas métricas Dashboard

```ts
mental_load_items_per_active_user: number;
decision_acceptance_rate: number;
decision_completion_rate: number;
decision_postpone_rate: number;
shopping_need_conversion_rate: number;
shopping_claims_with_evidence_rate: number;
insufficient_sustainability_data_rate: number;
privacy_filtered_decision_rate: number;
```

## 4. Nuevos endpoints admin

```text
GET /admin/mindflow/summary
GET /admin/mindflow/decision-quality
GET /admin/mindflow/open-loops
GET /admin/shopping/summary
GET /admin/shopping/evidence-quality
GET /admin/shopping/sustainability-claims
```

## 5. Nuevas capabilities de routing

Actualmente:

```text
daily_plan
task_rewrite
semantic_classify
weekly_summary
```

Agregar:

```text
mindflow_parse
decision_plan
shopping_plan
product_evidence
```

## 6. Feature flags

```text
mindflow_core_enabled
mindflow_decision_cards_enabled
mindflow_reminder_candidates_enabled
shopping_domain_enabled
shopping_product_evidence_enabled
shopping_external_sources_enabled
sustainability_claims_enabled
```

## 7. Admin UI

Agregar módulos:

```text
MindFlow
├─ Summary
├─ Decision quality
├─ Privacy filtered rate
├─ Open loop trends
└─ Feedback

Shopping
├─ Needs
├─ Evidence quality
├─ Claims status
├─ Insufficient sustainability data
└─ External sources readiness
```

## 8. No exponer datos sensibles

Admin puede ver:

```text
counts
rates
statuses
domains
fallbacks
latency
cost
safety events
privacy filtered counts
```

Admin no debe ver:

```text
journal text
raw purchase proof
raw financial record
raw personal note
raw decision content unless user support export explicitly permits
```

## 9. Quality metrics

```text
Decision quality:
- accepted
- completed
- rejected
- postponed
- repeated

Shopping evidence:
- verified
- partial
- insufficient
- not_checked
```

## 10. Incidents

Crear incidentes si:

```text
unverified claim attempted
privacy blocked data leak attempted
external action without confirmation attempted
AI fallback rate above threshold
decision rejection rate above threshold
```
