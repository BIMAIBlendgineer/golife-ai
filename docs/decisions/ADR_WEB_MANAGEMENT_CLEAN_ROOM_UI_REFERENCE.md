# ADR Web Management Clean Room UI Reference

Date: 2026-04-26
Status: accepted

## Decision

Use the referenced shadcn-style dashboard template only as visual inspiration. Do not copy code or assets into GoLife admin.

## Context

GoLife already has:

- an existing App Router admin
- established route names
- existing i18n
- server-only admin API access
- product-specific operational concepts

The referenced template is useful as a benchmark for:

- dashboard density
- table ergonomics
- sidebar hierarchy
- topbar affordances

But it also contains unrelated page families and a much broader demo structure than GoLife needs.

## Consequences

Positive:
- no licensing ambiguity in implementation
- no route drift
- no accidental product fork
- easier maintenance because components stay aligned with GoLife contracts

Negative:
- more implementation work than copy-adapting a template

## Rule

Clean-room implementation is mandatory for:

- layout code
- components
- copy
- data shapes
- route structure
