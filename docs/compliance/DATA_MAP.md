# GoLife AI Data Map

## Goal

Describe what data exists, where it lives, what can leave the device, what export covers, and what delete actually removes.

## Core principle

GoLife AI is local-first. The mobile app stores the personal graph and most user content on-device. Operational services store metadata needed for admin, support, safety, and routing, not a full cloud copy of the user’s local life database.

## Mobile local data

Primary local stores in `apps/mobile_flutter` include:

- privacy settings
- locale preference
- runtime config cache
- life events
- daily missions
- daily risks
- mission feedback
- tasks
- habits
- expenses
- pantry items
- purchase intentions
- week plans
- journal entries
- quick notes
- calendar items
- recipe rescues
- owned items
- purchase proofs
- warranty records
- maintenance reminders
- claim drafts
- evidence attachments

## Mobile sensitive collections

Sensitive collections currently encrypted at rest include:

- `life_events`
- `missions`
- `daily_risks`
- `expenses`
- `calendar_items`
- `journal_entries`
- `quick_notes`
- `owned_items`
- `purchase_proofs`
- `claim_drafts`
- `evidence_attachments`

Non-sensitive but still local-only support collections include:

- `warranty_records`
- `maintenance_reminders`
- runtime config cache
- locale preference
- privacy settings

## Submission assets

HomeMemory files no longer rely on raw external metadata-only paths.

Current behavior:

- submission asset bytes are copied into an app-private vault
- entity blobs keep only internal managed refs such as `vault://submission-assets/...`
- protected export bundles materialize those assets under `assets/`

## Data that can leave the device

### To AI Gateway

Allowed by explicit privacy settings only:

- filtered `life_events`
- filtered domain summaries
- locale
- mission feedback metadata
- privacy-safe feedback summaries
- freeform capture text for classify/parse
- proof text for proof parse
- task rewrite text
- reflection check text

The mobile client filters AI-eligible events locally before building mission requests.

### To Web Backend

Operational metadata only:

- runtime config fetches from `/public/mobile/runtime-config`
- AI Gateway operational ingestion for usage, invocations, safety events, mission audits, feedback audits, and model settings

### Data that does not leave the device by default in v1

- full local LifeGraph history sync
- raw journal/note replication to admin
- raw reflection text in admin telemetry
- raw mission feedback notes in admin telemetry
- submission asset bytes to operational backend
- local export bundle contents to backend

## Backend operational data

`services/web_backend` stores operational records such as:

- admin user summaries
- usage events
- AI invocations
- AI cost ledgers
- mission audit records
- feedback audit records
- safety audit records
- support/export-delete requests
- admin audit log
- OpenRouter key metadata and routing state

This backend is not the canonical storage for the full local mobile graph.

## Gateway-local learning memory

`services/ai_gateway` also persists a bounded feedback-memory layer for ranking:

- suggestion id
- stable learning key
- domains
- recommendation type
- feedback status
- rejection reason category
- effort feedback
- repeated flag
- privacy-safe summary
- recorded timestamp

It does not persist:

- raw journal text
- raw receipt text
- raw proof attachment bytes
- raw mission notes in operational telemetry
- secrets or provider credentials

## Admin visibility

The admin panel can see:

- operational summaries
- quality and safety aggregates
- support queue state
- metadata-only export bundles
- live/fallback/offline backend state

The admin panel should not see:

- raw personal graph exports
- raw reflection text
- raw mission feedback note text
- raw submission asset bytes
- raw feedback-memory note content

## Export behavior

### Mobile protected export

`GoLifeController.exportLocalDataFile()` produces:

- bundle directory `golife_local_export_<timestamp>`
- `data.json`
- `assets/` copied from the protected vault when available

This export covers the local mobile state, including a submission asset manifest.

### Backend/admin export

`GET /admin/support/export-delete/{request_id}/bundle` produces:

- metadata-only operational export bundle
- checksum SHA-256
- record counts
- operational summaries and audit rows

This export does not replace the mobile local export.

The gateway-local ranking memory is not treated as a separate user-facing export artifact in this repo. Its contents are already bounded to metadata that also appears through feedback and audit paths.

## Delete behavior

### Mobile `deleteAllLocalData()`

Deletes or resets:

- privacy settings
- locale preference
- runtime config cache
- local graph and domain collections
- daily missions and risks
- mission feedback
- submission asset vault contents
- demo seed state

### Backend delete request

`POST /admin/support/export-delete/{request_id}/execute-delete` removes operational records by `user_id`, including:

- `admin_users`
- `user_profiles`
- `usage_events`
- `ai_invocations`
- `ai_usage_ledger`
- `mission_audit_records`
- `feedback_audit_records`
- `safety_events`

## What is not deleted automatically

- external systems not managed by this repo
- user email account data
- third-party provider logs outside GoLife control
- any local mobile export file the user copied outside the app-private area

## Residual limits

- device-specific secure storage and retrieval UX still need validation if Android, iOS, or desktop runners are added
- backend export remains operational metadata only by design
- the policy engine is versioned and centralized, but still rule-based rather than a full DLP or jailbreak-resistant system
