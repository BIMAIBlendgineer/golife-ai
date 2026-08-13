# SPEC — AI System

## Architecture

```text
Mobile App
  → AI Service Client
  → AI Gateway FastAPI
  → Safety Layer
  → Context Retriever
  → LangGraph Orchestrator
  → Provider Adapter
  → Structured Output Validator
  → Explanation Builder
  → Response
```

## Provider strategy

Initial provider:

- OpenRouter.

Provider must be replaceable:

- OpenAI;
- Anthropic;
- Gemini;
- local model;
- mock.

## Agents

### DailyMissionAgent

Input:

- tasks;
- habits;
- expenses;
- pantry;
- preferences.

Output:

- 3–5 daily missions.

### TaskDoctorAgent

Detects:

- vague tasks;
- oversized tasks;
- missing dependencies;
- emotional blockers expressed by user.

Output:

- smaller tasks;
- next action.

### MoneyMirrorAgent

Detects:

- microspend;
- category spikes;
- repeated purchases;
- budget risk.

Output:

- insight with no investment advice.

### FridgeZeroAgent

Detects:

- expiry risk;
- duplicated groceries;
- missing staples.

Output:

- use-first plan;
- shopping list.

### ClosetLessAgent

Detects:

- duplicated clothing;
- low-use items;
- possible no-buy decision.

Output:

- outfit;
- do-not-buy warning.

### ExplanationAgent

Adds:

- evidence;
- uncertainty;
- why;
- next action.

## Guardrails

- no medical diagnosis;
- no psychological diagnosis;
- no financial advice;
- no manipulative purchase recommendations;
- no hidden sponsored recommendation.

## Structured output

All AI outputs must be validated against JSON Schema.

If invalid:

1. retry once;
2. repair;
3. fallback to deterministic recommendation;
4. show uncertainty.
