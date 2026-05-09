# ADR-006 — Feature flags para rollout progresivo

## Estado

Aprobado.

## Decisión

Agregar feature flags:

```text
mindflow_core_enabled
mindflow_decision_cards_enabled
mindflow_reminder_candidates_enabled
shopping_domain_enabled
shopping_product_evidence_enabled
shopping_external_sources_enabled
sustainability_claims_enabled
```

## Regla

`shopping_external_sources_enabled=false` hasta tener fuentes reales.
