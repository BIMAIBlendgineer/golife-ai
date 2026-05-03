# Premium Release Readiness Checklist

## Baseline

- Branch under review: `hardening/traceability-safety-pass`
- Main baseline: `77f4b7c7ca780aca54bf78a1e2caed7875c7329e`
- Scope: release hardening only, no new features

## Validation status

- [x] mobile validation
  - `flutter pub get`
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test`
- [x] admin validation
  - `npm ci`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
  - `npm audit --omit=dev --audit-level=high`
- [x] web backend validation
  - `python -m pytest -q`
  - `python -m pytest -q -W default`
- [x] ai gateway validation
  - focused local gateway route and safety tests
  - full remote `ai-gateway` job on GitHub Actions
- [x] security validation
  - focused local `bandit`
  - remote `secret-scan`, `python-security`, and `admin-security`
- [x] privacy validation
  - HomeMemory admin confirmed aggregate-only
  - BYOK secrets remain masked in admin responses
  - mobile encrypted collections extended to `life_events`, `missions`, `daily_risks`, `calendar_items`

## I18N status

- [x] gaps audited
- [ ] full locale parity
- Current gap summary:
  - `es`: HomeMemory-only gap
  - `pt_BR`: HomeMemory-only gap
  - `pt`: broad partial gap
  - `ja`: broad partial gap
  - `zh`: broad partial gap
  - `zh_Hans`: broad partial gap
- Source of truth: `docs/operations/I18N_RELEASE_GAP_REPORT.md`

## Known risks

- [x] PostCSS transitive risk documented
- [x] Python 3.14+ dependency warnings documented
- [x] HomeMemory privacy risk documented and re-tested
- [x] local AI gateway concurrent smoke instability documented
- [ ] PostCSS transitive issue remediated upstream
- [ ] Full locale parity completed

## Rollback plan

- If this hardening branch fails before merge:
  - `git switch main`
  - `git branch -D hardening/post-merge-release-readiness`
- If this branch is pushed and later discarded:
  - `git push origin --delete hardening/post-merge-release-readiness`
  - `git switch main`
  - `git branch -D hardening/post-merge-release-readiness`
- If a future hardening PR merges and release validation fails after merge:
  - prepare a revert PR against the hardening merge commit

## Release decision

- Decision: conditional go for a premium release candidate
- Conditions:
  - no new feature work lands before hardening review is complete
  - `docs/operations/RELEASE_RISK_REGISTER.md` ships with the release packet
  - locale incompleteness is disclosed as a known limitation
  - no regression appears in HomeMemory admin privacy coverage
  - `ADMIN_OPERATOR_SECRET` is configured in production environments
