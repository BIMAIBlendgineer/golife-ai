# ADR-001 — Use LifeGraph as the Core Model

## Status

Accepted.

## Decision

Represent user life data as events in a LifeGraph instead of isolated module tables only.

## Consequences

Positive:

- modules can interoperate;
- AI can reason across domains;
- future integrations are easier.

Negative:

- requires clear schemas;
- event retrieval must be carefully designed.
