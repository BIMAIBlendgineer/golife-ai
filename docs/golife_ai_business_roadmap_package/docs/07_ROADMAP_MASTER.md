# 07 - Master Roadmap

## Phase 0 - Audit and legal route

Duration: 1 week

Goals:

- audit local reference repos;
- confirm `clean-room rebuild` as default route;
- document license and dependency constraints;
- define what can be copied, adapted or only used as inspiration.

Outputs:

- `REPO_AUDIT.md`
- `LICENSE_MATRIX.md`
- `DEPENDENCY_MATRIX.md`
- `FEATURE_EXTRACTION_MATRIX.md`

Exit criterion:

- no implementation work depends on copying GPL code.

## Phase 1 - Product wedge and foundations

Duration: 1 to 2 weeks

Goals:

- lock positioning around `AI Daily Missions`;
- define strict MVP scope;
- define pricing assumptions;
- define North Star and guardrail metrics.

Outputs:

- strategy review
- monetization validation
- final roadmap
- final MVP scope

Exit criterion:

- the team can explain the product in one sentence and one screen.

## Phase 2 - Clean-room core app

Duration: 2 to 3 weeks

Goals:

- create new Flutter shell;
- define `LifeEvent`;
- implement quick capture;
- implement Home Today;
- implement local-first persistence;
- keep app usable without AI.

Exit criterion:

- a user can capture tasks, habits, expenses and pantry items locally.

## Phase 3 - AI Gateway

Duration: 2 weeks

Goals:

- build FastAPI gateway;
- create swappable provider interface;
- implement MockProvider first;
- add OpenRouter provider path;
- define structured schemas.

Exit criterion:

- app can request structured daily missions and survive provider failure.

## Phase 4 - LangGraph orchestration

Duration: 2 weeks

Goals:

- implement orchestration nodes;
- add safety and schema validation;
- route to specialized agents;
- persist trace and explanation.

Agents:

- DailyMissionAgent
- TaskDoctorAgent
- MoneyMirrorAgent
- FridgeZeroAgent
- ClosetLessAgent

Exit criterion:

- every recommendation has evidence, uncertainty and trace.

## Phase 5 - Private beta

Duration: 3 to 4 weeks

Goals:

- run a private beta with 20 to 50 testers;
- measure usefulness and repeat usage;
- tighten onboarding;
- identify useless or generic missions.

Exit criterion:

- D7 retention and mission usefulness are above threshold.

## Phase 6 - Monetization test

Duration: 1 to 2 weeks

Goals:

- test Free + Plus;
- validate AI usage caps;
- confirm conversion and margin;
- avoid expanding plan complexity too early.

Exit criterion:

- paid conversion is viable and AI cost is controlled.

## Phase 7 - Public beta decision

Duration: 1 week decision gate

Choose one:

- continue to public beta;
- narrow the product further to AI Daily Missions only;
- pivot toward frugal living / pantry + spending;
- stop expansion and fix usefulness first.
