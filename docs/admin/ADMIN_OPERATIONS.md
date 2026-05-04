# Admin Operations

## Purpose

The admin panel is the operational view for support, privacy, safety, quality, usage, and routing. It is not a raw personal data console.

## Source-state semantics

Every critical admin page should make the source state clear:

- `live`: backend reachable and current data available
- `fallback`: snapshot or fallback path is being shown
- `offline`: backend unreachable

This visibility exists to avoid presenting stale or seeded data as premium live production data.

## Core pages

- dashboard
- users
- privacy data map
- security summary
- audit log
- HomeMemory summary
- quality summary
- incidents
- usage
- AI costs
- missions
- feedback
- safety
- feature flags
- models
- support export/delete

## Support export/delete workflow

### Export request

1. Open `/support/export-delete`.
2. Find the `export` request.
3. Download the metadata-only operational bundle.
4. Review counts and checksum if needed.
5. Resolve the request in admin after handling.

### Delete request

1. Open `/support/export-delete`.
2. Find the `delete` request.
3. Execute operational delete.
4. Confirm returned record counts.
5. Record any out-of-band local-device guidance separately.

## Privacy boundaries

Admin should see:

- operational summaries
- metadata-only export bundle contents
- safety/quality/support state

Admin should not see:

- raw local LifeGraph export
- raw reflection text
- raw mission feedback notes
- raw attachment bytes

## Safety operations

- use the safety page for metadata review
- treat blocked inputs as sensitive even when admin only sees category/rule metadata
- use feature flags or routing/model controls to reduce exposure if needed

## Security operations

- production readiness is not enterprise SSO readiness
- token plus operator secret is stronger than token-only scaffold, but still not full enterprise identity
- OpenRouter and BYOK material should remain masked in admin responses

## Operational limits

- admin export/delete affects backend operational records, not the full local mobile graph
- fallback and offline states are expected in local/dev testing and must remain visible
