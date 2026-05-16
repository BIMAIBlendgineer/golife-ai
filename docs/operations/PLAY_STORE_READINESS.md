# Play Store Readiness

Date checked: `2026-05-08`
Branch: `release/play-store-readiness`
Scope: Google Play publication gate for `apps/mobile_flutter`

## Update on 2026-05-16

Repo state has moved since the original audit:

- repo-hosted public privacy policy, terms, and support pages now exist
- the Privacy screen now exposes public legal links in-app
- `flutter build appbundle --debug` now succeeds locally
- Android runner QA is still blocked by missing device/emulator evidence
- screenshot capture and Play Console declarations remain manual closeout items
- billing remains disabled in the current runtime baseline

## Decision

Current decision: `blocked`

This repository is not ready for Google Play publication yet.

The main blockers are:

- no verified Play Console package identity or developer verification state
- no public privacy-policy URL
- no Play Billing implementation for digital premium access
- no Android-device QA evidence
- no device-level accessibility evidence
- no final in-app public policy link
- no Play Console declarations completed by a human operator
- no completed Data safety form or public privacy-policy URL

## Official sources checked on 2026-05-08

These were reviewed from Google-owned documentation during this phase:

- Data safety form:
  - https://support.google.com/googleplay/android-developer/answer/10787469
- User data and privacy-policy requirements:
  - https://support.google.com/googleplay/android-developer/answer/10144311
- App account deletion requirement:
  - https://support.google.com/googleplay/android-developer/answer/13327111
- Play app signing:
  - https://support.google.com/googleplay/android-developer/answer/9842756/use-play-app-signing
- Target API requirement:
  - https://support.google.com/googleplay/android-developer/answer/11926878
- Android App Bundle requirement:
  - https://support.google.com/googleplay/android-developer/answer/9844279/inspect-app-versions-with-the-app-bundle-explorer
- Sensitive permissions and storage access policy:
  - https://support.google.com/googleplay/android-developer/answer/16558241
- AI-generated content policy:
  - https://support.google.com/googleplay/android-developer/answer/13985936
- Payments policy:
  - https://support.google.com/googleplay/android-developer/answer/9858738
  - https://support.google.com/googleplay/android-developer/answer/10281818
- Play Billing integration:
  - https://developer.android.com/google/play/billing/integrate
- Health apps declaration:
  - https://support.google.com/googleplay/android-developer/answer/14738291
  - https://support.google.com/googleplay/android-developer/answer/12261419
- Financial-features declaration:
  - https://support.google.com/googleplay/android-developer/answer/13849271
  - https://support.google.com/googleplay/android-developer/answer/16322411
- Play Console verification requirements:
  - https://support.google.com/googleplay/android-developer/answer/10841920
  - https://support.google.com/googleplay/android-developer/answer/10788890

## Repo evidence snapshot

- Mobile runtime exists in `apps/mobile_flutter`
- checked-in Android runner exists and release bundle path is documented
- `apps/mobile_flutter/pubspec.yaml` declares a Flutter package with local storage, secure storage, HTTP, and localization support
- `docs/compliance/DATA_MAP.md` and `docs/compliance/PRIVACY_REVIEW.md` provide strong raw material for Data safety and privacy disclosures
- `docs/security/SAFETY_POLICY.md` documents centralized safety policy and explicit product limits
- `docs/product/STORE_METADATA.md` contains early positioning and copy inputs
- `docs/operations/PLAY_I18N_PROFILE_AUDIT.md` documents the requested 10-locale mobile runtime and profile preferences

## Compliance gate table

| Requirement | Official source status | Repo evidence | Current state | Action to close |
| --- | --- | --- | --- | --- |
| New apps must publish as Android App Bundle | verified | Android runner exists and `.aab` build path is documented | ready in repo | keep bundle build green and produce signed artifact for upload |
| New apps and updates must target Android 15 / API 35 as of the policy now in effect after `2025-08-31` | verified | Android Gradle config exists in repo | validate before submission | confirm final target and successful release build before upload |
| Play app signing and upload-key flow must be configured | verified | signing placeholders and release instructions exist | partially closed | connect the real upload key outside the repo |
| Every Play app must complete Data safety and provide a privacy-policy URL | verified | `DATA_MAP.md` and `PRIVACY_REVIEW.md` exist, but no public URL is configured | blocked | publish public privacy page and complete Play form |
| Privacy policy must also be visible in-app or in-app text/link | verified | privacy screen exists, but no public-policy link is exposed | blocked | add visible policy link in the mobile settings/privacy surface |
| If the app lets users create accounts, it must provide an in-app deletion path and associated data deletion path | verified | current mobile runtime is local-first and shows no end-user sign-up or login surface | conditional | keep out of scope unless account creation is introduced for sync or subscriptions |
| Only necessary sensitive permissions may be requested, and broad file access is highly restricted | verified | Android manifest now exists and must stay minimal | review pending | validate final manifest and remove anything non-essential before submission |
| AI-generated apps must prevent restricted content and provide in-app reporting/flagging for offensive AI output | verified | safety engine exists, mission feedback exists, and claims review is documented | repo-closed | keep mission feedback visible in the shipped build and verify the final support path in Play metadata |
| Digital premium features sold in-app must use Google Play billing unless a policy exception clearly applies | verified | no Play Billing implementation exists | blocked | decide premium SKU model, then integrate Play Billing for digital entitlements |
| Health apps declaration must be completed in Play Console for published apps | verified | repo contains habits, recovery, journal, and reflection surfaces, but no declaration answer set exists | blocked | complete declaration and keep store copy away from clinical positioning |
| Financial-features declaration may be required if the shipped scope is interpreted as financial-product functionality | verified | repo contains expense tracking, finance reflections, and money-domain UI | manual review required | decide whether current scope triggers the declaration and prepare exact answers |
| Play Console developer verification and store-contact data must be complete | verified | repo has placeholder support emails only | blocked | verify Play Console account, legal entity, support email, phone, and public contact data |

## Store-claim boundaries for this release

Do not market the current app as:

- OIDC/SSO-ready business identity software
- a medical or clinical tool
- regulated-finance recommendation software
- juridical-counsel software
- an outcome-promising assistant

Safe current positioning:

- local-first daily decision system
- capture -> mission -> action -> feedback
- privacy controls before AI
- small practical daily actions

## Billing decision boundary

The current product scope is a digital app with digital premium behavior.

Unless a clearly documented policy exception applies in the target market, premium access inside the Android app should be implemented through Google Play billing, not through a custom external checkout flow.

This is a release blocker because:

- the repo currently has no Play Billing code
- the consumer plan boundary is now documented as `Free / Plus / Pro`
- the mobile current-plan field is local product state until real entitlements exist

## Data-safety draft from repo evidence

This is not the final Play Console form. It is the repo-derived baseline for Phase 6.

Likely declarations to prepare:

- user-generated content:
  - local life events, journal, quick notes, tasks, habits, pantry, calendar, recipes, HomeMemory records
- app activity:
  - mission feedback and usage metadata
- files and docs:
  - protected submission assets and local export bundles
- financial info:
  - expense records, if the shipped money domain remains active
- data shared off-device only by allowed flow:
  - filtered event summaries to AI Gateway
  - operational metadata to backend/admin

Open declaration questions:

- whether expense records must be declared under finance-only categories in Play Console
- whether any HomeMemory file flow should be declared as photos/files if an Android picker or camera is added later
- whether current reflection and recovery framing causes the app to be categorized under health-related declarations beyond the always-required health form

## Locale rollout gate for the requested 10 languages

Requested release languages:

- `en`
- `es`
- `pt-BR`
- `pt-PT`
- `fr`
- `it`
- `de`
- `ja`
- `zh-Hans`
- `zh-Hant`

Current repo reality on `2026-05-08`:

- mobile runtime now exposes the requested 10-language locale set
- all locale files now have full key coverage and the profile/settings surface is translated across the shipped locale set
- some deeper domain copy still mirrors English on secondary non-English surfaces pending human language polish
- admin runtime is still scoped to `en` and `es`

Conclusion:

- the 10-language rollout is now implemented in the mobile runtime
- release copy and manual language QA should still catch up to the new locale scope before store screenshots

## Profile preferences requested for the shipped app

These are reasonable profile/settings targets for the Android release:

1. language
2. theme: light / dark / system
3. notifications
4. quiet hours
5. measurement units: metric / imperial
6. region / country
7. reminder frequency
8. AI response style: brief / detailed
9. backup and sync
10. privacy controls: export / delete data / AI history
11. current plan: Free / Plus / Pro

Repo reality today:

- the mobile settings surface now persists the requested profile preferences locally
- privacy export/delete exists
- clear AI history now exists as a separate local control
- real billing-backed current-plan entitlements still do not exist

## Human decisions still required

- choose final app package id
- choose verified legal entity and store support contacts
- confirm whether the shipped scope includes finance features that require a declaration
- confirm whether the shipped scope will be positioned as a health-related app
- choose monetization model and entitlement mapping for Free / Plus / Pro
- decide whether backup and sync will exist before launch or remain out of scope
- decide whether the first Play launch accepts English fallback on secondary non-English domain surfaces or waits for deeper copy localization

## Exit criteria for the Play gate

This document can move from `blocked` to `ready for submission prep` only when all of the following are true:

- Android runner exists and AAB builds
- target API is compliant
- signing is configured without secrets in repo
- Data safety answers are documented and entered in Play Console
- public privacy-policy URL exists
- billing decision is closed and implemented if digital premium access is sold in-app
- AI-output reporting path is explicit
- Android-device QA evidence exists
- locale scope is updated to match the actual shipped runtime
- device accessibility validation exists

## Next phase

Recommended next phase: final QA, final Play Console declarations, and release closeout.
