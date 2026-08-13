# ADR-004 — LangGraph for Agent Orchestration

## Status

Proposed.

## Decision

Use LangGraph when flows require routing, state, memory, retries and human confirmation.

## Alternative

Use simple LangChain chains or direct LLM calls for MVP.

## Guidance

MVP can start without LangGraph. Adopt LangGraph when multi-agent flow becomes hard to manage.
