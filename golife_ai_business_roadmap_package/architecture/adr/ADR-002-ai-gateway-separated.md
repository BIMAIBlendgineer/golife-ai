# ADR-002 — Separate AI Gateway from Mobile App

## Status

Accepted.

## Decision

Use a separate FastAPI AI Gateway.

## Rationale

- hide provider keys;
- swap providers;
- centralize safety;
- test agents independently.

## Consequences

Adds backend complexity but avoids embedding LLM logic in Flutter.
