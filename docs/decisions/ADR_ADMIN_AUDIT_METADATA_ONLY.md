# ADR Admin Audit Metadata Only

Date: 2026-04-26
Status: accepted

## Decision

Admin audit logs must remain metadata-only.

## Reason

Operational traceability is necessary, but raw feedback, proof, journal, reflection, or secret material would turn the audit layer itself into a leak surface.
