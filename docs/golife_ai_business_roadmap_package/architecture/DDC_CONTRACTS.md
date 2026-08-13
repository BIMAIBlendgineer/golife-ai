# DDC — Detailed Design Contracts

## Contract: LifeEvent

```json
{
  "id": "uuid",
  "user_id": "uuid",
  "domain": "task|habit|money|pantry|wardrobe|planning|system",
  "event_type": "string",
  "occurred_at": "ISO-8601",
  "payload": {},
  "source": "manual|ai|import|integration",
  "confidence": 0.0,
  "privacy_level": "normal|sensitive|highly_sensitive"
}
```

## Contract: AIRecommendation

```json
{
  "id": "uuid",
  "type": "daily_mission|task_fix|spending_insight|pantry_plan|no_buy",
  "title": "string",
  "summary": "string",
  "evidence": ["string"],
  "uncertainty": ["string"],
  "action_minimum": "string",
  "risk_level": "low|medium|high",
  "domain_links": ["task", "money"],
  "requires_user_confirmation": true
}
```

## Contract: DayPlan

```json
{
  "date": "YYYY-MM-DD",
  "missions": [],
  "risks": [],
  "blocked_items": [],
  "estimated_effort_minutes": 0,
  "plan_realism_score": 0.0
}
```

## Contract: Provider Adapter

```python
class AIProvider:
    async def complete_structured(self, request: AIRequest, schema: dict) -> dict:
        ...
```

## Contract: Safety Decision

```json
{
  "allowed": true,
  "reason": "string",
  "redactions": [],
  "disclaimer_required": false,
  "escalation": "none|human|professional"
}
```
