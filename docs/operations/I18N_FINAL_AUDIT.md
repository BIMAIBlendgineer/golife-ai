# I18N Final Audit

Date: `2026-05-04`
Branch: `release/final-premium-production`

## Decision

This release supports only:

- `en`
- `es`

The repo still contains partial or historical locale assets for `pt`, `pt-BR`, `ja`, `zh`, and `zh-Hans`, but they are not release-supported UI locales for the current premium-production scope.

## Runtime alignment

### Mobile

- `apps/mobile_flutter/lib/core/i18n/app_locale.dart` now exposes only `system`, `en`, and `es`
- `supportedAppLocales` is now `en` and `es`
- stored or device locale values outside the release scope normalize back to `en`

### Admin

- `apps/admin_next/lib/i18n.ts` now exposes only `en` and `es` as admin UI locales
- `apps/admin_next/components/locale-switcher.tsx` now renders only `en` and `es`
- historical user records may still contain locale values such as `pt-BR`, `ja`, or `zh-Hans`; that is a data-reporting concern, not a claim that the admin UI is fully localized for those locales

## Evidence reviewed

- `apps/mobile_flutter/lib/l10n/*.arb`
- `apps/mobile_flutter/lib/core/i18n/app_locale.dart`
- `apps/admin_next/lib/i18n.ts`
- `docs/operations/I18N_RELEASE_GAP_REPORT.md`

## Status by locale

| Locale | Status | Release stance |
| --- | --- | --- |
| `en` | complete | supported |
| `es` | release-complete for the current shipped surfaces | supported |
| `pt-BR` | partial | not supported in this release |
| `pt` | partial | not supported in this release |
| `ja` | partial | not supported in this release |
| `zh` | partial | not supported in this release |
| `zh-Hans` | partial | not supported in this release |

## Why this is the correct release boundary

- it keeps the runtime aligned with verified coverage instead of aspirational coverage
- it avoids shipping a picker that suggests parity where parity does not exist
- it preserves existing translation assets for future completion without treating them as production-ready today

## Commands used

```bash
cd apps/mobile_flutter
flutter gen-l10n
flutter analyze
flutter test

cd ../admin_next
npm run lint
npm run typecheck
npm run build
```

## Residual limits

- non-release locale assets remain in the repo for future completion work
- user data and telemetry can still refer to older locale values from historical usage
- device-specific locale QA remains bounded by the current Flutter runner and CI setup
