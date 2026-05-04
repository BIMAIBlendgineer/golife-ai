# GoLife AI Quality and Security Audit

Date: `2026-04-25`

## Scope

- mobile Flutter app
- `services/ai_gateway`
- `services/web_backend`
- `apps/admin_next`
- CI and operational automation

## Corrections implemented

- redacted mission feedback note text before it reaches operational admin surfaces
- sanitized existing operational feedback reasons to the redaction marker on repository startup
- migrated AI gateway local feedback storage away from raw note persistence to metadata only
- hardened reflection safety matching with accent-insensitive normalization and broader multilingual crisis phrases
- replaced placeholder crisis contacts with region-aware defaults for `global`, `us`, `es`, and `br`
- added a checked-in crisis resource catalog sample at `services/ai_gateway/config/crisis_resources.catalog.json`
- added a resilient mobile local-store wrapper that falls back safely instead of crashing when secure storage is unavailable
- exposed the degraded encryption state in the privacy UI
- marked admin API access code as server-only and removed the production fallback admin token
- added CI security gates for `bandit`, `pip-audit`, `npm audit`, and a manual AI gateway load-smoke workflow
- added a reusable load-smoke script at `scripts/performance/ai_gateway_load_smoke.py`

## Risks still open

- sensitive encryption coverage was expanded after this audit to include `life_events`, `calendar_items`, `daily_risks`, and `missions`, and the current repo now validates protected export retrieval plus submission-asset vaulting on the real Flutter CI runner; device-specific validation still remains open if Android, iOS, or desktop targets are added
- reflection safety and the broader freeform gateway surfaces now cover accent stripping, punctuation splitting, letter-spaced obfuscation, and basic leetspeak variants across `reflection/check`, `events/classify`, `events/parse`, `proofs/parse`, and `tasks/rewrite`, plus the local mobile capture fallback; the remaining gap is that the policy is still rule-based, not a stronger policy engine
- clipboard-only export is no longer the primary path after the protected local bundle export hardening, but device-specific retrieval UX still needs validation if final platform runners are added
- dynamic browser-level regression coverage is still limited; current automation is strongest on API and storage boundaries

## QA and DevSecOps baseline

- functional and regression:
  - Python API tests in `services/ai_gateway/tests` and `services/web_backend/tests`
  - Flutter tests in `apps/mobile_flutter/test`
  - Next lint, typecheck, and production build in CI
- security:
  - `gitleaks` for secret scanning
  - `bandit` for Python SAST
  - `pip-audit` for Python dependency vulnerabilities
  - `npm audit --omit=dev --audit-level=high` for admin runtime dependencies
- performance:
  - manual workflow-dispatch load smoke against `ai_gateway`
  - script supports thresholds for `p95` latency and error rate

## Recommended next block

- add browser-level admin smoke tests and Flutter widget smoke flows for the privacy/export path
- add platform validation runs for secure storage on release candidates when concrete Android, iOS, or desktop runners exist in the repo
- extend the new feedback-backed mission memory into stronger evidence-level ranking over persisted LifeGraph state

## Canonical current-state docs

- [Release candidate summary](RELEASE_CANDIDATE_SUMMARY.md)
- [Release risk register](RELEASE_RISK_REGISTER.md)
- [Data map](../compliance/DATA_MAP.md)
- [Safety review](../compliance/SAFETY_REVIEW.md)
- [Safety policy](../security/SAFETY_POLICY.md)
