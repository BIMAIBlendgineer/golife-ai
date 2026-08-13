# SPEC — AI Gateway and Safety

## Purpose
Centralize AI calls, policy enforcement, prompt assembly, model routing, structured output and fallback visibility.

## Pipeline
```text
request
→ auth/entitlement
→ privacy filter
→ safety precheck
→ prompt assembly
→ model route
→ structured output
→ output safety review
→ ranking
→ trace
→ response
```

## Production requirements
- Mock mode blocked.
- `/ready` fails if live AI config is missing.
- Safety policy versioned.
- Fallback state visible.
- Structured output validation.
- No hidden data expansion.

## Safety exclusions
- medical diagnosis;
- legal advice;
- financial advice;
- self-harm guidance;
- coercive missions;
- unsafe actions.
