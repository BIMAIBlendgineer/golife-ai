# Prompt — Implementar grafo de misión diaria

Crea un grafo LangGraph para generar misión diaria.

Nodos:

1. `validate_consent`
2. `summarize_events`
3. `classify_day_state`
4. `detect_patterns`
5. `generate_candidates`
6. `guardrail_review`
7. `rank`
8. `build_response`

Entrada:

- LifeEvent[]
- privacy settings
- domain summaries
- constraints

Salida:

- máximo 3 sugerencias;
- cada sugerencia con evidencia;
- incertidumbre;
- confirmación requerida;
- trace.

Incluye provider mock y test con tres casos:

1. tareas + hábitos;
2. finance + pantry;
3. wardrobe + purchase_intention.
