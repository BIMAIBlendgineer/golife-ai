# Web Management Premium UI System

Date: 2026-04-26
Branch: `codex/premium-web-management`

## Intent

Who:
- internal operators running product quality, privacy, support, billing, routing, and trust workflows for thousands of GoLife users

What they must do:
- scan health quickly
- filter dense operational lists
- enter safe admin actions without hesitation
- understand cost, privacy, and AI routing posture from the same surface

How it should feel:
- quiet
- precise
- trustworthy
- dense enough for repeated work
- never theatrical

## Domain exploration

### Domain concepts

- decision desk
- routing control plane
- trust queue
- support triage
- storage posture
- privacy map
- incident ledger
- audit trail
- AI margin view
- aggregate product health

### Color world

This product's operator view is not a marketing surface. The natural color world is:

- graphite ink from logs, ledgers, and control surfaces
- cloud white from tables and text surfaces
- mineral gray from dividers and system chrome
- moss green for healthy, trusted states
- copper for operator warnings and cost pressure
- steel blue for informational states

### Signature

The signature element is a control-plane frame:

- left rail for stable orientation
- topbar for source state, environment, and command access
- compact KPI cards
- framed tool surfaces for tables and drawers
- metadata-first detail views

### Defaults to avoid

1. Generic card-dashboard with oversized marketing spacing.
2. Decorative gradient-heavy SaaS chrome.
3. Sidebar and content areas rendered as separate visual worlds.

### Replacements

1. Dense, operator-first layout with restrained spacing.
2. Neutral system palette with small semantic accents.
3. Shared canvas with quiet borders instead of loud panel segmentation.

## Foundations

### Palette

- canvas: pale mineral
- surface: near-white
- surface raised: slightly brighter than surface
- ink: graphite
- ink-soft: muted graphite
- line: low-opacity graphite
- moss: healthy state
- copper: warning/error pressure
- steel: informational state

### Depth

- base canvas and sidebar share the same family
- data tools and drawers sit one elevation above the canvas
- badges and pills use color through subtle tint, not heavy fill

### Surfaces

- `surface-0`: page canvas
- `surface-1`: framed table/tool containers
- `surface-2`: drawers, dialogs, command palette

### Typography

- `IBM Plex Sans` for UI copy
- `IBM Plex Mono` for IDs, token tails, metrics, and ledger fields

Reason:
- it reads like an operational console, not a landing page

### Spacing

- base unit: 4px
- normal rhythm: 8px, 12px, 16px, 24px
- no oversized hero spacing in tool surfaces

## Components to introduce

- `PremiumShell`
- `PremiumTopbar`
- `PageHeader`
- `MetricCard`
- `KpiGrid`
- `StatusBadge`
- `SourceStateBadge`
- `EnvironmentBadge`
- `DataTable`
- `FilterBar`
- `DetailDrawer`
- `AuditTimeline`
- `RiskBanner`
- `CostCard`
- `ModelCard`
- `SecretInput`
- `CopyableField`
- `ConfirmDialog`
- `EmptyState`
- `ErrorState`
- `LoadingState`
- `CommandPalette`

## Rules

- no secrets rendered in client
- no raw sensitive text rendered in admin
- no forbidden routes
- keep existing admin route family and improve it in place
- preserve i18n
- support mobile and desktop widths without overflow
