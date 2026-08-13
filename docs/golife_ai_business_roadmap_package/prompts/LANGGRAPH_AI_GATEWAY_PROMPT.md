# Prompt — LangGraph AI Gateway

Implement a LangGraph-style orchestration for GoLife AI.

Nodes:

1. normalize_input
2. classify_domain
3. retrieve_life_context
4. safety_check
5. route_agent
6. generate_recommendation
7. validate_schema
8. build_explanation
9. persist_trace
10. return_response

Agents:

- DailyMissionAgent
- TaskDoctorAgent
- MoneyMirrorAgent
- FridgeZeroAgent
- ClosetLessAgent

Provider:

- OpenRouter first;
- swappable provider interface;
- MockProvider for tests.

All responses must be JSON-schema-valid.
