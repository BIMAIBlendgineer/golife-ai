# ADR-005 Mission Ranking And Learning

- Status: `planned`
- Date: `2026-05-04`

## Context

GoLife AI already generates daily missions and already persists a bounded feedback-backed mission memory. That is useful, but it is not yet enough to justify the stronger premium claim that the system prioritizes the right action for today with explicit ranking logic.

The product thesis requires:

- missions to be ranked, not only generated
- ranking to be explainable
- privacy-filtered evidence to influence priority
- feedback and memory to improve ranking over time

## Current evidence

- [Persisted mission memory closeout](../../operations/F04_27_PERSISTED_MISSION_MEMORY.md)
- `services/ai_gateway/app/graphs/golife_graph.py`
- `services/ai_gateway/app/feedback_store.py`
- `docs/product/PRODUCT_STATUS.md`

## Decision

Introduce an explicit deterministic mission-ranker layer on top of suggestion generation.

Target scoring dimensions:

- impact
- urgency
- effort
- confidence
- privacy fit
- feedback fit
- novelty

Target outputs:

- `final_score`
- visible ranking reason
- evidence references
- per-mission score breakdown suitable for trace and UI display

## Alternatives considered

- Keep using only LLM ordering:
  - rejected because ranking would be opaque and harder to test
- Keep only the current heuristic confidence bumping:
  - rejected because it is too weak for the premium claim
- Train an external model immediately:
  - rejected because privacy-safe deterministic ranking should come first

## Consequences positive

- the user can see why a mission is first today
- ranking can be tested deterministically
- feedback can improve prioritization without pretending the model has hidden user memory

## Consequences negative

- scoring weights will need iterative tuning
- UI needs a compact explanation surface
- evidence and privacy boundaries must be enforced carefully in ranking inputs

## Residual risks

- the current persisted mission memory is still feedback-pattern based, not deep evidence memory
- overfitting simple weights to a few scenarios is possible without an offline evaluation corpus

## Affected files

Expected affected surfaces:

- `services/ai_gateway/app/graphs/*`
- `services/ai_gateway/app/use_cases.py`
- `services/ai_gateway/app/schemas.py`
- `services/ai_gateway/tests/*`
- `apps/mobile_flutter/lib/features/dashboard/*`
- `apps/mobile_flutter/test/*`

## Tests and gates

Required before this ADR becomes `accepted`:

- `cd services/ai_gateway && python -m pytest -q`
- `cd apps/mobile_flutter && flutter analyze`
- `cd apps/mobile_flutter && flutter test`
- offline ranking fixture coverage

## Reversibility

This ADR is still planned. If the ranker design proves too coupled or too opaque, the repo should keep the current simpler ranking layer until a better deterministic design is ready.
