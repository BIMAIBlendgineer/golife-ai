# Release Risk Register

Date: `2026-05-04`
Release candidate baseline: `main@d1b521375086142a9c0cdeb258de5968369344e9`

## Baseline decision

This repo is in a `conditional go` state for a premium release candidate.

That means:

- the core hardening program for anti-mock runtime, export/delete, secure export bundle, and adversarial input safety is closed by evidence
- release still depends on explicit acceptance of the residual risks below
- no unresolved secret exposure or failed CI gate is currently accepted

## Closed or mitigated risks

### RR-008 - AI Gateway mock or silent fallback in production

- State: `closed`
- Impact: production could look functional while returning mock missions or hidden fallback behavior
- Evidence:
  - [F03 AI Gateway production runtime closeout](F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md)
  - merged PRs `#7`, `#10`, `#11`
- Mitigation:
  - production validator blocks `AI_GATEWAY_ENABLE_MOCK=true`
  - production validator blocks missing live AI config
  - provider factory and OpenRouter provider no longer degrade silently to mock in production
  - `/ready` fails when production is not actually AI-ready
- Gate:
  - `services/ai_gateway`: `python -m pytest -q`
  - local production smoke with `mock_mode=false` and live OpenRouter response
- Release decision: not a blocker anymore unless the code regresses
- Next action: keep the deploy runbook aligned with the validated env contract

### RR-009 - Admin/backend export-delete was read-only

- State: `closed`
- Impact: privacy operations could be acknowledged operationally without executing real export or delete work
- Evidence:
  - [F04 11 admin export delete workflow](F04_11_ADMIN_EXPORT_DELETE_WORKFLOW.md)
  - merged PR `#10`
- Mitigation:
  - admin can download metadata-only export bundles
  - admin can resolve export requests explicitly
  - admin can execute backend delete workflows explicitly
- Gate:
  - `services/web_backend`: `python -m pytest -q`
  - `apps/admin_next`: `npm run lint`, `npm run typecheck`, `npm run build`
- Release decision: not a blocker anymore unless the workflow regresses
- Next action: keep support and privacy docs synchronized with the implemented flow

### RR-010 - HomeMemory submission assets persisted only as metadata refs

- State: `closed`
- Impact: export could lose the user's actual receipt or evidence files even if metadata remained
- Evidence:
  - [F04 secure mobile export bundle](F04_16_SECURE_MOBILE_EXPORT_BUNDLE.md)
  - merged PR `#10`
- Mitigation:
  - submission assets are copied to an app-private vault
  - protected export writes `data.json + assets/`
  - delete-all clears the private vault
- Gate:
  - `apps/mobile_flutter`: `flutter analyze`, `flutter test`
  - GitHub Actions `flutter`
- Release decision: not a blocker anymore for the current local-first scope
- Next action: validate device-specific retrieval UX if mobile platform runners are added

### RR-011 - Adversarial safety coverage was limited to reflection only

- State: `mitigated`
- Impact: unsafe obfuscated crisis or clinical text could still flow through other freeform AI surfaces
- Evidence:
  - [F04 15B reflection adversarial coverage](F04_15B_REFLECTION_ADVERSARIAL_COVERAGE.md)
  - [F04 adversarial input surfaces](F04_26_ADVERSARIAL_INPUT_SURFACES.md)
  - merged PR `#11`
- Mitigation:
  - reflection-style normalization now also protects classify, parse, proof-parse, and task-rewrite
  - mobile local capture parser drops obviously unsafe text instead of turning it into normal drafts
- Gate:
  - `services/ai_gateway`: `python -m pytest -q`
  - `apps/mobile_flutter`: `flutter test`
- Release decision: the old narrow-scope risk is no longer a blocker
- Next action: track the remaining broader rule-based safety limit separately as RR-007

### RR-012 - Mobile fallback looked like premium AI

- State: `closed`
- Impact: the user could mistake local fallback output for remote AI guidance
- Evidence:
  - [F03 AI Gateway production runtime closeout](F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md)
  - `apps/mobile_flutter/test/golife_app_test.dart`
- Mitigation:
  - degraded status and reason are visible in the mobile shell
  - `clientFallback`, `fallbackReason`, and mock traces are surfaced explicitly
- Gate:
  - `apps/mobile_flutter`: `flutter test`
- Release decision: not a blocker anymore unless visibility regresses
- Next action: preserve degraded UX in future mission-delivery changes

### RR-013 - Admin fallback snapshots looked live

- State: `closed`
- Impact: operators could mistake snapshot or offline data for live backend state
- Evidence:
  - `apps/admin_next/lib/api.ts`
  - `apps/admin_next/components/page-shell.tsx`
  - `apps/admin_next/components/premium/source-state-badge.tsx`
- Mitigation:
  - admin surfaces distinguish `live`, `fallback`, and `offline`
  - source state is visible in the topbar and page shell
- Gate:
  - `apps/admin_next`: `npm run lint`, `npm run typecheck`, `npm run build`
- Release decision: not a blocker anymore unless visibility regresses
- Next action: keep new admin pages on the same source-state pattern

### RR-014 - HomeMemory admin privacy regression risk

- State: `closed`
- Impact: raw proof text, evidence, or sensitive HomeMemory payloads could leak into admin surfaces
- Evidence:
  - [Quality and security audit](QUALITY_SECURITY_AUDIT_2026-04-25.md)
  - [Privacy review](../compliance/PRIVACY_REVIEW.md)
- Mitigation:
  - admin HomeMemory surfaces remain aggregate-only
  - operational telemetry stays metadata-only
- Gate:
  - `services/web_backend`: `python -m pytest -q`
  - `apps/admin_next`: `npm run build`
- Release decision: not a blocker anymore unless telemetry/admin contracts regress
- Next action: require a separate ADR before exposing deeper HomeMemory detail in admin

## Accepted or open risks

### RR-001 - Transitive Next/PostCSS advisory

- State: `accepted`
- Impact: moderate admin runtime dependency risk
- Evidence:
  - `npm audit --omit=dev`
  - `npm ls next postcss --depth=3`
  - `docs/operations/npm-audit-admin-next.json`
- Mitigation:
  - do not force-upgrade with `npm audit fix --force`
  - keep `npm audit` in CI
- Gate:
  - GitHub Actions `admin-security`
- Release decision: accepted temporarily, not a release blocker for the current RC
- Next action: update when a safe upstream Next/PostCSS path exists

### RR-002 - Flutter localization gaps

- State: `accepted`
- Impact: medium release-quality risk for locale parity claims
- Evidence:
  - `docs/operations/I18N_RELEASE_GAP_REPORT.md`
  - `flutter gen-l10n`
- Mitigation:
  - keep English fallback for missing keys
  - prioritize `es` and `pt-BR` parity first
- Gate:
  - `apps/mobile_flutter`: `flutter analyze`, `flutter test`
- Release decision: accepted for RC, not acceptable for full multilingual parity claims
- Next action: complete the translation sweep before broader launch claims

### RR-003 - Python 3.14+ dependency warnings

- State: `accepted`
- Impact: medium future-compatibility risk
- Evidence:
  - `python -m pytest -q -W default` in Python services
  - [Quality and security audit](QUALITY_SECURITY_AUDIT_2026-04-25.md)
- Mitigation:
  - keep warnings visible during hardening
  - avoid broad dependency churn without a dedicated compatibility pass
- Gate:
  - local Python test runs
  - GitHub Actions `ai-gateway` and `web-backend`
- Release decision: accepted temporarily
- Next action: revisit after upstream FastAPI and `langchain_core` updates

### RR-004 - AI Gateway concurrent smoke instability on local Windows + Python 3.14

- State: `accepted`
- Impact: medium release-operations risk for local load-signoff only
- Evidence:
  - `docs/operations/F04_18_PERFORMANCE_BASELINE.md`
  - manual load-smoke script behavior under Windows + Python 3.14
- Mitigation:
  - treat GitHub Actions Python 3.12 as the authoritative broad CI gate
  - keep the workflow-dispatch load smoke available
- Gate:
  - GitHub Actions `ai-gateway`
  - `ai-gateway-load-smoke` workflow when explicitly dispatched
- Release decision: accepted temporarily
- Next action: re-run load smoke from a Linux-like or Python 3.12 environment before stricter performance sign-off

### RR-005 - AI Gateway production runtime external configuration drift

- State: `accepted`
- Impact: high if deploy-time env values drift from the validated anti-mock configuration
- Evidence:
  - [F03 AI Gateway production runtime closeout](F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md)
- Mitigation:
  - production validator blocks mock mode, missing live config, and default dev routing tokens
  - deploys must replicate the validated external env contract
- Gate:
  - `/ready` production behavior
  - deployment runbook review
- Release decision: accepted only if deploy configuration is explicitly aligned
- Next action: mirror the documented env matrix into the real deploy platform

### RR-006 - No checked-in Android, iOS, or desktop runners

- State: `open`
- Impact: secure storage and export retrieval are validated on the repo Flutter runner, not on final device targets
- Evidence:
  - [F04 secure mobile export bundle](F04_16_SECURE_MOBILE_EXPORT_BUNDLE.md)
  - `apps/mobile_flutter/README.md`
- Mitigation:
  - keep the current Flutter test runner green
  - do not overclaim device-specific validation
- Gate:
  - GitHub Actions `flutter`
- Release decision: open but accepted for this repo-level RC
- Next action: add platform runners and device retrieval validation when those targets become part of the repo

### RR-007 - Safety remains rule-based, not a strong policy engine

- State: `open`
- Impact: adversarial behavior is reduced but not fully covered
- Evidence:
  - [Safety review](../compliance/SAFETY_REVIEW.md)
  - [F04 adversarial input surfaces](F04_26_ADVERSARIAL_INPUT_SURFACES.md)
- Mitigation:
  - structured refusals and metadata-only safety telemetry
  - broader lexical normalization across implemented surfaces
- Gate:
  - `services/ai_gateway`: `python -m pytest -q`
- Release decision: open but acceptable for RC if the limit is stated explicitly
- Next action: stronger policy engine, safer refusal catalog, and offline evaluation corpus

### RR-015 - Operational telemetry requires a live backend if enabled

- State: `accepted`
- Impact: production observability degrades if `OPERATIONAL_BACKEND_ENABLED=true` without a live backend
- Evidence:
  - [F03 AI Gateway production runtime closeout](F03_AI_GATEWAY_PRODUCTION_RUNTIME_CLOSEOUT.md)
  - [Support process](SUPPORT_PROCESS.md)
- Mitigation:
  - enable operational backend only when it is intentionally wired
  - keep admin fallback/offline signaling visible
- Gate:
  - backend health in admin
  - deployment runbook review
- Release decision: accepted if the deploy wiring is explicit
- Next action: validate the full live operational backend path in the target environment

## Release gate

The following conditions remain hard blockers:

- failing CI or local validation gates for touched surfaces
- `gitleaks` findings
- production env drift that re-enables mock mode or removes live AI configuration
- regressions that expose sensitive HomeMemory or feedback content in admin or operational telemetry
