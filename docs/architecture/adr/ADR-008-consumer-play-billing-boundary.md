# ADR-008 Consumer Play Billing Boundary

## Status

Accepted for the Play-readiness branch.

## Context

The repo already contains operational plan and billing concepts beyond the consumer mobile app, but the Play Store release must present a clear and policy-safe consumer purchase boundary.

The user-requested mobile profile also expects a current-plan field with:

- `Free`
- `Plus`
- `Pro`

## Decision

For the Play-distributed Android consumer app:

- the consumer plan catalog is `Free / Plus / Pro`
- if digital premium access is sold in-app, the purchase flow must use Google Play Billing
- org-oriented catalogs such as `Family`, `Team`, and `Enterprise` stay outside the Play consumer boundary

## Consequences

### Positive

- keeps the Android listing simple
- avoids mixing consumer and enterprise messaging
- aligns better with Google Play payment rules for digital premium access

### Negative

- introduces a temporary mismatch with existing admin operational catalogs
- requires a later entitlement source of truth before the mobile `current plan` field can reflect real purchases

## Implementation notes

- before Play Billing is live, a mobile current-plan selector is product state only
- do not claim active paid entitlements in store copy until billing is implemented
- do not route digital premium payment through external checkout from the Android app unless a clearly documented policy exception is verified
