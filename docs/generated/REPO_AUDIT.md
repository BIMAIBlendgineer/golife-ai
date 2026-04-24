# GoLife AI Repo Audit

Fecha de auditoria: 2026-04-24

## Alcance verificado

El prompt original asume `source_repos/`, pero en este workspace no existe esa carpeta. Se auditaron los repositorios y carpetas realmente presentes:

| Esperado por prompts | Ruta local encontrada | Estado |
|---|---|---|
| Habo | `C:\0 Work\GoLife AI\Habo` | VERIFICADO |
| Taskly | `C:\0 Work\GoLife AI\Taskly` | VERIFICADO |
| WeekToDo | `C:\0 Work\GoLife AI\weektodo` | VERIFICADO |
| Wanna | `C:\0 Work\GoLife AI\wanna` | VERIFICADO |
| OpenWardrobe app | `C:\0 Work\GoLife AI\app` | VERIFICADO |
| Flow | NO ENCONTRADO | NO VERIFICADO |
| OpenWardrobe db | NO ENCONTRADO | NO VERIFICADO |

## Habo

Ruta: `C:\0 Work\GoLife AI\Habo`

Ultimo commit verificado: `b7a67a8 2026-04-23 chore: update sync screen`

### Arbol hasta profundidad 3

```text
Habo/
  android/
    app/
      src/
    gradle/
      wrapper/
  assets/
    google_fonts/
    images/
      onboard/
      sync_onboard/
    sounds/
  fastlane/
    metadata/
      android/
  ios/
    Flutter/
    HaboWidget/
      Assets.xcassets/
    Runner/
      Assets.xcassets/
      Base.lproj/
    Runner.xcodeproj/
      project.xcworkspace/
      xcshareddata/
    Runner.xcworkspace/
      xcshareddata/
  lib/
    generated/
      intl/
    habits/
    helpers/
    l10n/
    model/
    navigation/
    onboarding/
    repositories/
    screens/
    services/
    settings/
    statistics/
    whats_new/
    widgets/
  supabase/
  test/
    habits/
    integration/
    mocks/
    model/
    repositories/
    services/
    widgets/
```

### Lenguaje y framework

- Dart + Flutter.
- Navegacion propia con `AppRouter`, `AppStateManager` y rutas declaradas en `lib/navigation/routes.dart`.

### Licencia

- GPL-3.0 verificada por `LICENSE` y README.

### Dependencias criticas

- Estado/UI: `provider`, `table_calendar`, `fl_chart`, `google_fonts`, `home_widget`.
- Persistencia: `sqflite`, `sqflite_common_ffi`, `shared_preferences`, `flutter_secure_storage`.
- Integraciones: `awesome_notifications`, `local_auth`, `supabase_flutter`, `supabase_auth_ui`, `purchases_flutter`, `sign_in_with_apple`, `google_sign_in`.

### Storage verificado

- SQLite local via `HaboModel` con tablas `habits`, `events`, `categories`, `habit_categories`.
- `shared_preferences` para preferencias.
- `flutter_secure_storage` y servicios de cifrado para datos sensibles.
- Supabase presente para sync/autenticacion.

### Entidades de dominio verificadas

- `HabitData`
- `Category`
- tablas/eventos asociados a habitos
- `SettingsData`
- backups y metadatos de sincronizacion (`uuid`, `updated_at`, `deleted_at`)

### Pantallas verificadas

- Splash
- Habits list / habit editor
- Statistics
- Settings
- Onboarding
- Whats new
- Sync/login/profile/reset password/account screens

### Servicios verificados

- Backup/import/export
- Notificaciones
- Biometria
- Cifrado
- Home widget
- Suscripciones
- Sync manager / sync service

### Tests verificados

- Tests de widgets, repositorios, servicios, integracion y modelo.
- Cobertura observable para backup, sync, encryption y CRUD de habitos.

### Reutilizacion recomendada

- Reutilizar solo como referencia funcional y de modelo conceptual.
- No copiar codigo GPL al nuevo producto salvo decision explicita de licenciamiento.

### Reescritura recomendada

- Todo el dominio `habits` para GoLife debe ser reescrito en modelos propios.
- Reescribir sync, UI y persistencia con contratos GoLife y `LifeEvent`.

### Riesgos

- GPL-3.0 bloquea copia directa en un producto propietario.
- Codigo con mezcla de SQLite, sync, subscriptions y auth aumenta acoplamiento.
- El dominio ya incorpora complejidad de conflicto LWW y soft-delete; copiar parcialmente puede introducir incoherencias.

## Taskly

Ruta: `C:\0 Work\GoLife AI\Taskly`

Ultimo commit verificado: `6282e34 2025-01-19 fix: error`

### Arbol hasta profundidad 3

```text
Taskly/
  android/
    app/
      src/
    gradle/
      wrapper/
  assets/
    fonts/
    sounds/
    svg/
  ios/
    Flutter/
    Runner/
      Assets.xcassets/
      Base.lproj/
    Runner.xcodeproj/
      project.xcworkspace/
      xcshareddata/
    Runner.xcworkspace/
      xcshareddata/
    RunnerTests/
  lib/
    enums/
    models/
    providers/
    resources/
    screens/
    service/
    storage/
    utils/
    widgets/
  test/
```

### Lenguaje y framework

- Dart + Flutter.

### Licencia

- MIT verificada por `LICENSE`.

### Dependencias criticas

- Estado y persistencia: `provider`, `shared_preferences`.
- UX: `flutter_slidable`, `fluttertoast`, `introduction_screen`, `flutter_confetti`.
- Utilidades: `speech_to_text`, `csv`, `file_picker`, `duration_picker`, `circular_countdown_timer`, `share_plus`, `url_launcher`.

### Storage verificado

- `shared_preferences` para tareas, tema, kudos e historial de meditacion.
- No se verifico una base de datos relacional o backend remoto.

### Entidades de dominio verificadas

- `Task`
- `Subtask`
- `Kudos`
- `Tip`

### Pantallas verificadas

- Splash
- Intro
- Home
- Task form
- Task list / task box
- Pomodoro
- Meditation
- Kudos details

### Servicios verificados

- Speech-to-text
- Import/export CSV
- Lanzamiento de Google Calendar via URL externa
- Permisos de storage
- Tips aleatorios

### Tests verificados

- Solo `test/widget_test.dart`.

### Reutilizacion recomendada

- Candidata principal para `domains/tasks` por licencia MIT.
- Reutilizacion selectiva posible para utilidades aisladas como voz, countdown y CSV.

### Reescritura recomendada

- Reescribir modelo `Task` para incluir `priority`, `estimated_duration`, `source`, `LifeEvent`, privacidad y trazabilidad.
- Reescribir storage para desacoplarse de `shared_preferences` plano.
- Reescribir UI completa bajo shell GoLife.

### Riesgos

- Cobertura de tests muy baja.
- Modelo actual de tareas es simple y no contempla privacidad, AI trace ni permisos por dominio.
- Integraciones externas (`url_launcher`, picker de archivos) requieren confirmacion humana en GoLife.

## WeekToDo

Ruta: `C:\0 Work\GoLife AI\weektodo`

Ultimo commit verificado: `d384fc7 2024-02-15 Update README.md`

### Arbol hasta profundidad 3

```text
weektodo/
  .github/
    workflows/
  build/
    icon/
    icons/
  public/
    fav_icons/
    img/
    libs/
    sounds/
  src/
    assets/
      img/
      languages/
      style/
    components/
      comfirmModals/
      layout/
    helpers/
    migrations/
    repositories/
    store/
      modules/
    views/
      donate/
      toDoModal/
      welcome/
```

### Lenguaje y framework

- JavaScript.
- Vue 3 + Vuex.
- Electron para escritorio.

### Licencia

- GPL-3.0 verificada por `LICENSE` y README.

### Dependencias criticas

- UI: `vue`, `bootstrap`, `bootstrap-icons`, `vue3-datepicker`.
- Estado y utilidades: `vuex`, `moment`, `rrule`, `markdown-it`, `lodash.uniqueid`.
- Escritorio/config: `electron`, `electron-config`, `auto-launch`.

### Storage verificado

- IndexedDB via `src/repositories/dbRepository.js` con object stores:
  - `todo_lists`
  - `repeating_events`
  - `repeating_events_by_date`
- `storageRepository` para configuracion local.
- `electron-config` para comportamiento de escritorio.

### Entidades de dominio verificadas

- To-do list semanal por fecha/lista
- Repeating events
- Configuracion de planner
- Custom lists
- Cache de ocurrencias recurrentes por fecha

### Pantallas verificadas

- Vista principal semanal
- Welcome flow
- Config modal
- Import/export modal
- Recurrent events modal
- Reorder custom lists modal
- Tips/about/donate/sponsor modals

### Servicios verificados

- Export/import backup `.wtdb`
- Recordatorios/notificaciones
- Generacion de instancias recurrentes
- Integraciones Electron para startup/background

### Tests verificados

- No se encontraron archivos de test verificables en el repo local.

### Reutilizacion recomendada

- Reutilizar exclusivamente conceptos de dominio y comportamiento.
- No copiar codigo por GPL y por desalineacion de stack.

### Reescritura recomendada

- Reescribir `domains/week` completo en Flutter.
- Reescribir recurrencia, subtareas, colores y planner local-first con modelos propios.

### Riesgos

- GPL-3.0 impide copia directa en producto propietario.
- Stack Vue/Electron no es portable a Flutter sin reimplementacion.
- Ultimo commit local verificado es antiguo frente a otros repos; riesgo de mantenimiento menor.

## Wanna

Ruta: `C:\0 Work\GoLife AI\wanna`

Ultimo commit verificado: `557eb45 2025-04-22 Fix for the Columns views when no items are available`

### Arbol hasta profundidad 3

```text
wanna/
  app/
    (tabs)/
      projects/
      shopping/
    +not-found.tsx
    settings.tsx
    sign-in.tsx
    _layout.tsx
  assets/
    fonts/
    symbols/
  components/
    __tests__/
      __snapshots__/
    *.tsx
  constants/
  hooks/
  scripts/
  services/
    socketService.ts
  state/
    actions-lists.ts
    actions-queue.ts
    actions-user.ts
    state.ts
  types/
    Item.ts
    list.ts
    listItem.ts
    user.ts
  utils/
    __tests__/
```

### Lenguaje y framework

- TypeScript.
- React Native / Expo.
- `expo-router` y React Navigation.

### Licencia

- MIT verificada por `LICENSE`.

### Dependencias criticas

- UI/runtime: `expo`, `react-native`, `expo-router`, `@react-navigation/native`.
- Estado/offline: `@legendapp/state`, `AsyncStorage`.
- Red y colaboracion: `socket.io-client`, `@react-native-community/netinfo`.
- Notificaciones: `expo-notifications`.

### Storage verificado

- Persistencia local con `AsyncStorage`.
- Cola offline persistida (`offline_queue`) en estado observable.
- Sin esquema SQL local verificado.

### Entidades de dominio verificadas

- `List`
- `ListUser`
- `Item`
- `QueuedOperation`
- `User`
- `ConnectionState`

### Pantallas verificadas

- Tabs para `projects` y `shopping`
- Sign-in
- Settings
- Modales de listas e items
- Vistas por lista compartida

### Servicios verificados

- Socket realtime
- Cola offline y resync
- Push notifications Expo
- Compartir listas por link / clipboard

### Tests verificados

- Suite de tests de componentes y snapshots.
- Tests utilitarios en `utils/__tests__`.

### Reutilizacion recomendada

- Muy buena referencia para `domains/pantry` y shared lists.
- Reutilizacion selectiva de logica no visual es posible por licencia MIT, pero el stack sigue siendo distinto.

### Reescritura recomendada

- Reescribir UI y estado en Flutter.
- Reescribir modelos para distinguir pantry, grocery list, cart, past purchase y permisos de IA.

### Riesgos

- Acoplamiento a Expo/React Native y `legendapp/state`.
- Hay funciones de realtime y notificaciones que requieren backend y politicas de permisos no definidas aun en GoLife.

## OpenWardrobe app

Ruta local auditada: `C:\0 Work\GoLife AI\app`

Ultimo commit verificado: `dd5a576 2025-02-15 Create FUNDING.yml`

### Arbol hasta profundidad 3

```text
app/
  android/
    app/
      src/
    gradle/
      wrapper/
  ios/
    Flutter/
    Runner/
      Assets.xcassets/
      Base.lproj/
    Runner.xcodeproj/
      project.xcworkspace/
      xcshareddata/
    Runner.xcworkspace/
      xcshareddata/
    RunnerTests/
  lib/
    models/
    repositories/
    router/
    services/
    ui/
      screens/
      widgets/
  linux/
    flutter/
    runner/
  macos/
    Flutter/
    Runner/
    Runner.xcodeproj/
    Runner.xcworkspace/
    RunnerTests/
  test/
  web/
    icons/
  windows/
    flutter/
    runner/
      resources/
```

### Lenguaje y framework

- Dart + Flutter.
- `go_router`.
- `flutter_bloc` presente en dependencias, aunque no se verifico uso extendido en el arbol auditado.

### Licencia

- MIT verificada en archivo `LICENSE`.
- Riesgo de procedencia: el `LICENSE` local indica `Copyright (c) 2025 SUGGESTIED ✨`, mientras README y nombre del paquete indican OpenWardrobe. Requiere validacion de procedencia antes de copiar archivos.

### Dependencias criticas

- Persistencia: `hive`, `hive_flutter`.
- Backend: `supabase_flutter`, `supabase_auth_ui`.
- Navegacion/conectividad: `go_router`, `connectivity_plus`.
- Estado: `flutter_bloc`, `equatable`.

### Storage verificado

- Hive local para `WardrobeItem` y `Outfit`.
- Supabase para auth y sync remoto.

### Entidades de dominio verificadas

- `WardrobeItem`
- `Outfit`
- `Brand`
- `ItemCategory`

### Pantallas verificadas

- Auth
- Home
- Wardrobe
- Shell/tab scaffold

### Servicios verificados

- `WardrobeRepository` con estrategia online/offline
- `WardrobeService`
- Autenticacion Supabase

### Tests verificados

- Solo `test/widget_test.dart`.

### Reutilizacion recomendada

- Mejor fuente actual para `domains/wardrobe` por stack Flutter + licencia MIT.
- Reutilizacion selectiva posible de modelos y sincronizacion offline, una vez validada procedencia/licencia del repo local.

### Reescritura recomendada

- Reescribir repositorio y UI para incluir `purchase_intention`, permisos por dominio y `LifeEvent`.
- Reescribir sync con contratos mas estrictos y pruebas.

### Riesgos

- Repo parece inmaduro; pocas pantallas y poca cobertura.
- Procedencia del codigo/licencia requiere validacion antes de copiar archivos.
- `WardrobeRepository` actual tiene logica de sync minima y bajo test coverage.

## Flow

Ruta esperada: `source_repos/flow` o equivalente local.

- Estado: `NO VERIFICADO`
- Motivo: no existe repo local en este workspace.
- Impacto: el dominio `finance` no puede migrarse desde Flow con evidencia local; solo puede crearse un placeholder propio hasta disponer del codigo.

## OpenWardrobe db

Ruta esperada: `source_repos/openwardrobe_db` o equivalente local.

- Estado: `NO VERIFICADO`
- Motivo: no existe repo local en este workspace.
- Impacto: no se puede auditar esquema Supabase ni replicar sincronizacion de armario con respaldo documental completo.
