# 16 - Data Privacy and Safety

## Principles

1. Minimize data.
2. Ask for explicit consent.
3. Show what influenced the output.
4. Keep export and deletion possible.
5. Keep local-only mode useful.
6. Default to safe language and reversible actions.

## Sensitive domains

GoLife handles signals that reveal daily routines and private behavior:

- spending
- habits
- purchases
- pantry inventory
- wardrobe purchases
- planning context

Treat all of them as sensitive by default.

## AI rules

- send summaries when summaries are enough
- avoid free text and names when structured fields are enough
- do not send photos without clear consent
- do not log raw personal prompts by default
- do not use user data for training without explicit opt-in

## Safety policy

The gateway should refuse or block requests that ask for:

- medical diagnosis or treatment
- legal advice
- investment, tax or credit advice
- destructive actions without confirmation

## Safety card contents

Sensitive recommendations should always expose:

- evidence
- uncertainty
- whether the action is reversible
- whether human review is better
