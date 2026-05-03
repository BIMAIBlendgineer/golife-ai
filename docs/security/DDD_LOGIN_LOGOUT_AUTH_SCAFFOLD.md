# DDD — Login Logout Auth Scaffold

## Aggregates
- `AdminSession`
- `AdminIdentity`
- `AdminRole`

## Rules
- Token-only access is scaffold, not enterprise auth.
- Logout clears scaffold session cookie.
- Backend authorization still stays server-side.
- Do not expose backend admin token in client code.
