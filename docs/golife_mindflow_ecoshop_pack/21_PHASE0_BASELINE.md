# Phase 0 Baseline

Date: 2026-05-09
Branch: `feat/mindflow-ecoshop-core`
Base commit: `c18453d`

## Approved scope

- PRD approved as the execution source for MindFlow Core + EcoShop.
- DDD approved with one product shell only; no separate EcoShop app will be created.
- ADR set approved for local-first storage, privacy-before-AI, feature flags, confirmation gates, and evidence-first claims.

## Commercial decisions

### Free

- Capture Inbox, Today fallback, HomeMemory local, export local.
- No external shopping claims or remote evidence by default.

### Plus

- Remote decision cards, local-first shopping, explainability, reminders.
- Evidence cards only when evidence is available and the related flags are enabled.

### Pro

- Everything in Plus.
- Higher operational limits, admin insights, quality breakdown, rollout controls.
- BYOK and advanced observability remain admin/backoffice features.

## Marketing guardrails

- Do not position GoLife AI as a chatbot.
- Do not claim best price, lowest price, or live availability without verified source evidence.
- Do not claim sustainability, ethics, or environmental impact without verified source evidence.
- Do not suggest external action automation; every action requires human confirmation.
- Approved message:

```text
Capture everything.
GoLife turns scattered life inputs into safe, explainable decisions.
Sensitive data stays local unless you explicitly allow AI.
```

## Baseline tests

- `flutter test` in `apps/mobile_flutter`: 55 passed.
- `python -m pytest tests` in `services/ai_gateway` with `PYTHONPATH` set to the service root: 95 passed.
- `python -m pytest tests` in `services/web_backend` with `PYTHONPATH` set to the service root: 25 passed.

## Baseline invocation caveat

- Running Python tests from the monorepo root without a service-local `PYTHONPATH` resolves another external `app.main` module on this machine.
- This is a real baseline risk for CI/local reproduction and should be normalized later with packaging or command wrappers.

## Files in scope

- `apps/mobile_flutter/lib/app/router/app_router.dart`
- `apps/mobile_flutter/lib/features/app_state/golife_controller.dart`
- `apps/mobile_flutter/lib/features/dashboard/dashboard_screen.dart`
- `apps/mobile_flutter/lib/features/capture/capture_screen.dart`
- `apps/mobile_flutter/lib/features/domains/domain_screens.dart`
- `apps/mobile_flutter/lib/features/homememory/homememory_screen.dart`
- `apps/mobile_flutter/lib/core/storage/*`
- `apps/mobile_flutter/lib/core/ai_client/*`
- `apps/mobile_flutter/lib/core/runtime/*`
- `apps/mobile_flutter/lib/core/i18n/*`
- `services/ai_gateway/app/*`
- `services/ai_gateway/tests/*`
- `services/web_backend/app/*`
- `services/web_backend/tests/*`
- `apps/admin_next/lib/*`
- `apps/admin_next/app/*`
- `apps/admin_next/messages/*`

## Controller debt review

- `GoLifeController` is currently mission-centric; Today state, capture flow, and gateway status are tightly coupled to `DailyMission`.
- Localization strings are embedded in controller helper methods, which increases change surface for new decision/shopping states.
- Capture, mission fallback, and HomeMemory side effects live in one class, so MindFlow additions must preserve backwards compatibility carefully.

## Localization review

- Mobile already supports the 10 target locales: `en`, `es`, `pt-PT`, `pt-BR`, `fr`, `it`, `de`, `ja`, `zh-Hans`, `zh-Hant`.
- New MindFlow/EcoShop keys must be added to generated localization assets and validated with English fallback coverage.
- Admin currently ships fewer locales than mobile; new admin copy should follow the existing message bundle pattern.

## Risk review

- Privacy: new endpoints and DTOs must continue filtering data before any AI call.
- EcoShop claims: no price, availability, or sustainability claim may become user-visible without source evidence.
- SQLite migration: mobile database must move from v4 to v5 without losing encrypted rows or HomeMemory data.
- Offline fallback: Capture Inbox, Today, Decisions, and Shopping must stay usable with deterministic local fallbacks.
