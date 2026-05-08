# Monetization Decision

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `10`
Status: `decision documented; implementation still pending`

## Decision

For the Android consumer app, the working commercial model is:

- `Free`
- `Plus`
- `Pro`

If digital premium access is sold inside the Play-distributed Android app, the app should use Google Play Billing for those consumer entitlements.

## Why this is the right boundary

The repo currently contains operational plan and billing surfaces for broader org-level scenarios, including `Family`, `Team`, and `Enterprise`, but the mobile consumer profile requested for Play release is narrower and should stay consumer-facing:

- `Free`
- `Plus`
- `Pro`

That keeps the Play listing simple and avoids mixing consumer mobile plans with internal or org-level admin catalogs.

## What this repo has today

- operational plan and billing metadata in admin and backend
- no Play Billing integration in the Flutter Android app
- no store-backed entitlement source of truth for `Free / Plus / Pro`

## What this means now

Until billing integration exists, any `current plan` control in the mobile profile must be treated as local product state, not as proof of a real purchase.

## Working entitlement posture

### Free

- local-first core shell
- capture
- privacy center
- export and delete
- baseline daily planning

### Plus

- premium AI-assisted routines and deeper review flows
- expanded daily mission value
- richer personalization over time

### Pro

- full premium consumer tier
- highest AI assistance level within consumer scope
- advanced household and long-term organizational features that remain consumer-safe

The exact entitlement table remains a product decision and should not be exposed in Play copy as implemented unless billing and entitlements are live.

## Payment policy rule

If the Android app sells digital upgrades, subscriptions, or in-app premium access, the default implementation path is Google Play Billing.

Do not introduce:

- external checkout prompts inside the Android app
- webview payment flows for digital premium
- claims that billing is live before Play entitlements are wired

## Separation rule

- consumer Play plans: `Free / Plus / Pro`
- org or ops catalog: `Family / Team / Enterprise` may remain admin-facing and must not leak into Play consumer copy

## Remaining work

1. Add Play Billing packages and entitlements in Flutter Android.
2. Define SKU ids for `plus_monthly`, `plus_yearly`, `pro_monthly`, and `pro_yearly` if those offers are chosen.
3. Add backend entitlement verification only after the purchase flow is defined.
4. Align admin billing views with the final consumer catalog if the product wants a single shared plan language.

## Gate decision

- Monetization decision gate: passed
- Billing implementation gate: still blocked
