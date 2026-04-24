# GoLife AI — paquete de implementación

Fecha: 2026-04-24

## Qué es

**GoLife AI** es una propuesta de app móvil única que une:

- hábitos tipo RPG personal;
- tareas y planificación semanal;
- finanzas personales;
- armario/ropa;
- compra, despensa y desperdicio;
- IA explicable con memoria y límites.

La idea no es crear seis apps pequeñas. La idea es crear un **sistema operativo personal de vida diaria**: una sola app donde la IA observa eventos permitidos por el usuario y propone misiones pequeñas, realistas y verificables.

## Repositorios base


| Área | Repositorio | Enlace | Stack verificado públicamente | Licencia verificada públicamente | Uso propuesto |
|---|---|---|---|---|---|
| Hábitos | Habo | https://github.com/xpavle00/Habo | Flutter/Dart; dependencias: provider, shared_preferences, sqflite, fl_chart, notifications, local_auth, home_widget | GPL-3.0 | Base conceptual y/o código para hábitos, streaks, notas y recordatorios |
| Semana/planificador | WeekToDo | https://github.com/manuelernestog/weektodo | Vue 3 + Electron; Vuex, moment, rrule, markdown-it | GPL-3.0 | Conceptos de semana, privacidad, recurrent tasks, subtareas; no integrar directo en mobile Flutter salvo reescritura |
| Finanzas | Flow | https://github.com/flow-mn/flow | Flutter/Dart; offline-first; ObjectBox; fl_chart; local_auth; csv/pdf/export; múltiples monedas | GPL-3.0 | Base fuerte para finanzas; atención: README menciona AI receipt parser externo Eny |
| Armario | OpenWardrobe app | https://github.com/OpenWardrobe/app | Flutter/Dart; Supabase, Hive, BLoC, go_router | MIT | Base para closet/outfits y cloud sync opcional |
| Armario DB | OpenWardrobe db | https://github.com/OpenWardrobe/db | Supabase backend / PLpgSQL | MIT | Referencia para esquema de armario |
| Compra/despensa | Wanna | https://github.com/leechy/wanna | Expo/React Native/TypeScript; expo-router; Supabase; shared grocery list | MIT | Conceptos de listas compartidas; reescritura o adapter API, no mezclar UI RN en Flutter |
| Tareas | Taskly | https://github.com/IMGIITRoorkee/Taskly | Flutter/Dart; shared_preferences, provider, speech_to_text, csv, file_picker, duration_picker, countdown, share_plus | MIT | Base simple para tareas, Pomodoro/duración, voz y reescritura de tareas |


## Decisión crítica

No se recomienda “pegar todo el código” en un solo proyecto sin análisis. Hay stacks distintos:

- Flutter/Dart: Habo, Flow, OpenWardrobe, Taskly.
- Vue/Electron: WeekToDo.
- Expo/React Native/TypeScript: Wanna.

La estrategia recomendada es:

1. Crear un nuevo producto **GoLife AI**.
2. Usar Flutter como shell móvil principal, porque 4 de las 6 bases principales son Flutter.
3. Mantener los repositorios originales como `source_repos/`.
4. Extraer dominio, pantallas, modelos y flujos útiles.
5. Reescribir o adaptar lo que venga de Vue/Electron y React Native.
6. Crear un `AI Gateway` separado con FastAPI + LangGraph/LangChain + OpenRouter.
7. Mantener proveedores IA intercambiables.

## Aviso de licencia

Habo, WeekToDo y Flow son GPL-3.0. Si copias código GPL dentro de GoLife, el resultado derivado normalmente debe respetar GPL-3.0. OpenWardrobe, Wanna y Taskly son MIT. Esto no es asesoramiento jurídico; antes de comercializar, auditar licencias y dependencias.

## Cómo usar este ZIP

1. Crea una carpeta local:
   ```bash
   mkdir golife-ai-lab
   cd golife-ai-lab
   ```

2. Copia dentro este paquete documental.

3. Ejecuta el script:
   ```bash
   bash scripts/clone_repos.sh
   ```

4. Entrega a una IA programadora el archivo:
   ```text
   prompts/MASTER_PROMPT_FOR_AI_CODER.md
   ```

5. La IA debe empezar por auditoría local, no por escribir código.

## Estructura deseada

```text
golife-ai-lab/
  source_repos/
    habo/
    weektodo/
    flow/
    openwardrobe_app/
    openwardrobe_db/
    wanna/
    taskly/
  new_app/
    golife_flutter/
  services/
    ai_gateway/
  docs/
  prompts/
```

## Resultado esperado

Un MVP llamado **GoLife AI** con:

- Dashboard de vida.
- LifeGraph de eventos.
- Motor de misiones.
- Planner semanal asistido.
- TaskDoctor.
- MoneyMirror.
- ClosetLess.
- FridgeZero.
- AI Gateway con OpenRouter intercambiable.
- Explicaciones y trazabilidad de cada sugerencia.
