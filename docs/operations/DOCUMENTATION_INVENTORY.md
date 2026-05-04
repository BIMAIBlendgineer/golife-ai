# Documentation Inventory

Date: `2026-05-04`
Branch: `docs/release-production-readiness`
Scope: repo-local documentation inventory after merge of PR `#10` and PR `#11`

## Summary

- Files under `docs/`: `229` at inventory start, plus this documentation pass
- Files under `golife_ai_business_roadmap_package/`: `88`
- Top-level README files found:
  - `README.md`
  - `README_START_HERE.md`
  - `apps/mobile_flutter/README.md`
  - `docs/archive/README.md`
  - `golife_ai_business_roadmap_package/README.md`

## Canonical runtime source of truth

These documents currently describe the implemented product, runtime behavior, safety, privacy, and release state.

### Root and repo entrypoints

- `README.md` - canonical repo entrypoint
- `docs/commands.md` - short command reference
- `docs/development/LOCAL_SETUP.md` - canonical local setup guide
- `docs/development/TESTING.md` - canonical testing guide
- `.github/workflows/ci.yml` - canonical CI gate source

### Operations

- `docs/operations/RELEASE_CANDIDATE_SUMMARY.md`
- `docs/operations/RELEASE_RISK_REGISTER.md`
- `docs/operations/PREMIUM_RELEASE_READINESS_CHECKLIST.md`
- `docs/operations/VALIDATION_MATRIX.md`
- `docs/operations/DEPLOYMENT_RUNBOOK.md`
- `docs/operations/ENVIRONMENT_MATRIX.md`
- `docs/operations/EXECUTION_PACK_STATUS.md`
- `docs/operations/F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md`
- `docs/operations/F04_11_ADMIN_EXPORT_DELETE_WORKFLOW.md`
- `docs/operations/F04_16_SECURE_MOBILE_EXPORT_BUNDLE.md`
- `docs/operations/F04_26_ADVERSARIAL_INPUT_SURFACES.md`
- `docs/operations/QUALITY_SECURITY_AUDIT_2026-04-25.md`
- `docs/operations/SUPPORT_PROCESS.md`
- `docs/operations/DOCUMENTATION_INVENTORY.md`

### Compliance and security

- `docs/compliance/PRIVACY_REVIEW.md`
- `docs/compliance/DATA_MAP.md`
- `docs/compliance/SAFETY_REVIEW.md`
- `docs/compliance/LICENSE_REVIEW.md`
- `docs/compliance/CRISIS_RESOURCES_CONFIG.md`
- `docs/security/SAFETY_POLICY.md`

### API and admin

- `docs/api/AI_GATEWAY_API.md`
- `docs/api/WEB_BACKEND_API.md`
- `docs/admin/ADMIN_OPERATIONS.md`

### Product

- `docs/product/PRODUCT_STATUS.md`
- `docs/product/HOMEMEMORY_RECALLBOX_MVP.md`
- `docs/product/STORE_METADATA.md`

### Architecture

- `docs/architecture/adr/ADR-001-ai-gateway-production-anti-mock.md`
- `docs/architecture/adr/ADR-002-admin-export-delete-workflow.md`
- `docs/architecture/adr/ADR-003-secure-mobile-export-bundle.md`
- `docs/architecture/adr/ADR-004-adversarial-safety-input-surfaces.md`
- `docs/architecture/adr/ADR-005-admin-and-mobile-fallback-visibility.md`

## Live but secondary

Useful docs that are still relevant but are no longer the best top-level entrypoint:

- `apps/mobile_flutter/README.md`
- `docs/operations/WEB_MANAGEMENT_PREMIUM_RUNBOOK.md`
- `docs/operations/WEB_MANAGEMENT_PREMIUM_RELEASE_CHECKLIST.md`
- `docs/operations/INTEGRATION_HOMEMEMORY_PREMIUM_WEB.md`
- `docs/compliance/ReflectionSafetyPolicy.md`
- `docs/adrs/**`
- `docs/decisions/**`

## Historical but useful

These are execution records, not primary current-state docs:

- `docs/operations/F04_01_REPO_FORENSIC_BASELINE.md`
- `docs/operations/F04_02_GIT_HYGIENE_AUDIT.md`
- `docs/operations/F04_03_LOCAL_VALIDATION_BASELINE.md`
- `docs/operations/F04_04_WEB_BACKEND_GATE_FIX.md`
- `docs/operations/F04_05_LEGACY_DUPLICATION_AUDIT.md`
- `docs/operations/F04_10_EXPORT_DELETE_HARDENING.md`
- `docs/operations/F04_15_TRACEABILITY_SAFETY_PASS.md`
- `docs/operations/F04_15B_REFLECTION_ADVERSARIAL_COVERAGE.md`
- `docs/operations/F04_16_ADMIN_AUTH_HARDENING.md`
- `docs/operations/F04_17_MOBILE_SENSITIVE_ENCRYPTION.md`
- `docs/operations/F04_18_PERFORMANCE_BASELINE.md`
- `docs/operations/F04_19_UI_PREMIUM_REVIEW.md`
- `docs/operations/F04_20_ACCESSIBILITY_PASS.md`
- `docs/operations/F04_21_FULL_VALIDATION_RC.md`
- `docs/operations/F04_22_DOCUMENTATION_SYNC.md`
- `docs/operations/F04_23_DEPLOY_READINESS.md`
- `docs/operations/F04_24_LOCAL_RELEASE_CANDIDATE.md`
- `docs/operations/F04_25_REMOTE_CLOSURE.md`

## Legacy or quarantine candidates

These remain in-repo for provenance, but future implementers should not use them as runtime source of truth.

### Legacy business package

- `golife_ai_business_roadmap_package/**`
  - status: `legacy`, `historical`
  - risk: older path and packaging assumptions

### Product execution pack

- `docs/golife_ai_product_execution_pack/**`
  - status: `historical`, `reference`
  - risk: roadmap assumptions may not match current runtime source of truth

### Generated and prompt material

- `docs/generated/**`
  - status: `generated`, `historical`
- `docs/prompts/**`
  - status: `historical`, `tooling reference`

### Stale legacy docs now bannered

- `docs/autocopilot.md`
- `docs/DesignUI/F01_UI_UX_STORYBOARD.md`
- `README_START_HERE.md`
- `docs/golife_ai_product_execution_pack/00_README.md`
- `docs/golife_ai_product_execution_pack/05_roadmap/master_roadmap.md`
- `golife_ai_business_roadmap_package/README.md`

## Split taxonomies to watch

- ADRs are split across `docs/adrs/**`, `docs/decisions/**`, and `docs/architecture/adr/**`
- design material is split across `docs/design/**` and `docs/DesignUI/**`
- older release/admin checklists still overlap with the canonical release checklist

## Stale references detected

Confirmed stale or legacy framing:

- `docs/autocopilot.md`
  - references old repo names and paths
- `docs/DesignUI/F01_UI_UX_STORYBOARD.md`
  - references older PlantMind branding

Intentional historical references:

- `docs/operations/F04_01_REPO_FORENSIC_BASELINE.md`
- `golife_ai_business_roadmap_package/**`

## Canonical documentation set after consolidation

- root:
  - `README.md`
- operations:
  - `docs/operations/RELEASE_CANDIDATE_SUMMARY.md`
  - `docs/operations/RELEASE_RISK_REGISTER.md`
  - `docs/operations/PREMIUM_RELEASE_READINESS_CHECKLIST.md`
  - `docs/operations/VALIDATION_MATRIX.md`
  - `docs/operations/DEPLOYMENT_RUNBOOK.md`
  - `docs/operations/ENVIRONMENT_MATRIX.md`
  - `docs/operations/DOCUMENTATION_INVENTORY.md`
- development:
  - `docs/commands.md`
  - `docs/development/LOCAL_SETUP.md`
  - `docs/development/TESTING.md`
- compliance and security:
  - `docs/compliance/PRIVACY_REVIEW.md`
  - `docs/compliance/DATA_MAP.md`
  - `docs/compliance/SAFETY_REVIEW.md`
  - `docs/security/SAFETY_POLICY.md`
- API and admin:
  - `docs/api/AI_GATEWAY_API.md`
  - `docs/api/WEB_BACKEND_API.md`
  - `docs/admin/ADMIN_OPERATIONS.md`
- product:
  - `docs/product/PRODUCT_STATUS.md`
  - `docs/product/HOMEMEMORY_RECALLBOX_MVP.md`
- architecture:
  - `docs/architecture/adr/ADR-001...ADR-005`
- archive:
  - `docs/archive/README.md`

## Next documents to keep synchronized

1. `docs/operations/RELEASE_CANDIDATE_SUMMARY.md`
2. `docs/operations/RELEASE_RISK_REGISTER.md`
3. `docs/operations/PREMIUM_RELEASE_READINESS_CHECKLIST.md`
4. `docs/compliance/PRIVACY_REVIEW.md`
5. `docs/compliance/DATA_MAP.md`
6. `docs/compliance/SAFETY_REVIEW.md`
7. `docs/security/SAFETY_POLICY.md`
8. `docs/api/**`
9. `docs/product/PRODUCT_STATUS.md`
