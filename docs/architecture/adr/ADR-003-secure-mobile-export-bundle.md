# ADR-003 Secure Mobile Export Bundle

- Status: `accepted`, `implemented`
- Date: `2026-05-04`

## Context

HomeMemory needed to preserve proof and evidence assets in a way that survives local export and delete cycles. Persisting only external metadata refs was not enough for a premium local-first recall surface.

The product thesis required:

- sensitive assets stay local
- exports remain recoverable
- exported JSON must not expose raw device paths as the canonical storage model

## Evidence

- [F04 secure mobile export bundle](../../operations/F04_16_SECURE_MOBILE_EXPORT_BUNDLE.md)
- merged PR `#10`
- files:
  - `apps/mobile_flutter/lib/core/export/submission_asset_vault.dart`
  - `apps/mobile_flutter/lib/core/export/local_export_service.dart`
  - `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`

## Decision

Submission assets are stored in an app-private vault and exported through a protected bundle.

Implemented behavior:

- source files are copied into a private vault
- entity blobs keep only internal managed refs
- protected export writes `data.json + assets/`
- `deleteAllLocalData()` clears the vault as part of the local wipe

## Alternatives Considered

- Keep external file paths only:
  - rejected because exported state could become unrecoverable
- Inline binary assets into the JSON export:
  - rejected because it would bloat exports and weaken separation of metadata vs files
- Upload assets to backend for export:
  - rejected because HomeMemory remains local-first in this RC

## Consequences Positive

- local export is materially recoverable
- internal refs replace fragile external device paths
- the privacy boundary stays device-local

## Consequences Negative

- device-specific retrieval UX is still not fully validated without platform runners
- older legacy metadata refs need compatibility handling

## Residual Risks

- checked-in Android, iOS, or desktop runners still do not exist in this repo
- legacy metadata refs remain a compatibility case instead of the preferred storage path

## Affected Files

- `apps/mobile_flutter/lib/core/export/submission_asset_vault.dart`
- `apps/mobile_flutter/lib/core/export/local_export_service.dart`
- `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`
- `apps/mobile_flutter/test/core/export/submission_asset_vault_test.dart`
- `apps/mobile_flutter/test/core/export/local_export_service_test.dart`
- `apps/mobile_flutter/test/features/app_state/golife_controller_test.dart`

## Tests And Gates

- `cd apps/mobile_flutter && flutter analyze`
- `cd apps/mobile_flutter && flutter test`
- GitHub Actions `flutter`
- `gitleaks git`

## Reversibility

Reversible by reverting the vault and export-bundle implementation, but that would reintroduce the weaker metadata-only asset story and reopen the export recoverability gap.
