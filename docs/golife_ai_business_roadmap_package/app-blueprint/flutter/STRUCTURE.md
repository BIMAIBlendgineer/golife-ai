# Flutter App Blueprint

Clean-room Flutter structure for GoLife AI:

```text
lib/
  main.dart
  app/
    golife_app.dart
    router/
    shell/
    theme/
  core/
    config/
    storage/
    privacy/
    analytics/
    flags/
  domains/
    lifegraph/
      life_event.dart
      life_context.dart
      life_event_repository.dart
    tasks/
      task.dart
      task_repository.dart
    habits/
      habit.dart
      habit_log.dart
    planning/
      day_plan.dart
      week_plan.dart
    money/
      expense.dart
      spending_summary.dart
    pantry/
      pantry_item.dart
      pantry_plan.dart
    wardrobe/
      closet_item.dart
      purchase_intention.dart
    ai/
      ai_gateway_client.dart
      ai_trace.dart
      recommendation.dart
  ui/
    today/
    capture/
    plan/
    money/
    pantry/
    settings/
```

## First clean-room slice

Build these in order:

1. `LifeEvent`
2. `Home Today`
3. `Capture`
4. gateway client and offline fallback
5. `DailyMissionAgent` integration

## LifeEvent contract

Every captured signal should become one `LifeEvent`:

- `id`
- `userId`
- `domain`
- `eventType`
- `occurredAt`
- `payload`
- `source`
- `privacyLevel`

This is the common event backbone across tasks, habits, money, pantry and wardrobe.

## Home Today composition

Home Today should show:

- greeting and day context
- 3 main missions
- evidence and uncertainty
- blocked items or risks
- quick feedback on mission usefulness
- a clear fallback state when AI is off

## Capture principles

Capture starts with one entry point and routes later:

- text input first
- voice and photo only after the text flow works
- classify into domain after capture, not before
- never force complex forms on day one

## Feature flags

- `AI_ENABLED`
- `PANTRY_ENABLED`
- `MONEY_ENABLED`
- `WARDROBE_ENABLED`
- `PAYWALL_ENABLED`

## Non-negotiables

- no GPL code copy
- no direct provider calls from mobile
- privacy by domain
- local-first persistence
- app remains useful when AI is disabled
