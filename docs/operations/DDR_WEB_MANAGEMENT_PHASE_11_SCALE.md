# DDR — Phase 11 Scale

## Delivery decision
- Prefer pagination and bounded slices over exhaustive admin dumps.
- Derived aggregates may still paginate after summarization when source cardinality is small.
