# ADR-005 Mission Ranking And Learning

- Status: `accepted`
- Date: `2026-05-04`

## Context

GoLife AI already generated daily missions and already persisted a bounded feedback-backed mission memory. That was useful, but it was not enough to justify the stronger premium claim that the system prioritizes the right action for today with explicit ranking logic.

The product thesis requires:

- missions to be ranked, not only generated
- ranking to be explainable
- privacy-filtered evidence to influence priority
- feedback and memory to improve ranking over time

## Evidence

- [Persisted mission memory closeout](../../operations/F04_27_PERSISTED_MISSION_MEMORY.md)
- [Mission ranking evaluation](../../operations/MISSION_RANKING_EVALUATION.md)
- `services/ai_gateway/app/graphs/golife_graph.py`
- `services/ai_gateway/app/feedback_store.py`
- `services/ai_gateway/app/learning_memory.py`
- `apps/mobile_flutter/lib/features/dashboard/dashboard_screen.dart`

## Decision

Introduce and keep an explicit deterministic mission-ranker layer on top of suggestion generation.

The ranker scores each suggestion over:

- impact
- urgency
- effort
- confidence
- privacy fit
- feedback fit
- novelty

Each suggestion now exposes:

- `final_score`
- `ranking_reason`
- `evidence_refs`
- per-mission score breakdown

The current weighted formula is:

```text
final_score =
  impact * 0.25 +
  urgency * 0.20 +
  confidence * 0.15 +
  feedback * 0.15 +
  novelty * 0.10 +
  privacy * 0.10 -
  effort_penalty * 0.05
```

Learning remains metadata-only:

- completed and useful patterns can reinforce similar missions
- repeated rejected patterns can reduce novelty or feedback fit
- `too_hard` and effort metadata can penalize expensive patterns
- privacy-blocked events stay out of provider payloads and score inputs

## Alternatives considered

- Keep using only LLM ordering:
  - rejected because ranking would be opaque and harder to test
- Keep only the earlier heuristic confidence bumping:
  - rejected because it was too weak for the premium claim
- Train an external model immediately:
  - rejected because privacy-safe deterministic ranking should come first

## Consequences positive

- the user can see why a mission is first today
- ranking can be tested deterministically
- feedback can improve prioritization without pretending the model has hidden user memory
- mobile UI can show compact “why today” and effort hints

## Consequences negative

- scoring weights will need iterative tuning
- UI needs a compact explanation surface
- evidence and privacy boundaries must be enforced carefully in ranking inputs

## Residual risks

- the current persisted mission memory is still metadata-backed ranking memory, not deep cloud memory over the whole LifeGraph
- scoring remains heuristic even though it is explicit and tested
- future evidence-level learning will still need more corpus breadth than the current five-case baseline

## Affected files

Implemented surfaces:

- `services/ai_gateway/app/graphs/golife_graph.py`
- `services/ai_gateway/app/schemas.py`
- `services/ai_gateway/app/feedback_store.py`
- `services/ai_gateway/app/learning_memory.py`
- `services/ai_gateway/tests/test_daily_mission_graph.py`
- `services/ai_gateway/tests/test_mission_ranking_evaluation.py`
- `apps/mobile_flutter/lib/features/dashboard/dashboard_screen.dart`
- `apps/mobile_flutter/lib/domains/missions/daily_mission.dart`
- `apps/mobile_flutter/test/golife_app_test.dart`

## Tests and gates

- `cd services/ai_gateway && python -m pytest -q`
- `cd apps/mobile_flutter && flutter analyze`
- `cd apps/mobile_flutter && flutter test`
- offline ranking fixture coverage in `tests/fixtures/mission_ranking_cases.json`

## Reversibility

The scoring weights and metadata summaries are reversible. The product should not revert to opaque LLM-only ordering, but it can retune or simplify the deterministic scorer if later evidence shows a better explicit design.
