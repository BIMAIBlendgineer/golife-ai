# ADR-005 — LangGraph para orquestación de IA

## Estado
Aceptado.

## Contexto
GoLife necesita memoria, pasos verificables, pausa para revisión humana y flujos multi-dominio.

## Decisión
Usar LangGraph para flujos durables:

- classify_day_state;
- detect_patterns;
- generate_candidates;
- guardrail_review;
- human_confirmation;
- persist_trace.

## Consecuencias
- Más estructura que una llamada LLM simple.
- Mejor control de decisiones.
- Facilita trazabilidad y reanudación.
