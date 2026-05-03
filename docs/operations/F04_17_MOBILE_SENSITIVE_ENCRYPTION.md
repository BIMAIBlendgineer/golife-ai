# F04_17 Mobile Sensitive Encryption Expansion

## Phase

- Roadmap phase: F10 persistence/privacy continuation
- Branch: `hardening/traceability-safety-pass`
- Date: 2026-05-03

## Objective

Close the previously documented at-rest privacy gap for mobile collections that were still persisted as plaintext JSON blobs.

## Scope

- `apps/mobile_flutter/lib/core/storage/sqlite_local_store.dart`
- `apps/mobile_flutter/lib/core/i18n/app_localized_values.dart`
- `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`
- `apps/mobile_flutter/test/core/storage/sqlite_local_store_test.dart`
- `apps/mobile_flutter/test/features/app_state/golife_controller_test.dart`

## Changes

- Switched SQLite persistence for these mobile collections from plaintext JSON to `SensitiveDataCipher` encryption:
  - `life_events`
  - `missions`
  - `daily_risks`
  - `calendar_items`
- Extended the legacy sensitive-row migration so existing plaintext rows in those tables are re-encrypted on upgrade.
- Updated local export metadata so `encrypted_collections` now reports the expanded protection set.
- Updated privacy UI collection labels to reflect the wider encrypted set.

## Verification

Executed local gates:

- `cd apps/mobile_flutter`
- `flutter analyze`
  - Result: pass
- `flutter test test/core/storage/sqlite_local_store_test.dart`
  - Result: `10 passed`
- `flutter test test/features/app_state/golife_controller_test.dart`
  - Result: `6 passed`

## Risks

- This closes the specific plaintext-blob gap for `life_events`, `missions`, `daily_risks`, and `calendar_items`.
- Device-level secure-storage behavior still requires platform validation on Android, iOS, and desktop targets before broader release claims.
- Some UI collection labels remain English-first in non-English locales pending the broader localization sweep.

## Rollback

- Revert the mobile-encryption commit or restore the touched mobile files.
