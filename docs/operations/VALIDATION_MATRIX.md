# Validation Matrix

| Surface | Gate | Command / check | Expected result | Current status | Notes |
| --- | --- | --- | --- | --- | --- |
| AI Gateway | unit/integration | `cd services/ai_gateway && python -m pytest -q` | full suite green | green baseline | anti-mock, routing, safety, API |
| AI Gateway | production health | `GET /health` | `active_provider=openrouter`, `mock_mode=false` | validated locally | production local single-key smoke |
| AI Gateway | readiness | `GET /ready` | `200` in valid production config | validated locally | production validator enforced |
| AI Gateway | live smoke | `POST /v1/missions/daily` | `200`, suggestions, no `mock: true` | validated locally | one-request OpenRouter smoke |
| Web Backend | unit/integration | `cd services/web_backend && python -m pytest -q` | full suite green | green baseline | includes support export/delete |
| Web Backend | support export | admin bundle endpoint | metadata-only bundle available | validated locally | no local LifeGraph sync |
| Web Backend | support delete | admin execute-delete endpoint | operational records removed | validated locally | local device data untouched |
| Mobile | static analysis | `cd apps/mobile_flutter && flutter analyze` | green | green baseline | CI runner: ubuntu-latest |
| Mobile | tests | `cd apps/mobile_flutter && flutter test` | green | green baseline | includes fallback and export bundle coverage |
| Mobile | secure export | controller/export tests | `data.json + assets/` | green baseline | submission-asset vault validated |
| Admin | lint | `cd apps/admin_next && npm run lint` | green | green baseline | docs-only PR should not affect |
| Admin | typecheck | `cd apps/admin_next && npm run typecheck` | green | green baseline | |
| Admin | build | `cd apps/admin_next && npm run build` | green | green baseline | |
| Security | secret scan | `gitleaks git` | no findings | green baseline required | must be re-run for docs PR |
| Security | Python SAST | `bandit -q -r app -s B105,B106` | green | CI baseline | run in both Python services |
| Security | Python deps | `pip-audit --ignore-vuln CVE-2026-3219` | green or accepted exception only | CI baseline | |
| Security | Admin deps | `npm audit --omit=dev --audit-level=high` | green or accepted exception only | CI baseline | |
| Git | docs diff | `git diff --stat` and secret grep | docs-only, no secrets | pending final review | |
| Git | branch hygiene | PR merged, branch deleted | clean main | pending final closeout | |

## Residual non-blocking gaps

- No checked-in Android, iOS, or desktop runner validation
- Safety remains rule-based, not a strong policy engine
- Deploy environment must reproduce documented external variables
