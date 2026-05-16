# Commercial Support Runbook

## Scope

This runbook covers the minimum commercial support flows for the current GoLife AI scope:

- cancellation and renewal-state questions;
- refund escalation tracking;
- local export requests;
- local delete requests;
- AI outage response;
- provider cost spike response;
- unsafe content reports;
- store review issues.

## Cancellation

1. Confirm the user platform and current billing state.
2. If billing is disabled for the current release, state that no recurring subscription is active in-product.
3. If store billing is later enabled, direct the user to the native store subscription screen and record the renewal state change in support notes.

## Refund

1. Record platform, purchase date, and entitlement status.
2. Do not promise a refund outcome inside support copy.
3. Route the user to the native store refund flow when billing is store-managed.
4. Mark the case as `refund_pending`, `refund_seen`, or `refund_rejected` in support metadata only.

## Export

1. Confirm whether the user wants a local export bundle only.
2. Instruct support to use the in-app export action or the documented local export path.
3. Record only metadata: request timestamp, completion timestamp, and delivery confirmation.

## Delete

1. Confirm the user understands this clears local device data.
2. Trigger the in-app delete flow only after explicit confirmation.
3. Verify that demo seed remains disabled after delete unless the user opts back in.

## AI Outage

1. Check `/health` and `/ready`.
2. If `/ready` fails for production conditions, stop release activity and keep source state visible as fallback/local only.
3. If AI is temporarily unavailable, preserve local capture and local mission fallback behavior.

## Provider Cost Spike

1. Check model routing, request volume, and fallback rate.
2. Prefer lowering refresh frequency or moving traffic to documented lower-cost routes before broadening scope.
3. Do not silently degrade the user-facing source-state label.

## Unsafe Content

1. Capture the correlation id, route, locale, and policy category.
2. Do not copy raw sensitive user text into support systems.
3. Confirm whether the block came from input policy, output policy, or reflection safety.

## Store Review Issue

1. Cross-check the complaint against `docs/marketing/PLAY_STORE_LISTING.md`, privacy disclosures, and the current release artifact.
2. Run `store-copy-lint` before editing copy.
3. If the issue is about unsupported claims, remove the claim before resubmission rather than adding explanation around it.
