# Roadmap por etapas

## Etapa 0 — Preparación y auditoría

Objetivo: entender repositorios antes de tocar código.

Tareas:

1. Clonar repos en `source_repos/`.
2. Ejecutar audit script.
3. Detectar licencias.
4. Detectar stacks.
5. Detectar modelos de datos.
6. Detectar almacenamiento local/cloud.
7. Detectar pantallas reutilizables.
8. Detectar conflictos de dependencias.

Entregables:

- `REPO_AUDIT.md`
- `LICENSE_MATRIX.md`
- `DEPENDENCY_MATRIX.md`
- `DOMAIN_EXTRACTION_PLAN.md`

Criterio de salida:

- decidir licencia del nuevo producto;
- decidir qué se copia, qué se reescribe y qué solo inspira.

## Etapa 1 — Shell GoLife Flutter

Objetivo: crear app nueva.

Tareas:

1. Crear `new_app/golife_flutter`.
2. Implementar router.
3. Implementar tema.
4. Implementar navegación principal:
   - Dashboard;
   - LifeQuest;
   - Week;
   - Money;
   - Pantry;
   - Closet;
   - Copilot.
5. Crear storage local.

Criterio de salida:

- app abre en Android/iOS;
- navegación funcional;
- no integra IA todavía.

## Etapa 2 — LifeGraph Core

Objetivo: crear columna vertebral de eventos.

Tareas:

1. Implementar `LifeEvent`.
2. Implementar `LifeEventStore`.
3. Implementar permisos por dominio.
4. Implementar exportación JSON.
5. Implementar dashboard básico de eventos.

Criterio de salida:

- tareas, hábitos y gastos pueden emitir eventos.

## Etapa 3 — TaskDoctor básico

Objetivo: tareas accionables.

Tareas:

1. Migrar o reescribir modelo de Taskly.
2. Crear task CRUD.
3. Añadir duración estimada.
4. Añadir estado, prioridad, fecha.
5. Emitir eventos.
6. Crear endpoint `/v1/tasks/rewrite`.

Criterio de salida:

- tarea vaga se convierte en pasos pequeños.

## Etapa 4 — Habit Engine / LifeQuest base

Objetivo: hábitos + gamificación.

Tareas:

1. Migrar conceptos de Habo.
2. Crear hábitos.
3. Streaks.
4. Notas.
5. Recordatorios.
6. XP.
7. Misiones simples.

Criterio de salida:

- completar hábito genera XP y eventos.

## Etapa 5 — WeekPilot

Objetivo: semana inteligente.

Tareas:

1. Reescribir conceptos de WeekToDo.
2. Semana + días + subtareas.
3. Recurrent tasks.
4. Replanificación manual.
5. Replanificación IA opcional.

Criterio de salida:

- IA puede proponer plan semanal editable.

## Etapa 6 — FridgeZero

Objetivo: despensa + lista.

Tareas:

1. Reescribir conceptos de Wanna.
2. Crear pantry item.
3. Crear grocery list.
4. Crear “cart”.
5. Past purchases.
6. Compartir lista opcional.
7. Endpoint `/v1/pantry/rescue`.

Criterio de salida:

- IA sugiere usar comida antes de comprar.

## Etapa 7 — MoneyMirror

Objetivo: reflexión financiera.

Tareas:

1. Adaptar conceptos de Flow.
2. Cuentas/categorías/gastos.
3. Charts.
4. Export.
5. Patrones.
6. Endpoint `/v1/finance/reflect`.

Criterio de salida:

- IA detecta microfuga de gasto y propone misión no regulada.

## Etapa 8 — ClosetLess

Objetivo: armario anti-consumo.

Tareas:

1. Adaptar conceptos de OpenWardrobe.
2. Closet item.
3. Outfit.
4. Intención de compra.
5. Endpoint `/v1/closet/decision`.

Criterio de salida:

- app puede decir “no compres, ya tienes equivalente” con evidencia.

## Etapa 9 — AI Gateway + LangGraph

Objetivo: IA trazable.

Tareas:

1. Crear FastAPI.
2. Crear provider OpenRouter.
3. Crear LangGraph.
4. Crear guardrails.
5. Crear memory summaries.
6. Crear trace store.
7. Conectar mobile.

Criterio de salida:

- misión diaria multi-dominio con explicación.

## Etapa 10 — GoLife Daily Loop

Objetivo: experiencia central.

Flujo diario:

1. abrir app;
2. ver estado del día;
3. recibir misión;
4. aceptar/editar;
5. completar;
6. revisar progreso.

Criterio de salida:

- usuario entiende utilidad en menos de 60 segundos.

## Etapa 11 — Privacidad, exportación y release beta

Tareas:

1. pantalla de permisos;
2. exportación;
3. borrado;
4. backup;
5. tests;
6. beta cerrada.

Criterio de salida:

- beta instalable.
