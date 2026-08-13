# 09 - MVP Scope

## Strict MVP question

The MVP exists to answer only one thing:

> Can GoLife generate 3 useful daily missions that people actually follow?

## Included

### App

- local profile or simple local-first account;
- Home Today;
- quick capture;
- task creation;
- habit creation;
- manual expense logging;
- manual pantry item logging;
- daily mission feedback: useful / not useful / incorrect.

### AI

- event classification;
- daily plan;
- task diagnosis;
- micro-spend reflection;
- pantry usage plan;
- explanation;
- uncertainty;
- safety limits;
- fallback without AI.

### Backend

- AI Gateway;
- MockProvider;
- OpenRouterProvider;
- JSON schemas;
- technical logs without sensitive payloads.

## Excluded

- banking integrations;
- investment advice;
- medical, therapy or legal guidance;
- mandatory fridge photos;
- advanced OCR;
- marketplace;
- social/community features;
- visual wardrobe catalog;
- family plan;
- wearables;
- calendar sync;
- complex multi-device sync.

## Success criteria

- first mission shown in under 5 minutes from onboarding start;
- private beta D7 retention >= 35%;
- active users use the app at least 3 days per week;
- >= 30% of recommendations are marked useful;
- >= 2 missions completed per active day;
- AI cost per active user stays inside the margin target of the Plus plan.

## Failure criteria

- users do not capture enough data;
- missions feel generic or repetitive;
- the app feels heavier than useful;
- AI cost exceeds plausible revenue;
- users cannot understand the value in 30 seconds.

## Scope rule

If a feature does not improve one of these, it leaves the MVP:

- mission quality;
- capture ease;
- trust in the recommendation.
