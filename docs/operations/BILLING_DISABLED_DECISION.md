# Billing Disabled Decision

## Decision

Store billing remains disabled for this release slice.

## Reason

The current commercialization branch adds entitlement contracts and release gates, but it does not yet implement:

- runtime purchase restore;
- refund and cancel state handling;
- receipt validation workflow;
- end-to-end paywall behavior tied to verified entitlements.

## Release rule

Do not enable mobile billing or paywall enforcement until restore purchases and renewal-state handling are implemented and tested.

## Scope note

Export and delete must remain available regardless of plan state.
