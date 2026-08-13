# MASTER PROMPT FOR AI CODER — GoLife AI

You are an expert senior software architect and implementation agent. Your task is to convert the current folder of reference apps into a new product called GoLife AI.

## Critical rule

Do not copy code blindly. First audit licenses and architectures.

## Project vision

GoLife AI is a mobile personal operating system that combines:

- LifeQuest AI: habits as adaptive missions;
- WeekPilot AI: weekly planning;
- MoneyMirror AI: spending insight;
- ClosetLess AI: anti-consumption wardrobe assistant;
- FridgeZero AI: pantry and grocery planning;
- TaskDoctor AI: task diagnosis and decomposition.

## Input repository layout expected

The user may place references like:

```text
references/
  Habo/
  weektodo/
  flow/
  openwardrobe-app/
  wanna/
  Taskly/
```

## Phase 0 — Audit

Before coding:

1. Inspect each repository.
2. Produce `REPO_AUDIT.md`.
3. Produce `LICENSE_MATRIX.md`.
4. Produce `DEPENDENCY_MATRIX.md`.
5. Identify stack, architecture, reusable ideas, and legal constraints.
6. Mark whether code can be copied, adapted, or only used as inspiration.

Do not modify app code until audit is complete.

## Phase 1 — Decide implementation route

Ask no broad questions. Make a default decision:

- If commercial/proprietary: clean-room rebuild.
- If open-source GPL acceptable: fork-compatible architecture.

Default: **clean-room rebuild**.

## Phase 2 — Create GoLife architecture

Create:

```text
app/
  lib/
    core/
    domains/
      lifegraph/
      tasks/
      habits/
      planning/
      money/
      pantry/
      wardrobe/
      ai/
    ui/
      today/
      capture/
      plan/
      money/
      pantry/
      settings/
ai-gateway/
  app/
    main.py
    schemas.py
    provider.py
    graph.py
    safety.py
    retrieval.py
    memory.py
docs/
schemas/
```

## Phase 3 — Implement MVP

Implement:

- LifeEvent model.
- Local persistence.
- Capture screen.
- Today screen.
- Task, habit, expense and pantry item creation.
- AI Gateway with MockProvider and OpenRouterProvider.
- `/ai/daily-plan`.
- `/ai/task-diagnosis`.
- `/ai/spending-insight`.
- `/ai/pantry-plan`.

## Phase 4 — AI behavior

The IA must:

- generate 3–5 realistic missions;
- explain evidence;
- state uncertainty;
- avoid medical/financial/legal claims;
- ask for confirmation before destructive changes;
- support fallback if provider fails.

## Phase 5 — Tests

Add tests for:

- schema validation;
- provider fallback;
- safety refusal;
- daily mission generation;
- event classification;
- UI feature flags.

## Phase 6 — Documentation

Update:

- `AI_ARCHITECTURE.md`
- `AI_API.md`
- `PRIVACY.md`
- `MONETIZATION.md`
- `ROADMAP.md`
- `LICENSE_MATRIX.md`

## Output expected

A working MVP where the user can:

1. add daily data;
2. generate GoLife daily missions;
3. see explanations;
4. give feedback;
5. use the app even when AI is disabled.
