# SPEC — Billing Implementation

## Components
- EntitlementService.
- BillingProviderAdapter.
- ReceiptValidator.
- SubscriptionStateService.
- FeatureGate.
- BillingAuditLog.

## Flow
```text
purchase
→ store billing UI
→ receipt
→ backend validation
→ entitlement update
→ app entitlement refresh
```

## States
```text
free
trial
active
grace
expired
refunded
disabled
```

## Required behavior
- Server validates receipts.
- Client cannot spoof premium.
- Restore purchases works.
- Cancellation/refund updates entitlement.
- Paywall copy matches actual gates.
