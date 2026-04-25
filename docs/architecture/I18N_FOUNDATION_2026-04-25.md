# GoLife AI i18n Foundation

Date: 2026-04-25

## Preconditions

- PR #1 was merged into `main` before starting i18n work.
- Merge commit on `main`: `cb40204`
- This keeps privacy/telemetry P0 fixes in the baseline before locale work.

## Locale set

Initial supported locales:

- `en`
- `es`
- `pt-BR`
- `ja`
- `zh-Hans`

Normalization rules in gateway/mobile:

- `pt` -> `pt-BR`
- `zh` -> `zh-Hans`
- `zh-CN` -> `zh-Hans`
- unknown -> `en`

## AI Gateway

Implemented:

- `locale` added to request schemas for:
  - suggestions
  - event classify
  - event parse
  - task rewrite
  - feedback
  - reflection safety
- locale normalization in `services/ai_gateway/app/i18n/locales.py`
- localized reflection safety messages via:
  - `services/ai_gateway/config/reflection_safety_messages.json`
  - `services/ai_gateway/app/i18n/reflection_messages.py`
- locale included in operational metadata
- prompts updated so provider responses keep user locale for:
  - semantic classify
  - semantic parse
  - task rewrite
  - suggestion graph

Parser fallback:

- deterministic parser expanded for:
  - Spanish
  - Portuguese
  - Japanese
  - Simplified Chinese
- multilingual heuristics now cover:
  - finance
  - pantry/expiry
  - task intent
  - habit terms
  - weekly planning terms

## Mobile Flutter

Implemented:

- `flutter_localizations`
- `intl`
- `l10n.yaml`
- ARB files for:
  - `en`
  - `es`
  - `pt`
  - `pt-BR`
  - `ja`
  - `zh`
  - `zh-Hans`
- locale preference persisted in local store
- app observes device locale when preference is `system`
- current locale sent to gateway for:
  - `/v1/events/classify`
  - `/v1/events/parse`
  - `/v1/missions/daily`
  - `/v1/feedback`

Visible mobile coverage completed in this stage:

- app shell
- privacy screen
- dashboard
- capture
- copilot
- domain screens
- editor dialogs
- domain action snackbars and success/error messages
- dashboard disclosure copy for:
  - data used
  - data sent to AI
  - blocked from AI
  - encrypted / always-local collections
- local dashboard fallback mission copy for:
  - primary mission card
  - support mission cards
  - explanation sheet

Additional mobile work completed after the foundation pass:

- `ja` / `zh-Hans` critical dashboard and copilot strings no longer fall back to English on the main visible surfaces
- dashboard signal cards use localized fallback copy instead of hardcoded English mock labels
- week/day chips localize `Today`
- controller-generated domain action feedback now respects the current locale

Parser fallback tests added for Portuguese, Japanese, and Chinese.

## Admin Next.js

Implemented:

- locale cookie-based admin i18n layer
- deep-merge fallback to English for untranslated keys
- locale-aware formatting for:
  - percent
  - currency
  - number
  - datetime
- localized error banner

Admin pages localized in this stage:

- shell
- navigation
- dashboard
- AI costs
- feedback
- users
- user detail
- feature flags
- usage
- safety
- missions
- model catalog
- openrouter keys
- routing profiles
- routing snapshots
- support queue
- model settings

Current admin locale status:

- `es` and `pt-BR` cover the long-tail operational pages above
- `ja` and `zh-Hans` now cover the highest-visibility long-tail operational pages added in this pass
- some earlier admin surfaces still rely on English fallback outside the pages listed above

## Privacy and telemetry constraints preserved

- locale is stored in telemetry metadata
- private reflection text is not added to operational audit payloads
- private feedback notes remain redacted
- admin formatting for feedback reasons uses safe strings only

## Validation

Validated locally:

- `apps/mobile_flutter`
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test test/golife_app_test.dart test/features/domains/domain_screens_test.dart test/features/capture/capture_parser_test.dart test/core/ai_client/http_ai_gateway_client_test.dart`
  - targeted widget/unit tests:
    - dashboard locale rendering (`en`, `es`, `pt-BR`)
    - multilingual capture parser fallback
    - gateway client locale propagation
- `apps/admin_next`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
- `services/ai_gateway`
  - `python -m pytest -q` targeted nodeids for:
    - multilingual parse (`en`, `pt-BR`, `ja`, `zh-Hans`)
    - reflection safety (`es`, `pt-BR`, `ja`, `zh-Hans`, unknown -> `en`)
    - locale normalization in operational audit
  - result: `9 passed`

## Remaining work

Not fully covered yet:

- professional translation review for:
  - `ja`
  - `zh-Hans`
  - nuanced admin/operator copy in every locale
- remaining English fallback on some non-critical admin pages and strings outside the surfaces listed above
- locale-aware copy for every low-visibility local parser rationale and demo seed string in mobile
- professional translation pass before public release
- future RTL architecture for Arabic

## Recommendation

Treat this as i18n foundation plus critical-surface rollout with broad operational coverage, not the final translation pass for public launch.
