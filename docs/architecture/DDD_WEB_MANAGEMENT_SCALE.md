# DDD — Web Management Scale

## Aggregate
- `ScaleOps`

## Rules
- Large admin surfaces use `limit` and `offset`.
- Reasonable defaults and max limit enforced.
- Avoid unbounded list rendering in operational routes.
- Add indices where backend queries are most likely to grow.
