# Integration HomeMemory Premium Web

## Scope

- Final branch: `integration/homememory-premium-web`
- Target branch: `main`
- Integrated branches:
  - `origin/codex/homememory-recallbox-mvp`
  - `origin/codex/premium-web-management`
  - `origin/rescue/local-wip-premium-web-2026-05-03`

## Integrated commits

- `main` base at validation start: `35bbe5335c75c032aec99b27a22b9cbdfaaa4cdd`
- PR #3 head: `3bc9c3d782902b6fbc49abed442b77164e96a9b7`
- PR #3 existing merge on integration branch: `34660732dbce30e0a44c3e3dbfd532b3ed1d00c2`
- PR #4 head: `4a3190967335c77a027f0cd86f48173c85e719fa`
- Rescue head: `494c13f53fb4972586b7b2fa18e13fce690e446d`

## Merge results

- PR #3 was already present on `integration/homememory-premium-web` as a clean merge from `main`.
- PR #4 merged cleanly with no manual conflict resolution required.
- Rescue required manual conflict resolution in mobile storage and tests.

## Conflicts found

- `apps/mobile_flutter/lib/core/storage/local_store.dart`
- `apps/mobile_flutter/lib/core/storage/memory_local_store.dart`
- `apps/mobile_flutter/lib/core/storage/resilient_local_store.dart`
- `apps/mobile_flutter/lib/core/storage/shared_prefs_local_store.dart`
- `apps/mobile_flutter/lib/core/storage/sqlite_local_store.dart`
- `apps/mobile_flutter/test/core/storage/sqlite_local_store_test.dart`
- `apps/mobile_flutter/test/features/app_state/golife_controller_test.dart`

## Conflict resolution

- Preserved HomeMemory storage contracts and persistence APIs from PR #3.
- Preserved rescue delete-by-id storage APIs for task, expense, pantry, journal, calendar, and recipe entities.
- Combined both behaviors in all storage implementations instead of picking one side.
- Kept HomeMemory encryption coverage tests and added rescue delete-path tests in the same suites.
- Fixed one merge-resolution regression in `sqlite_local_store_test.dart` where `databasePath` was accidentally redeclared.
- Kept `docs/adrs/ADR-000-initial-audit.md` from rescue and retained existing `docs/decisions/*` from premium web. No folder consolidation was done in this integration to avoid mixing separate documentation taxonomies without an ADR.

## Sensitive-data guardrails verified

- `services/web_backend/app/schemas.py` keeps `HomeMemorySummary.sensitive_data_excluded = True`.
- `services/web_backend/app/main.py` exposes only aggregate HomeMemory admin endpoints:
  - `GET /admin/homememory/summary`
  - `GET /admin/homememory/parser-usage`
- `apps/admin_next/app/homememory/page.tsx` renders only counts, rates, locale distribution, and encrypted collection metadata.
- `services/web_backend/tests/test_admin_api.py` asserts HomeMemory admin responses remain aggregate-only.

## Critical files modified

- Backend:
  - `services/web_backend/app/main.py`
  - `services/web_backend/app/repository.py`
  - `services/web_backend/app/schemas.py`
  - `services/web_backend/tests/test_admin_api.py`
- Admin:
  - `apps/admin_next/app/homememory/page.tsx`
  - `apps/admin_next/lib/api.ts`
  - `apps/admin_next/lib/types.ts`
- Mobile:
  - `apps/mobile_flutter/lib/core/storage/local_store.dart`
  - `apps/mobile_flutter/lib/core/storage/memory_local_store.dart`
  - `apps/mobile_flutter/lib/core/storage/resilient_local_store.dart`
  - `apps/mobile_flutter/lib/core/storage/shared_prefs_local_store.dart`
  - `apps/mobile_flutter/lib/core/storage/sqlite_local_store.dart`
  - `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`
  - `apps/mobile_flutter/lib/features/domains/domain_screens.dart`
  - `apps/mobile_flutter/test/core/storage/sqlite_local_store_test.dart`
  - `apps/mobile_flutter/test/features/app_state/golife_controller_test.dart`
- Docs:
  - `docs/admin/*`
  - `docs/operations/*`
  - `docs/security/*`
  - `docs/DesignUI/*`
  - `docs/adrs/ADR-000-initial-audit.md`
  - `docs/commands.md`
  - `docs/production-audit.md`

## Validations executed

- PR #3 partial:
  - `flutter pub get`
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test`
  - `python -m pytest -q` in `services/web_backend`
  - `python -m pytest -q` in `services/ai_gateway`
- PR #4 partial:
  - `npm ci`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
  - `npm audit --omit=dev --audit-level=high`
  - `python -m pytest -q` in `services/web_backend`
  - `python -m pytest -q` in `services/ai_gateway`
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test`
- Final full-stack:
  - `flutter pub get`
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test`
  - `npm ci`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
  - `npm audit --omit=dev --audit-level=high`
  - `python -m pytest -q` in `services/web_backend`
  - `python -m pytest -q` in `services/ai_gateway`
  - `gitleaks git`
  - repository-wide secret keyword scan via `rg`

## Validations passed

- Mobile final:
  - `flutter pub get`: passed, with upstream advisory decoding warnings from `pub.dev`
  - `flutter gen-l10n`: passed
  - `flutter analyze`: passed
  - `flutter test`: passed (`44` tests)
- Admin final:
  - `npm ci`: passed
  - `npm run lint`: passed
  - `npm run typecheck`: passed
  - `npm run build`: passed
  - `npm audit --omit=dev --audit-level=high`: passed
- Backend final:
  - `python -m pytest -q`: passed (`21` tests)
- AI gateway final:
  - `python -m pytest -q`: passed (`55` tests)
- Security final:
  - `gitleaks git`: passed, no leaks found

## Validations failed

- During rescue conflict resolution, one intermediate `flutter analyze` run failed because `sqlite_local_store_test.dart` redeclared `databasePath`.
- The issue was fixed immediately and the subsequent final mobile validation passed.

## Timeouts

- No command timed out.
- `services/ai_gateway` test suite is materially slower than the rest of the stack and took roughly 12 minutes in repeated runs.

## Security scan notes

- The keyword scan reported example tokens and configuration placeholders in `.env.example`, README, workflow, and documentation files.
- No active secret leak was detected by `gitleaks`.

## Remaining risks

- `npm audit --omit=dev --audit-level=high` still reports moderate transitive `postcss` issues under `next`, but nothing at `high` or above.
- Flutter localization files still report untranslated strings for `es`, `ja`, `pt`, `pt_BR`, `zh`, and `zh_Hans`.
- `services/ai_gateway` emits Python 3.14 compatibility warnings through third-party dependencies (`langchain_core` Pydantic v1 path, FastAPI coroutine deprecation path).

## Rollback

If the branch must be discarded after push:

```bash
git push origin --delete integration/homememory-premium-web
git switch main
git branch -D integration/homememory-premium-web
```

If a future local re-run must restart from scratch before push:

```bash
git merge --abort
git switch main
git branch -D integration/homememory-premium-web
```

## Recommendation

- Create one final PR from `integration/homememory-premium-web` to `main`.
- Once that PR exists and is accepted as the canonical integration branch, close PR #3 and PR #4 as replaced by the unified integration PR.
