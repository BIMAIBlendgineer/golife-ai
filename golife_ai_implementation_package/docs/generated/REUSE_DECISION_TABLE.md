# GoLife AI Reuse Decision Table

Fecha: 2026-04-24

| Fuente | Ruta / area origen | Licencia | Decision | Destino GoLife | Justificacion |
|---|---|---|---|---|---|
| Habo | `lib/model/habit_data.dart` | GPL-3.0 | REFERENCE_ONLY_REWRITE | `domains/habits` | Modelo valioso pero GPL |
| Habo | `lib/model/habo_model.dart` | GPL-3.0 | REFERENCE_ONLY_REWRITE | `domains/habits` storage | SQLite y sync estan demasiado acoplados y son GPL |
| Habo | `lib/habits/*` | GPL-3.0 | REFERENCE_ONLY_REWRITE | `features/habits` | UI GPL no reutilizable |
| Habo | `lib/services/*` | GPL-3.0 | REFERENCE_ONLY_REWRITE | servicios GoLife | mezcla sync/auth/subscriptions |
| Taskly | `lib/models/task.dart` | MIT | ADAPT_REWRITE | `domains/tasks/models` | el modelo actual es demasiado simple para GoLife |
| Taskly | `lib/models/subtask.dart` | MIT | COPY_ALLOWED_IF_NEEDED | `domains/tasks/models` | utilidad aislada y facil de atribuir |
| Taskly | `lib/service/speech_service.dart` | MIT | COPY_ALLOWED_IF_NEEDED | `domains/tasks/services` | servicio encapsulado, bajo riesgo |
| Taskly | `lib/storage/task_storage.dart` | MIT | ADAPT_REWRITE | `domains/tasks/storage` | requiere nuevo esquema y privacidad |
| Taskly | `lib/screens/*` | MIT | REWRITE | `features/tasks` | UI no encaja con shell GoLife |
| Taskly | `lib/google_calendar.dart` | MIT | REWRITE | integraciones opcionales | toda accion externa debe requerir confirmacion |
| WeekToDo | `src/helpers/repeatingEvents.js` | GPL-3.0 | REFERENCE_ONLY_REWRITE | `domains/week` | reglas utiles, codigo no reutilizable |
| WeekToDo | `src/repositories/*` | GPL-3.0 | REFERENCE_ONLY_REWRITE | `domains/week/storage` | IndexedDB/Electron + GPL |
| WeekToDo | `src/views/*` | GPL-3.0 | REFERENCE_ONLY_REWRITE | `features/week` | stack incompatible y GPL |
| Wanna | `types/list.ts` | MIT | ADAPT_REWRITE | `domains/pantry/models` | estructura util, pero debe pasar a Dart |
| Wanna | `types/Item.ts` | MIT | ADAPT_REWRITE | `domains/pantry/models` | buen punto de partida para grocery/cart |
| Wanna | `state/state.ts` | MIT | REFERENCE_ONLY_REWRITE | `domains/pantry/state` | patron offline-first util, pero no portable directo |
| Wanna | `services/socketService.ts` | MIT | REFERENCE_ONLY_REWRITE | sync/shared lists | buena referencia para realtime y offline queue |
| Wanna | `utils/notifications.ts` | MIT | REFERENCE_ONLY_REWRITE | notifications service | depende de Expo APIs |
| Wanna | `components/*` | MIT | REWRITE | `features/pantry` | UI React Native no portable directo |
| OpenWardrobe app | `lib/models/wardrobe_item.dart` | MIT | HOLD_UNTIL_PROVENANCE_VERIFIED | `domains/wardrobe/models` | tecnico util, pero primero validar procedencia |
| OpenWardrobe app | `lib/models/outfit.dart` | MIT | HOLD_UNTIL_PROVENANCE_VERIFIED | `domains/wardrobe/models` | mismo motivo |
| OpenWardrobe app | `lib/repositories/wardrobe_repository.dart` | MIT | ADAPT_REWRITE_AFTER_VALIDATION | `domains/wardrobe/data` | logica offline/sync util, pero inmadura |
| OpenWardrobe app | `lib/router/app_router.dart` | MIT | REWRITE | `app/router` | el shell GoLife tendra rutas distintas |
| Flow | repo ausente | NO VERIFICADO | BLOCKED | `domains/finance` | no hay codigo local para decidir |
| OpenWardrobe db | repo ausente | NO VERIFICADO | BLOCKED | `domains/wardrobe/sync` | no hay esquema local para decidir |

## Leyenda

- `COPY_ALLOWED_IF_NEEDED`: se puede copiar selectivamente con aviso de origen.
- `ADAPT_REWRITE`: tomar la idea o fragmentos pequenos, pero no trasladar el archivo completo.
- `REFERENCE_ONLY_REWRITE`: usar como referencia funcional; implementar desde cero.
- `HOLD_UNTIL_PROVENANCE_VERIFIED`: no copiar hasta validar origen/licencia.
- `BLOCKED`: la fuente no esta disponible localmente.
