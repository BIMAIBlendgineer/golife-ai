# Validation Matrix

| Surface | Gate | Command / check | Expected result | Current status | Notes |
| --- | --- | --- | --- | --- | --- |
| Documentation | canonical release docs | manual review of final docs set | no stale claims, no secrets, clear blockers | green on integration branch | final summary, runbooks, ADR index, risk register, i18n audit, ranking evaluation |
| AI Gateway | unit/integration | `cd services/ai_gateway && python -m pytest -q` | full suite green | green (`95 passed`) | anti-mock, routing, safety, ranker, API |
| AI Gateway | production health | `GET /health` | `active_provider=openrouter`, `mock_mode=false` | validated locally | production local single-key smoke |
| AI Gateway | readiness | `GET /ready` | `200` in valid production config | validated locally | production validator enforced |
| AI Gateway | live smoke | `POST /v1/missions/daily` | `200`, suggestions, no `mock: true` | validated locally | one-request OpenRouter smoke |
| AI Gateway | persisted mission memory | feedback -> follow-up daily mission | later ranking reflects stored pattern memory, trace stays visible | green | current scope is metadata-backed ranking memory |
| AI Gateway | mission ranker | top 3 deterministic with explicit score breakdown | ranking fields visible and privacy-safe | green | covered by graph tests and offline corpus |
| AI Gateway | policy engine | structured policy decisions across guarded routes | `policy_id` and `policy_version` returned | green | input, reflection, and mission-output checks |
| Web Backend | unit/integration | `cd services/web_backend && python -m pytest -q` | full suite green | green (`25 passed`) | includes support export/delete |
| Web Backend | support export | admin bundle endpoint | metadata-only bundle available | validated locally | no local LifeGraph sync |
| Web Backend | support delete | admin execute-delete endpoint | operational records removed | validated locally | local device data untouched |
| Mobile | l10n generation | `cd apps/mobile_flutter && flutter gen-l10n` | generation succeeds | green | all locale files now have full key coverage; some long-tail non-English copy still mirrors English pending polish |
| Mobile | static analysis | `cd apps/mobile_flutter && flutter analyze` | green | green | CI runner: ubuntu-latest |
| Mobile | tests | `cd apps/mobile_flutter && flutter test` | green | green (`55 passed`) | includes locale normalization, theme preference, fallback, export bundle, ranker visibility |
| Mobile | secure export | controller/export tests | `data.json + assets/` | green | submission-asset vault validated |
| Mobile | locale scope | runtime locale picker | requested 10-locale set available | green | requested 10-locale mobile runtime is live; profile/settings copy is translated across the shipped locale set |
| Mobile | profile settings | settings surface | language, theme, notifications, quiet hours, units, region, reminders, AI detail, backup/sync, privacy controls, current plan | green | local-first profile preferences are persisted |
| Mobile | Android release bundle | `cd apps/mobile_flutter/android && gradlew.bat bundleRelease` | `.aab` produced | green locally | use Gradle command as authoritative signal in this workspace |
| Admin | lint | `cd apps/admin_next && npm run lint` | green | green | |
| Admin | typecheck | `cd apps/admin_next && npm run typecheck` | green | green | |
| Admin | build | `cd apps/admin_next && npm run build` | green | green | |
| Auth | enterprise boundary | admin/web backend auth status review | no enterprise claims without OIDC/SSO | documented and runtime-aligned | current mode is hardening-grade, not enterprise-ready |
| Security | secret scan | `gitleaks git` | no findings | green | no leaks found |
| Security | Python SAST | `bandit -q -r app -s B105,B106` | green | CI baseline | run in both Python services |
| Security | Python deps | clean-venv `pip-audit --ignore-vuln CVE-2026-3219` per Python service | green or accepted exception only | green in isolated service envs | workstation global Python is noisy; release gate should run in a clean env per service |
| Security | Admin deps | `npm audit --omit=dev --audit-level=high` | green or accepted exception only | green at `high` threshold | 2 moderate transitive `postcss` findings remain under `next`; no `high` or above |
| Git | docs and code diff | `git diff --stat` and secret grep | no unrelated secrets or scope drift | green | final review completed; `git diff --check` only reported CRLF normalization warnings |
| Git | branch hygiene | merged release branch, deleted rescue branch, verified worktrees | clean main | green | only `main` remains as the durable local branch after closeout |

## Residual gaps

- Android device and emulator QA is still blocked on the current workstation
- policy engine is centralized and versioned, but still rule-based rather than jailbreak-proof
- deploy environment must reproduce documented external variables
- enterprise identity remains out of scope unless real OIDC/SSO is added
