# 31 - Product Strategy Review

Fecha: 2026-04-24

## Verdict

GoLife AI has a strong thesis, but the product still risks becoming too wide before it becomes habit-forming.
The only viable launch shape is a tight loop:

`capture -> mission -> action -> feedback`

## Evaluation

### Positioning sharpness

- Current state: promising, but too broad in some docs.
- Decision: anchor the product around `AI Daily Missions`.

### MVP scope

- Current state: close, but still includes too many future-facing ideas.
- Decision:
  - keep: tasks, habits, pantry, expense logging, daily mission, explanation, feedback;
  - reduce: weekly planning to lightweight support;
  - postpone: family, OCR, wearables, calendar sync, visual wardrobe.

### Monetization risk

- Main risk: recurring LLM cost before willingness to pay is proven.
- Decision:
  - free tier with clear AI limits;
  - one simple Plus offer first;
  - no Family-first and no Lifetime-first launch.

### Onboarding friction

- Main risk: asking users to configure six domains before they see value.
- Decision:
  - onboarding in 3 steps max;
  - first mission inside 5 minutes;
  - start with tasks + habits + pantry or expense, not every module.

### Retention loop

Correct loop:

1. user captures minimal friction;
2. app returns 3 missions;
3. user completes at least 1;
4. app explains why it mattered;
5. user returns tomorrow.

### Privacy risk

- High, because multiple personal domains are combined.
- Decision:
  - privacy by domain;
  - AI opt-in;
  - visible trace;
  - usable mode without AI.

### Daily decision-making test

Every feature must pass this test:

> Does this make today's decision easier?

If not, it should not be in the MVP.

## Rejected or postponed features

- advanced receipt OCR
- fridge photo workflows
- social/community
- family collaboration
- calendar integrations
- full visual wardrobe
- banking integrations
- affiliate shopping suggestions

## Final recommendation

Proceed with the `clean-room commercial` route.

Wedge statement:

> GoLife AI = 3 realistic missions every morning based on your tasks, habits, spending and pantry context.
