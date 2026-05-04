# Product Status

## Thesis

GoLife AI is a daily decision system, not a generic assistant. The value comes from:

- local capture
- LifeGraph evidence
- privacy-filtered AI
- three actionable missions
- visible trace and feedback loops

## Current runtime scope

### Closed or materially implemented

- Capture with multi-event parsing and per-item privacy
- Home Today mission flow
- local LifeGraph event spine
- core domain boards for task, habit, finance, pantry, week, and wardrobe
- HomeMemory MVP
- local export/delete
- backend operational export/delete workflow
- AI Gateway production anti-mock hardening
- adversarial safety across reflection and other freeform input surfaces
- mobile/admin fallback visibility
- persisted mission memory over stored feedback metadata

### Still limited or pending

- stronger mission ranking over stored evidence beyond the current feedback-backed memory layer
- shared or service-backed mission memory beyond the current local gateway runtime store
- stronger privacy dashboard and retention controls
- device-specific secure storage/export retrieval validation
- stronger safety policy engine
- broader i18n parity

## HomeMemory

Current HomeMemory value:

- owned items
- proofs
- warranty reminders
- maintenance reminders
- claim drafts
- evidence attachments

Current limit:

- no OCR-heavy or email-ingestion promise in this release candidate

See [HomeMemory RecallBox MVP](HOMEMEMORY_RECALLBOX_MVP.md).

## Explicitly not included yet

Do not market or plan as already shipped:

- banking integration
- full calendar sync
- social/community features
- marketplace
- medical, legal, or regulated financial advice
- strong policy-engine safety claims
- final app-store submission package

## Next product blocks after documentation closeout

- mission ranker improvements over persisted evidence
- shared mission memory architecture if the gateway stops being single-runtime scoped
- privacy dashboard maturity
- domain CRUD maturity
- device and runner validation
