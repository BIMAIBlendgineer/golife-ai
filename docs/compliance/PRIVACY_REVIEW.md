# GoLife AI Privacy Review

## Current boundary

- personal LifeGraph data remains device-local by default
- mobile fetches runtime config only; it does not sync the full personal graph in v1
- AI requests are filtered locally by domain permission and event privacy level
- admin surfaces use operational metadata and should not store raw personal payloads

## Implemented controls

- per-domain privacy settings in mobile
- per-item privacy confirmation during multi-event capture
- encrypted-at-rest local storage for the most sensitive mobile collections
- safe secure-storage fallback that avoids app crash if device secure storage is unavailable
- protected local export bundle to app-private storage
- submission assets copied into a private vault instead of storing only external metadata refs
- local delete-all flow that clears graph data plus submission-asset vault contents
- backend support queue with real admin export/delete workflows for operational metadata
- public mobile runtime-config endpoint with no secrets
- internal routing config endpoint protected by internal token
- metadata-only safety telemetry
- mission feedback redaction in gateway, backend, and admin views

## Data boundaries

### Leaves device only by allowed flow

- AI requests to `services/ai_gateway`
- mission feedback to `services/ai_gateway`
- runtime config pull from `services/web_backend`

### Stays local by design in v1

- full LifeGraph history
- raw local entity database replication
- raw reflection content in admin telemetry
- raw mission feedback note text in admin telemetry
- protected submission asset bytes in operational backend

## Export/delete posture

- mobile export: protected local bundle with `data.json` plus `assets/`
- mobile delete: `deleteAllLocalData()` clears local data and private asset vault
- backend export: metadata-only operational bundle
- backend delete: operational records only, not local device data

See:

- [Data map](DATA_MAP.md)
- [Support process](../operations/SUPPORT_PROCESS.md)
- [F04 admin export/delete workflow](../operations/F04_11_ADMIN_EXPORT_DELETE_WORKFLOW.md)
- [F04 secure mobile export bundle](../operations/F04_16_SECURE_MOBILE_EXPORT_BUNDLE.md)

## Residual risks

- secure-storage behavior is validated on the checked CI Flutter runner, but device-specific runners still need validation if Android, iOS, or desktop projects are added
- the admin export bundle covers backend operational metadata only; full local LifeGraph export remains device-local by design
- device-level compromise is out of scope for app-only controls

## Release assessment

- privacy/export/delete: implemented across mobile plus backend operational workflow
- privacy operations queue: actionable in admin
- remaining before broader release: stronger retention guidance, broader encrypted-domain review, evidence-aware mission ranking review, and device-specific validation if new runners are added
