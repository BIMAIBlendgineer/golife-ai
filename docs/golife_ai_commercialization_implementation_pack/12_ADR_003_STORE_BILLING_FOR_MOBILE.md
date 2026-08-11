# ADR-003 — Store Billing for Mobile

## Decision
Use native app store billing for mobile digital subscriptions where required.

## Implementation
- iOS: App Store In-App Purchase.
- Android: Google Play Billing.
- RevenueCat optional.
- Stripe only for web/B2B where allowed.

## Acceptance
- receipt validation;
- restore purchases;
- cancellation/refund handling.
