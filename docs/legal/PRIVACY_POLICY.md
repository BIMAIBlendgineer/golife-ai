# GoLife AI Privacy Policy

Last updated: `2026-05-16`

## Scope

GoLife AI is a local-first daily decision app. It helps users capture events, review priorities, and act on up to three daily missions across tasks, habits, pantry, spending awareness, weekly planning, and purchase restraint.

GoLife AI is not a medical, therapy, legal, or regulated financial advice service.

## What data the app stores locally

The app stores product data on the device so the user can keep working without a permanent network connection. Local collections can include:

- LifeGraph events
- mission snapshots
- daily risks
- mission feedback
- evidence items
- LifeGraph relations
- privacy audit entries
- tasks, habits, expenses, pantry items, weekly plans, purchase intentions
- journal entries and quick notes
- calendar items and recipe rescue items
- HomeMemory records such as owned items, purchase proofs, reminders, and claim drafts
- metadata-only analytics events

Some sensitive local collections are encrypted at rest when secure storage is available on the device runtime.

## When data may leave the device

GoLife AI only sends event data to the AI Gateway when both of these conditions are true:

1. the domain is allowed for AI by the current privacy settings; and
2. the individual event is marked as AI allowed.

If either condition is not met, the event stays local and is excluded from AI requests.

The app also records source-state and fallback visibility so the user can see whether a mission came from live AI, degraded fallback, or fully local behavior.

## Metadata-only analytics

GoLife AI records local analytics and KPI events for product traceability. These analytics are metadata only.

The analytics layer does not store raw LifeGraph payloads, journal text, receipt text, claim text, freeform capture text, or file references.

## Export and delete

GoLife AI provides local export and delete controls inside the app.

- Export creates a protected local bundle with the current local snapshot.
- Delete all removes local app data from the device.
- Clear AI history removes locally stored mission and AI feedback history without deleting the full LifeGraph.

## Sharing and sale of data

GoLife AI does not sell user data.

Local analytics in the current runtime are not sent to a remote analytics pipeline.

## Children

GoLife AI is designed for adult users managing daily life information. It is not positioned as a service for children.

## Policy changes

If the product scope changes materially, this policy should be updated in the repository and in the in-app legal links before release.

## Support

Public support instructions are available at:

- `https://github.com/BIMAIBlendgineer/golife-ai/blob/main/docs/legal/SUPPORT.md`
