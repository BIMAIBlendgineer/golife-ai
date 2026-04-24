# GoLife AI Architecture

## Principles

- clean-room rebuild
- Flutter mobile shell
- FastAPI gateway
- LangGraph-style orchestration
- swappable provider interface
- local-first fallback
- privacy by domain
- explicit evidence, uncertainty and trace

## Layers

1. Mobile app stores `LifeEvent` objects locally and stays usable without AI.
2. The app sends only consented and minimized summaries to the gateway.
3. The gateway runs orchestration, safety, routing and schema validation.
4. Providers sit behind one interface: `OpenRouterProvider` first, `MockProvider` fallback.
5. The response returns structured recommendations plus trace metadata.

## Orchestration nodes

1. `normalize_input`
2. `classify_domain`
3. `retrieve_life_context`
4. `safety_check`
5. `route_agent`
6. `generate_recommendation`
7. `validate_schema`
8. `build_explanation`
9. `persist_trace`
10. `return_response`

## Initial agents

- `DailyMissionAgent`
- `TaskDoctorAgent`
- `MoneyMirrorAgent`
- `FridgeZeroAgent`
- `ClosetLessAgent`

## Failure behavior

- if OpenRouter is unavailable, the gateway falls back to `MockProvider`
- if provider output is invalid, the gateway falls back to deterministic structured payloads
- if AI is disabled for a domain, the gateway returns a safe blocked response instead of guessing
- if safety rules trigger, the gateway refuses or demands confirmation

## Minimum promise

The app is still useful when:

- AI is disabled
- the provider times out
- the schema validation fails
- the user restricts domains such as money or pantry
