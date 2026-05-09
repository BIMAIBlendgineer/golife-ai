# 14 - Release Readiness

Updated: 2026-05-09
Current state: `release_candidate`
production_ready = false
store_ready = false

## 1. Release state labels

```text
development
local_validated
integration_candidate
staging_candidate
release_candidate
production_ready
```

## 2. Current recommendation

MindFlow Core + EcoShop Domain V1 is ready to move as `release_candidate`.

## 3. Hard blockers cleared

- [x] No privacy leak observed in automated coverage and privacy guardrails remain enabled.
- [x] No external action executes without confirmation; decision and shopping actions stay gated.
- [x] No unverified shopping claim is surfaced; insufficient data is labeled with disclaimers.
- [x] SQLite v4 to v5 migration coverage passes for clean and legacy data paths.
- [x] Offline and fallback paths remain available for mission, decisions, shopping, and capture flows.
- [x] Gateway failure falls back locally instead of breaking capture or dashboard experiences.
- [x] Admin endpoints aggregate metrics without exposing raw sensitive text.
- [x] Safety guardrails pass AI Gateway tests.
- [x] Automated suites pass.

## 4. Soft blockers status

- [x] The 10-locale set is wired and English fallback coverage is tested.
- [x] Required UI surfaces exist for Capture v2, Today, Decisions, Shopping, and HomeMemory.
- [x] Admin MindFlow and Shopping pages, metrics, and quality breakdowns are implemented.
- [x] Product evidence defaults to local-only or insufficient-data when external sources are disabled.

## 5. Evidence executed

```text
2026-05-09 apps/mobile_flutter flutter analyze lib test      PASS
2026-05-09 apps/mobile_flutter flutter test                  PASS (65 tests)
2026-05-09 services/ai_gateway python -m pytest tests        PASS (105 tests)
2026-05-09 services/web_backend python -m pytest tests       PASS (26 tests)
2026-05-09 apps/admin_next npm run typecheck                 PASS
2026-05-09 apps/admin_next npm run build                     PASS
```

## 6. QA coverage summary

- Mobile tests cover offline fallback, gateway down behavior, capture multi-item flow, decision accept and postpone actions, shopping without evidence, HomeMemory warranty signals, delete-all-data, and export data.
- Storage tests cover clean migration, v4 to v5 migration, sensitive encryption, and table cleanup.
- AI Gateway tests cover privacy filtering, confirmation contracts, and no-claim guardrails.
- Admin tests cover schemas, endpoints, feature flags, routing capabilities, and aggregate-only output.

## 7. Rollback

Recommended release flags:

```text
mindflow_core_enabled=true
mindflow_decision_cards_enabled=true
shopping_domain_enabled=true
shopping_product_evidence_enabled=true
shopping_external_sources_enabled=false
sustainability_claims_enabled=false
```

Fast rollback switches:

```text
mindflow_decision_cards_enabled=false
shopping_domain_enabled=false
shopping_product_evidence_enabled=false
shopping_external_sources_enabled=false
sustainability_claims_enabled=false
```

Do not rollback SQLite migration destructively. Leave v5 tables in place and disable the surfaces with flags.

## 8. Production notes

Do not market:

```text
best price
real-time availability
verified sustainability
automatic shopping
```

until external sources are implemented, verified, and the related flags are intentionally enabled.
