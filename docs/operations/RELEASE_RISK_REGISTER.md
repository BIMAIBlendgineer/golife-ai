# Release Risk Register

## Baseline

- Branch: `hardening/traceability-safety-pass`
- Main baseline: `77f4b7c7ca780aca54bf78a1e2caed7875c7329e`
- Supporting evidence:
  - `docs/operations/npm-audit-admin-next.json`
  - `docs/operations/I18N_RELEASE_GAP_REPORT.md`

## RR-001 - Transitive PostCSS issue under Next

- Area: `apps/admin_next`
- Severity: moderate
- Origin: transitive advisory `GHSA-qx2v-qp2m-jg93` through `next@15.5.15 -> node_modules/next/node_modules/postcss@8.4.31`
- Direct dependency status: the repo-level `postcss` dependency is already `8.4.47`; the flagged copy is the one bundled under `next`
- Evidence:
  - `npm audit --omit=dev`
  - `npm ls next postcss --depth=3`
  - `docs/operations/npm-audit-admin-next.json`
- Fix available: only via `npm audit fix --force`, which proposes a semver-major `next` change and is not acceptable in this hardening pass
- Runtime impact:
  - Inference: low for the current product because the admin app does not expose a user-authored CSS surface
  - The vulnerable package sits in the CSS stringify path owned by `next`, so the fix needs to come from a safe upstream update rather than a local force-upgrade
- Decision: accepted temporarily
- Mitigation:
  - do not run `npm audit fix --force`
  - keep the high-severity audit gate in CI/release validation
  - avoid shipping any feature that processes user-supplied CSS or theme code before the upstream dependency is fixed safely
- Follow-up:
  - monitor the first safe `next` release that removes the vulnerable bundled `postcss`
  - re-run `npm audit --omit=dev` before each release candidate

## RR-002 - Flutter localization gaps

- Area: `apps/mobile_flutter`
- Severity: medium release-quality risk
- Origin: locale files lag behind the HomeMemory and everyday-surface string expansion
- Evidence:
  - `flutter gen-l10n`
  - `docs/operations/I18N_RELEASE_GAP_REPORT.md`
- Current counts:
  - `es`: 65 missing keys
  - `pt_BR`: 65 missing keys
  - `pt`: 196 missing keys
  - `ja`: 195 missing keys
  - `zh`: 195 missing keys
  - `zh_Hans`: 195 missing keys
- Decision: accepted temporarily for a premium release candidate, but not acceptable for claiming full locale parity
- Mitigation:
  - keep English template fallback in place for missing keys
  - prioritize human translation of the HomeMemory key set for `es` and `pt_BR` first because those are closest to parity and are visible user-facing locales
  - treat `pt`, `ja`, `zh`, and `zh_Hans` as partial-localization follow-up work
- Follow-up:
  - complete the translation sweep tracked in `docs/operations/I18N_RELEASE_GAP_REPORT.md`
  - do not advertise full multilingual completeness until the gap report is cleared

## RR-003 - Python 3.14+ dependency warnings

- Area: `services/web_backend`, `services/ai_gateway`
- Severity: medium future-compatibility risk
- Origin:
  - `fastapi` still hits `asyncio.iscoroutinefunction`, which is deprecated and slated for removal in Python 3.16
  - `langchain_core` still imports the Pydantic v1 compatibility path under Python 3.14+
- Evidence:
  - `python -m pytest -q -W default` in both Python services
- Decision: partially corrected, remainder accepted temporarily
- Corrected in this hardening branch:
  - closed SQLite repository connections cleanly in `services/web_backend`
  - reduced backend warnings from FastAPI deprecation plus many SQLite `ResourceWarning` messages down to the external FastAPI deprecation warnings only
- Remaining uncorrected warnings:
  - FastAPI deprecation path in both services
  - `langchain_core` Pydantic v1 compatibility warning in `ai_gateway`
- Mitigation:
  - keep running tests with warnings visible during hardening/release passes
  - avoid broad dependency upgrades without an ADR or a dedicated compatibility pass
- Follow-up:
  - revisit after upstream FastAPI and `langchain_core` releases land with Python 3.14+/3.16-safe internals

## RR-004 - AI Gateway concurrent smoke instability on local Python 3.14

- Area: `services/ai_gateway`
- Severity: medium release-operations risk
- Origin: the repo load smoke script timed out locally under Windows + Python 3.14 while the same surface remained functionally healthy for isolated requests
- Evidence:
  - `python scripts/performance/ai_gateway_load_smoke.py --base-url http://127.0.0.1:8003 --requests 60 --concurrency 10 --max-p95-ms 2000 --max-error-rate 0.0`
  - `docs/operations/F04_18_PERFORMANCE_BASELINE.md`
- Working evidence:
  - a single local `POST /v1/missions/daily` probe returned `200` in `97.17 ms`
  - the normal PR CI workflow passed for `ai-gateway` on Python 3.12
- Decision: accepted temporarily as an environment-specific release-operations limitation
- Mitigation:
  - treat GitHub Actions Python 3.12 as the authoritative broad gate for the branch
  - keep the manual `ai-gateway-load-smoke` workflow available for future controlled runs
  - avoid claiming local Windows + Python 3.14 load parity with Linux CI
- Follow-up:
  - re-run the smoke from a Python 3.12 or Linux-like environment before a stricter performance sign-off

## RR-005 - HomeMemory admin privacy regression risk

- Area: admin UI + backend operational APIs
- Severity: high if regressed
- Origin: potential exposure of raw proof text, receipts, evidence details, claim text, journal/reflection content, or raw BYOK secrets through admin surfaces
- Evidence reviewed:
  - `apps/admin_next/app/homememory/page.tsx`
  - `apps/admin_next/lib/api.ts`
  - `apps/admin_next/lib/types.ts`
  - `services/web_backend/app/main.py`
  - `services/web_backend/app/schemas.py`
  - `services/web_backend/app/repository.py`
  - `services/web_backend/tests/test_admin_api.py`
  - `docs/admin/DDC_HOMEMEMORY_ADMIN_TELEMETRY.md`
  - `docs/admin/DDD_HOMEMEMORY_ADMIN_AGGREGATES.md`
  - `docs/admin/SPEC_HOMEMEMORY_ADMIN_UI.md`
- Decision: verified safe in the current build
- Mitigation:
  - backend exposes only `GET /admin/homememory/summary` and `GET /admin/homememory/parser-usage`
  - response schema remains aggregate-only
  - admin UI renders only counts, rates, parser names, locale distribution, and encrypted collection metadata
  - regression tests now assert exact aggregate field shape and absence of sensitive fragments
- Follow-up:
  - keep HomeMemory admin aggregate-only until a separately reviewed privacy ADR authorizes any deeper visibility

## RR-006 - Release decision

- Decision: conditional go for a premium release candidate
- Not a blocker for this hardening branch:
  - RR-001 accepted temporarily
  - RR-002 accepted temporarily with documented fallback
  - RR-003 accepted temporarily for upstream-only warnings
  - RR-004 accepted temporarily for local environment-specific performance smoke instability
  - RR-005 verified safe
- Would block release:
  - failing tests or build
  - `gitleaks` findings
  - any regression exposing sensitive HomeMemory or BYOK data in admin
