# DDC AI Billing and BYOK Contracts

Date: 2026-04-26

## BYOK endpoints

- `GET /admin/openrouter-byok`
- `POST /admin/openrouter-byok`
- `PATCH /admin/openrouter-byok/{key_id}`
- `POST /admin/openrouter-byok/{key_id}/test`
- `POST /admin/openrouter-byok/{key_id}/disable`
- `POST /admin/openrouter-byok/{key_id}/rotate`

## xInsightAI endpoints

- `GET /admin/xinsightai/usage`
- `GET /admin/xinsightai/credits`
- `GET /admin/xinsightai/plans`

## OpenRouterByokKeyRecord

- `key_id`
- `organization_id`
- `project_id`
- `label`
- `secret_last4`
- `status`
- `created_at`
- `last_used_at`
- `disabled_at`
- `scopes`

## AiUsageLedgerRow

- `id`
- `organization_id`
- `user_id`
- `ai_mode`
- `provider`
- `model`
- `endpoint`
- `input_tokens`
- `output_tokens`
- `platform_cost_usd`
- `customer_charge_usd`
- `xinsight_credits_debited`
- `byok_external_billing`
- `created_at`
