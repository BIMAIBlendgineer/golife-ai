# GoLife AI Privacy Review

## Current Boundary

- Personal LifeGraph data remains device-local by default.
- Mobile fetches runtime config only; it does not sync the personal graph in v1.
- AI requests are filtered locally by domain permission and event privacy level.
- Admin surfaces use operational metadata and should not store raw personal payloads.

## Implemented Controls

- Per-domain privacy settings in mobile
- Per-item privacy during multi-event capture confirmation
- Sensitive local encryption at rest for finance, journal entries, quick notes, `life_events`, `missions`, `daily_risks`, and `calendar_items`
- Legacy plaintext migration for encrypted mobile collections
- Safe local-store fallback that avoids app crash if secure storage is unavailable
- Protected local export bundle to app-private storage
- HomeMemory submission assets copied into a private vault instead of persisting only external metadata refs
- Local delete-all flow
- Support queue plus backend operational export/delete workflows in admin
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

- Secure-storage behavior is validated on the repo's real CI Flutter runner, but device-specific runner projects still need validation if Android, iOS, or desktop builds are added
- The admin export bundle covers backend operational metadata only; full local LifeGraph export remains device-local by design
- Device-level compromise is out of scope for app-only controls

## Release Assessment

- Privacy/export/delete: implemented at local-app level
- Privacy operations queue: implemented in admin with real backend operational jobs
- Remaining before wider beta: expand encryption review to more domains and tighten retention guidance
