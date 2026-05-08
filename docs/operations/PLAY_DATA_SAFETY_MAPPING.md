# Play Data Safety Mapping

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `6`
Status: `working mapping for Play Console completion`

## Scope

This document maps repository evidence to the Google Play Data safety form.

Primary repo evidence:

- `docs/compliance/DATA_MAP.md`
- `docs/compliance/PRIVACY_REVIEW.md`
- `apps/mobile_flutter/lib/features/settings/privacy_screen.dart`
- `services/ai_gateway/app/main.py`
- `services/web_backend/app/main.py`

Policy source of truth remains the official Play documentation already linked in:

- [PLAY_STORE_READINESS.md](PLAY_STORE_READINESS.md)

## Decision posture

GoLife AI is local-first. Most personal content remains on-device. Some user-provided text and metadata can leave the device only through explicit AI-enabled flows or operational metadata flows.

Because the Play Console form is policy-sensitive, treat the table below as the engineering answer draft, not the final legal submission.

## Working answers by data category

| Play category | Repo evidence | Draft answer | Why |
| --- | --- | --- | --- |
| Personal info | no mandatory account profile flow is present in mobile runtime | likely `not collected in mobile runtime` | the current Flutter shell does not require sign-up or a cloud profile |
| Financial info | `expenses`, `purchase_proofs`, warranty and claim-related data exist locally | `collected on device`; `not shared by default` | finance and proof data are stored locally and exported locally |
| Health and fitness | none detected as a product feature | `not collected as a dedicated category` | current product must not claim health functionality |
| Messages | freeform capture, reflection text, and task rewrite input can be sent to AI services | `collected`; `transferred only for requested AI features` | capture and reflection text can go to AI Gateway when the user invokes those features |
| Photos and videos | proof and evidence attachments exist in HomeMemory | `collected on device`; `not transferred to admin/backend by default` | asset bytes remain in the private vault and local export bundle |
| Audio files | no audio capture flow found | `not collected` | no mobile audio feature is implemented in this repo |
| Files and docs | export bundles and proof attachments exist | `collected on device`; `shared only when user exports locally` | export is local-to-device by design |
| Calendar | `calendar_items` exist locally | `collected on device`; `not shared by default` | calendar data remains part of the local graph |
| App activity | mission feedback, usage metadata, safety events, and support metadata exist | `collected`; `some metadata transferred` | operational telemetry is metadata-only |
| App info and performance | runtime config, gateway status, and backend health are used operationally | `collected in limited form` | needed for service operation and support |
| Device or other IDs | no advertising ID flow found | `no advertising ID usage detected` | no ad stack is present in repo evidence |

## Draft form guidance by behavior

| Form question | Draft answer | Repo evidence |
| --- | --- | --- |
| Is data collected? | yes, on-device and in limited network paths | local store, capture flows, AI Gateway calls |
| Is data shared? | limited transfer, not broad third-party sharing | AI Gateway and backend calls are first-party service flows for app operation |
| Is data encrypted in transit? | should be `yes` in deployed production | production deployment must use HTTPS even though local dev URLs are HTTP |
| Can users request deletion? | yes | local delete-all flow plus backend operational delete workflow |
| Is data processed ephemerally? | mixed | some operational metadata persists; local graph persists until user deletion |
| Is collection required? | mixed | core local features work without cloud sync, but some AI features need user-provided text |

## High-confidence statements

- Local LifeGraph content is the canonical store for personal data in v1.
- Admin does not store a full cloud copy of the local mobile graph.
- AI-eligible events are filtered locally before mission requests are built.
- Submission asset bytes remain local unless the user exports them from the device.
- Delete flows exist both locally and for backend operational records.

## Human review items before Play Console submission

1. Confirm the final production transport is HTTPS everywhere.
2. Confirm whether any crash reporting or analytics SDK is added outside this repo before ship.
3. Confirm whether app signing, backup transport, or Play-integrated services add device identifiers.
4. Confirm exact wording for AI text transfer under the current Play form.
5. Confirm whether proof or evidence attachments ever leave the device in a production support workflow.

## Gate decision

- Engineering mapping: ready
- Legal and console submission mapping: still needs human verification against the live Play Console form
