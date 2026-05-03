# DDC — HomeMemory Admin Telemetry

## Route
- `/homememory`

## Endpoints
- `GET /admin/homememory/summary`
- `GET /admin/homememory/parser-usage`

## Allowed fields
- `proof_parse_count`
- `warranty_reminder_count`
- `claim_draft_count`
- `evidence_attachment_count`
- `parser_success_rate`
- `fallback_rate`
- `locale_distribution`
- `encrypted_collections`
- `storage_impact_estimate`
- `sensitive_data_excluded`

## Forbidden fields
- raw receipt text
- item name
- serial number
- claim body
- `fileRef`
