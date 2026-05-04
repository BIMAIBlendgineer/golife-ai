# GoLife AI License Review

## Primary source of truth

- generated matrix: `docs/generated/LICENSE_MATRIX.md`
- ADR: `docs/adrs/ADR-011-license-first-development.md`

## Current position

- MIT-friendly references may inform clean-room implementations
- GPL repositories must not be copied directly into proprietary surfaces without a deliberate licensing decision
- current mobile domain files are written as clean-room rewrites and include provenance notes where relevant

## Known sensitive inputs

- Habo: GPL-3.0
- WeekToDo: GPL-3.0
- Flow: GPL-3.0

## Known safer inputs

- Taskly: MIT
- Wanna: MIT
- OpenWardrobe app/db: MIT, but provenance still needs normal verification discipline

## Review outcome

- no source repo folders remain in the active root structure
- clean-room approach is still the correct default
- license review for this release is acceptable provided the generated matrix remains updated
