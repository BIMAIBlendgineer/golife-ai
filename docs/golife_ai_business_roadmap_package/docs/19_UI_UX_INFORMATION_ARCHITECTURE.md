# 19 - UI/UX Information Architecture

## Recommended navigation

Bottom navigation:

1. Today
2. Capture
3. Plan
4. Money
5. Pantry
6. More

Wardrobe should live inside `More` for the MVP.

## Today

Today is the product center. It should contain:

- greeting and day context
- 3 main missions
- evidence and uncertainty
- visible risks or blocked items
- quick feedback actions
- fallback state when AI is disabled

## Capture

Capture should be one input first, routing second.

Initial modes:

- text
- quick chips
- voice later
- photo later

## Plan

Plan is lightweight in the MVP:

- today and this week
- overloaded vs realistic signals
- task and habit alignment

## Money and Pantry

Keep both narrow and mission-linked:

- Money: manual expenses, pattern hints, no banking integration
- Pantry: inventory, expiry awareness, anti-waste plan

## More

- wardrobe
- settings
- privacy
- subscription
- export

## UX rule

Do not show all domains with equal weight on day one. The interface should progressively reveal complexity after the user trusts the Today loop.
