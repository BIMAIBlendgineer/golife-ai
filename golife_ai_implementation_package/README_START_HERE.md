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

## Decision actual 2026-04-24

El gateway productivo unico es:

`services/ai_gateway`

Reglas activas:

- la API canonica es `v1`
- Flutter debe integrarse contra `services/ai_gateway`
- `golife_ai_business_roadmap_package/ai-gateway-skeleton` queda como referencia de roadmap, no como segundo backend productivo
- el contrato canonico de evento usa `event_id`, `user_id`, `domain`, `event_type`, `timestamp`, `payload`, `source`, `privacy_level`

## Ejecutar Flutter contra el gateway local

La app usa `http://127.0.0.1:8000` por defecto, pero en emuladores o dispositivos conviene pasar la URL explicita:

```bash
flutter run --dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://127.0.0.1:8000
```

Referencias practicas:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://127.0.0.1:8000`
- dispositivo fisico: `http://<IP-DE-TU-MAQUINA>:8000`

## Superficies actuales del producto

Ahora el paquete ya no es solo mobile + AI gateway. La arquitectura activa queda en tres superficies:

- `new_app/golife_flutter`
  - app movil offline-first
  - LifeGraph local
  - captura, misiones, riesgos, feedback y privacidad
- `services/ai_gateway`
  - motor IA productivo
  - API canonica `v1`
  - clasificacion, daily plan, feedback y ranking
- `services/web_backend`
  - backend operacional/admin
  - usuarios, usage, ai costs, missions, safety, feature flags y support queue
- `apps/admin_next`
  - panel operativo Next.js
  - dashboard, users, usage, ai-costs, missions, feedback, safety, feature-flags, models y support/export-delete

## Ejecutar backend operacional y panel admin

Backend operacional:

```bash
cd services/web_backend
python -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
```

Panel admin:

```bash
cd apps/admin_next
npm install
npm run dev
```

Variables utiles para el panel:

```bash
GOLIFE_ADMIN_API_BASE_URL=http://127.0.0.1:8010
GOLIFE_ADMIN_API_TOKEN=golife-admin-dev
```

## Base operacional recomendada: PostgreSQL

El `web_backend` ya acepta dos modos:

- `OPERATIONAL_DATABASE_URL=postgresql://...`
- `OPERATIONAL_DATABASE_PATH=.runtime/web_backend.db`

La prioridad actual recomendada es PostgreSQL para operacion real y SQLite solo para dev/local o tests.

Ejemplo:

```bash
cd services/web_backend
set ENVIRONMENT=dev
set ADMIN_TOKEN=golife-admin-dev
set INGESTION_TOKEN=golife-ingest-dev
set OPERATIONAL_DATABASE_URL=postgresql://postgres:<PASSWORD>@localhost:5432/golife_ops
python -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
```

Si `OPERATIONAL_DATABASE_URL` no esta definido, el backend cae a `OPERATIONAL_DATABASE_PATH`.

## Conectar AI Gateway con backend operacional

Para que el admin deje de depender de datos fallback y empiece a mostrar ingestiones reales:

```bash
cd services/ai_gateway
set OPERATIONAL_BACKEND_ENABLED=true
set OPERATIONAL_BACKEND_BASE_URL=http://127.0.0.1:8010
set OPERATIONAL_BACKEND_INGESTION_TOKEN=golife-ingest-dev
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Con eso, las rutas del gateway registran:

- invocaciones IA
- auditoria de misiones generadas
- feedback
- safety events por guardrails
- modelos activos en el backend operacional

## Estados del admin

El panel admin ahora distingue:

- `LIVE DATA`
- `FALLBACK SNAPSHOT`
- `BACKEND OFFLINE`

Tambien muestra la ultima ingestion conocida para evitar confundir snapshots con datos operacionales en vivo.
