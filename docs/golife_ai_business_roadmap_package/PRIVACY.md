# GoLife AI Privacy

## Non-negotiables

- AI is opt-in
- privacy is controlled per domain
- local-only mode must remain useful
- no silent background sharing
- no reuse of user data for training without explicit opt-in

## Domain permission model

Each domain can be handled separately:

- `local_only`
- `sync_allowed`
- `ai_allowed`

Only `ai_allowed` data can be summarized for the gateway.

## Data minimization

- send summaries, not raw histories, when summaries are enough
- avoid names and free text when structured fields are enough
- do not log full prompts with personal data
- never require wardrobe photos, receipts or pantry photos for the MVP

## Safety boundaries

GoLife does not provide:

- medical diagnosis or treatment
- legal advice
- investment, tax or credit advice

High-risk requests should be refused or routed back as human-review-needed.

## UX trust requirements

Each recommendation should show:

- what signals influenced it
- how certain it is
- whether confirmation is required
- whether the response came from mock fallback
