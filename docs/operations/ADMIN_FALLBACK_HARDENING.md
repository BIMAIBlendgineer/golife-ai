# Admin Fallback Hardening

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `7`
Status: `verified; no code change required`

## Goal

Confirm that production operators cannot mistake fallback or offline admin data for live backend state.

## Files reviewed

- `apps/admin_next/app/layout.tsx`
- `apps/admin_next/components/page-shell.tsx`
- `apps/admin_next/components/premium/premium-topbar.tsx`
- `apps/admin_next/components/premium/source-state-badge.tsx`
- `apps/admin_next/lib/api.ts`

## Findings

1. `RootLayout` wraps the entire admin app with `PageShell`.
2. `PageShell` calls `getBackendHealth()` on every render path for the shell.
3. `PageShell` derives a global `source` value of `live`, `fallback`, or `offline`.
4. `PremiumTopbar` renders `SourceStateBadge` for that global state.
5. `adminRequest()` in `lib/api.ts` already returns explicit `source` metadata and fallback messages.

## Result

The repo already enforces a shell-level visibility rule:

- `live`: backend answered with live data
- `fallback`: backend answered through seeded or fallback state
- `offline`: backend unreachable

Because the topbar is inherited from the root layout, every route gets a visible source-state indicator without per-page duplication.

## Residual risk

This hardening only holds while new admin routes continue to render inside the same root layout and do not bypass `PageShell`.

## Required rule for future admin work

Any new admin surface must keep the global shell and must not hide the topbar state pills in production.

## Gate decision

- Fallback visibility gate: passed
- Code change: not needed in this phase
