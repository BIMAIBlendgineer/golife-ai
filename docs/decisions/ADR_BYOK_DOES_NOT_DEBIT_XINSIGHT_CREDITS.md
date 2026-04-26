# ADR BYOK Does Not Debit xInsightAI Credits

Date: 2026-04-26
Status: accepted

## Decision

When a customer uses BYOK, GoLife does not debit xInsightAI credits for that traffic.

## Reason

The external model cost is borne by the customer through OpenRouter. GoLife may still charge platform and storage fees, but not internal AI credits for that request path.
