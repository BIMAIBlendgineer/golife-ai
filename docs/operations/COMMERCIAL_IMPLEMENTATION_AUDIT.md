# Commercial Implementation Audit

Date: 2026-05-16
Repo: `C:\0 Work\GoLife AI`
Branch: `main`
Head: `24430f2`

## Audit scope

This audit was completed before commercial hardening changes against the mandatory pack under `docs/golife_ai_commercialization_implementation_pack/`.

Commands executed:
- `git status --short`
- `git branch -vv`
- `git log --oneline -5`
- `git worktree list`

Mandatory commercialization docs read:
- `00_README.md`
- `01_PRD_COMMERCIAL_PREMIUM.md`
- `02_DDD_DOMAIN_MODEL.md`
- `03_DDC_DELIVERY_CONTRACTS.md`
- `04_SPEC_AI_GATEWAY_AND_SAFETY.md`
- `05_SPEC_MOBILE_PREMIUM_APP.md`
- `06_SPEC_MONETIZATION_AND_ENTITLEMENTS.md`
- `07_SPEC_BILLING_IMPLEMENTATION.md`
- `18_SPEC_STORE_READINESS.md`
- `19_SPEC_PRIVACY_DATA_SAFETY.md`
- `20_SPEC_ANALYTICS_AND_KPIS.md`
- `22_RELEASE_GATES.md`
- `23_IMPLEMENTATION_ROADMAP.md`
- `24_RISK_REGISTER_COMMERCIAL.md`
- `25_CI_CD_AND_RELEASE_AUTOMATION.md`
- `29_COMMERCIAL_ACCEPTANCE_CHECKLIST.md`
- `30_RACI_AND_WORKSTREAMS.md`

Supporting docs also checked during reconciliation:
- `10_ADR_001_SCOPED_PREMIUM_COMMERCIALIZATION.md`
- `13_ADR_004_NO_ENTERPRISE_CLAIMS_WITHOUT_OIDC.md`
- `26_SUPPORT_AND_OPERATIONS.md`

## Git state

Current worktree is not clean.

Observed local changes:
- untracked: `docs/golife_ai_commercialization_implementation_pack/`

Interpretation:
- the repo is dirty because the commercialization pack itself is not tracked yet;
- no existing tracked source files were locally modified before this audit;
- logic changes should stay bounded and traceable because the pack is the source of truth for this pass.

## Verified baseline

### Mobile Flutter

Confirmed:
- `GoLifeApp` initializes `ResilientLocalStore(primary: SqliteLocalStore(), fallback: MemoryLocalStore())`.
- `GoLifeApp` wires `HttpAiGatewayClient` from `GOLIFE_AI_GATEWAY_BASE_URL`.
- `GoLifeApp` wires runtime config from `GOLIFE_RUNTIME_CONFIG_BASE_URL`.
- `GoLifeController.bootstrap()` loads privacy, locale, profile preferences, runtime config, LifeGraph, daily missions, daily risks, mission feedback, domain entities, mental load, decision cards, shopping needs and product evidence.
- `GoLifeController` already exposes `prepareCaptureDrafts`, `captureEvent`, `captureDrafts`, `completeMission`, `rejectMission`, `refreshDecisionPlan`, `refreshShoppingPlan`.
- `CaptureScreen` already uses `prepareCaptureDrafts(...)`, shows editable draft cards and supports saving all parsed items at once.
- `CaptureParser` already splits multi-capture text and derives basic hints such as amount, currency, time, pantry expiry and wardrobe pause hours.
- `LocalStore` already defines contracts for tasks, habits, expenses, pantry, wardrobe, week, journal, calendar, recipes, homememory, mindflow, shopping and product evidence.
- `SqliteLocalStore` already persists `life_events`, `missions`, `daily_risks`, `mission_feedback`, domain tables, `mental_load_items`, `decision_cards`, `shopping_needs` and `product_evidence_cards`.
- `LifeEvent` preserves `eventId`, `userId`, `domain`, `eventType`, `timestampIso`, `payload`, `source`, `privacyLevel`, `evidenceHash`.
- export/delete already exist and `deleteAllData()` disables demo reseeding.

Partially confirmed:
- privacy/source-state UX exists, but source state is inferred from trace rather than carried as a normalized `live|fallback|offline|local|degraded` contract;
- daily risks are persisted, but missions are still stored as flat `DailyMission` rows instead of a day-level `MissionSet`.

Not present yet:
- `MissionSet` model and persistence;
- `EvidenceItem` aggregate aligned with commercialization DDD;
- `LifeGraphRelation`;
- LifeGraph timeline/date search/relation UI;
- event-level privacy audit log;
- entitlement model, quota gates, billing restore/refund state.

### AI Gateway

Confirmed:
- FastAPI exposes `/health` and `/ready`.
- `/ready` returns `503` in production when provider is mock, mock mode is enabled or live AI config is missing.
- `/v1/missions/daily`, `/v1/events/classify` and `/v1/events/parse` exist.
- deterministic fallbacks exist for classify/parse.
- `golife_graph.py` pipeline is effectively `validate_consent -> summarize_events -> classify_day_state -> assess_risks -> detect_patterns -> generate_candidates -> feedback_learning -> guardrail_review -> rank -> build_response`.
- ranking includes impact, urgency, effort, confidence, privacy, feedback and novelty.
- trace is visible and current payloads do not hide local fallback or mock mode.
- feedback storage is metadata-oriented and tests already assert raw notes are not sent back to provider payloads.

Partially confirmed:
- OpenRouter normalization retries invalid JSON once at provider level, but there is no explicit repair prompt, no standardized `jsonRepairAttempted/jsonRepairSucceeded` trace and no commercial contract around that behavior.
- output trace includes rich internal node data, but not the commercialization keys and naming expected by the pack such as `policyVersion`, `rankingVersion`, `fallbackUsed` and `sourceState`.

Not present yet:
- `MissionSet` response contract as first-class shape;
- explicit `policy_v1` contract surface;
- explicit `sourceState` top-level contract;
- commercialization `PrivacyJob` contract;
- contract-first billing receipt validation schema.

### CI/CD and release discipline

Confirmed:
- a monorepo CI workflow exists in `.github/workflows/ci.yml`;
- tests/builds run for AI gateway, web backend, admin Next and Flutter;
- gitleaks is already present.

Gaps:
- current job names do not match the commercialization pack names;
- missing named jobs or gates: `billing-contract-test`, `store-copy-lint`, `release-gate`;
- no release artifact JSON under `docs/operations/release_artifacts/`;
- no machine-readable release gate script covering `/ready`, env contract, mock-disabled, runbooks and store copy.

## Major gaps against commercialization pack

### A. Scope and claims

Gaps:
- productive mobile locale surface is not restricted to EN/ES. `supportedAppLocales` and locale preferences still include `pt-BR`, `pt-PT`, `fr`, `it`, `de`, `ja`, `zh-Hans`, `zh-Hant`.
- many non-EN/ES localization files and strings remain in active app bundles.
- no dedicated `store-copy-lint` script or allowlist-based claim gate.

Risk:
- store/readiness and scope-integrity gates can fail because language scope and claim controls are not enforced automatically.

### B. Contracts and domain model

Gaps:
- no `MissionSet` aggregate on mobile or gateway;
- no `EvidenceItem` aggregate/table distinct from homememory evidence attachments;
- no `PrivacyJob` schema;
- no `Entitlement` schema in mobile app runtime;
- `DailyMission` and `SuggestionResponse` still act as the effective contract.

Risk:
- commercial release requirements are documented but not encoded as stable contracts.

### C. Capture

Strengths:
- multi-capture confirmation flow already exists and is editable before save;
- gateway parse endpoint already returns list items and deterministic local fallback exists.

Gaps:
- draft trace does not carry normalized `remote`, `parser`, `fallbackReason` per item as a formal contract;
- extracted hints are still limited and do not cover the full pack list such as due date, expiry date, estimated minutes, quantity or cadence in a normalized way;
- adversarial EN/ES tests should be expanded for obfuscated crisis/diagnosis/financial-advice prompts.

### D. Home Today and missions

Strengths:
- UI already centers on daily missions, explanation and fallback visibility;
- daily risks are derivable from mission trace.

Gaps:
- no first-class `MissionSet`;
- no persistent `minimumAction`;
- no explicit mission-level `sourceState` field;
- accept/complete/reject exist, but `postpone` and `replace` are not yet formalized in the contract;
- risks are linked implicitly through domain overlap, not explicit mission references.

### E. Feedback learning

Strengths:
- feedback metadata is persisted locally and summarized safely for the gateway;
- ranking already uses feedback and novelty.

Gaps:
- feedback status set is incomplete relative to commercialization pack;
- explicit rejection reason collection is not enforced in the UI;
- anti-repetition logic exists implicitly, but not yet surfaced as a stable commercial contract.

### F. Privacy, export and delete

Strengths:
- local export bundle is real;
- submission assets are exported from a protected vault;
- delete-all clears local stores and disables demo reseeding.

Gaps:
- no `EvidenceItem` or `LifeGraphRelation` in export;
- no event-level privacy change audit trail;
- no commercial privacy dashboard counts and “what left the device” proof surface as a first-class spec-aligned dashboard.

### G. Real domains

Strengths:
- task, habit, expense, pantry, week, wardrobe, homememory, decision and shopping entities already exist with persistence and tests.

Gaps:
- several domains are present but still lighter than the commercialization target:
  - tasks: no explicit subtasks contract in audit pass;
  - habits: no recovery mission contract;
  - finance: no weekly budget/recurring spend contract;
  - pantry: no explicit rescue priority fields in current contract;
  - week: no overload-first weekly contract in a dedicated MissionSet pipeline;
  - wardrobe: anti-buy flow exists partially, not yet formalized.

### H. Monetization and entitlements

Gaps:
- no mobile `Entitlement` aggregate;
- no quota model for daily refreshes or AI captures;
- no restore/refund/cancel flow in mobile;
- no billing validation contract exposed in CI.

Risk:
- pack explicitly forbids activating paywall/billing without restore and entitlement validation.

### I. Analytics and metadata-only ops

Strengths:
- AI gateway operational payloads are already metadata-oriented;
- admin export/delete routes exist on web backend.

Gaps:
- no product analytics event contract aligned to commercialization KPI names;
- no explicit payload schema tests for `mission_set_generated`, `fallback_used`, `privacy_setting_changed`, `trial_started`, `subscription_activated` and related events;
- no formal `PrivacyJob` schema for export/delete lifecycle.

## Checklist status

### Phase 1 audit

- [x] Git status reviewed
- [x] Branch and recent history reviewed
- [x] Worktree list reviewed
- [x] Commercialization pack read
- [x] Core mobile files inspected
- [x] Core AI gateway files inspected
- [x] CI workflow inspected
- [x] Audit document created
- [ ] Dirty repo resolved

### Immediate commercialization blockers

- [ ] Restrict productive language scope to EN/ES or document and gate additional locales
- [ ] Introduce commercial `MissionSet` contract
- [ ] Introduce `EvidenceItem` contract/table
- [ ] Introduce `Entitlement` contract
- [ ] Introduce `PrivacyJob` contract
- [ ] Add `store-copy-lint`
- [ ] Add release artifact JSON
- [ ] Add release-gate script
- [ ] Normalize source state contract
- [ ] Standardize policy/ranking contract fields

## Risks

High:
- locale scope mismatch versus EN/ES-only commercialization scope
- commercial contract gap: `MissionSet`/`Entitlement`/`PrivacyJob` not encoded
- no automated claim/store copy gate
- billing and entitlement flow not production-ready

Medium:
- source-state is visible but not standardized
- capture hint coverage is still partial
- privacy dashboard and event-level audit trail remain incomplete
- CI jobs exist but do not yet map to release-gate artifact expectations

Low:
- repo dirtiness currently limited to untracked commercialization pack inputs

## Scope decision

Recommended next implementation slice:

1. Contract and safety hardening only.
2. No broad product expansion.
3. Keep existing local-first behavior intact.

Closed next slice:
- add commercial contract models for `MissionSet`, `Entitlement` and `PrivacyJob`;
- surface normalized `policyVersion`, `rankingVersion`, `fallbackUsed` and `sourceState`;
- add `store-copy-lint` with allowlist and CI wiring;
- restrict productive locale scope to EN/ES and add tests for critical EN/ES strings;
- add release artifact scaffold and release-gate script skeleton.

Deferred after that slice:
- `EvidenceItem` and `LifeGraphRelation` persistence;
- deeper privacy dashboard and timeline/search UI;
- billing provider integration and restore/refund handling;
- full quota/paywall implementation.

## Acceptance for next slice

The next patch should be accepted only if:
- no existing local-first mission flow regresses;
- new commercial contracts are test-covered;
- fallback and mock visibility remain explicit;
- EN/ES scope is enforced in runtime and tests;
- CI includes store copy and release-gate checks;
- no forbidden claims are introduced.
