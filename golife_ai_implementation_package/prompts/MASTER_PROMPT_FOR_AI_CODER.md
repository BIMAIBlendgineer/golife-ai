# PROMPT MAESTRO PARA IA PROGRAMADORA — GoLife AI

Actúa como arquitecto senior de software móvil y backend. Tu tarea es convertir varios repositorios open-source existentes en un nuevo producto llamado **GoLife AI**, una app móvil que une hábitos, tareas, planificación semanal, finanzas personales, despensa/lista de compra, armario y una capa de IA explicable.

## Contexto

El usuario tendrá esta estructura local:

```text
golife-ai-lab/
  source_repos/
    habo/
    weektodo/
    flow/
    openwardrobe_app/
    openwardrobe_db/
    wanna/
    taskly/
  docs/
  prompts/
  new_app/
  services/
```

Repositorios:

- Habo: https://github.com/xpavle00/Habo
- WeekToDo: https://github.com/manuelernestog/weektodo
- Flow: https://github.com/flow-mn/flow
- OpenWardrobe app: https://github.com/OpenWardrobe/app
- OpenWardrobe db: https://github.com/OpenWardrobe/db
- Wanna: https://github.com/leechy/wanna
- Taskly: https://github.com/IMGIITRoorkee/Taskly

## Objetivo de producto

Crear **GoLife AI**, no seis apps separadas.

GoLife AI debe funcionar como un “life operating system” personal:

- hábitos como juego;
- tareas convertidas en pasos;
- semana organizada;
- gastos explicados;
- comida/despensa conectada al gasto;
- armario conectado al anti-consumo;
- IA que genera misiones pequeñas y justificadas.

## Restricciones absolutas

1. No empieces modificando código. Primero audita.
2. No mezcles código GPL en un producto propietario sin decisión explícita.
3. No borres repositorios fuente.
4. No pongas claves de IA en la app móvil.
5. No llames OpenRouter desde Flutter directamente.
6. La IA debe devolver JSON validable.
7. Toda sugerencia debe incluir evidencia e incertidumbre.
8. Toda acción externa requiere confirmación humana.
9. No dar asesoría financiera regulada.
10. No diagnosticar salud física o mental.
11. No enviar datos a IA si el dominio no tiene permiso `ai_allowed`.
12. Mantén provider IA intercambiable.

## Fase 1 — Auditoría obligatoria

Genera estos archivos antes de implementar:

```text
docs/generated/REPO_AUDIT.md
docs/generated/LICENSE_MATRIX.md
docs/generated/DEPENDENCY_MATRIX.md
docs/generated/DOMAIN_EXTRACTION_PLAN.md
docs/generated/RISK_REGISTER.md
```

Para cada repo, identifica:

- lenguaje;
- framework;
- licencia;
- estructura de carpetas;
- modelos de dominio;
- almacenamiento;
- navegación;
- estado de mantenimiento;
- dependencias críticas;
- código reutilizable;
- código que debe reescribirse;
- riesgos.

## Fase 2 — Decisión de arquitectura

Crea o actualiza:

```text
docs/generated/ARCHITECTURE_DECISION.md
```

Decisión esperada:

- Flutter como shell móvil principal.
- FastAPI como AI Gateway.
- LangGraph para orquestación IA.
- OpenRouter como proveedor inicial.
- Provider abstraction para cambiar modelo/proveedor.
- LifeGraph como columna vertebral de eventos.

## Fase 3 — Crear app Flutter

Crear:

```text
new_app/golife_flutter/
```

Módulos:

```text
lib/
  app/
  core/
    privacy/
    storage/
    ai_client/
    lifegraph/
  domains/
    habits/
    tasks/
    week/
    finance/
    pantry/
    wardrobe/
    missions/
  features/
    dashboard/
    copilot/
```

Implementar primero:

- navegación;
- tema;
- dashboard vacío;
- storage local;
- entidades base;
- LifeEvent;
- permisos por dominio.

## Fase 4 — Adaptar dominios

No copies masivamente. Haz migración limpia.

### Habo → `domains/habits`

Extraer o reescribir:

- Habit;
- HabitLog;
- streak;
- reminder;
- notes;
- stats.

### Taskly → `domains/tasks`

Extraer o reescribir:

- Task;
- TaskForm;
- priority;
- duration;
- voice input si estable;
- countdown si útil.

### WeekToDo → `domains/week`

Reescribir conceptos:

- WeekPlan;
- DayPlan;
- recurring tasks;
- subtasks;
- colors;
- local privacy.

### Flow → `domains/finance`

Extraer con cuidado:

- Account;
- Expense;
- Category;
- Budget;
- charts;
- export.

Atención: Flow ya menciona un AI receipt parser externo. No prometer que Flow está libre de IA.

### Wanna → `domains/pantry`

Reescribir:

- GroceryList;
- SharedList;
- Cart;
- PastPurchase;
- notifications.

### OpenWardrobe → `domains/wardrobe`

Extraer o reescribir:

- ClosetItem;
- Outfit;
- Supabase sync;
- Hive local;
- purchase intention.

## Fase 5 — Crear AI Gateway

Crear:

```text
services/ai_gateway/
```

Stack:

- Python 3.11+;
- FastAPI;
- Pydantic;
- LangGraph;
- LangChain opcional;
- OpenRouter provider.

Endpoints mínimos:

```text
POST /v1/suggestions/generate
POST /v1/tasks/rewrite
POST /v1/week/plan
POST /v1/missions/daily
POST /v1/pantry/rescue
POST /v1/finance/reflect
POST /v1/closet/decision
GET  /health
```

## Fase 6 — Provider abstraction

Crear:

```python
class LLMProvider:
    async def complete_json(...): ...
```

Implementar:

```text
OpenRouterProvider
```

Variables:

```env
LLM_PROVIDER=openrouter
OPENROUTER_API_KEY=
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
OPENROUTER_DEFAULT_MODEL=
OPENROUTER_FALLBACK_MODEL=
```

## Fase 7 — LangGraph

Implementar grafo:

1. validate_consent
2. summarize_events
3. classify_day_state
4. detect_cross_domain_patterns
5. generate_candidate_suggestions
6. guardrail_review
7. rank_suggestions
8. persist_trace

## Fase 8 — Mobile AI Client

En Flutter:

```text
core/ai_client/
  ai_gateway_client.dart
  dto/
  mappers/
```

Regla:

- mandar solo summaries permitidos;
- no enviar datos `local_only`;
- mostrar trace al usuario.

## Fase 9 — MVP daily loop

Pantalla dashboard:

- misión del día;
- tareas críticas;
- hábito de recuperación;
- gasto relevante;
- comida a usar;
- botón “explicar”.

## Fase 10 — Tests

Tests mínimos:

- JSON schema validation;
- privacy gating;
- provider fallback;
- task rewrite;
- mission generation;
- no regulated advice;
- no hidden data sharing.

## Formato de respuesta que debes producir

Trabaja por pull requests pequeños:

1. `PR-001-repo-audit`
2. `PR-002-golife-shell`
3. `PR-003-lifegraph-core`
4. `PR-004-ai-gateway`
5. `PR-005-task-habit-mvp`
6. `PR-006-daily-mission`
7. `PR-007-finance-pantry-wardrobe`

Para cada PR:

- resumen;
- archivos creados;
- archivos modificados;
- tests;
- riesgos;
- pasos manuales.

## Definición de terminado

El MVP está terminado cuando:

- el usuario crea tareas, hábitos, gastos y pantry items;
- la app genera LifeEvents;
- AI Gateway genera una misión diaria;
- la misión tiene evidencia;
- usuario acepta/edita/rechaza;
- no se envían datos sin permiso;
- proveedor IA se puede cambiar sin tocar Flutter.
