# GoLife AI Dependency Matrix

Fecha: 2026-04-24

## Matriz por repositorio

| Repo | Stack base | Estado / navegacion | Persistencia | Red / backend | Otras dependencias relevantes | Tests |
|---|---|---|---|---|---|---|
| Habo | Flutter/Dart | `provider`, router propio | `sqflite`, `shared_preferences`, `flutter_secure_storage` | `supabase_flutter`, `supabase_auth_ui` | `awesome_notifications`, `fl_chart`, `local_auth`, `home_widget`, `purchases_flutter` | `flutter_test`, `mocktail` |
| Taskly | Flutter/Dart | `provider` | `shared_preferences` | NO VERIFICADO como backend dedicado | `speech_to_text`, `csv`, `file_picker`, `duration_picker`, `circular_countdown_timer`, `share_plus`, `url_launcher` | `flutter_test` |
| WeekToDo | Vue 3 / Electron | `vuex` | IndexedDB + `electron-config` | NO VERIFICADO como backend remoto | `moment`, `rrule`, `markdown-it`, `bootstrap`, `@sentry/vue` | script `test` placeholder |
| Wanna | Expo / React Native / TypeScript | `expo-router`, React Navigation, `@legendapp/state` | `AsyncStorage` | `socket.io-client`, API URL por env | `expo-notifications`, `@react-native-community/netinfo`, `expo-clipboard` | `jest-expo`, testing-library |
| OpenWardrobe app | Flutter/Dart | `go_router`, `flutter_bloc` | `hive`, `hive_flutter` | `supabase_flutter`, `supabase_auth_ui` | `connectivity_plus`, `equatable` | `flutter_test` |
| Flow | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO |
| OpenWardrobe db | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO | NO VERIFICADO |

## Dependencias con impacto arquitectonico

### Repos GPL

| Repo | Dependencia / area | Impacto en GoLife |
|---|---|---|
| Habo | `sqflite`, sync Supabase, provider, auth, subscriptions | Reutilizar ideas, no copiar implementaciones |
| WeekToDo | `vuex`, `rrule`, IndexedDB, Electron | Reescritura completa en Flutter |

### Repos MIT

| Repo | Dependencia / area | Impacto en GoLife |
|---|---|---|
| Taskly | `speech_to_text`, `csv`, `duration_picker`, countdown | Posible reutilizacion parcial de utilidades |
| Wanna | `AsyncStorage`, sockets, offline queue, notifications | Fuente fuerte para pantry/shared lists y offline-first |
| OpenWardrobe app | Hive + Supabase + GoRouter | Fuente fuerte para wardrobe local-first con sync opcional |

## Dependencias objetivo recomendadas para GoLife

Tomando en cuenta lo auditado y los prompts:

- Mobile shell: Flutter.
- Storage local base: Hive o Drift/SQLite. No decidido definitivamente en esta matriz.
- Backend IA: FastAPI + Pydantic + LangGraph.
- Proveedor inicial: OpenRouter.
- Auth/sync opcional por dominio: aislado y nunca requerido para funcionamiento local.

## Notas

- `Flow` y `OpenWardrobe db` no estan disponibles localmente; cualquier dependencia atribuida a esos repos seria inventada en este workspace, por lo que se deja como `NO VERIFICADO`.
- El repo local `app` se audita como OpenWardrobe app porque README y `pubspec.yaml` lo identifican asi.
