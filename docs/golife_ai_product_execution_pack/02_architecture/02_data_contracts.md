# DDC global — contratos

## LifeEvent

```json
{
  "event_id": "string",
  "user_id": "string",
  "domain": "task|habit|week|finance|pantry|wardrobe|journal|note|calendar|board|recipe|system",
  "event_type": "string",
  "timestamp": "ISO-8601",
  "payload": {},
  "source": "manual|ai|import|system",
  "privacy_level": "local_only|sync_allowed|ai_allowed",
  "evidence_hash": "string|null"
}
```

## Entidades móviles

- Task
- Habit
- ExpenseRecord
- PantryItem
- WardrobeItem
- PurchaseIntention
- WeekPlan
- CalendarItem
- JournalEntry
- QuickNote
- BoardItem
- Recipe
- DailyMission
- DailyRisk
- MissionFeedback

## Contratos Gateway

- SuggestionRequest
- SuggestionResponse
- EventClassificationRequest
- EventClassificationResponse
- MultiEventParseRequest
- MultiEventParseResponse
- ReflectionRequest
- ReflectionResponse
- SafetyEvent

## Contratos operacionales

- UsageEvent
- AIInvocation
- MissionAuditRecord
- FeedbackAuditRecord
- SafetyAuditRecord
- FeatureFlag
- ModelSettings
- SupportRequest
