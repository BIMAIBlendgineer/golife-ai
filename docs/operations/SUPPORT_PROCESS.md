# GoLife AI Support Process

## Purpose

Support exists to resolve product issues, privacy requests, trust concerns, and beta feedback without exposing raw user payloads to operational tools.

## Channels

- Product support: `support@golife.local`
- Privacy requests: `privacy@golife.local`
- Operations escalation: `ops@golife.local`

## Intake Types

- Access or login issue
- Export request
- Delete request
- Billing or quota issue
- Safety concern
- AI quality complaint
- Bug report

## First Response Targets

- P0 outage or privacy incident: `4 business hours`
- P1 blocked workflow: `1 business day`
- P2 general bug or product question: `2 business days`
- Export/delete request acknowledgement: `1 business day`

## Export/Delete Flow

1. Confirm the request identity in the support system.
2. Mark the request in the admin support queue.
3. Trigger local guidance for the user when possible.
4. For server-side operational records, complete the request through the admin workflow.
5. Record completion timestamp and operator note.

## Safety Escalation

- Any report of harmful, regulated, or unsafe AI output becomes a safety review ticket.
- Keep only operational metadata in admin unless a protected investigation is required.
- Mission feedback notes and reflection text must stay redacted from admin by default.
- Feature flags may be used to disable a risky route or model profile immediately.

## Bug Handling

- Reproduce on the smallest affected surface: mobile, ai_gateway, web_backend, or admin_next.
- Capture only minimal metadata needed for reproduction.
- Link support ticket to commit or release note when fixed.

## Beta Support Notes

- Closed beta users get human review for export/delete and safety requests.
- Product feedback should be tagged by domain: task, habit, finance, pantry, week, wardrobe, mission.
