# GoLife AI Repository Audit

Fecha: 2026-04-24

## Nota metodologica

El prompt espera `references/`, pero ese directorio no existe en este workspace. La auditoria se hizo sobre los repos locales realmente presentes.

## Estado de fuentes

| Fuente esperada | Ruta local | URL verificada | Branch | Estado |
|---|---|---|---|---|
| Habo | `C:\0 Work\GoLife AI\Habo` | `https://github.com/xpavle00/Habo.git` | `master` | VERIFICADO |
| Taskly | `C:\0 Work\GoLife AI\Taskly` | `https://github.com/IMGIITRoorkee/Taskly.git` | `main` | VERIFICADO |
| Wanna | `C:\0 Work\GoLife AI\wanna` | `https://github.com/leechy/wanna.git` | `main` | VERIFICADO |
| WeekToDo | `C:\0 Work\GoLife AI\weektodo` | `https://github.com/manuelernestog/weektodo.git` | `main` | VERIFICADO |
| OpenWardrobe app | `C:\0 Work\GoLife AI\app` | `https://github.com/OpenWardrobe/app.git` | `main` | VERIFICADO |
| Flow | NO ENCONTRADO | NO VERIFICADO | NO VERIFICADO | BLOQUEADO |
| OpenWardrobe db | NO ENCONTRADO | NO VERIFICADO | NO VERIFICADO | BLOQUEADO |

## 1. Habo

- Ultimo commit local: `b7a67a8 2026-04-23 chore: update sync screen`
- Stack: Flutter / Dart
- Arquitectura: app Flutter con `provider`, router propio, SQLite + servicios de sync
- Modelos verificados: `HabitData`, `Category`, eventos por fecha, settings, backup
- Pantallas: habits, edit habit, statistics, settings, onboarding, sync/profile/auth
- Conceptos reutilizables:
  - streaks;
  - recordatorios;
  - logs de habitos;
  - estadisticas;
  - categorias.
- Licencia: GPL-3.0
- Recomendacion: `inspiration only`
- Riesgos:
  - GPL;
  - dominio y sync fuertemente acoplados;
  - copiar parcialmente puede romper reglas de streak y conflictos.

## 2. Taskly

- Ultimo commit local: `6282e34 2025-01-19 fix: error`
- Stack: Flutter / Dart
- Arquitectura: app Flutter sencilla con `provider` y `shared_preferences`
- Modelos verificados: `Task`, `Subtask`, `Kudos`, `Tip`
- Pantallas: home, task form, task list, pomodoro, meditation, intro
- Conceptos reutilizables:
  - task decomposition;
  - subtasks;
  - voice input;
  - duration selection;
  - CSV import/export.
- Licencia: MIT
- Recomendacion: `adapt`
- Riesgos:
  - cobertura baja;
  - modelo demasiado simple para AI trace y privacy gating;
  - integraciones externas requieren confirmacion humana.

## 3. Wanna

- Ultimo commit local: `557eb45 2025-04-22 Fix for the Columns views when no items are available`
- Stack: Expo / React Native / TypeScript
- Arquitectura: `expo-router`, `@legendapp/state`, `AsyncStorage`, sockets
- Modelos verificados: `List`, `Item`, `QueuedOperation`, `User`, `ConnectionState`
- Pantallas: tabs `projects` y `shopping`, sign-in, settings, list/item modals
- Conceptos reutilizables:
  - grocery lists compartidas;
  - cart state;
  - offline queue;
  - realtime sync;
  - push notifications.
- Licencia: MIT
- Recomendacion: `adapt`
- Riesgos:
  - stack distinto a Flutter;
  - logica de realtime y offline queue necesita backend y politica de privacidad clara.

## 4. WeekToDo

- Ultimo commit local: `d384fc7 2024-02-15 Update README.md`
- Stack: Vue 3 / Electron / JavaScript
- Arquitectura: Vuex + IndexedDB + Electron
- Modelos verificados: weekly todo lists, repeating events, custom lists, config local
- Pantallas: planner semanal, welcome flow, config/import/export/recurrence modals
- Conceptos reutilizables:
  - recurring planning;
  - subtasks;
  - color coding;
  - local-first weekly planning.
- Licencia: GPL-3.0
- Recomendacion: `inspiration only`
- Riesgos:
  - GPL;
  - stack no portable directo a Flutter;
  - tests no verificados localmente.

## 5. OpenWardrobe app

- Ultimo commit local: `dd5a576 2025-02-15 Create FUNDING.yml`
- Stack: Flutter / Dart
- Arquitectura: `go_router`, Hive, Supabase, `flutter_bloc` en dependencias
- Modelos verificados: `WardrobeItem`, `Outfit`, `Brand`, `ItemCategory`
- Pantallas: auth, home, wardrobe, shell/tab scaffold
- Conceptos reutilizables:
  - closet items;
  - outfits;
  - sync opcional con Supabase;
  - cache local con Hive.
- Licencia: MIT
- Recomendacion: `adapt cautiously`
- Riesgos:
  - procedencia del repo local a validar;
  - baja cobertura;
  - sync aun inmaduro.

## 6. Flow

- Estado: `NO VERIFICADO`
- Motivo: el repo no existe localmente.
- Impacto: el dominio `money` no puede migrarse desde una fuente real; solo se puede modelar de forma propia y conservadora.

## 7. OpenWardrobe db

- Estado: `NO VERIFICADO`
- Motivo: el repo no existe localmente.
- Impacto: no se puede auditar el esquema backend del dominio wardrobe ni prometer sync completo basado en evidencia local.

## Conclusiones

1. La ruta correcta por defecto es `clean-room rebuild`.
2. El wedge de salida debe ser `AI Daily Missions`, no una superapp completa desde el dia 1.
3. MIT reutilizable de forma selectiva:
   - Taskly
   - Wanna
   - OpenWardrobe app, pero con validacion previa de procedencia
4. GPL no reusable en producto cerrado:
   - Habo
   - WeekToDo
   - presumiblemente Flow, pero aqui sigue no verificado
