# DDD Web Management Scope

Date: 2026-04-26
Branch: `codex/premium-web-management`

## Product boundary

GoLife AI web management is an internal operating surface for the GoLife platform. It is not a separate product, and it must not replace or redefine the mobile and AI product thesis.

The management surface exists to operate:

- users
- organizations
- plans
- AI usage and cost
- BYOK and global OpenRouter keys
- xInsightAI internal billing
- storage and privacy posture
- support and audit workflows
- aggregate product quality and incident signals

## Existing subdomains in repo today

- `DashboardOps`
- `UserOps`
- `UsageOps`
- `AiCostOps`
- `OpenRouterOps`
- `MissionQualityOps`
- `SafetyOps`
- `FeatureFlagOps`
- `SupportOps`
- `RoutingOps`
- `ModelCatalogOps`

## Missing premium subdomains

- `OrganizationOps`
- `BillingOps`
- `StorageOps`
- `PrivacyOps`
- `SecurityOps`
- `AuditOps`
- `BYOKOps`
- `XInsightAIOps`
- `QualityOps`
- `IncidentOps`
- `HomeMemoryAggregateOps`
- `AuthScaffoldOps`
- `ScaleOps`

## Aggregates

### UserOps

Purpose:
- operate individual user state safely at scale

Core entities:
- `AdminUser`
- `UserUsageSummary`
- `UserPrivacySummary`
- `UserSupportSummary`
- `UserRiskSummary`

Rules:
- metadata-first
- no raw journal/reflection/proof text
- email should be masked in list views
- pagination and filters are mandatory

### OrganizationOps

Purpose:
- operate Family, Team, and Enterprise groupings without changing the mobile product

Core entities:
- `Organization`
- `OrganizationMember`
- `OrganizationAiConfig`

Rules:
- organizations aggregate users
- org defaults shape platform behavior and billing

### AiUsageOps

Purpose:
- explain usage, cost, fallback, routing, and model quality

Core entities:
- `AiUsageLedger`
- `AICostSnapshot`
- `RoutingProfile`
- `ModelSelectionSnapshot`

Rules:
- distinguish global platform keys, BYOK, and xInsightAI
- do not expose secrets

### BillingOps

Purpose:
- expose plan, storage, and xInsightAI charges without pretending payment integration exists

Core entities:
- `BillingAccount`
- `SubscriptionPlan`
- `SubscriptionState`
- `AiCreditLedger`

Rules:
- no fake invoices as if they were settled financial records
- storage is separate from AI charges
- BYOK does not debit xInsightAI credits

### StorageOps

Purpose:
- show operational storage posture and pricing impact

Core entities:
- `StorageUsage`
- `QuotaUsage`

Rules:
- surface encrypted collections
- surface retention risk
- surface HomeMemory only as aggregate metadata

### PrivacyOps

Purpose:
- operate export/delete requests and data handling posture

Core entities:
- `PrivacyRequest`
- `DataMapSummary`

Rules:
- admin sees categories and status, not intimate content

### SecurityOps

Purpose:
- operate production readiness and secret/key posture

Core entities:
- `SecurityEvent`
- `SecuritySummary`

Rules:
- secrets never leave the server
- unsafe defaults must be visible

### AuditOps

Purpose:
- record operator-impacting writes with safe metadata

Core entities:
- `AuditLog`

Rules:
- metadata only
- no secrets
- no raw sensitive payloads
- every admin write should have an auditable trail

### HomeMemoryAggregateOps

Purpose:
- expose health of HomeMemory as a product capability without leaking item-level personal data

Core entities:
- `HomeMemorySummary`
- `HomeMemoryParserUsage`

Rules:
- no item names
- no receipt text
- no serial numbers
- no claim body
- dependency on PR `#3` must be documented until merged

### QualityOps and IncidentOps

Purpose:
- explain if the product is actually working well and when it is failing

Core entities:
- `QualitySummary`
- `Incident`

Rules:
- use aggregate metrics
- safe summary only

## Cross-cutting rules

- Preserve the existing route family. Do not create `/control`, `/admin`, or `/studio`.
- Preserve existing i18n support.
- Keep secrets server-only.
- Keep operational telemetry metadata-only.
- Keep HomeMemory admin aggregate-only until the product surface is merged and stabilized.
- Design for thousands of users, not seed-only demos.
