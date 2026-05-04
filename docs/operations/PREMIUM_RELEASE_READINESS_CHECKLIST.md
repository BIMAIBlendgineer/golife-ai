# Premium Release Readiness Checklist

## Baseline

- Documentation branch: `docs/final-production-readiness`
- Runtime baseline on `main`: `3848c162822038ae9a80171e0919e7e980695bc0`
- Scope: RC hardening plus persisted mission-memory baseline

See also:

- [Final release summary](FINAL_RELEASE_SUMMARY.md)
- [Final release readiness checklist](FINAL_RELEASE_READINESS_CHECKLIST.md)

## Product thesis gate

- [ ] GoLife AI is described as a daily decision system built on LifeGraph, evidence, privacy, and feedback
- [ ] No canonical doc describes the product as a generic chatbot
- [ ] No canonical doc claims features that are not implemented

## AI Gateway

- [x] production blocks `AI_GATEWAY_ENABLE_MOCK=true`
- [x] production blocks missing OpenRouter key or valid routing backend
- [x] production blocks dev routing token
- [x] factory cannot route production to `MockLLMProvider`
- [x] provider no longer delegates to mock in production
- [x] `/ready` exists and is production-aware
- [x] local production single-key smoke returned real OpenRouter output
- [x] `mock_mode=false` validated in real smoke
- [x] no `mock: true` in live daily mission response
- [x] persisted mission memory exists for feedback-backed follow-up planning
- [ ] explicit score-based mission ranker

## Web Backend

- [x] `python -m pytest -q`
- [x] support export/delete workflow is actionable, not read-only
- [x] admin export bundle is metadata-only by design
- [x] production validator blocks dev default tokens and weak secrets

## Mobile

- [x] `flutter analyze`
- [x] `flutter test`
- [x] protected export bundle writes `data.json` plus `assets/`
- [x] submission assets stored in private vault
- [x] delete-all clears local data plus private vault
- [x] gateway fallback is visible to the user
- [ ] Android, iOS, and desktop runner validation

## Admin

- [x] `npm run lint`
- [x] `npm run typecheck`
- [x] `npm run build`
- [x] live/fallback/offline source state visible
- [x] support export/delete workflow exposed in UI

## Safety and privacy

- [x] reflection safety covered
- [x] adversarial capture, parse, proof-parse, and task-rewrite coverage added
- [x] mobile capture parser blocks crisis and clinical text from normal drafts
- [x] admin receives metadata-only operational telemetry
- [x] mission feedback notes stay redacted in operational surfaces
- [x] persisted mission memory remains metadata-only
- [ ] stronger policy engine beyond rule-based guardrails

## Security

- [x] `gitleaks git`
- [x] CI secret scan workflow exists
- [x] CI Python security workflow exists
- [x] CI admin security workflow exists
- [ ] upstream remediation of accepted transitive advisories where applicable

## Environment and deploy

- [x] external production env requirements documented
- [x] single-key production mode documented
- [x] control-plane mode documented as conditional
- [ ] deploy environment actually replicates documented external values
- [ ] operational telemetry enablement decided for real production

## Git and release hygiene

- [ ] docs PR opened
- [ ] docs PR merged
- [ ] docs branch deleted locally
- [ ] docs branch deleted remotely
- [ ] worktree clean on `main`

## Residual accepted limits

- [ ] locale parity still incomplete
- [ ] safety still rule-based
- [ ] enterprise auth still not real OIDC/SSO
- [ ] device-specific runner validation still open
- [ ] control-plane production remains conditional on live backend routing

## Release decision

- Decision target: conditional go for production-readiness closeout
- Conditions:
  - docs PR merged
  - no secrets in diff
  - risk register and release summary shipped together
  - external deploy mirrors the documented production env
