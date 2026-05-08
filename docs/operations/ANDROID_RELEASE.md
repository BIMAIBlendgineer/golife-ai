# Android Release Notes

Date: `2026-05-08`
Branch: `release/play-store-readiness`

## Current Android identity

- package / application id: `ai.golife.mobile`
- app label: `GoLife AI`
- source runner path: `apps/mobile_flutter/android`

## Signing model

Current repo behavior:

- `android/key.properties` is external and ignored by git
- `android/key.properties.example` documents the expected fields
- release builds fall back to debug signing only when no external upload key is configured

This means:

- local release bundles remain buildable without committing secrets
- Play-uploadable signing still requires an external upload key and Play App Signing enrollment

## Artifact path

Current release bundle output:

- `apps/mobile_flutter/build/app/outputs/bundle/release/app-release.aab`

## Verified local commands

```powershell
cd apps/mobile_flutter
flutter pub get
flutter gen-l10n
flutter analyze
flutter test

cd android
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
.\gradlew.bat bundleRelease
```

## Tooling note for this Windows workspace

In this environment, `flutter build appbundle --release` can emit a false-negative symbol-stripping failure after Gradle has already produced a valid AAB.

Observed state on `2026-05-08`:

- direct Gradle `bundleRelease`: success
- output AAB exists at the expected path
- local PowerShell invocation needs `JAVA_HOME` set to the Android Studio bundled JBR
- Flutter wrapper command may still report failure text after the artifact is created

Until the local Flutter/Gradle wrapper behavior is normalized, use `gradlew.bat bundleRelease` as the authoritative local AAB gate in this workspace.
