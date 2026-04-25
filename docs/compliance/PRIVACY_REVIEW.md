# GoLife AI Privacy Review

## Current Boundary

- Personal LifeGraph data remains device-local by default.
- Mobile fetches runtime config only; it does not sync the personal graph in v1.
- AI requests are filtered locally by domain permission and event privacy level.
- Admin surfaces use operational metadata and should not store raw personal payloads.

## Implemented Controls

- Per-domain privacy settings in mobile
- Per-item privacy during multi-event capture confirmation
- Sensitive local encryption at rest for finance, journal entries, and quick notes in SQLite
- Legacy plaintext migration for encrypted mobile collections
- Safe local-store fallback that avoids app crash if secure storage is unavailable
- Local JSON export
- Local delete-all flow
- Support queue for export/delete operations
- Public mobile runtime-config endpoint with no secrets
- Internal routing config endpoint protected by internal token
- Reflection safety telemetry with metadata-only operational audit
- Mission feedback audit redaction in gateway, backend, and admin views

## Data Leaving Device

- AI requests to `services/ai_gateway`
- Mission feedback to `services/ai_gateway`
- Runtime config pull from `services/web_backend`

## Data Not Leaving Device in v1

- Full LifeGraph history sync
- Raw local entity database replication
- Background upload of personal notes or events
- Reflection text in operational admin telemetry
- Mission feedback note text in operational admin telemetry

## Residual Risks

- Export currently copies JSON to clipboard instead of writing a protected file
- Sensitive encryption still covers only finance, journal entries, and quick notes
- Secure-storage behavior still needs validation on each target platform
- Device-level compromise is out of scope for app-only controls

## Release Assessment

- Privacy/export/delete: implemented at local-app level
- Privacy operations queue: implemented in admin
- Remaining before wider beta: expand encryption review to more domains and tighten retention guidance
