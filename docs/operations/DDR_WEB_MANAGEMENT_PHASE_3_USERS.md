# DDR Web Management Phase 3 Users

Date: 2026-04-26

## Decision

Upgrade `/users` in place instead of creating a second user-management route family.

## Why

The route already exists, but the current implementation is a seed-scale roster. Premium operations need:

- filterable rows
- paginated transport
- masked personal identifiers
- safe metadata summaries

## Non-goals

- no content browser
- no raw sensitive exports
- no duplicate `/admin/users` route family in the frontend
