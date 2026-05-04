# Final Release Readiness Checklist

Date: `2026-05-04`
Baseline: `main@3848c162822038ae9a80171e0919e7e980695bc0`

## Documentation

- [x] canonical release summary exists
- [x] deployment runbook exists
- [x] rollback runbook exists
- [x] environment matrix exists
- [x] data map exists
- [x] API docs exist for AI Gateway and web backend
- [x] admin operations doc exists
- [x] ADR index exists
- [ ] final docs branch merged

## AI Gateway runtime

- [x] production blocks mock mode
- [x] production blocks missing live AI config
- [x] production blocks dev routing token
- [x] `/ready` is production-aware
- [x] local production single-key OpenRouter smoke passed
- [x] persisted mission-memory baseline exists
- [ ] mission ranker exposes explicit scoring fields
- [ ] evidence-aware top-3 ranking is finalized
- [ ] offline ranking evaluation corpus exists

## Learning and memory

- [x] metadata-only feedback memory exists
- [x] per-user feedback isolation exists
- [x] raw feedback notes stay out of operational telemetry
- [ ] rejection reason categories are normalized for ranking
- [ ] effort feedback is captured and used
- [ ] evidence-aware memory is validated

## Safety and policy

- [x] rule-based adversarial safety covers current freeform surfaces
- [x] telemetry remains metadata-only
- [ ] centralized policy engine exists
- [ ] `policy_id` and `policy_version` are returned in policy decisions
- [ ] prompt-injection corpus is covered
- [ ] mission-output policy pass is centralized

## Mobile

- [x] fallback visibility is explicit
- [x] secure export bundle exists
- [x] submission assets are preserved in a private vault
- [ ] ranked mission explanation is visible in UI
- [ ] release locales are finalized
- [ ] device-specific runners are validated if added to scope

## Admin and backend

- [x] export/delete workflow is executable
- [x] admin source state is explicit
- [x] production token validation exists
- [ ] enterprise auth remains explicitly non-claimed or is replaced by OIDC
- [ ] real OIDC flow exists if enterprise is claimed

## Security and privacy

- [x] `gitleaks git` is part of the gate
- [x] CI security checks exist
- [x] privacy boundary is documented
- [ ] strong policy-engine posture replaces the current rule-based-only claim
- [ ] deploy environment mirrors the documented production env contract

## Final gates

- [ ] `cd services/ai_gateway && python -m pytest -q`
- [ ] `cd services/web_backend && python -m pytest -q`
- [ ] `cd apps/mobile_flutter && flutter gen-l10n && flutter analyze && flutter test`
- [ ] `cd apps/admin_next && npm run lint && npm run typecheck && npm run build`
- [ ] `gitleaks git`
- [ ] final integration PR merged
- [ ] temporary branches removed
- [ ] worktree clean on `main`
