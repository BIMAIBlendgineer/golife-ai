# DDD OpenRouter BYOK and xInsightAI

Date: 2026-04-26

## Aggregates

- `OrganizationAiConfig`
- `OpenRouterByokKey`
- `AiUsageLedger`
- `AiCreditLedger`
- `XInsightAIPlan`

## Rules

- BYOK secrets are encrypted server-side
- frontend only sees `last4`
- BYOK usage never debits xInsightAI credits
- xInsightAI usage does debit xInsightAI credits
- platform/storage charges remain separate from external OpenRouter billing
