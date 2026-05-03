# DDC Audit and Privacy Contracts

Date: 2026-04-26

## Routes

- `GET /admin/privacy/requests`
- `GET /admin/privacy/data-map`
- `GET /admin/security/summary`
- `GET /admin/audit?limit=&offset=&actor=&action=`

## AuditLogRow

- `audit_id`
- `actor_id`
- `action`
- `target_type`
- `target_id`
- `safe_diff`
- `correlation_id`
- `created_at`
