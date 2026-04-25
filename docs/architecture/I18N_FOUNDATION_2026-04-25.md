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

Other admin pages currently fall back to English where untranslated.

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
  - targeted widget/unit tests:
    - dashboard locale rendering (`en`, `es`, `pt-BR`)
    - multilingual capture parser fallback
    - gateway client locale propagation
- `apps/admin_next`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
- `services/ai_gateway`
  - targeted pytest nodeids for multilingual parse + operational audit

## Remaining work

Not fully covered yet:

- full localization of all Flutter domain screens and editor dialogs
- full localization of long-tail admin pages:
  - feature flags
  - missions
  - model catalog
  - openrouter keys
  - routing profiles
  - routing snapshots
  - safety
  - support queue
  - usage
  - model settings
- locale-aware copy for all local mock mission fallbacks in mobile
- professional translation pass before public release
- future RTL architecture for Arabic

## Recommendation

Treat this as the i18n foundation plus critical-surface rollout, not the final translation pass.
