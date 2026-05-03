# DDD User Management Premium

Date: 2026-04-26
Branch: `codex/premium-web-management`

## Aggregate

`UserOps`

## Purpose

Operate user state safely at scale for support, privacy, and AI quality follow-up.

## Entities

- `UserManagementRow`
- `UserSummary`
- `UserUsageSummary`
- `UserPrivacySummary`
- `UserSupportSummary`

## Rules

- pagination is mandatory
- filters are mandatory
- list views must use masked email
- locale and plan must be visible
- support and privacy state must be visible
- no journal text
- no reflection text
- no receipt/proof text
- no HomeMemory personal content

## Notes

User detail is metadata-only and should be presented as an operator dossier, not a content browser.
