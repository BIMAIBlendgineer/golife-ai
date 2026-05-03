# DDD Billing and Storage

Date: 2026-04-26

## Aggregates

- `BillingAccount`
- `SubscriptionPlan`
- `StorageUsage`
- `QuotaUsage`

## Rules

- no fake real-world payment settlement
- invoices remain placeholder-only unless a provider exists
- storage is charged separately from AI
- BYOK does not charge internal AI credits
