# Web Management Premium Release Checklist

- [ ] no `/control`
- [ ] no `/admin`
- [ ] no `/studio`
- [ ] existing admin routes improved
- [ ] users scalable
- [ ] organizations and plans present
- [ ] BYOK management present
- [ ] xInsightAI distinction visible
- [ ] billing visible
- [ ] storage visible
- [ ] privacy/security/audit visible
- [ ] HomeMemory aggregate only
- [ ] no raw sensitive telemetry
- [ ] no secrets in browser
- [ ] tests executed
- [ ] CI green

## Local validation note

- `apps/admin_next`: `npm run lint`, `npm run typecheck`, `npm run build`, `npm audit --omit=dev --audit-level=high`
- `services/web_backend`: `python -m pytest -q`
- `services/ai_gateway`: targeted smoke suite passed; full `python -m pytest -q` timed out locally
- `apps/mobile_flutter`: `flutter gen-l10n`, `flutter analyze`, `flutter test`
- repo: `gitleaks git`
