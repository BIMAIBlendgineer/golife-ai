# GoLife AI Domain Migration Log

Fecha: 2026-04-24

## Resumen

La migracion inicial hacia `apps/mobile_flutter` se hizo con modelos propios y emision de `LifeEvent`.

No se copio ningun archivo fuente completo desde los repos auditados.

## Tasks

- Fuente auditada: Taskly (MIT)
- Decision: reescritura propia inspirada en el modelo `Task` y el flujo de subtareas
- Archivos nuevos:
  - `lib/domains/tasks/go_task.dart`
- LifeEvents:
  - `task_progress_ping`
  - cualquier otro tipo enviado via `GoTask.toLifeEvent(...)`
- Copias literales: ninguna

## Habits

- Fuente auditada: Habo (GPL-3.0)
- Decision: clean-room rewrite
- Archivos nuevos:
  - `lib/domains/habits/habit.dart`
  - `lib/domains/habits/habit_log.dart`
- LifeEvents:
  - cualquier tipo enviado via `Habit.toLifeEvent(...)`
- Copias literales: ninguna
- Nota de licencia: cabecera explicita indicando que no se copio codigo GPL

## Week

- Fuente auditada: WeekToDo (GPL-3.0)
- Decision: clean-room rewrite
- Archivos nuevos:
  - `lib/domains/week/week_plan.dart`
- LifeEvents:
  - `week_plan_checked`
  - otros tipos emitidos via `WeekPlan.toLifeEvent(...)`
- Copias literales: ninguna
- Nota de licencia: cabecera explicita indicando que no se copio codigo GPL

## Pantry

- Fuente auditada: Wanna (MIT)
- Decision: reescritura propia basada en conceptos de listas compartidas y pantry rescue
- Archivos nuevos:
  - `lib/domains/pantry/pantry_item.dart`
  - `lib/domains/pantry/grocery_list.dart`
- LifeEvents:
  - `ingredient_flagged`
  - otros tipos emitidos via `PantryItem.toLifeEvent(...)`
- Copias literales: ninguna

## Wardrobe

- Fuente auditada: OpenWardrobe app local (`app`) (MIT, procedencia pendiente de validar)
- Decision: reescritura propia, sin copiar archivos por ahora
- Archivos nuevos:
  - `lib/domains/wardrobe/closet_item.dart`
  - `lib/domains/wardrobe/outfit_plan.dart`
  - `lib/domains/wardrobe/purchase_intention.dart`
- LifeEvents:
  - `purchase_intention`
  - otros tipos emitidos via `ClosetItem.toLifeEvent(...)`
- Copias literales: ninguna

## Finance

- Fuente auditada: Flow
- Estado local: NO VERIFICADO / repo ausente
- Decision: placeholder propio para no bloquear arquitectura
- Archivos nuevos:
  - `lib/domains/finance/expense_record.dart`
  - `lib/domains/finance/budget_snapshot.dart`
- LifeEvents:
  - `expense_logged`
- Copias literales: ninguna

## Tests escritos

- `test/domains/tasks/go_task_test.dart`
- `test/domains/habits/habit_test.dart`
- `test/domains/week/week_plan_test.dart`
- `test/domains/pantry/pantry_item_test.dart`
- `test/domains/wardrobe/purchase_intention_test.dart`
- `test/domains/finance/expense_record_test.dart`

## Limitacion de validacion

No fue posible ejecutar `flutter test` en este entorno porque no hay SDK Flutter/Dart instalado.
