# GoLife AI Feature Extraction Matrix

Fecha: 2026-04-24

| Dominio GoLife | Fuente principal | Features verificadas | Decision |
|---|---|---|---|
| LifeQuest AI / habits | Habo | streak, logs, reminders, notes, stats, categories | `inspiration_only` |
| TaskDoctor AI / tasks | Taskly | tasks, subtasks, voice input, countdown, CSV import/export | `adapt_and_rewrite` |
| WeekPilot AI / planning | WeekToDo | weekly plan, recurring tasks, subtasks, color system, privacy local-first | `inspiration_only` |
| MoneyMirror AI / money | Flow | NO VERIFICADO | `blocked_placeholder_only` |
| FridgeZero AI / pantry | Wanna | shared grocery list, cart, past purchases idea, notifications, offline queue | `adapt_and_rewrite` |
| ClosetLess AI / wardrobe | OpenWardrobe app | closet items, outfits, Hive local, Supabase sync optional | `adapt_cautiously` |
| AI Copilot | ninguna fuente directa | prompt + gateway + mission loop | `build_original` |

## Prioridad de extraccion

1. `LifeEvent` y capture flow original
2. `AI Daily Missions` original
3. Tasks desde Taskly como base conceptual
4. Pantry desde Wanna como base conceptual
5. Habits clean-room inspirados en Habo
6. Planning clean-room inspirado en WeekToDo
7. Wardrobe adaptativo
8. Money placeholder hasta disponer de Flow

## Decisiones por feature

| Feature | Origen | Copiar | Adaptar | Inspiracion | Comentario |
|---|---|---|---|---|---|
| Habit streak logic | Habo | No | No | Si | GPL |
| Habit reminders | Habo | No | No | Si | GPL |
| Task model | Taskly | No completo | Si | Si | necesita privacy + trace |
| Speech-to-text | Taskly | Si, selectivo | Si | Si | MIT |
| Weekly recurrence | WeekToDo | No | No | Si | GPL |
| Shared pantry list | Wanna | No completo | Si | Si | stack distinto |
| Offline queue | Wanna | No completo | Si | Si | util para sync futuro |
| Closet item model | OpenWardrobe app | No completo | Si | Si | primero validar procedencia |
| Outfit model | OpenWardrobe app | No completo | Si | Si | primero validar procedencia |
| Finance import/export | Flow | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | repo ausente |
