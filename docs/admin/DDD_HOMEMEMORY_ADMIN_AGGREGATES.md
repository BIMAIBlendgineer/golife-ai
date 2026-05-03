# DDD — HomeMemory Admin Aggregates

## Aggregate
- `HomeMemoryAggregateOps`

## Rules
- Admin sees aggregate metadata only.
- Forbidden in admin: item names, receipt text, serial numbers, file references, claim bodies.
- Aggregate-safe telemetry only.
- Compatible with `main` even if HomeMemory mobile schema is not merged yet.

## Scope
- Proof parse volume
- Warranty reminder count
- Claim draft count
- Evidence attachment count
- Locale distribution
- Parser fallback/success posture
- Encryption/storage posture when available
