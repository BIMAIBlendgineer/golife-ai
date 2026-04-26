# DDD Web Admin Security and Privacy

Date: 2026-04-26

## Aggregates

- `PrivacyRequest`
- `SecurityEvent`
- `AuditLog`

## Rules

- no raw sensitive data in admin
- admin writes generate audit entries
- secrets never enter audit payloads
- safe diffs only
- insecure production defaults must remain visible
