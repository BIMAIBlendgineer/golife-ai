# 08 — AI Gateway Spec

## 1. Archivos afectados

```text
services/ai_gateway/app/main.py
services/ai_gateway/app/schemas.py
services/ai_gateway/app/use_cases.py
services/ai_gateway/app/guardrails.py
services/ai_gateway/app/graphs/mindflow_graph.py
services/ai_gateway/app/graphs/shopping_graph.py
services/ai_gateway/tests/
```

## 2. Endpoints nuevos

```text
POST /v1/mindflow/inbox/parse
POST /v1/mindflow/decisions/daily
POST /v1/mindflow/decisions/{decision_id}/explain
POST /v1/mindflow/reminders/propose
POST /v1/shopping/needs/extract
POST /v1/shopping/list/optimize
POST /v1/shopping/product/evidence
```

## 3. Prompts nuevos

### MINDFLOW_PARSE_SYSTEM_PROMPT

```text
Return JSON only.
Convert free-form user text into mental load items.
Do not execute external actions.
Do not infer sensitive facts beyond the text.
Every item must include type, domain, title, summary, urgency_score,
effort_score, confidence, evidence_refs, privacy recommendation,
and whether user confirmation is required.
Allowed item types: task, reminder, decision, shopping, document,
calendar, money, home_memory, meal, note.
```

### DECISION_PLAN_SYSTEM_PROMPT

```text
Return JSON only.
Generate at most 3 DecisionCards.
Each decision must be safe, small, explainable and confirmable.
Use only privacy-allowed context.
Every decision must include evidence, uncertainty, confidence,
privacy_summary and action_contract.
No external action without human confirmation.
```

### SHOPPING_OPTIMIZATION_SYSTEM_PROMPT

```text
Return JSON only.
Create a shopping decision plan from pantry, finance, recipes,
wardrobe and homememory context.
Prefer using existing items before recommending purchases.
Do not claim best price, availability, or sustainability unless
source evidence is present.
If evidence is missing, set sustainability_status='insufficient_verified_data'.
Every purchase recommendation requires human confirmation.
```

## 4. mindflow_graph

Nodes:

```text
validate_consent
filter_events
parse_inbox
build_mental_load_items
detect_open_loops
create_decision_candidates
rank_decisions
sanitize_decisions
build_response
```

## 5. shopping_graph

Nodes:

```text
validate_consent
collect_local_context
extract_shopping_needs
prefer_existing_items
generate_list_candidates
attach_evidence_status
sanitize_purchase_claims
build_response
```

## 6. Guardrails nuevos

### no_unverified_price_claim

Bloquear frases equivalentes a:

```text
best price
cheapest
lowest price
available now
```

si no hay `source`, `checked_at`, `merchant_name`, `price`.

### no_unverified_sustainability_claim

Bloquear frases equivalentes a:

```text
sustainable
eco-friendly
low carbon
fair trade
ethical
```

si no hay evidencia.

### confirmation_required

Toda decisión debe tener:

```text
confirmation_required=true
action_contract.requires_confirmation=true
```

## 7. Tests obligatorios

```text
test_mindflow_parse_contract.py
test_decision_plan_privacy.py
test_decision_requires_confirmation.py
test_shopping_plan_no_external_claims.py
test_shopping_insufficient_sustainability.py
test_mindflow_fallback.py
```

## 8. Fallback

Si provider falla:

```text
- construir MentalLoadItem local desde parser determinístico
- construir DecisionCard básica desde reglas
- trace.clientFallback=true
- no bloquear app
```

## 9. Telemetría

Enviar metadata operacional:

```text
endpoint
provider
model
latency
status
fallback
safety_events
privacy_filtered_count
decision_count
shopping_need_count
```

No enviar texto crudo sensible al admin.
