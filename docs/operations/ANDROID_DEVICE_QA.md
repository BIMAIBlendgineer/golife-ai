# Android Device QA

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `5`
Status: `blocked in current workstation`

## Goal

Record the Android smoke validation that must happen before Play submission and document the exact local blocker found during this phase.

## Commands attempted

```powershell
cd apps/mobile_flutter
flutter devices
adb devices
flutter emulators
flutter emulators --create --name golife_api35
```

## Observed result

- `flutter devices` returned only Windows desktop plus browser targets.
- `adb devices` returned no attached Android devices.
- `flutter emulators` returned no configured Android emulators.
- `flutter emulators --create --name golife_api35` failed because `avdmanager` is missing from the installed Android SDK command-line tools.

## What this means

- The repo is now capable of producing an Android App Bundle locally.
- The current machine cannot complete runner-level QA because there is no attached device and no working Android Virtual Device creation path.
- This is an environment blocker, not a repo-code blocker.

## Critical flows still required on a real device or emulator

1. First launch and shell navigation.
2. Home Today renders missions and gateway state cleanly.
3. Capture accepts freeform text and saves drafts.
4. Privacy center opens and persists preferences.
5. Protected local export writes `data.json` plus `assets/`.
6. Delete-all clears local state and vault contents.
7. Offline or degraded gateway state remains visible.
8. Non-English locale switching works across the supported 10-language set.
9. Theme switching works across `system`, `light`, and `dark`.
10. TalkBack or equivalent screen reader reaches critical controls.

## Required evidence for unblock

- device model or emulator API level
- install method used
- pass or fail for each critical flow
- screenshots for Home, Capture, Preferences, Export, and Delete
- any `adb logcat` excerpt for failures

## Recommended unblock actions

1. Install Android SDK command-line tools including `avdmanager` and `sdkmanager`.
2. Create at least one emulator at a current Play-supported API level.
3. Or attach a physical Android device with USB debugging enabled.
4. Re-run the smoke list above and attach evidence to this document.

## Gate decision

- Android QA gate: not passed yet
- Release documentation gate: passed, because the blocker is explicit and reproducible
- Play submission gate: still blocked until this document contains device evidence
