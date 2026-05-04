# F04 Secure Mobile Export Bundle

Date: `2026-05-04`

## Objective

Close the remaining HomeMemory hardening gap:

- store submission assets outside metadata copies
- validate secure storage plus protected export retrieval on real CI runners

## Implementation

- Added a protected submission-asset vault in `apps/mobile_flutter/lib/core/export/submission_asset_vault.dart`.
- HomeMemory submission files now copy into an app-private vault and persist only an internal managed ref in `PurchaseProof.fileRef` and `EvidenceAttachment.fileRef`.
- Added protected export bundling in `apps/mobile_flutter/lib/core/export/local_export_service.dart`.
- Protected exports now write:
  - bundle directory `golife_local_export_<timestamp>`
  - `data.json`
  - `assets/...` copied from the private vault or flagged as legacy metadata refs when the source file is no longer available
- `GoLifeController` now:
  - stores submission assets through the vault
  - emits export metadata with a `submission_assets` manifest
  - clears the vault on delete-all

## Validation

Local validation:

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`

Focused runtime coverage:

- `test/core/export/submission_asset_vault_test.dart`
- `test/core/export/local_export_service_test.dart`
- `test/features/app_state/golife_controller_test.dart`

The controller end-to-end test verifies:

- source files are copied into the protected vault
- stored refs are internal managed refs, not original file paths
- export bundle contains `data.json` plus copied assets
- delete-all clears the protected vault

## Real runner gate

The final runner gate for this block is the existing GitHub Actions `flutter` job in `.github/workflows/ci.yml`.

Expected signal:

- PR branch green on `flutter`
- secure bundle tests pass on `ubuntu-latest`

## Residual limits

- the repo still has no checked-in `android/`, `ios/`, or desktop runner projects, so device-specific export UX remains out of scope here
- legacy metadata refs from older local states are exported as `legacy_metadata_ref` entries and only become bundled when the original source file is still reachable

## Canonical follow-up docs

- [Data map](../compliance/DATA_MAP.md)
- [Privacy review](../compliance/PRIVACY_REVIEW.md)
- [HomeMemory RecallBox MVP](../product/HOMEMEMORY_RECALLBOX_MVP.md)

## Rollback

- revert the branch commit that introduces the vault and bundle exporter
- existing local metadata remains readable because the stored `fileRef` field format is still string-based
