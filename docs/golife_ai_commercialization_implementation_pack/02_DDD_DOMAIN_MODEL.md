# DDD — Domain Model

## Bounded contexts
1. LifeGraph Context.
2. Mission Planning Context.
3. AI Gateway Context.
4. Privacy and Export Context.
5. Entitlement and Monetization Context.
6. Admin Operations Context.
7. Support and Compliance Context.

## Aggregates

### LifeGraph
- life_graph_id
- user_id
- local_entities
- evidence_refs
- privacy_profile
- updated_at

### EvidenceItem
- evidence_id
- source_type
- local_payload_ref
- privacy_class
- allowed_for_ai
- created_at

### MissionSet
- mission_set_id
- date
- missions
- ranking_trace
- source_state
- created_at

### Mission
- mission_id
- title
- action
- effort
- reason
- evidence_refs
- score_breakdown
- status

### FeedbackEvent
- feedback_id
- mission_id
- feedback_type
- metadata_payload
- created_at

### Entitlement
- plan
- quota
- trial_status
- billing_provider
- renewal_state

### PrivacyJob
- job_id
- kind
- status
- audit_ref

## Invariants
- No production mock.
- No hidden fallback.
- No AI access to raw LifeGraph outside privacy filter.
- Admin sees metadata by default, not raw private payloads.
- Mission output must have reason/evidence visibility.
