# GoLife AI Roadmap

Date: 2026-04-24

## Final wedge

GoLife AI launches as:

> the app that gives you 3 realistic missions every morning.

This is intentionally narrower than a full life superapp. The first release wins only if users can capture a few signals fast, receive a small set of useful missions, and still use the app when AI is off.

## Implementation route

- Route: `clean-room rebuild`
- Why:
  - `Habo` and `weektodo` are GPL and cannot be mixed into a proprietary app
  - `flow` and `openwardrobe-db` are not present in the local workspace
  - the source apps use different stacks, persistence models and UX assumptions
  - a new domain model gives GoLife one coherent product instead of stitched apps

## MVP that should be built

Included:

- unified quick capture
- Home Today
- `LifeEvent` local-first storage
- tasks and habits
- manual expense logging
- manual pantry items
- `DailyMissionAgent`
- explanation, uncertainty and feedback
- graceful AI fallback

Explicitly excluded:

- bank connections
- advanced OCR
- family plan
- social features
- wearables
- calendar sync
- advanced wardrobe catalog

## Sequence

1. Audit and legal route
2. Product wedge and monetization validation
3. Clean-room app shell and `LifeEvent`
4. AI Gateway base and provider abstraction
5. LangGraph orchestration and traceability
6. Private beta
7. Free + Plus monetization test
8. Public beta decision gate

## 90-day execution

- Days 1-7: audit, wedge, pricing assumptions, legal route
- Days 8-25: clean-room Flutter shell, capture, local persistence
- Days 26-45: gateway, schemas, DailyMissionAgent, fallback behavior
- Days 46-65: TaskDoctor, MoneyMirror and FridgeZero light versions
- Days 66-75: onboarding, paywall, analytics, beta readiness
- Days 76-85: private beta and qualitative interviews
- Days 86-90: go, narrow, reprice or pause feature expansion

## Release gates

- first mission shown in under 5 minutes from install
- D7 retention target for private beta: `>= 35%`
- recommendation usefulness target: `>= 30%`
- at least `2` useful missions completed per active week
- economics remain compatible with `EUR 7.99` Plus pricing

## Deliverables already locked

- `REPO_AUDIT.md`
- `LICENSE_MATRIX.md`
- `DEPENDENCY_MATRIX.md`
- `FEATURE_EXTRACTION_MATRIX.md`
- `docs/31_PRODUCT_STRATEGY_REVIEW.md`
- `docs/32_MONETIZATION_VALIDATION.md`
- `app-blueprint/`
- `ai-gateway-skeleton/`
