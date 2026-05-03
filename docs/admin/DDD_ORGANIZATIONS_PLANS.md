# DDD Organizations and Plans

Date: 2026-04-26

## Aggregates

- `Organization`
- `OrganizationMember`
- `Plan`
- `SubscriptionState`

## Rules

- an organization can have many users
- a user can belong to one organization in the current MVP
- plan defines limits and commercial policy
- no fake invoice or payment processor behavior in this phase
