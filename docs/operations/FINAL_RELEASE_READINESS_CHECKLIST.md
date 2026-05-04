# Final Release Readiness Checklist

Date: `2026-05-04`
Baseline before this integration branch: `main@81787ba`

## Documentation

- [x] canonical release summary exists
- [x] deployment runbook exists
- [x] rollback runbook exists
- [x] environment matrix exists
- [x] data map exists
- [x] API docs exist for AI Gateway and web backend
- [x] admin operations doc exists
- [x] ADR index exists
- [x] i18n final audit exists
- [x] mission ranking evaluation doc exists

## AI Gateway runtime

- [x] production blocks mock mode
- [x] production blocks missing live AI config
- [x] production blocks dev routing token
- [x] `/ready` is production-aware
- [x] local production single-key OpenRouter smoke passed
- [x] persisted mission-memory baseline exists
- [x] mission ranker exposes explicit scoring fields
- [x] evidence-aware top-3 ranking is finalized for the current scope
- [x] offline ranking evaluation corpus exists

## Learning and memory

- [x] metadata-only feedback memory exists
- [x] per-user feedback isolation exists
- [x] raw feedback notes stay out of operational telemetry
- [x] rejection reason categories are normalized for ranking
- [x] effort feedback is captured and used
- [x] evidence-aware ranking is validated with privacy-filtered inputs

## Safety and policy

- [x] adversarial safety covers current freeform surfaces
- [x] telemetry remains metadata-only
- [x] centralized policy engine exists
- [x] `policy_id` and `policy_version` are returned in policy decisions
- [x] prompt-injection corpus is covered
- [x] mission-output policy pass is centralized

## Mobile

- [x] fallback visibility is explicit
- [x] secure export bundle exists
- [x] submission assets are preserved in a private vault
- [x] ranked mission explanation is visible in UI
- [x] release locales are finalized to `en` and `es`
- [ ] device-specific runners are validated if added to scope

## Admin and backend

- [x] export/delete workflow is executable
- [x] admin source state is explicit
- [x] production token validation exists
- [x] enterprise auth remains explicitly non-claimed
- [ ] real OIDC flow exists if enterprise is claimed

## Security and privacy

- [x] `gitleaks git` is part of the gate
- [x] CI security checks exist
- [x] privacy boundary is documented
- [x] centralized policy-engine posture is documented with explicit residual limits
- [ ] deploy environment mirrors the documented production env contract

## Final gates

- [x] `cd services/ai_gateway && python -m pytest -q`
- [x] `cd services/web_backend && python -m pytest -q`
- [x] `cd apps/mobile_flutter && flutter gen-l10n && flutter analyze && flutter test`
- [x] `cd apps/admin_next && npm run lint && npm run typecheck && npm run build`
- [x] `gitleaks git`
- [ ] final integration PR merged
- [ ] temporary branches removed
- [ ] worktree clean on `main`
