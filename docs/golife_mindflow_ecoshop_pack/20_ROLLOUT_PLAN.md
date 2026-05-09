# 20 - Rollout Plan

Updated: 2026-05-09
Recommended starting stage: `Stage 4`

## 1. Rollout by flags

### Stage 1

```text
mindflow_core_enabled=true
mindflow_decision_cards_enabled=false
shopping_domain_enabled=false
```

Objective: storage plus local capture.

### Stage 2

```text
mindflow_decision_cards_enabled=true
shopping_domain_enabled=false
```

Objective: Today plus Decisions.

### Stage 3

```text
shopping_domain_enabled=true
shopping_product_evidence_enabled=false
```

Objective: local-only shopping needs.

### Stage 4

```text
shopping_product_evidence_enabled=true
shopping_external_sources_enabled=false
sustainability_claims_enabled=false
```

Objective: evidence cards stay local-first and claim-safe. This is the recommended release-candidate default.

### Stage 5

```text
shopping_external_sources_enabled=true
sustainability_claims_enabled=false
```

Objective: controlled external evidence without verified sustainability claims.

### Stage 6

```text
sustainability_claims_enabled=true
```

Enable only after verified source contracts, operational monitoring, and explicit product approval.

## 2. Rollback order

If issues appear, disable features in this order:

1. `sustainability_claims_enabled=false`
2. `shopping_external_sources_enabled=false`
3. `shopping_product_evidence_enabled=false`
4. `shopping_domain_enabled=false`
5. `mindflow_decision_cards_enabled=false`

Keep `mindflow_core_enabled=true` unless storage or capture regressions are observed.

Do not revert SQLite migration destructively. Leave the tables unused if a rollback is required.

## 3. Beta scope

Internal beta defaults:

- MindFlow enabled.
- Decision cards enabled.
- Shopping enabled with local-first evidence only.
- External evidence disabled by default.
- Sustainability claims disabled by default.

## 4. Beta metrics

```text
capture usage
decision accepted
decision rejected
postpone rate
privacy blocked rate
fallback rate
shopping need created
shopping need completed
product evidence loaded
```

## 5. Go or no-go

Go if:

- no privacy leak
- no unverified claim
- fallback works
- completion rate is measurable
- no crash spike
- admin metrics remain aggregate-only

No-go if:

- any claim appears without source evidence
- sensitive data is exposed
- migration is unsafe
- offline fallback regresses
- confirmation gates are bypassed
