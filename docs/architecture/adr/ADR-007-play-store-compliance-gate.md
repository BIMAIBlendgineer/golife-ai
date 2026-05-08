# ADR-007: Play Store compliance gate before Android publication

Date: `2026-05-08`
Status: `accepted`

## Context

The repository is strong at repo-level quality gates, but Google Play publication requires additional external compliance work that does not exist inside the current release scope.

Key repo facts on `2026-05-08`:

- `apps/mobile_flutter/README.md` states platform runners are missing
- release locale scope is explicitly limited to `en` and `es`
- privacy and safety documentation is strong, but Play-facing declarations are not completed
- there is no Play Billing implementation for digital premium access

At the same time, official Google documentation now requires:

- Android App Bundle publication for new apps
- current target API compliance
- Data safety completion and a public privacy-policy URL
- Play-compliant treatment of digital purchases
- additional declaration work for AI, health, and possibly finance-adjacent features

## Decision

Treat Play Store readiness as a hard external gate, separate from repo-local premium-production readiness.

No publication claim should be made until all of the following are complete:

- Android runner and AAB path
- target API compliance
- signing setup
- Play Data safety and privacy artifacts
- billing-policy decision and implementation where required
- Android-device QA
- locale-scope alignment with the actual runtime

## Consequences

Positive:

- avoids confusing repo-local quality with store-ready compliance
- keeps business, legal, and Android-release work visible
- prevents premature claims about billing, locale support, or device validation

Negative:

- adds a new gate outside CI
- requires manual Play Console work that cannot be fully proven from git alone
- slows publication until policy and store decisions are explicit

## Alternatives considered

### Treat current release state as enough for Play submission

Rejected.

Why:

- there is no Android runner
- there is no AAB path
- there is no Play Billing path
- store declarations are incomplete

### Solve Play readiness only with documentation

Rejected.

Why:

- AAB, signing, billing, and Android QA require code and build work

## Follow-up

- `docs/operations/PLAY_STORE_READINESS.md` is the operating checklist for this ADR
- Android runner and signing work close the technical side of the gate
- Data safety, policy declarations, billing, and store copy close the Play-side of the gate
