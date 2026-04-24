# GoLife AI Architecture Decision

Fecha: 2026-04-24

## Decision

GoLife AI se implementara como un producto nuevo con esta arquitectura:

1. App movil principal en Flutter: `new_app/golife_flutter`
2. Gateway IA separado en FastAPI: `services/ai_gateway`
3. Orquestacion IA con LangGraph
4. Proveedor inicial LLM: OpenRouter
5. Abstraccion de proveedor obligatoria
6. Modelo de eventos comun: `LifeEvent`
7. Privacidad por dominio y gating antes de cualquier llamada al gateway

## Motivos

- La mayoria de fuentes reutilizables reales del workspace son Flutter.
- WeekToDo y Habo son GPL; no conviene fusionar su codigo con un producto propietario.
- Wanna usa Expo/React Native; es una buena fuente conceptual, no una buena base de UI para GoLife.
- Separar gateway evita exponer claves IA en la app movil.
- LangGraph permite imponer pasos de consentimiento, guardrails, ranking y trazabilidad.

## Consecuencias practicas

### Mobile

- La app Flutter sera local-first.
- Cada dominio tendra modelos propios.
- Ningun dato `local_only` saldra del dispositivo.
- La app nunca llamara OpenRouter directamente.

### AI Gateway

- El gateway recibira solo summaries y eventos permitidos.
- Todas las respuestas de IA deben ser JSON validable.
- Toda sugerencia debe incluir evidencia, incertidumbre y `requires_confirmation`.

### Domain migration

- MIT: reutilizacion selectiva posible con trazabilidad.
- GPL: referencia solamente, reescritura obligatoria.
- `finance` se construira con modelos propios minimos hasta disponer de Flow.

## Restricciones activas

- No acciones externas automaticas.
- No consejo financiero regulado.
- No diagnostico medico o de salud mental.
- No envio silencioso de datos a IA.
- No copia directa desde Habo o WeekToDo.

## Estado de fuentes

- Habo: disponible, GPL
- Taskly: disponible, MIT
- WeekToDo: disponible, GPL
- Wanna: disponible, MIT
- OpenWardrobe app (`app`): disponible, MIT con procedencia a validar
- Flow: ausente
- OpenWardrobe db: ausente

## Aprobacion operativa

Esta decision queda adoptada para los siguientes prompts:

- `02_IMPLEMENT_AI_GATEWAY_PROMPT.md`
- `03_FLUTTER_SHELL_PROMPT.md`
- `04_DOMAIN_MIGRATION_PROMPT.md`
- `05_LANGGRAPH_DAILY_MISSION_PROMPT.md`
