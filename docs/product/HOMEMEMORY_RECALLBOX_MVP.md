# GoLife AI HomeMemory / RecallBox MVP

## Objective

HomeMemory turns receipts, owned items, warranties, reminders, and claim drafts into a local-first memory surface inside GoLife AI.

This is not a separate product. It reinforces the GoLife thesis:

- capture daily reality quickly
- structure it into useful memory
- keep sensitive evidence local
- turn it into reminders and next actions

## Scope

MVP flow:

1. manual proof or manual item entry
2. owned item created locally
3. purchase proof attached locally
4. warranty recorded when explicitly provided
5. maintenance reminder optionally created
6. claim draft prepared locally
7. LifeEvents emitted for downstream planning

## Mobile Models

- `OwnedItem`
- `PurchaseProof`
- `WarrantyRecord`
- `MaintenanceReminder`
- `ClaimDraft`
- `EvidenceAttachment`

## Local Storage

SQLite and local-store adapters persist the HomeMemory entities.

Submission asset bytes are stored separately in an app-private vault. The
encrypted entity blobs keep only internal managed refs for purchase-proof and
evidence files.

Sensitive collections encrypted at rest:

- `owned_items`
- `purchase_proofs`
- `claim_drafts`
- `evidence_attachments`

Non-sensitive support collections kept local but not encrypted in this MVP:

- `warranty_records`
- `maintenance_reminders`

## LifeGraph Events

HomeMemory emits local LifeEvents for:

- `purchase_proof_added`
- `owned_item_created`
- `warranty_detected`
- `maintenance_scheduled`
- `claim_draft_created`
- `evidence_attachment_added`

For MVP these events are stored under the local `system` domain with payload marker `module = homememory`.

## UI

Mobile route:

- `/homememory`

Primary UI blocks:

- warranties ending soon
- recent proofs
- maintenance reminders
- claim drafts
- owned items list

Entry point:

- linked from `Everyday`

## Proof Parser

Gateway endpoint:

- `POST /v1/proofs/parse`

Behavior:

- deterministic parser first
- semantic provider only when feature flag `proof_parser` is enabled
- deterministic fallback if semantic parsing fails

Allowed operational telemetry:

- `locale`
- `region`
- `parser`
- `confidence`
- `has_amount`
- `has_date`
- `has_warranty_hint`
- `item_count`

Forbidden in telemetry/admin for this MVP:

- raw receipt text
- full invoice body
- full claim text as operational audit content

## Privacy

HomeMemory is local-first.

Receipts, draft claims, evidence, and item notes are treated as sensitive local data.

This MVP does not upload owned items, receipts, or attachments to the operational backend.

Protected local export now emits a bundle with `data.json` plus `assets/` so
local retrieval can recover both metadata and locally stored submission files
without exposing raw device paths in the exported JSON.

The admin/backend export workflow remains metadata-only and does not replace
the local protected export bundle.

## Limits

- no OCR pipeline yet
- no email inbox parsing yet
- no PDF extraction pipeline yet
- no legal review
- no automatic outbound emails
- no guarantee estimation unless explicitly provided by the user in manual entry

## Legal/Safety Boundaries

- no legal advice
- no promise that warranty interpretation is valid
- user must verify seller and manufacturer policy
- claim drafts are user-edited text sent outside the app

## Future Work

- OCR for receipt photos
- PDF invoice parsing
- email receipt ingestion
- manual finder lookup for appliances
- stronger warranty country rules
- richer maintenance templates by category
- calendar linkage beyond MVP

See also:

- [Product status](PRODUCT_STATUS.md)
- [Data map](../compliance/DATA_MAP.md)
