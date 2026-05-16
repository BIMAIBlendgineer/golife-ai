# Store Submission Packet

Date: `2026-05-16`
Branch baseline: `main@9b6fd3f`
Status: `manual closeout required`

## Scope

This packet documents the repo-verifiable store, legal, and disclosure material for the current GoLife AI release scope.

Current release scope:

- local-first daily decision system
- privacy-bounded AI
- three actionable daily missions
- metadata-only analytics
- EN/ES release scope
- no billing runtime

## Public legal URLs

- Privacy policy:
  - `https://github.com/BIMAIBlendgineer/golife-ai/blob/main/docs/legal/PRIVACY_POLICY.md`
- Terms of service:
  - `https://github.com/BIMAIBlendgineer/golife-ai/blob/main/docs/legal/TERMS_OF_SERVICE.md`
- Support URL:
  - `https://github.com/BIMAIBlendgineer/golife-ai/blob/main/docs/legal/SUPPORT.md`

These links are also exposed inside the app at:

- `Settings -> Privacy -> Store and legal`

## Store metadata sources

- core listing copy:
  - `docs/product/STORE_METADATA.md`
- copy lint config:
  - `scripts/release/store_copy_lint_config.json`
- release artifact:
  - `docs/operations/release_artifacts/commercial_premium_release_artifact.json`

## Privacy and disclosure sources

- privacy policy:
  - `docs/legal/PRIVACY_POLICY.md`
- terms:
  - `docs/legal/TERMS_OF_SERVICE.md`
- support:
  - `docs/legal/SUPPORT.md`
- data map:
  - `docs/compliance/DATA_MAP.md`
- privacy review:
  - `docs/compliance/PRIVACY_REVIEW.md`
- Play data safety mapping:
  - `docs/operations/PLAY_DATA_SAFETY_MAPPING.md`

## Deletion and export disclosure

The current runtime exposes:

- protected local export
- delete all local data
- clear AI history
- domain-level privacy controls
- event-level privacy controls

The app remains local-first and does not require a user account for the current scope.

## Billing status

Billing remains disabled in this baseline.

Reference:

- `docs/operations/BILLING_DISABLED_DECISION.md`

No store listing or legal copy should imply an active subscription purchase flow in the current release.

## Screenshot and visual assets

Current screenshot inventory and capture plan:

- `docs/operations/STORE_SCREENSHOT_CHECKLIST.md`

This remains a manual closeout item because store screenshots must be captured from a real release-like mobile runner.

## Device QA evidence

Current Android runner evidence:

- `docs/operations/DEVICE_QA_CLOSEOUT.md`

This packet does not claim Android device QA passed. It documents the verified bundle build plus the remaining manual runner blocker.

## Remaining manual closeout items

- capture final store screenshots from a real Android runner
- complete Play Console verification and operator contact details
- complete runner-level Android QA on device or emulator
- submit human-reviewed privacy and data safety forms in the target store consoles
