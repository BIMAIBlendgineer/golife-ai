# F04 Persisted Mission Memory

Date: `2026-05-04`
Executor: `Codex`
Branch: `feature/f04-persisted-mission-memory`
Base SHA: `4663805362018cbe101d340298449ff5f6ef80ae`

## Objective

Close the next product gap after export/delete, anti-mock runtime hardening, and adversarial safety:

- turn persisted mission feedback into reusable mission memory
- keep learning metadata-only and privacy-bounded
- make later daily plans visibly improve even when suggestion IDs change between runs

## Scope

- `services/ai_gateway/app/learning_memory.py`
- `services/ai_gateway/app/feedback_store.py`
- `services/ai_gateway/app/graphs/golife_graph.py`
- `services/ai_gateway/tests/test_api.py`

## Implementation

### Persisted learning key

- Added a stable mission-pattern key built from:
  - `recommendation_type`
  - sorted `domain_targets`
- Feedback persistence now stores:
  - `learning_key`
  - `learning_key_source`
- If a response trace already maps a suggestion ID to a learning key, that key is reused.
- If not, the gateway derives a safe fallback key from feedback metadata.

### Metadata-only mission memory

- The feedback store now summarizes persisted feedback into:
  - `by_pattern`
  - `by_recommendation_type`
  - `memory_profile`
- `memory_profile` exposes only bounded metadata:
  - reinforce patterns
  - avoid patterns
  - reinforce domains
  - avoid domains
  - recent feedback status snapshots
- Raw feedback notes remain excluded from stored learning summaries.

### Graph learning and visible trace

- `generate_candidates` now sends both:
  - `feedback_summary`
  - `mission_memory`
  to the provider payload.
- `feedback_learning` now applies deltas from:
  - exact suggestion history
  - domain history
  - stable mission-pattern history
  - recommendation-type history
- The daily mission response trace now includes:
  - `mission_memory`
  - `learning_keys_by_suggestion_id`
  - per-candidate `feedback_learning.candidate_biases`

### Why this matters

- The gateway no longer depends mainly on ephemeral `suggestion_id` values.
- A task mission completed yesterday can bias a similar task mission tomorrow even when the new suggestion has a different ID.
- The product stays aligned with the thesis:
  - decisions come from LifeGraph + feedback + visible evidence
  - not from pretending the model has hidden user memory

## Validation

Focused coverage added:

- feedback storage persists a derived learning key without raw notes
- feedback summary builds reinforce/avoid pattern memory
- follow-up daily missions expose mission memory and learning keys in trace
- ranking can flip across different suggestion IDs when persisted pattern memory favors the mission pattern

Commands run:

- `cd services/ai_gateway && python -m pytest -q tests/test_api.py -k "feedback_summary or feedback_store or persisted_pattern_memory"`
  - result: `5 passed`
- `cd services/ai_gateway && python -m pytest -q tests/test_api.py -k "reorders_new_suggestion_ids_using_persisted_pattern_memory"`
  - result: `1 passed`

## Operational effect

- Later daily plans can adapt from stored mission outcomes instead of treating every request as stateless.
- The memory remains explainable because the response trace shows:
  - which mission pattern was reinforced
  - which pattern was avoided
  - which bias was applied to each candidate
- Learning remains bounded to persisted gateway feedback metadata and user scope.

## Residual risks

- This is still feedback-backed mission memory, not deep evidence-level memory over all persisted LifeGraph state.
- Ranking deltas remain heuristic, not a learned model or policy engine.
- The current memory store is local to the gateway runtime path and not yet a shared multi-node persistence layer.

## Canonical follow-up docs

- [AI Gateway API](../api/AI_GATEWAY_API.md)
- [Execution pack status](EXECUTION_PACK_STATUS.md)
- [Product status](../product/PRODUCT_STATUS.md)

## Next useful gap

- strengthen the mission ranker over persisted evidence, not only persisted feedback metadata
- decide whether gateway mission memory should remain local-runtime scoped or move to a shared service-backed store

## Rollback

- revert the commit for this block
- restore:
  - `services/ai_gateway/app/learning_memory.py`
  - `services/ai_gateway/app/feedback_store.py`
  - `services/ai_gateway/app/graphs/golife_graph.py`
  - `services/ai_gateway/tests/test_api.py`
