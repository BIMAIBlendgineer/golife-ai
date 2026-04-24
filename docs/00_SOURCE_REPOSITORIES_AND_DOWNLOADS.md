# Repositorios base y enlaces de descarga

## Tabla principal


| Área | Repositorio | Enlace | Stack verificado públicamente | Licencia verificada públicamente | Uso propuesto |
|---|---|---|---|---|---|
| Hábitos | Habo | https://github.com/xpavle00/Habo | Flutter/Dart; dependencias: provider, shared_preferences, sqflite, fl_chart, notifications, local_auth, home_widget | GPL-3.0 | Base conceptual y/o código para hábitos, streaks, notas y recordatorios |
| Semana/planificador | WeekToDo | https://github.com/manuelernestog/weektodo | Vue 3 + Electron; Vuex, moment, rrule, markdown-it | GPL-3.0 | Conceptos de semana, privacidad, recurrent tasks, subtareas; no integrar directo en mobile Flutter salvo reescritura |
| Finanzas | Flow | https://github.com/flow-mn/flow | Flutter/Dart; offline-first; ObjectBox; fl_chart; local_auth; csv/pdf/export; múltiples monedas | GPL-3.0 | Base fuerte para finanzas; atención: README menciona AI receipt parser externo Eny |
| Armario | OpenWardrobe app | https://github.com/OpenWardrobe/app | Flutter/Dart; Supabase, Hive, BLoC, go_router | MIT | Base para closet/outfits y cloud sync opcional |
| Armario DB | OpenWardrobe db | https://github.com/OpenWardrobe/db | Supabase backend / PLpgSQL | MIT | Referencia para esquema de armario |
| Compra/despensa | Wanna | https://github.com/leechy/wanna | Expo/React Native/TypeScript; expo-router; Supabase; shared grocery list | MIT | Conceptos de listas compartidas; reescritura o adapter API, no mezclar UI RN en Flutter |
| Tareas | Taskly | https://github.com/IMGIITRoorkee/Taskly | Flutter/Dart; shared_preferences, provider, speech_to_text, csv, file_picker, duration_picker, countdown, share_plus | MIT | Base simple para tareas, Pomodoro/duración, voz y reescritura de tareas |


## Clonado recomendado

```bash
mkdir -p source_repos
git clone https://github.com/xpavle00/Habo.git source_repos/habo
git clone https://github.com/manuelernestog/weektodo.git source_repos/weektodo
git clone https://github.com/flow-mn/flow.git source_repos/flow
git clone https://github.com/OpenWardrobe/app.git source_repos/openwardrobe_app
git clone https://github.com/OpenWardrobe/db.git source_repos/openwardrobe_db
git clone https://github.com/leechy/wanna.git source_repos/wanna
git clone https://github.com/IMGIITRoorkee/Taskly.git source_repos/taskly
```

## ZIP manual desde GitHub

Cada repositorio también puede descargarse desde:

- `https://github.com/xpavle00/Habo/archive/refs/heads/master.zip`
- `https://github.com/manuelernestog/weektodo/archive/refs/heads/main.zip`
- `https://github.com/flow-mn/flow/archive/refs/heads/stable.zip`
- `https://github.com/OpenWardrobe/app/archive/refs/heads/main.zip`
- `https://github.com/OpenWardrobe/db/archive/refs/heads/main.zip`
- `https://github.com/leechy/wanna/archive/refs/heads/master.zip`
- `https://github.com/IMGIITRoorkee/Taskly/archive/refs/heads/main.zip`

## Observación de verificación

El paquete documental se basa en información pública visible en README, manifestos `pubspec.yaml` / `package.json` y páginas GitHub. No sustituye una auditoría local completa del código.
