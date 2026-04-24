# GoLife AI License Review

## Primary Source of Truth

- Generated matrix: [LICENSE_MATRIX.md](/C:/0%20Work/GoLife%20AI/docs/generated/LICENSE_MATRIX.md)
- ADR: [ADR-011-license-first-development.md](/C:/0%20Work/GoLife%20AI/docs/adrs/ADR-011-license-first-development.md)

## Current Position

- MIT-friendly references may inform clean-room implementations
- GPL repositories must not be copied directly into proprietary surfaces without a deliberate licensing decision
- Current mobile domain files are written as clean-room rewrites and include provenance notes where relevant

## Known Sensitive Inputs

- Habo: GPL-3.0
- WeekToDo: GPL-3.0
- Flow: GPL-3.0

## Known Safer Inputs

- Taskly: MIT
- Wanna: MIT
- OpenWardrobe app/db: MIT, but provenance still needs normal verification discipline

## Review Outcome

- No source repo folders remain in the active root structure
- Clean-room approach is still the correct default
- License review for this release is acceptable provided the generated matrix remains updated
