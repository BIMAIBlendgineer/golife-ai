# Mission Ranking Evaluation

Date: `2026-05-04`
Branch: `release/final-premium-production`

## Goal

Demonstrate that daily mission ranking is now deterministic, privacy-bounded, and improved by stored feedback metadata instead of opaque LLM ordering.

## Runtime model

The mission ranker attaches a `ranking` object to every suggestion with:

- `impact_score`
- `urgency_score`
- `effort_score`
- `confidence_score`
- `privacy_score`
- `feedback_score`
- `novelty_score`
- `final_score`
- `ranking_reason`
- `evidence_refs`

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

## Offline corpus

Fixture file:

- `services/ai_gateway/tests/fixtures/mission_ranking_cases.json`

Executable test:

- `services/ai_gateway/tests/test_mission_ranking_evaluation.py`

## Covered cases

1. `reject_spend_pattern_does_not_repeat_same_finance_loop`
   - repeated rejected finance pattern should lose to a pantry rescue with similar evidence
2. `completed_pantry_plus_money_promotes_cross_domain_mission`
   - completed cross-domain pantry + finance mission should reinforce a similar pattern
3. `too_hard_feedback_reduces_effort_preference`
   - a previously rejected high-effort pattern should lose to a smaller task mission
4. `privacy_blocked_event_stays_out_of_payload`
   - local-only or blocked events must not enter provider payloads or ranking evidence
5. `repeated_rejection_lowers_novelty`
   - repeated rejected patterns should lose novelty and stop resurfacing as the top mission

## Acceptance behavior

The evaluation asserts that:

- top suggestion ordering is deterministic
- feedback changes ranking scores
- repeated rejection lowers novelty or feedback fit
- privacy-blocked events stay out of provider payloads
- ranking remains explainable through structured fields, not hidden model state

## Commands

```bash
cd services/ai_gateway
python -m pytest -q tests/test_mission_ranking_evaluation.py
python -m pytest -q tests/test_daily_mission_graph.py
python -m pytest -q tests/test_api.py
```

## Release interpretation

This evaluation closes the earlier gap where GoLife AI generated missions but could not clearly justify why one mission was first today.

What it does not claim:

- deep lifelong memory over the entire LifeGraph
- external model training
- unrestricted cross-domain ranking beyond consented evidence
- safety or privacy exceptions for ranking inputs
