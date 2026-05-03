# DDC Organizations and Plans Contracts

Date: 2026-04-26

## Routes

- `GET /admin/organizations`
- `GET /admin/organizations/{organization_id}`
- `GET /admin/plans`

## OrganizationRow

- `organization_id`
- `name`
- `status`
- `plan`
- `user_count`
- `storage_used_gb`
- `ai_mode_default`
- `created_at`

## PlanRow

- `plan_id`
- `name`
- `price_label`
- `user_limit`
- `storage_limit_gb`
- `ai_credit_policy`
- `byok_allowed`
- `support_level`
