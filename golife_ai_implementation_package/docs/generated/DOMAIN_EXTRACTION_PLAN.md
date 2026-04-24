# GoLife AI Domain Extraction Plan

Fecha: 2026-04-24

## Principios

1. GoLife AI es un producto nuevo, no una union literal de repos.
2. No copiar codigo GPL en el nuevo producto sin cambiar conscientemente la licencia final.
3. Preferir modelos GoLife propios aunque la fuente sea MIT.
4. Cada dominio debe emitir `LifeEvent`.
5. Cada dominio debe declarar permisos de privacidad (`local_only`, `sync_allowed`, `ai_allowed`).

## Disponibilidad real de fuentes

| Dominio GoLife | Fuente ideal segun prompts | Fuente local real | Estado |
|---|---|---|---|
| habits | Habo | Habo | LISTO PARA EXTRAER CON REESCRITURA |
| tasks | Taskly | Taskly | LISTO PARA EXTRAER |
| week | WeekToDo | WeekToDo | LISTO PARA EXTRAER CON REESCRITURA |
| pantry | Wanna | Wanna | LISTO PARA EXTRAER |
| wardrobe | OpenWardrobe app + db | `app` solamente | PARCIAL |
| finance | Flow | NO ENCONTRADO | BLOQUEADO |

## Orden de migracion

Segun el prompt 04 y ajustado al estado local:

1. Taskly -> `domains/tasks`
2. Habo -> `domains/habits`
3. WeekToDo -> `domains/week`
4. Wanna -> `domains/pantry`
5. OpenWardrobe app -> `domains/wardrobe`
6. Finance propio temporal -> `domains/finance` hasta disponer de Flow

## Dominio `tasks`

### Fuente

- Repo: Taskly
- Licencia: MIT

### Modelos origen verificados

- `Task`
- `Subtask`
- `Kudos`

### Modelos GoLife propuestos

- `GoTask`
- `GoSubtask`
- `TaskPriority`
- `TaskEstimate`
- `TaskRewriteSuggestion`

### Reutilizacion

- Copia selectiva posible en utilidades aisladas:
  - patron de `speech_service.dart`
  - ideas de import/export CSV
  - countdown / pomodoro como referencia

### Reescritura obligatoria

- Modelo central de tarea
- Storage
- UI
- Cualquier integracion externa debe requerir confirmacion humana

### LifeEvents a emitir

- `task_created`
- `task_updated`
- `task_completed`
- `task_deleted`
- `task_rewritten_by_ai`
- `task_split_into_steps`

## Dominio `habits`

### Fuente

- Repo: Habo
- Licencia: GPL-3.0

### Modelos origen verificados

- `HabitData`
- `Category`
- eventos por fecha

### Modelos GoLife propuestos

- `Habit`
- `HabitLog`
- `HabitReminder`
- `HabitStats`
- `HabitCategory`

### Reutilizacion

- Solo referencia conceptual y de comportamiento.
- No copiar codigo ni widgets.

### Reescritura obligatoria

- Todo el dominio por restriccion GPL.
- Persistencia y calculo de streak bajo contratos GoLife.

### LifeEvents a emitir

- `habit_created`
- `habit_checked`
- `habit_failed`
- `habit_skipped`
- `habit_progress_logged`
- `habit_archived`

## Dominio `week`

### Fuente

- Repo: WeekToDo
- Licencia: GPL-3.0

### Conceptos origen verificados

- listas semanales
- subtareas
- recurrencias
- colores
- planner local-first

### Modelos GoLife propuestos

- `WeekPlan`
- `DayPlan`
- `RecurringRule`
- `WeekTaskRef`

### Reutilizacion

- Solo conceptos de UX y dominio.
- No copiar codigo ni helpers GPL.

### Reescritura obligatoria

- Planner semanal entero en Flutter.
- Recurrencia propia.

### LifeEvents a emitir

- `week_plan_created`
- `day_plan_adjusted`
- `recurring_task_generated`
- `week_review_completed`

## Dominio `pantry`

### Fuente

- Repo: Wanna
- Licencia: MIT

### Modelos origen verificados

- `List`
- `Item`
- `QueuedOperation`
- `ConnectionState`

### Modelos GoLife propuestos

- `GroceryList`
- `PantryItem`
- `CartItem`
- `PastPurchase`
- `SharedListMember`

### Reutilizacion

- Reutilizacion selectiva de conceptos offline queue, lista compartida y notificaciones.
- UI Expo/React Native no debe copiarse tal cual.

### Reescritura obligatoria

- Estado Flutter
- Modelos Dart
- Integracion de sharing y realtime bajo servicios propios

### LifeEvents a emitir

- `grocery_list_created`
- `grocery_item_added`
- `grocery_item_checked`
- `cart_item_marked`
- `past_purchase_recorded`
- `shared_list_updated`

## Dominio `wardrobe`

### Fuente

- Repo: `app` identificado localmente como OpenWardrobe app
- Licencia: MIT, con procedencia local a validar

### Modelos origen verificados

- `WardrobeItem`
- `Outfit`
- `Brand`
- `ItemCategory`

### Modelos GoLife propuestos

- `ClosetItem`
- `Outfit`
- `PurchaseIntention`
- `ClosetInsight`

### Reutilizacion

- Posible reutilizacion selectiva de modelos y patron Hive + sync opcional.
- Bloqueada la copia directa hasta validar procedencia del repo local.

### Reescritura obligatoria

- Repositorio
- Sync
- Pantallas
- Nuevas capacidades de `purchase_intention` y anti-consumo

### LifeEvents a emitir

- `closet_item_added`
- `outfit_created`
- `closet_item_worn`
- `purchase_intention_created`
- `closet_decision_requested`

## Dominio `finance`

### Fuente

- Flow
- Estado local: `NO VERIFICADO`

### Decision

- No migrar desde Flow aun.
- Crear solo modelos propios minimos para permitir arquitectura y AI trace:
  - `Account`
  - `Expense`
  - `Category`
  - `Budget`

### LifeEvents a emitir

- `expense_logged`
- `budget_threshold_reached`
- `account_balance_changed`

## Politica de copia por archivo

| Tipo de fuente | Politica |
|---|---|
| GPL-3.0 | referencia solamente |
| MIT verificada | copia selectiva con cabecera de origen y justificante |
| MIT con procedencia dudosa | primero validar origen, luego decidir |
| Fuente ausente | no usar como base |

## Trazabilidad obligatoria en migraciones

Cada PR de migracion debe documentar:

1. archivo origen;
2. licencia origen;
3. decision tomada: `copied`, `adapted`, `rewritten`, `reference_only`;
4. razon tecnica;
5. `LifeEvents` emitidos por el modulo.

## Bloqueos actuales

- `Flow` no existe en el workspace.
- `OpenWardrobe db` no existe en el workspace.
- El prompt habla de `source_repos/`, pero aqui las fuentes estan a nivel raiz.
- La procedencia exacta del repo local `app` debe confirmarse antes de copiar archivos.
