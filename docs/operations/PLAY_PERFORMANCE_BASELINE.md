# Play Performance Baseline

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `13`
Status: `baseline captured`

## Mobile build baseline

- artifact: `apps/mobile_flutter/build/app/outputs/bundle/release/app-release.aab`
- artifact size: `45,407,189` bytes
- artifact timestamp observed locally: `2026-05-08` after the final reproducible bundle run

## Authoritative local Android bundle command

```powershell
cd apps/mobile_flutter/android
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
.\gradlew.bat bundleRelease
```

## Important build note

In this Windows workspace, `flutter build appbundle --release` can report a false-negative symbol-stripping failure even after Gradle has already produced a valid `.aab`.

For this branch, `gradlew.bat bundleRelease` is the authoritative local release build signal.

## Validation signals captured with this baseline

- `flutter gen-l10n`: green
- `flutter analyze`: green
- `flutter test`: green (`55 passed`)

## What is still missing

- cold-start timing on a real Android device
- frame-time or jank capture on Home, Capture, and Settings
- gateway latency p95 measurement for a release candidate deployment

## Release interpretation

The repo now has a reproducible Android bundle artifact and a size baseline. It does not yet have device-level runtime performance evidence.
