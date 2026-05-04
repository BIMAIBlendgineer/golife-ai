# F01 UI/UX Storyboard — PlantMind Premium

## Rule

Users always use PlantMind AI. The mobile app must not show OpenRouter, API keys, provider settings or internal model names.

Admin-web is company-facing and may show model, cost, usage, router health and internal operations. It must never show secrets.

## Panels

### Mobile
1. Settings Hub
2. PlantMind AI Usage
3. Paywall / Upgrade
4. Backup & Sync
5. Privacy
6. AI Hub / History

### Admin
7. Dashboard Overview
8. Users / Installations
9. AI Usage / Cost
10. Model Configuration
11. Router Health
12. Plans & Entitlements
13. Storage
14. Content CMS
15. Support / Safety / Quality
16. Analytics

## Acceptance
- No OpenRouter text in mobile.
- No API key entry in mobile.
- PlantMind AI usage/quota visible.
- Backup/storage separated from AI usage.
- Admin sees internal costs/model/router status.
- Admin never sees secrets.
- Empty/loading/error/quota/read-only states must be implemented.
# Historical / legacy reference
#
# This storyboard predates the current runtime naming and topology. Use current product and release-readiness docs before treating it as active scope.
