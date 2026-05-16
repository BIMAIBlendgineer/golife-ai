# Billing Sandbox Decision

## Decision

This release enables **Google Play Billing sandbox only** for internal Android testing.

## What is enabled

- Google Play catalog loading on Android when the device store is available
- sandbox purchase start
- sandbox restore purchases
- backend validation endpoint for Google Play sandbox tokens
- local entitlement activation only after backend verification succeeds

## What remains disabled

- production purchases
- App Store IAP
- Stripe or external checkout
- receipt validation for production go-live
- subscription activation claims in public store copy
- refund or cancel automation

## Release rules

- do not market billing as production-ready
- do not activate premium without backend verification
- keep export and delete available regardless of plan state
- keep `productionPurchasesEnabled = false` in the runtime artifact until the live billing slice is explicitly approved

## Evidence boundary

The current repo baseline supports Android sandbox verification and local entitlement enforcement, but it is still **not** a production billing closeout.
