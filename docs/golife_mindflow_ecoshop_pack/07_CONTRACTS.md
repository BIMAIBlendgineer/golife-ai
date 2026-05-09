# 07 — Contratos funcionales

## 1. MentalLoadItem

Representa una unidad de carga mental.

Campos obligatorios:

```text
item_id
user_id
type
domain
title
summary
urgency_score
effort_score
confidence
state
privacy_level
requires_confirmation
trace
```

## 2. DecisionCard

Representa una decisión sugerida.

Campos obligatorios:

```text
decision_id
user_id
title
recommended_action
alternatives
domain_targets
source_items
evidence
ranking
confidence
uncertainty
privacy_summary
confirmation_required
action_contract
status
```

## 3. ShoppingNeed

Representa una necesidad de compra, no una compra.

Campos obligatorios:

```text
need_id
user_id
need_type
title
source_domain
source_event_ids
urgency_score
state
```

## 4. ProductEvidenceCard

Representa evidencia sobre un producto.

Campos obligatorios:

```text
product_name
confidence
sustainability_status
disclaimer
```

Campos condicionados:

```text
price + currency → requiere merchant/source/checked_at
sustainability_status=verified → requiere source/methodology/certification
```

## 5. PrivacySummary

Debe aparecer en toda DecisionCard.

```json
{
  "ai_enabled": true,
  "sent_event_count": 4,
  "blocked_event_count": 8,
  "allowed_domains": ["task", "pantry"],
  "blocked_domains": ["journal", "finance"],
  "local_only_collections": ["Journal", "Purchase proofs"]
}
```

## 6. ActionContract

Ninguna decisión ejecuta acción directamente.

```json
{
  "action_type": "create_reminder",
  "requires_confirmation": true,
  "destructive": false,
  "external": false,
  "payload_preview": {}
}
```

## 7. Evidence status

```text
verified
partial
local_only
insufficient_verified_data
not_checked
```

## 8. Contrato no-claim

```text
Si source == null:
  no usar: best, cheapest, most sustainable, available
```

## 9. Compatibility

`AISuggestion` sigue existiendo.

Mapeo:

```text
AISuggestion.suggestion_id → DecisionCard.decision_id
AISuggestion.title → DecisionCard.title
AISuggestion.body → DecisionCard.recommended_action
AISuggestion.domain_targets → DecisionCard.domain_targets
AISuggestion.evidence → DecisionCard.evidence
AISuggestion.ranking → DecisionCard.ranking
AISuggestion.confidence → DecisionCard.confidence
AISuggestion.uncertainty → DecisionCard.uncertainty
```
