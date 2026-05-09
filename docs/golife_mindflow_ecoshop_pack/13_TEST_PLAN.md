# 13 — Test Plan

## 1. Unit tests — AI Gateway

### Privacy

- `test_mindflow_parse_respects_ai_disabled`
- `test_decision_plan_filters_local_only`
- `test_shopping_plan_filters_finance_if_not_allowed`
- `test_journal_never_sent_by_default`

### Contracts

- `test_mental_load_item_schema`
- `test_decision_card_requires_confirmation`
- `test_product_evidence_requires_disclaimer`
- `test_shopping_need_schema`

### Guardrails

- `test_no_best_price_without_source`
- `test_no_sustainable_claim_without_source`
- `test_external_action_forbidden`
- `test_safety_capture_block`

### Graph

- `test_mindflow_graph_returns_max_three`
- `test_shopping_graph_prefers_existing_pantry`
- `test_decision_ranking_has_reason`

## 2. Unit tests — Flutter

### DTO

- `mindflow_dto_from_json_test`
- `decision_card_dto_from_json_test`
- `shopping_need_dto_from_json_test`

### Storage

- `sqlite_v5_migration_empty_db_test`
- `sqlite_v5_migration_existing_v4_test`
- `mental_load_upsert_load_test`
- `decision_cards_upsert_load_test`
- `shopping_needs_upsert_load_test`
- `delete_all_data_removes_mindflow_test`

### Controller

- `capture_creates_mental_load_item_test`
- `capture_creates_shopping_need_test`
- `decision_accept_updates_state_test`
- `decision_postpone_updates_state_test`
- `offline_fallback_decision_test`

## 3. Widget tests

- Capture Inbox displays drafts.
- Decision Card displays privacy summary.
- Shopping screen displays insufficient verified data.
- Explain sheet displays data used and blocked.
- HomeMemory displays generated decisions.

## 4. Integration tests

### Scenario A

```text
User captures:
"tomorrow pay internet, buy milk, use spinach, review laptop warranty"
```

Expected:

- 4 drafts
- finance reminder
- shopping need
- pantry rescue
- HomeMemory reminder
- privacy controls visible

### Scenario B

All domains local-only.

Expected:

- no AI payload
- local fallback decision
- UI says data blocked by privacy

### Scenario C

EcoShop without external sources.

Expected:

- no best price claim
- sustainability insufficient
- local shopping list allowed

### Scenario D

Gateway 503.

Expected:

- local fallback
- trace fallback reason
- app usable

## 5. Admin tests

- MindFlow summary returns metrics.
- Shopping evidence quality returns counts.
- Feature flags toggle.
- Admin does not expose raw journal text.
- Admin does not expose raw purchase proof text.

## 6. Release tests

- Flutter analyze.
- Flutter test.
- AI Gateway pytest.
- Web backend pytest.
- Admin lint/typecheck/build.
- Secrets scan.
- Manual QA checklist.
