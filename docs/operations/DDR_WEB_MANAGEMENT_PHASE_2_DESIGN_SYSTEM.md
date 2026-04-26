# DDR Web Management Phase 2 Design System

Date: 2026-04-26
Branch: `codex/premium-web-management`

## Decision

Upgrade the current admin shell and shared components into a premium, operator-grade design system without changing the core route family.

## Why

The current admin works as a prototype, but premium operations for thousands of users need:

- clearer state hierarchy
- denser tables
- reusable filters and drawers
- source/environment visibility
- safer secret and audit presentation patterns

## Delivery scope

- new `components/premium/*`
- refactored shell/sidebar/topbar
- reusable badges, cards, tables, drawers, empty/error/loading states
- command palette scaffold for operator navigation
- i18n-preserving integration

## Non-goals

- replacing the route map
- adding forbidden route families
- changing backend contracts in this phase

## Constraint carried forward

All future admin pages should consume the premium system rather than invent new local one-off styles.
