# GoLife AI Dependency Matrix

Fecha: 2026-04-24

| Repo | Stack | Estado / routing | Persistencia | Backend / red | Dependencias clave | Recomendacion |
|---|---|---|---|---|---|---|
| Habo | Flutter / Dart | router propio + `provider` | `sqflite`, `shared_preferences`, `flutter_secure_storage` | `supabase_flutter`, auth, notifications | `fl_chart`, `table_calendar`, biometria, subscriptions | No copiar; usar como referencia |
| Taskly | Flutter / Dart | Flutter navigation + `provider` | `shared_preferences` | URLs externas, archivos locales | `speech_to_text`, `csv`, `duration_picker`, `circular_countdown_timer` | Adaptar conceptos y utilidades selectivas |
| Wanna | Expo / RN / TS | `expo-router`, React Navigation | `AsyncStorage` | `socket.io-client`, push notifications | `@legendapp/state`, `expo-notifications`, `netinfo` | Reescribir en Flutter como pantry/shared list domain |
| WeekToDo | Vue 3 / Electron | Vuex | IndexedDB + `electron-config` | Electron IPC, local-first | `rrule`, `moment`, `markdown-it`, `bootstrap` | Reescribir planner y recurrencia |
| OpenWardrobe app | Flutter / Dart | `go_router` | Hive | Supabase | `connectivity_plus`, `flutter_bloc`, `equatable` | Adaptar con validacion de procedencia |
| Flow | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | Bloqueado |
| OpenWardrobe db | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | Bloqueado |

## Implicacion para GoLife AI

- App movil principal: Flutter.
- Planner, habits y money: modelos propios.
- Pantry y tasks: adaptacion conceptual fuerte desde fuentes MIT.
- AI Gateway: FastAPI + LangGraph + provider swappable.
- Privacy y consent: obligatorios antes de cualquier llamada al gateway.
