# 0. Técnica de Producción Seleccionada

> Corrección operativa verificada el 2026-05-03:
> este roadmap describe bien la técnica de ejecución, pero no coincide al 100% con la topología real del repo.
> La superficie activa verificada es `apps/mobile_flutter`, `apps/admin_next`, `services/ai_gateway`, `services/web_backend` y `packages/contracts`.
> El remoto real es `BIMAIBlendgineer/golife-ai`.
> La trazabilidad ejecutada para F04 vive en `docs/operations/F04_01_*` a `F04_04_*`.

## Técnica principal

**Auditoría Forense + Roadmap por Gates + Autopiloto Local con Gate Remoto Pendiente.**

## Técnica secundaria

**Coordinador + agentes especializados + sprints quirúrgicos multiagente + worktrees temporales sólo cuando reduzcan conflicto real.**

## Por qué aplica a este repositorio

El repositorio no es una app simple. Hay al menos tres superficies reales:

1. **Flutter mobile** en `frontend/`.
2. **FastAPI AI Gateway** en `ai-gateway/`.
3. **Next.js Admin Web** en `admin-web/`.

Evidencia:

* `ai-gateway/pyproject.toml` define un paquete Python `plantmind-ai-gateway` con FastAPI, Pydantic, LangGraph, SQLAlchemy, Alembic y Psycopg.
* `admin-web/package.json` define una app Next.js con React, TypeScript, Cypress, ESLint y scripts de build/lint/e2e.
* `frontend/pubspec.yaml` define una app Flutter con Drift, provider, go_router, workmanager, http, image_picker y tests Flutter.
* La arquitectura C4-lite documenta explícitamente Flutter, gateway IA, providers externos, Drift local, admin y ops stores.

## Cómo acelera sin perder calidad

* **Acelera** porque permite agentes paralelos por superficie: gateway, Flutter, admin, seguridad, docs.
* **No pierde calidad** porque cada fase tiene gates: build, lint, typecheck, tests, security, performance, integración y limpieza.
* **Evita dispersión** porque todo vuelve a una única rama de integración.
* **Evita deuda multiagente** porque cada worktree, rama temporal, PR o carpeta creada debe mergearse, cerrarse, eliminarse o justificarse.

## Cuándo usar agentes

Usar varios agentes sólo cuando las áreas no se pisan:

| Caso                                                      | Agentes                                      |
| --------------------------------------------------------- | -------------------------------------------- |
| Gateway + Admin + Frontend separados por contrato OpenAPI | Backend/API, Admin, Frontend, QA             |
| Seguridad transversal                                     | Seguridad + Backend + QA                     |
| UI premium                                                | Frontend/UI + Accesibilidad + QA             |
| Limpieza estructural                                      | Auditor + Integración/Merge + Documentación  |

## Cuándo usar worktrees

Usar worktrees si:

* una fase toca sólo `ai-gateway/`;
* otra fase toca sólo `frontend/`;
* otra fase toca sólo `admin-web/`;
* hay un spike aislado con alto riesgo;
* se necesita comparar una solución sin ensuciar la rama principal.

No usar worktrees si:

* la tarea modifica menos de 3 archivos;
* el cambio es documentación;
* el cambio es un fix lineal;
* hay riesgo de conflictos en los mismos archivos;
* la IA local no puede limpiar correctamente.

## Cuándo usar una sola rama

Usar una sola rama de integración para la macrofase:

```text
integration/premium-production
```

o, siguiendo lo ya usado:

```text
prod/f04-autopilot-roadmap
```

## Cuándo usar más de una PR

Sólo si:

* hay migración de datos crítica;
* hay cambio de seguridad/auth/billing;
* hay refactor estructural masivo;
* hay frontend y backend independientes pero revisables por separado;
* el PR supera tamaño revisable razonable.

Regla: **varias PRs temporales deben terminar mergeadas o cerradas antes de cerrar la macrofase.**

## Cuándo parar

Parar sólo por bloqueo real:

* secreto expuesto;
* test local crítico rojo sin causa;
* build irrecuperable;
* migración destructiva;
* decisión de negocio/seguridad/legal no inferible;
* conflicto Git no trivial;
* acción destructiva necesaria.

No parar por billing de GitHub Actions. Ese caso se registra como:

```text
LOCAL ROADMAP: CONTINÚA
REMOTE GATE: PENDIENTE
```

---

# 1. Inventario Forense del Repositorio

## 1.1 Resumen del Repositorio

| Campo                               | Estado verificado                                                                                      |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Repositorio                         | `BIMAIBlendgineer/plant`                                                                               |
| Visibilidad                         | privado                                                                                                |
| Default branch                      | `main`                                                                                                 |
| PR activo relevante                 | `#6`                                                                                                   |
| Rama PR                             | `premium-plant/f00-ground-truth`                                                                       |
| Head PR verificado                  | `080593f1dc2fb8e6b101d2eb10926133d68eb181`                                                             |
| Estado PR                           | abierto, no merged, no draft, mergeable                                                                |
| Tipo de proyecto                    | Full-stack: Flutter + FastAPI + Next admin                                                             |
| Frontend móvil                      | Flutter en `frontend/`                                                                                 |
| Backend/API                         | FastAPI en `ai-gateway/`                                                                               |
| Admin                               | Next.js en `admin-web/`                                                                                |
| Contratos                           | OpenAPI en `packages/contracts/openapi.yaml`                                                           |
| CI/CD                               | GitHub Actions para gateway, admin y frontend                                                          |
| Estado remoto actual                | workflows fallan por bloqueo externo reportado; API muestra failure sin steps reales para algunos jobs |
| Estado local reportado por IA local | gateway completo verde: `103 passed`, focal verde: `10 passed`, gitleaks OK                            |

Evidencia PR: `#6` está abierto, `mergeable: true`, `draft: false`, con head `080593f1...`, 29 commits y 135 archivos cambiados.

No puedo verificar: `git status`, `git worktree list` y ramas locales reales de la máquina del usuario.
Evidencia disponible: GitHub API del PR y archivos del repositorio.
Impacto: no puedo garantizar limpieza local de worktrees fuera de GitHub.
Acción recomendada: la IA local debe ejecutar `git status --short`, `git branch`, `git branch -a`, `git worktree list` antes de tocar archivos.

## 1.2 Mapa de Carpetas

| Ruta                    | Propósito inferido                        | Evidencia                                                                             | Estado                | Riesgo                                                             |
| ----------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------- | --------------------- | ------------------------------------------------------------------ |
| `frontend/`             | App Flutter móvil                         | `pubspec.yaml` declara Flutter, Drift, provider, go_router, tests.                    | Activa                | Riesgo de regresión móvil si se mezcla IA con UI sin capa servicio |
| `ai-gateway/`           | Gateway IA FastAPI                        | `pyproject.toml` declara FastAPI, Pydantic, LangGraph, SQLAlchemy, Alembic, Psycopg.  | Activa                | Riesgo mock/prod, DB dual SQLite/Postgres, contratos               |
| `admin-web/`            | Panel admin Next.js                       | `package.json` declara Next 16, React 19, Cypress, ESLint, TypeScript.                | Activa                | Riesgo de depender de mock gateway en e2e                          |
| `.github/workflows/`    | CI                                        | Gateway, Admin Web, Automated Tests.                                                  | Activa                | Actualmente bloqueada por billing según reporte local              |
| `packages/contracts/`   | Contrato OpenAPI                          | PR #6 sincroniza OpenAPI y consumidores.                                              | Activa                | Drift contractual bloquea full-stack                               |
| `docs/plantmind/`       | PRD, C4, ADR, audit, runbooks             | PRD y C4 actuales.                                                                    | Activa                | Debe mantenerse sincronizada con implementación                    |
| `plantmind_ai_package/` | Paquete histórico/especificación/skeleton | Búsqueda muestra skeleton y prompts previos.                                          | Riesgo de duplicación | Debe auditarse antes de reutilizar/eliminar                        |

## 1.3 Módulos Reales Detectados

| Módulo         | Ruta                    | Responsabilidad                                            | Implementación              | Dependencias                           | Riesgos                                       | Falta producción                               |
| -------------- | ----------------------- | ---------------------------------------------------------- | --------------------------- | -------------------------------------- | --------------------------------------------- | ---------------------------------------------- |
| Mobile app     | `frontend/`             | UI usuario, Drift, cache, servicios IA                     | Avanzada                    | Flutter, Drift, provider, go_router    | Symlinks/toolchain local, tests, UI PlantMind | widget coverage, UX premium, build release     |
| AI Gateway     | `ai-gateway/`           | Health, identify, grow-here, today-plan, memory, admin ops | Avanzada                    | FastAPI, Pydantic, SQLAlchemy, Alembic | mock provider, DB dual, safety                | no-mock prod, hardening safety, Postgres gates |
| Admin Web      | `admin-web/`            | Usage, billing, costs, models, installations               | Funcional                   | Next, React, Cypress                   | e2e con mock gateway                          | producción con gateway real/config             |
| Contracts      | `packages/contracts/`   | OpenAPI compartido                                         | Activo                      | export/check scripts                   | drift                                         | gate obligatorio por endpoint                  |
| Docs/Audit     | `docs/plantmind/`       | Trazabilidad, PRD, C4, ADR, rollback                       | Activo                      | Markdown                               | stale docs si no se actualiza                 | auditoría por fase                             |
| Legacy package | `plantmind_ai_package/` | Especificación/skeleton anterior                           | Histórico/posible duplicado | Python skeleton/docs/prompts           | duplicación                                   | decidir conservar, migrar o archivar           |

## 1.4 Comandos Detectados

| Comando                                                 | Origen              | Propósito                     | Gate           |
| ------------------------------------------------------- | ------------------- | ----------------------------- | -------------- |
| `python scripts/check_openapi.py`                       | PR #6 y Gateway CI  | Verificar contrato OpenAPI    | QA/API         |
| `python scripts/export_openapi.py`                      | PR #6               | Regenerar OpenAPI             | Contract gate  |
| `pytest` / `python -m pytest -q`                        | Gateway CI          | Tests gateway                 | QA             |
| `bandit -q -r app`                                      | Gateway CI          | SAST Python                   | Security       |
| `pip-audit --skip-editable --ignore-vuln CVE-2026-3219` | Gateway CI          | Auditoría dependencias Python | Security       |
| `alembic upgrade head`                                  | Gateway Postgres CI | Migraciones Postgres          | DB gate        |
| `python scripts/load_test.py ... /health ...`           | Gateway CI          | Smoke de rendimiento gateway  | Performance    |
| `npm ci`                                                | Admin CI            | Instalación reproducible      | Build          |
| `npm audit --audit-level=high`                          | Admin CI            | Seguridad dependencias        | Security       |
| `npm run lint`                                          | Admin CI            | Lint                          | QA             |
| `npm run build`                                         | Admin CI            | Build Next                    | Build          |
| `npm run test:e2e`                                      | Admin CI            | Cypress e2e                   | QA             |
| `flutter pub get`                                       | Automated Tests     | Dependencias Flutter          | Build          |
| `flutter analyze`                                       | Automated Tests     | Análisis Dart                 | Lint/typecheck |
| `flutter test`                                          | Automated Tests     | Tests Flutter                 | QA             |

Evidencia CI: Gateway CI contiene Bandit, pip-audit, OpenAPI check, load smoke, pytest y Postgres con Alembic. Admin Web CI contiene npm ci, audit, lint, build y e2e. Automated Tests contiene Flutter pub get, analyze y test.

---

# 2. Diagnóstico General del Repositorio

## 2.1 Arquitectura Actual

| Área           | Diagnóstico con evidencia                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------- |
| Frontend       | Flutter app con Drift, provider, go_router, workmanager, HTTP, image_picker y tests.                              |
| Backend/API    | FastAPI gateway con Pydantic, LangGraph, SQLAlchemy, Alembic y Psycopg.                                            |
| Admin          | Next.js admin con React, TypeScript, Cypress y ESLint.                                                             |
| Datos          | Drift local en Flutter y gateway analyses/ops/weather/geocoding cache según C4-lite.                              |
| IA             | Endpoints estructurados: analyze, identify, grow-here, today-plan; safety/citations/fallback/memory según PRD/C4. |
| Testing        | CI cubre gateway, Postgres, admin e2e, Flutter analyze/test.                                                       |
| Deploy         | No verifiqué pipeline de deploy productivo final en los archivos inspeccionados.                                   |
| Observabilidad | C4 menciona admin/ops stores; PR #6 incluye usage/cost/admin. Falta validar exhaustivamente logging productivo.   |
| Documentación  | PRD y C4-lite existen; PR #6 agrega audit trail y rollback.                                                        |

## 2.2 Problemas Detectados

| Categoría    | Problema                                                                     | Evidencia                                                          | Impacto         | Prob. | Sev.  | Mitigación                                       |
| ------------ | ---------------------------------------------------------------------------- | ------------------------------------------------------------------ | --------------- | ----: | ----: | ------------------------------------------------ |
| CI/CD        | GitHub Actions remoto no ejecuta correctamente por billing reportado         | API muestra workflows failure; usuario reporta anotación billing.  | Alto            |  Alta |  Alta | Continuar local; remote gate pendiente.          |
| Git/PR       | PR #6 abierto y no mergeado                                                  | PR `merged:false`, `state:open`.                                   | Alto            |  Alta |  Alta | No cerrar producción remota hasta resolver.      |
| Mocks        | `AI_PROVIDER: mock` aparece en CI para gateway y Postgres                    | Gateway CI usa `AI_PROVIDER: mock` para smoke/tests.               | Alto si llega a prod | Media |  Alta | Fase anti-mock prod.                             |
| Contratos    | OpenAPI es gate central                                                      | PR #6 trata import isolation, OpenAPI sync y consumidores.         | Alto            | Media |  Alta | Contract-first en cada fase.                     |
| Datos        | SQLite/Postgres dual puede romper tests/privacidad                           | F03A-10 reporta fixes de aislamiento; Gateway CI Postgres existe.  | Alto            |  Alta |  Alta | Fixtures idempotentes + tests dual DB.           |
| Seguridad    | Baseline gitleaks histórico aceptado, sin rotación                           | PR #6 documenta baseline exacto y no rotación.                     | Medio/Alto      | Media |  Alta | Mantener gitleaks y plan de rotación si procede. |
| IA safety    | PRD exige no consumo seguro sin evidencia, no raw image, degradación climática | PRD Safety Requirements.                                         | Alto            | Media |  Alta | Safety/citation gates.                           |
| UX           | Falta widget-level coverage PlantMind                                        | PRD Priority Gap #5.                                               | Medio           |  Alta | Media | Fase UI/testing.                                 |
| Arquitectura | Critical domain logic must stay out of widgets                               | C4 constraints.                                                    | Medio           | Media |  Alta | Separación UI/services/domain.                   |
| Limpieza     | `plantmind_ai_package` puede duplicar skeleton actual                        | Búsqueda muestra skeleton histórico.                               | Medio           | Media | Media | Auditoría de duplicados antes de eliminar.       |

## 2.3 Riesgos Principales

| Riesgo                | Evidencia                                                 | Impacto                 | Probabilidad | Severidad | Archivos/Módulos                      | Mitigación                 | Fase  |
| --------------------- | --------------------------------------------------------- | ----------------------- | -----------: | --------: | ------------------------------------- | -------------------------- | ----- |
| PR base no mergeado   | PR #6 abierto, no merged.                                 | Bloquea cierre remoto   |         Alta |      Alta | GitHub PR                             | Gate remoto pendiente      | 25    |
| Billing bloquea CI    | Workflows failure sin steps útiles; reporte local billing | No hay validación remota |         Alta |      Alta | GitHub Actions                        | Local RC + rerun posterior | 1,25  |
| Mock en producción    | CI usa `AI_PROVIDER: mock`; provider mock detectado.      | Producto no premium     |        Media |      Alta | `ai-gateway/app/provider.py`, runtime | prod fail-fast             | 12    |
| Contrato roto         | OpenAPI sync es parte central PR.                         | Flutter/Admin fallan    |        Media |      Alta | `schemas.py`, `openapi.yaml`          | export/check obligatorio   | 3,11  |
| Safety insuficiente   | PRD exige safety fuerte.                                  | Riesgo usuario/legal    |        Media |   Crítica | `safety.py`, `citation_guard.py`      | tests adversariales        | 17    |
| Duplicación/legacy    | skeleton en `plantmind_ai_package`.                       | Mantenibilidad baja     |        Media |     Media | docs/skeleton                         | consolidación auditada     | 5     |
| DB dual inconsistente | Gateway CI Postgres + SQLite local                        | Fallos CI/privacidad    |         Alta |      Alta | `db.py`, tests, alembic               | fixtures duales            | 10,21 |
| UI sin cobertura      | PRD gap widget-level coverage.                            | Regresiones UX          |         Alta |     Media | `frontend/lib/ui/plantmind`           | widget tests               | 19,21 |

---

# 3. Estado de Madurez por Área

| Área                  | Puntuación | Evidencia                                            | Brecha                                   | Prioridad | Acción            |
| --------------------- | ---------: | ---------------------------------------------------- | ---------------------------------------- | --------- | ----------------- |
| Arquitectura          |          4 | C4-lite existente.                                   | Consolidar objetivo vs código            | Alta      | ADR + enforcement |
| Frontend              |          3 | Flutter completo con Drift/routes/provider.          | UI premium + widget tests                | Alta      | Fases 19–21       |
| UI/UX                 |          3 | PlantMind UI existe según C4, pero PRD pide coverage | Falta polish premium                     | Alta      | UX audit          |
| Backend               |          4 | FastAPI + SQLAlchemy + Alembic.                      | no-mock prod + hardening                 | Crítica   | Fases 3,12,17     |
| Dominio               |          3 | PRD define health/identify/grow/today.               | DDD formal                               | Media     | Fase 8            |
| Datos                 |          3 | Drift + ops stores.                                  | relaciones normalizadas, backup completo | Alta      | Fases 9–10        |
| Persistencia          |          3 | Alembic/Postgres CI + Drift                          | dual DB hardening                        | Alta      | Fase 10           |
| IA local              |          3 | Provider abstraction y endpoints                     | prod provider/no mock                    | Crítica   | Fase 13           |
| Prompts               |          2 | skeleton/prompts históricos detectados.              | consolidar fuente activa                 | Media     | Fase 14           |
| Trazabilidad          |          4 | audit trail PR #6.                                   | automatizar por fase                     | Alta      | Fase 15           |
| Seguridad             |          3 | Bandit, pip-audit, gitleaks.                         | baseline histórico y prod policy         | Crítica   | Fase 17           |
| Rendimiento           |          3 | load smoke `/health`.                                | endpoints reales + Flutter perf          | Media     | Fase 18           |
| Testing               |          4 | gateway/admin/frontend CI.                           | CI remoto bloqueado                      | Crítica   | Fase 21/25        |
| Accesibilidad         |          2 | No verifiqué tests a11y explícitos                   | falta audit                              | Media     | Fase 20           |
| Documentación         |          4 | PRD/C4/audit docs                                    | mantener sincronía                       | Alta      | Fase 22           |
| Deploy                |          2 | No verifiqué pipeline producción final               | release readiness                        | Alta      | Fase 23           |
| Observabilidad        |          3 | admin/ops usage                                      | logs/metrics prod                        | Media     | Fase 16           |
| DX/mantenibilidad     |          3 | scripts CI claros                                    | legacy/duplicados                        | Media     | Fase 5            |
| Limpieza estructural  |          2 | skeleton histórico + PR grande                       | duplicados/worktrees no verificables     | Alta      | Fase 2/5/25       |
| Salud Git/PR/worktree |          2 | PR #6 abierto, remote gate bloqueado                 | merge pendiente                          | Crítica   | Fase 25           |

---

# 4. PRD Técnico

## 4.1 Objetivo del Producto

Transformar Plant-it/PlantMind en una app premium de producción para cuidado vegetal con:

* análisis de salud;
* identificación conservadora;
* grow-here con grounding;
* garden/hydro context;
* today-plan;
* memoria local;
* backup;
* admin/usage/cost control;
* safety y trazabilidad.

El PRD técnico existente define exactamente esa evolución desde care logging hacia “plant operating system”.

## 4.2 Usuarios o Actores

| Actor                    | Responsabilidad                                         |
| ------------------------ | ------------------------------------------------------- |
| Usuario final            | Gestiona plantas, pide análisis, revisa recomendaciones |
| Administrador            | Controla usage, costes, modelos, billing, instalaciones |
| IA gestora               | Planifica, audita, define gates                         |
| IA local ejecutora       | Modifica archivos, ejecuta validaciones                 |
| Sistema móvil            | UI, Drift, cache, memoria local                         |
| Gateway IA               | Orquestación, safety, provider, memoria, ops            |
| Servicios externos       | IA provider, weather/geocoding                          |
| Desarrollador/mantenedor | Revisa PRs, deploy, rollback                            |

## 4.3 Requisitos Funcionales

| ID    | Descripción                 | Evidencia actual          | Estado           | Brecha                | Prioridad | Criterio aceptación                |
| ----- | --------------------------- | ------------------------- | ---------------- | --------------------- | --------- | ---------------------------------- |
| RF-01 | Análisis salud planta       | PRD `/ai/analyze-plant`.  | Parcial/avanzado | safety/prod hardening | Crítica   | endpoint estructurado + tests + UI |
| RF-02 | Identificación conservadora | PRD `/ai/identify-plant`. | Parcial          | retrieval/taxonomía   | Alta      | candidatos + incertidumbre         |
| RF-03 | Grow-here                   | PRD `/ai/grow-here`.      | Parcial          | species requirements  | Alta      | degraded si falta clima            |
| RF-04 | Today-plan                  | PRD `/ai/today-plan`.     | Parcial          | UX/actionability      | Alta      | acciones priorizadas               |
| RF-05 | Memoria IA local            | PRD local AI memory       | Parcial          | privacy + dual DB     | Alta      | no raw image, delete flow          |
| RF-06 | Backup                      | PRD content/backup flows  | Parcial          | restore completo      | Alta      | export/restore verificado          |
| RF-07 | Admin usage/costs           | PR #6 admin changes       | Parcial          | prod e2e real         | Alta      | admin build/e2e                    |
| RF-08 | Contratos OpenAPI           | PR #6 sync                | Avanzado         | mantener gate         | Crítica   | check_openapi pasa                 |
| RF-09 | Safety                      | PRD Safety Requirements   | Parcial          | adversarial suite     | Crítica   | no unsafe claims                   |
| RF-10 | Local fallback/cache        | C4 key flow               | Parcial          | validar offline       | Alta      | fallback probado                   |

## 4.4 Requisitos No Funcionales

| Categoría       | Requisito                                                                           |
| --------------- | ----------------------------------------------------------------------------------- |
| Rendimiento     | `/health` smoke p95 < 500 ms; endpoints reales con métricas; Flutter no bloquea UI |
| Seguridad       | gitleaks, Bandit, pip-audit, npm audit; sin mock prod; sin secretos logs           |
| Escalabilidad   | gateway desacoplado por OpenAPI                                                     |
| Mantenibilidad  | UI fuera de lógica crítica; services/domain separados                               |
| Auditabilidad   | audit doc por fase                                                                  |
| Trazabilidad    | request_id, provider/model, safety flags, actor, timestamp                          |
| Accesibilidad   | textos localizados, estados accesibles, contraste mínimo                            |
| IA local futura | prompts/versiones/outputs trazables                                                 |
| Deploy          | release runbook, rollback, env checklist                                            |
| Git hygiene     | una rama integrada, sin worktrees/PRs temporales huérfanos                          |

## 4.5 Criterios de Aceptación Globales

* `python scripts/check_openapi.py` pasa.
* `python -m pytest -q` pasa en gateway.
* Gateway Postgres pasa con Alembic.
* `bandit`, `pip-audit`, `gitleaks` pasan o tienen excepción documentada.
* `npm ci`, `npm run lint`, `npm run build`, `npm run test:e2e` pasan.
* `flutter pub get`, `flutter analyze`, `flutter test`, build release pasan.
* No hay mocks visibles en producción.
* No hay carpetas temporales sin justificar.
* No hay PRs abiertos sin decisión.
* No hay worktrees huérfanos.
* OpenAPI sincronizado.
* Rollback actualizado.
* CI remoto verde cuando billing se resuelva.

---

# 5. DDD — Modelo de Dominio

## 5.1 Dominio Principal

**Plant Operating System**: gestión y recomendación inteligente de cuidado vegetal, integrando salud, identificación, entorno, espacios, memoria, backup y operaciones premium.

## 5.2 Subdominios

| Tipo       | Subdominios                                            |
| ---------- | ------------------------------------------------------ |
| Core       | Health analysis, identification, grow-here, today-plan |
| Supporting | Garden, hydro, content, backup, AI memory, feedback    |
| Generic    | Admin, billing, usage, provider secrets, auth, CI/CD   |

## 5.3 Entidades

| Entidad            | Responsabilidad        | Atributos                                   | Evidencia                    | Brecha                         |
| ------------------ | ---------------------- | ------------------------------------------- | ---------------------------- | ------------------------------ |
| Plant              | Planta gestionada      | id, species/name, location, care            | PRD/Flutter domain implícito | relación normalizada con space |
| Analysis           | Resultado IA           | id, type, summary, confidence, safety flags | PRD endpoints + admin analyses | privacy hardening            |
| Identification     | Candidatos taxonómicos | candidates, confidence, flags               | PRD identify                 | citation-backed                |
| GrowHereEvaluation | Evaluación ubicación   | plant, location, climate evidence           | PRD grow-here                | requirements source            |
| TodayPlan          | Acciones diarias       | actions, evidence, priority                 | PRD today-plan               | UI premium                     |
| Feedback           | Señal usuario          | analysis_id, rating, reason                 | PRD memory/feedback          | learning loop                  |
| UsageRecord        | Uso admin              | endpoint, provider, model, cost             | Admin/ops scope              | cost integrity                 |
| BackupManifest     | Export/restore         | version, tables, checksum                   | PRD backup                   | restore completo               |

## 5.4 Value Objects

| Value Object   | Propósito              | Validaciones             | Brecha                |
| -------------- | ---------------------- | ------------------------ | --------------------- |
| Confidence     | Calibrar incertidumbre | enum/rango válido        | evitar overconfidence |
| SafetyFlag     | Riesgo safety          | flag/severity/message    | adversarial coverage  |
| EvidenceRef    | Fuente/cita            | no vacía si claim fuerte | source retrieval      |
| ImageRef       | Foto                   | no raw persistence       | sanitization          |
| InstallationId | Tenant/instalación     | único, token asociado    | test isolation        |
| ProviderModel  | Modelo IA              | provider/model/version   | admin usage           |
| CostEstimate   | Coste                  | número >=0               | billing               |

## 5.5 Agregados

| Aggregate Root | Internas                  | Invariantes                  |
| -------------- | ------------------------- | ---------------------------- |
| Plant          | events, reminders, images | existe sin IA                |
| AIResult       | analysis/identify/grow    | siempre uncertainty + safety |
| Installation   | memory, feedback, usage   | aislamiento por instalación  |
| GardenSpace    | plants/crops/hydro        | relaciones no text matching  |
| Backup         | manifest/items            | no secretos                  |

## 5.6 Servicios de Dominio

| Servicio         | Entrada                | Salida         | Evidencia               |
| ---------------- | ---------------------- | -------------- | ----------------------- |
| PlantAiService   | plant/symptoms/photo   | analysis       | C4 frontend components. |
| PlantIdentifier  | image/context          | candidates     | C4 gateway components.  |
| GrowHereService  | plant/location/weather | evaluation     | PRD gap grow-here.      |
| TodayPlanService | memory/weather/events  | actions        | C4 components.          |
| SafetyService    | provider output        | safe output    | PRD safety.             |
| BackupService    | data                   | export/restore | PRD backup.             |

## 5.7 Casos de Uso

| Caso               | Actor           | Flujo                                           | Errores                      | Resultado                | Archivos                                          |
| ------------------ | --------------- | ----------------------------------------------- | ---------------------------- | ------------------------ | ------------------------------------------------- |
| Analizar salud     | Usuario         | Flutter → gateway → provider → safety → memoria | provider down, unsafe output | análisis estructurado    | `frontend/lib/data/service/ai`, `ai-gateway/app` |
| Identificar planta | Usuario         | foto/context → candidates                       | baja confianza               | candidatos conservadores | `identity/plant_identifier.py`                    |
| Grow-here          | Usuario         | planta/location/weather → evaluación            | sin clima                    | respuesta degradada      | `environment/grow_here.py`                        |
| Today-plan         | Usuario         | home → plan                                     | cache/gateway fail           | acciones/fallback        | `today_plan.py`, home                             |
| Admin usage        | Admin           | dashboard → gateway ops                         | auth/cost missing            | métricas                 | `admin-web`, `ops_repository.py`                  |
| Backup/restore     | Usuario/sistema | export/restore                                  | schema mismatch              | recuperación             | backup services                                   |

## 5.8 Bounded Contexts

| Contexto            | Actual             | Objetivo                       |
| ------------------- | ------------------ | ------------------------------ |
| Mobile Care         | Flutter + Drift    | UI limpia, servicios testeados |
| AI Gateway          | FastAPI            | contratos/safety/prod provider |
| Ops/Admin           | Next + endpoints   | billing/usage completo         |
| Data/Backup         | Drift + gateway DB | restore completo               |
| Contracts           | OpenAPI            | autoridad única                |
| Documentation/Audit | Markdown           | ADR por decisión               |

---

# 6. DDC — Data-Driven Control

## 6.1 Fuentes de Datos

* Inputs usuario: síntomas, fotos, ubicación, feedback.
* Internos: plantas, eventos, recordatorios, memoria, settings.
* Externos: AI provider, weather/geocoding.
* Archivos: imágenes, backup, OpenAPI.
* Bases: Drift local, SQLite/Postgres gateway.
* UI state: loading/error/cache/offline.
* Outputs IA: analysis, identify, grow-here, today-plan.
* Config/env: `AI_PROVIDER`, `AI_ENABLED`, DB URLs, admin tokens en CI.

## 6.2 Flujo de Datos

| Flujo       | Origen                | Transformación            | Persistencia     | Riesgo               |
| ----------- | --------------------- | ------------------------- | ---------------- | -------------------- |
| Health      | Flutter               | Pydantic + graph + safety | memory/ops/cache | raw image/safety     |
| Identify    | imagen/context        | provider + safety         | result/cache     | overconfidence       |
| Grow-here   | plant/location        | weather + evidence        | cache            | advice sin grounding |
| Today-plan  | memory/events/weather | ranking                   | local/cache      | acciones genéricas   |
| Admin usage | endpoint calls        | cost tracking             | ops store        | PII/cost incorrecto  |
| Backup      | local/gateway         | manifest/export           | file/db          | secretos/schema      |

## 6.3 Estados Críticos

* `ai_disabled`
* `provider_mock_test_only`
* `provider_missing_prod`
* `gateway_unavailable`
* `offline_cache_available`
* `unsafe_output_degraded`
* `low_confidence`
* `contract_out_of_sync`
* `remote_ci_billing_blocked`
* `release_candidate_local_only`

## 6.4 Eventos

| Evento                  | Disparador      | Payload                 | Consumidor   | Brecha         |
| ----------------------- | --------------- | ----------------------- | ------------ | -------------- |
| `ai_analysis_requested` | usuario analiza | plant/symptoms/imageRef | gateway      | audit trace    |
| `safety_degraded`       | safety flag     | flag/severity           | UI/admin     | UX             |
| `feedback_submitted`    | usuario rating  | analysis_id/reason      | memory       | learning       |
| `backup_created`        | export          | manifest                | storage      | restore tests  |
| `contract_changed`      | schema update   | OpenAPI diff            | CI/consumers | strict gate    |
| `remote_gate_blocked`   | CI no arranca   | run/job reason          | audit        | manual billing |

## 6.5 Persistencia

| Dato            | Dónde                  | Riesgo              | Falta           |
| --------------- | ---------------------- | ------------------- | --------------- |
| Plantas/eventos | Drift                  | migraciones Flutter | backup restore  |
| AI results      | gateway DB/local cache | privacy/delete      | isolation       |
| Images          | filesystem/local refs  | raw persistence     | sanitization    |
| Usage/costs     | ops store              | PII/cost leak       | retention       |
| Backup          | file/export            | secretos            | manifest        |
| OpenAPI         | `packages/contracts`   | drift               | automatic check |

## 6.6 Trazabilidad

Cada fase debe crear:

```text
docs/plantmind/audit/FXX_<nombre>.md
```

Debe incluir:

* fase;
* agente;
* rama/worktree;
* archivos;
* comandos;
* resultados;
* errores;
* rollback;
* PR/commit;
* riesgos;
* decisión ADR si aplica.

---

# 7. C4-lite — Arquitectura

## 7.1 Contexto

```text
Usuario
→ Flutter mobile app
→ FastAPI PlantMind gateway
→ AI/weather/geocoding providers
→ Drift local + gateway ops DB
→ Admin Web
→ GitHub Actions
```

Evidencia: C4-lite documenta ese flujo y componentes.

## 7.2 Contenedores

| Contenedor     | Ruta                 | Estado                       |
| -------------- | -------------------- | ---------------------------- |
| Frontend móvil | `frontend/`          | Activo                       |
| Gateway        | `ai-gateway/`        | Activo                       |
| Admin          | `admin-web/`         | Activo                       |
| DB local       | Drift                | Activo                       |
| DB gateway     | SQLite/Postgres      | Activo                       |
| Contracts      | `packages/contracts` | Activo                       |
| CI/CD          | `.github/workflows`  | Activo pero remoto bloqueado |
| Docs/Audit     | `docs/plantmind`     | Activo                       |

## 7.3 Componentes

| Nombre                      | Ruta            | Responsabilidad      | Estado | Brecha            |
| --------------------------- | --------------- | -------------------- | ------ | ----------------- |
| `PlantAiService`            | Flutter service | AI requests          | Activo | tests/fallback    |
| `PlantMindTodayPlanService` | Flutter/gateway | today-plan           | Activo | UX                |
| `graph.py`                  | gateway         | orchestration        | Activo | prod provider     |
| `safety.py`                 | gateway         | deterministic safety | Activo | adversarial tests |
| `citation_guard.py`         | gateway         | grounding            | Activo | sources           |
| `ops_repository.py`         | gateway         | admin/usage DB       | Activo | retention         |
| Admin dashboard             | `admin-web/app` | ops UI               | Activo | e2e real          |

## 7.4 Mapa de Dependencias

```text
frontend service layer
→ OpenAPI-compatible payloads
→ ai-gateway schemas/main
→ graph/provider/safety/repositories
→ ops DB / memory DB
→ admin-web consumes ops/admin endpoints
```

## 7.5 Actual vs Objetivo

| Área      | Actual                              | Objetivo             | Brecha           | Acción  |
| --------- | ----------------------------------- | -------------------- | ---------------- | ------- |
| IA        | mock en tests, provider abstraction | prod no-mock         | enforcement      | F12     |
| Contratos | OpenAPI gate                        | contract-first total | mantener         | F11     |
| DB        | SQLite/Postgres                     | dual robust          | test isolation   | F10     |
| UI        | PlantMind screens                   | premium UX           | coverage/a11y    | F19–20  |
| Admin     | Next app                            | prod ops             | real gateway e2e | F11/F23 |
| CI        | workflows                           | remote green         | billing          | F25     |

---

# 8. ADR — Decisiones Arquitectónicas

## ADR-001 — Rama única de integración premium

* Estado: aceptado recomendado.
* Contexto: PR grande y roadmap multiagente.
* Evidencia: PR #6 tiene 135 archivos cambiados y sigue abierto.
* Decisión: usar `prod/f04-autopilot-roadmap` como integración local.
* Alternativas: PRs múltiples permanentes.
* Motivo: evitar dispersión.
* Consecuencias positivas: control y limpieza.
* Consecuencias negativas: PR final puede crecer.
* Riesgos: conflicto si agentes pisan archivos.
* Archivos afectados: Git only.
* Reversibilidad: alta.
* Fase: 2,25.

## ADR-002 — No mock en producción

* Estado: aceptado recomendado.
* Evidencia: CI usa `AI_PROVIDER: mock` sólo para tests/smoke.
* Decisión: mock sólo dev/test; prod falla si mock.
* Alternativas: fallback mock.
* Motivo: app premium sin simulación.
* Riesgo: prod requiere provider real.
* Fase: 12.

## ADR-003 — OpenAPI como contrato obligatorio

* Estado: aceptado recomendado.
* Evidencia: PR #6 sincroniza OpenAPI y CI ejecuta `check_openapi`.
* Decisión: todo endpoint cambia con export/check.
* Fase: 11.

## ADR-004 — Safety posterior al provider

* Estado: aceptado recomendado.
* Evidencia: PRD exige safety y C4 incluye safety/citation.
* Decisión: no confiar en provider output.
* Fase: 17.

## ADR-005 — Persistencia image-sanitized

* Estado: aceptado recomendado.
* Evidencia: PRD prohíbe raw image persistence y raw image en prompt storage.
* Decisión: guardar refs/hash/metadatos, no raw image.
* Fase: 10.

## ADR-006 — Tests dual SQLite/Postgres

* Estado: aceptado recomendado.
* Evidencia: Gateway CI tiene job Postgres con Alembic y pytest.
* Decisión: fixtures idempotentes y compatibles.
* Fase: 21.

## ADR-007 — Legacy package bajo cuarentena

* Estado: propuesto.
* Evidencia: `plantmind_ai_package/ai-gateway-skeleton` detectado junto a `ai-gateway/`.
* Decisión: no eliminar hasta verificar referencias; consolidar docs/prompts útiles.
* Fase: 5.

## ADR-008 — Remote gate pendiente por billing

* Estado: aceptado operativo.
* Evidencia: workflows en failure, jobs sin steps reales; usuario reporta billing annotation.
* Decisión: continuar local; no release remoto final.
* Fase: 25.

## ADR-009 — Admin e2e con mock sólo en CI controlado

* Estado: propuesto.
* Evidencia: `admin-web/package.json` tiene `mock:gateway` y `test:e2e`.
* Decisión: separar e2e mock de smoke real gateway.
* Fase: 11,23.

## ADR-010 — Limpieza obligatoria de worktrees

* Estado: aceptado recomendado.
* Decisión: todo worktree tiene dueño, fase, archivos permitidos, cierre y eliminación.
* Fase: todas.

---

# 9. Roadmap Autopilot de Producción Masiva

## Convención global

* Rama integración: `prod/f04-autopilot-roadmap`.
* PR base pendiente: `#6`.
* Modo: local autopilot, remote gate pendiente.
* Fase mínima: commit + audit doc + gates.
* No borrar legacy sin verificación de referencias.

---

## Fase 1 — Auditoría inicial del repositorio

### Objetivo

Congelar estado real y baseline.

### Tipo de fase

Diagnóstico.

### Prioridad

Crítica.

### Dependencias

Ninguna.

### Técnica de ejecución

Agente único: Auditor Forense. Rama única. Sin worktree.

### Justificación

PR #6 está abierto y remote gate bloqueado; hay que congelar baseline antes de continuar.

### Evidencia del repositorio

PR #6 abierto y mergeable.

### Archivos a revisar

`README*`, `.github/workflows/*`, `frontend/pubspec.yaml`, `ai-gateway/pyproject.toml`, `admin-web/package.json`, `docs/plantmind/*`.

### Archivos a modificar

`docs/plantmind/audit/F04_01_REPO_FORENSIC_BASELINE.md`.

### Archivos prohibidos

Código runtime.

### Checklist de ejecución

* `git status`
* `git branch -a`
* `git worktree list`
* `git log --oneline --decorate -n 30`
* inventario de carpetas
* documentar baseline.

### Tareas para IA local

TAREA: Crear baseline forense
ID: F01-T01
FASE: 1
AGENTE RESPONSABLE: Auditor Forense
PRIORIDAD: Crítica
RIESGO: Bajo
CONTEXTO: PR base abierto y CI remoto bloqueado.
OBJETIVO: Documentar estado real antes de cambios.
ARCHIVOS A LEER: `.github/workflows/*`, `frontend/pubspec.yaml`, `ai-gateway/pyproject.toml`, `admin-web/package.json`.
ARCHIVOS A MODIFICAR: `docs/plantmind/audit/F04_01_REPO_FORENSIC_BASELINE.md`.
ARCHIVOS PROHIBIDOS: código fuente.
CAMBIOS PERMITIDOS: documentación.
CAMBIOS PROHIBIDOS: código/config.
DEPENDENCIAS: ninguna.
PASOS DE EJECUCIÓN: ejecutar comandos de inventario y registrar salidas.
CRITERIOS DE ACEPTACIÓN: audit doc con SHA, ramas, worktrees, módulos, comandos.
COMANDOS DE VERIFICACIÓN: `git status --short`, `git worktree list`.
QUÉ REPORTAR AL FINAL: baseline, riesgos, estado Git.
ROLLBACK: eliminar audit doc.
RESULTADO ESPERADO: baseline firmado.

### QA Gate

Documento completo y `git status` limpio.

### Security Gate

No incluir secretos.

### Performance Gate

No aplica.

### Integration Gate

Commit directo a rama de integración.

### Cleanup Gate

Sin worktrees.

### Resultado esperado

Baseline local.

### Condición de avance

Audit doc creado.

### Próxima fase lógica

Auditoría Git/PR/worktrees.

---

## Fase 2 — Auditoría Git/PR/worktrees/directorios temporales

### Objetivo

Evitar cierre con ramas, PRs o worktrees huérfanos.

### Tipo

Diagnóstico / limpieza.

### Prioridad

Crítica.

### Dependencias

Fase 1.

### Técnica

Agente Auditor + Integración. Sin worktree.

### Evidencia

PR #6 abierto y no mergeado.

### Archivos a revisar

Git metadata local, `.github`, docs audit.

### Archivos a modificar

`docs/plantmind/audit/F04_02_GIT_HYGIENE_AUDIT.md`.

### Archivos prohibidos

Código.

### Tarea

TAREA: Auditar higiene Git
ID: F02-T01
FASE: 2
AGENTE RESPONSABLE: Integración/Merge
PRIORIDAD: Crítica
RIESGO: Medio
CONTEXTO: multiagente puede dejar residuos.
OBJETIVO: listar ramas, PRs, worktrees, carpetas temporales.
ARCHIVOS A LEER: Git metadata local.
ARCHIVOS A MODIFICAR: audit doc.
ARCHIVOS PROHIBIDOS: código.
CAMBIOS PERMITIDOS: documentación.
CAMBIOS PROHIBIDOS: borrar ramas sin merge.
DEPENDENCIAS: F1.
PASOS DE EJECUCIÓN: `git branch`, `git branch -a`, `git worktree list`, buscar `old|backup|temp|final|copy`.
CRITERIOS DE ACEPTACIÓN: inventario y plan de cierre.
COMANDOS DE VERIFICACIÓN: `git status --short`.
QUÉ REPORTAR AL FINAL: ramas/worktrees/carpetas.
ROLLBACK: revert doc.
RESULTADO ESPERADO: mapa de limpieza.

### Gates

QA: doc completo. Security: no secretos. Integration: sin merge. Cleanup: plan documentado.

### Próxima

Estabilización build.

---

## Fase 3 — Estabilización del build local

### Objetivo

Reproducir gates localmente.

### Tipo

Estabilización.

### Prioridad

Crítica.

### Dependencias

F1–F2.

### Técnica

Multiagente secuencial: Gateway, Admin, Frontend, QA. Worktrees sólo si toolchains se pisan.

### Evidencia

Workflows definen comandos reales.

### Tarea

TAREA: Ejecutar full validation local base
ID: F03-T01
FASE: 3
AGENTE RESPONSABLE: QA/Testing
PRIORIDAD: Crítica
RIESGO: Medio
CONTEXTO: CI remoto bloqueado; local debe ser autoridad temporal.
OBJETIVO: validar gateway/admin/frontend.
ARCHIVOS A LEER: workflows.
ARCHIVOS A MODIFICAR: `docs/plantmind/audit/F04_03_LOCAL_VALIDATION_BASELINE.md`.
ARCHIVOS PROHIBIDOS: código salvo fix posterior.
CAMBIOS PERMITIDOS: doc de resultados.
CAMBIOS PROHIBIDOS: relajar tests.
DEPENDENCIAS: F2.
PASOS: ejecutar comandos de workflows.
CRITERIOS: resultados registrados.
COMANDOS: `pytest`, `npm run build`, `flutter test`, etc.
REPORTE: comandos y resultados.
ROLLBACK: revert doc.
RESULTADO: baseline validado.

### Gates

QA: gateway/admin/frontend. Security: bandit/pip/npm/gitleaks. Performance: load smoke.

---

## Fase 4 — Corrección de errores críticos

### Objetivo

Corregir sólo errores que impiden gates.

### Tipo

Estabilización.

### Prioridad

Crítica.

### Dependencias

F3.

### Técnica

Sprint quirúrgico; worktree por área si hay errores simultáneos.

### Tarea

TAREA: Fix quirúrgico por gate rojo
ID: F04-T01
FASE: 4
AGENTE RESPONSABLE: QA + área afectada
PRIORIDAD: Crítica
RIESGO: Medio/Alto
CONTEXTO: sólo actuar sobre fallos reproducidos.
OBJETIVO: dejar gates verdes.
ARCHIVOS A LEER: logs y archivos afectados.
ARCHIVOS A MODIFICAR: sólo afectados.
ARCHIVOS PROHIBIDOS: no relacionados.
CAMBIOS PERMITIDOS: fixes mínimos.
CAMBIOS PROHIBIDOS: skips generales.
DEPENDENCIAS: F3.
PASOS: reproducir, fix, test focal, full suite.
CRITERIOS: gate verde.
COMANDOS: según área.
REPORTE: causa raíz.
ROLLBACK: revert commit.
RESULTADO: build estable.

---

## Fase 5 — Limpieza de estructura y duplicados

### Objetivo

Clasificar legacy, duplicados y temporales.

### Tipo

Limpieza.

### Prioridad

Alta.

### Dependencias

F3/F4.

### Técnica

Agente Auditor + Documentación. No borrar hasta verificar.

### Evidencia

`skeleton` histórico detectado en `plantmind_ai_package`.

### Tarea

TAREA: Auditar `plantmind_ai_package` y duplicados
ID: F05-T01
FASE: 5
AGENTE RESPONSABLE: Auditor de Arquitectura
PRIORIDAD: Alta
RIESGO: Medio
CONTEXTO: existe paquete histórico junto a implementación real.
OBJETIVO: decidir conservar/migrar/eliminar.
ARCHIVOS A LEER: `plantmind_ai_package/**`, `ai-gateway/**`, docs.
ARCHIVOS A MODIFICAR: audit doc y ADR si aplica.
ARCHIVOS PROHIBIDOS: borrado directo.
CAMBIOS PERMITIDOS: docs, deprecated markers si necesario.
CAMBIOS PROHIBIDOS: eliminar sin referencia scan.
DEPENDENCIAS: F4.
PASOS: `rg` referencias, comparar lógica, documentar.
CRITERIOS: plan de consolidación.
COMANDOS: `rg "plantmind_ai_package|ai-gateway-skeleton" .`.
REPORTE: candidatos.
ROLLBACK: revert doc.
RESULTADO: mapa de duplicados.

---

## Fase 6 — Normalización de dependencias

### Objetivo

Revisar dependencias, lockfiles, audits.

### Tipo

Estabilización / seguridad.

### Prioridad

Alta.

### Evidencia

Python, npm, Flutter deps declaradas.

### Tarea

TAREA: Dependency audit
ID: F06-T01
FASE: 6
AGENTE: Seguridad
PRIORIDAD: Alta
RIESGO: Medio
CONTEXTO: app premium requiere deps auditadas.
OBJETIVO: detectar vulnerabilidades y drift.
ARCHIVOS A LEER: manifests/locks.
ARCHIVOS A MODIFICAR: audit doc; locks sólo si fix necesario.
ARCHIVOS PROHIBIDOS: actualizar major sin ADR.
CAMBIOS PERMITIDOS: docs, patches justificados.
CAMBIOS PROHIBIDOS: upgrades masivos.
DEPENDENCIAS: F3.
PASOS: audits Python/npm/Flutter.
CRITERIOS: sin high crítico no documentado.
COMANDOS: `pip-audit`, `npm audit`, `flutter pub outdated`.
ROLLBACK: revert deps.
RESULTADO: deps controladas.

---

## Fase 7 — Separación de capas

### Objetivo

Evitar lógica crítica en widgets.

### Tipo

Arquitectura/refactor.

### Prioridad

Alta.

### Evidencia

C4 constraint: critical domain logic out of widgets.

### Tarea

TAREA: Audit UI/domain separation
ID: F07-T01
FASE: 7
AGENTE: Arquitectura + Frontend
PRIORIDAD: Alta
RIESGO: Medio
OBJETIVO: localizar lógica crítica en widgets y mover a services/viewmodels.
ARCHIVOS A LEER: `frontend/lib/ui/**`, `frontend/lib/data/service/**`.
ARCHIVOS A MODIFICAR: sólo módulos con acoplamiento probado.
ARCHIVOS PROHIBIDOS: DB schema.
CAMBIOS PERMITIDOS: extracción pequeña.
CAMBIOS PROHIBIDOS: reescritura UI masiva.
COMANDOS: `flutter analyze`, `flutter test`.
RESULTADO: capas limpias incrementalmente.

---

## Fase 8 — Definición de dominio/DDD

### Objetivo

Formalizar entidades, servicios, invariantes.

### Tipo

Dominio/documentación.

### Prioridad

Media.

### Tarea

TAREA: Crear DDD técnico vivo
ID: F08-T01
FASE: 8
AGENTE: Dominio/DDD
PRIORIDAD: Media
RIESGO: Bajo
ARCHIVOS A LEER: PRD, C4, schemas, models.
ARCHIVOS A MODIFICAR: `docs/plantmind/domain/DDD.md`.
ARCHIVOS PROHIBIDOS: código runtime.
CAMBIOS PERMITIDOS: docs.
CRITERIOS: entidades y bounded contexts mapeados a código.
ROLLBACK: revert doc.

---

## Fase 9 — Organización de datos

### Objetivo

Normalizar plant-to-space, garden/hydro, memory.

### Tipo

Datos.

### Prioridad

Alta.

### Evidencia

PRD gap: reemplazar matching heurístico `plant.location` por relación normalizada.

### Tarea

TAREA: Diseñar relación plant-to-space
ID: F09-T01
FASE: 9
AGENTE: Datos/Persistencia
PRIORIDAD: Alta
RIESGO: Alto
ARCHIVOS A LEER: Drift DB, garden models/services.
ARCHIVOS A MODIFICAR: schema/migration sólo si necesario y con ADR.
ARCHIVOS PROHIBIDOS: UI no relacionada.
CAMBIOS PERMITIDOS: migration incremental.
CAMBIOS PROHIBIDOS: romper datos existentes.
COMANDOS: Flutter tests + migration tests.
ROLLBACK: migration rollback documentado.

---

## Fase 10 — Persistencia y privacidad

### Objetivo

Asegurar SQLite/Postgres/Drift sin raw image y con delete flow.

### Tipo

Datos/seguridad.

### Prioridad

Crítica.

### Evidencia

PRD safety: no raw image en SQLite ni prompt storage.

### Tarea

TAREA: Hardening persistencia IA
ID: F10-T01
FASE: 10
AGENTE: Datos + Seguridad
PRIORIDAD: Crítica
RIESGO: Alto
ARCHIVOS A LEER: `ai-gateway/app/db.py`, `ops_repository.py`, memory/privacy tests.
ARCHIVOS A MODIFICAR: repos/tests si brecha real.
ARCHIVOS PROHIBIDOS: provider logic.
CAMBIOS PERMITIDOS: sanitization, tests.
CAMBIOS PROHIBIDOS: ocultar datos sin delete semantics.
COMANDOS: `pytest tests/test_privacy_* tests/test_memory.py`.
RESULTADO: privacy gate verde.

---

## Fase 11 — Servicios internos y contratos

### Objetivo

OpenAPI estable entre gateway, admin, Flutter.

### Tipo

Arquitectura/API.

### Prioridad

Crítica.

### Evidencia

PR #6 se centra en sync OpenAPI.

### Tarea

TAREA: Contract-first hardening
ID: F11-T01
FASE: 11
AGENTE: Backend/API
PRIORIDAD: Crítica
RIESGO: Alto
ARCHIVOS A LEER: `schemas.py`, `main.py`, `packages/contracts/openapi.yaml`, Flutter services, admin types.
ARCHIVOS A MODIFICAR: sólo contratos y consumidores.
ARCHIVOS PROHIBIDOS: UI visual.
CAMBIOS PERMITIDOS: schema additive/backward-compatible.
COMANDOS: `python scripts/export_openapi.py`, `check_openapi.py`, admin tsc, Flutter tests.
RESULTADO: contrato fuerte.

---

## Fase 12 — Eliminación de mocks productivos

### Objetivo

Mock sólo dev/test.

### Tipo

Seguridad/IA.

### Prioridad

Crítica.

### Evidencia

Gateway CI usa `AI_PROVIDER: mock` para tests.

### Tarea

TAREA: No-mock production gate
ID: F12-T01
FASE: 12
AGENTE: Seguridad + Backend
PRIORIDAD: Crítica
RIESGO: Alto
ARCHIVOS A LEER: provider/runtime/tests.
ARCHIVOS A MODIFICAR: runtime config/tests.
ARCHIVOS PROHIBIDOS: CI tests que requieren mock.
CAMBIOS PERMITIDOS: fail-fast prod.
CAMBIOS PROHIBIDOS: quitar mock de tests.
COMANDOS: runtime/provider tests + full pytest.
RESULTADO: prod sin mock.

---

## Fase 13 — Integración IA local/provider real

### Objetivo

Provider real configurable, fallback controlado.

### Tipo

IA local/backend.

### Prioridad

Alta.

### Tarea

TAREA: Provider readiness
ID: F13-T01
FASE: 13
AGENTE: IA Local/Prompts
PRIORIDAD: Alta
RIESGO: Alto
ARCHIVOS A LEER: `provider.py`, runtime, secrets backend.
ARCHIVOS A MODIFICAR: provider config/tests/docs.
ARCHIVOS PROHIBIDOS: hardcode secrets.
CAMBIOS PERMITIDOS: env validation.
COMANDOS: provider tests, secret backend tests.
RESULTADO: provider real listo.

---

## Fase 14 — Sistema de prompts

### Objetivo

Versionar prompts activos y retirar duplicados.

### Tipo

IA local/documentación.

### Prioridad

Media.

### Evidencia

Prompts históricos detectados.

### Tarea

TAREA: Prompt inventory
ID: F14-T01
FASE: 14
AGENTE: IA Local/Prompts
PRIORIDAD: Media
RIESGO: Medio
ARCHIVOS A LEER: prompts históricos, provider/graph.
ARCHIVOS A MODIFICAR: docs/prompt registry.
ARCHIVOS PROHIBIDOS: provider runtime sin tests.
RESULTADO: prompts trazables.

---

## Fase 15 — Sistema de trazabilidad

### Objetivo

Trazar decisiones, outputs, errores, agentes.

### Tipo

Documentación/observabilidad.

### Prioridad

Alta.

### Tarea

TAREA: Audit trail enforcement
ID: F15-T01
FASE: 15
AGENTE: Documentación/ADR
PRIORIDAD: Alta
RIESGO: Bajo
ARCHIVOS A LEER: audit docs actuales.
ARCHIVOS A MODIFICAR: templates audit/ADR.
RESULTADO: plantilla obligatoria.

---

## Fase 16 — Logging y auditoría runtime

### Objetivo

Logs útiles sin secretos.

### Tipo

Observabilidad/seguridad.

### Prioridad

Alta.

### Tarea

TAREA: Logging sanitization audit
ID: F16-T01
FASE: 16
AGENTE: Seguridad
PRIORIDAD: Alta
RIESGO: Medio
ARCHIVOS A LEER: logging middleware, runtime, admin endpoints.
ARCHIVOS A MODIFICAR: sanitization/tests si falta.
COMANDOS: privacy tests + grep tokens.
RESULTADO: logs seguros.

---

## Fase 17 — Seguridad

### Objetivo

Cierre seguridad integral.

### Tipo

Seguridad.

### Prioridad

Crítica.

### Evidencia

Bandit/pip-audit/gitleaks/npm audit en gates.

### Tarea

TAREA: Full security gate
ID: F17-T01
FASE: 17
AGENTE: Seguridad
PRIORIDAD: Crítica
RIESGO: Alto
ARCHIVOS A LEER: env examples, secrets, provider backend, CI.
ARCHIVOS A MODIFICAR: docs/fixes mínimos.
COMANDOS: `gitleaks git --redact`, `bandit`, `pip-audit`, `npm audit`.
RESULTADO: security pass.

---

## Fase 18 — Optimización de rendimiento

### Objetivo

Gateway, admin y Flutter sin degradaciones.

### Tipo

Rendimiento.

### Prioridad

Media.

### Evidencia

Gateway CI ya tiene health load smoke.

### Tarea

TAREA: Performance smoke expansion
ID: F18-T01
FASE: 18
AGENTE: Performance
PRIORIDAD: Media
RIESGO: Medio
ARCHIVOS A LEER: load_test, endpoints, Flutter screens.
ARCHIVOS A MODIFICAR: scripts/tests si falta.
COMANDOS: load smoke + Flutter performance review.
RESULTADO: perf baseline.

---

## Fase 19 — UI/UX premium

### Objetivo

Pulir experiencia PlantMind.

### Tipo

UI.

### Prioridad

Alta.

### Tarea

TAREA: Premium UX pass
ID: F19-T01
FASE: 19
AGENTE: Frontend/UI Premium
PRIORIDAD: Alta
RIESGO: Medio
ARCHIVOS A LEER: `frontend/lib/ui/plantmind/**`, home, l10n.
ARCHIVOS A MODIFICAR: UI y l10n.
ARCHIVOS PROHIBIDOS: backend/schema.
COMANDOS: `flutter analyze`, `flutter test`.
RESULTADO: UI consistente.

---

## Fase 20 — Accesibilidad

### Objetivo

A11y mínima.

### Tipo

UI/accesibilidad.

### Prioridad

Media.

### Tarea

TAREA: Accessibility pass
ID: F20-T01
FASE: 20
AGENTE: Frontend + QA
PRIORIDAD: Media
RIESGO: Bajo
ARCHIVOS A LEER: widgets PlantMind.
ARCHIVOS A MODIFICAR: semantics/labels/l10n.
COMANDOS: Flutter tests.
RESULTADO: accesibilidad mínima.

---

## Fase 21 — Testing

### Objetivo

Cobertura crítica y widget-level PlantMind.

### Tipo

Testing.

### Prioridad

Crítica.

### Evidencia

PRD gap: widget-level coverage para rutas/pantallas.

### Tarea

TAREA: Critical coverage closure
ID: F21-T01
FASE: 21
AGENTE: QA/Testing
PRIORIDAD: Crítica
RIESGO: Medio
ARCHIVOS A LEER: tests existentes.
ARCHIVOS A MODIFICAR: tests.
COMANDOS: pytest, npm e2e, flutter test.
RESULTADO: coverage crítica.

---

## Fase 22 — Documentación

### Objetivo

Docs sincronizadas.

### Tipo

Documentación.

### Prioridad

Alta.

### Tarea

TAREA: Documentation sync
ID: F22-T01
FASE: 22
AGENTE: Documentación/ADR
PRIORIDAD: Alta
RIESGO: Bajo
ARCHIVOS A LEER: PRD, C4, ADR, runbooks.
ARCHIVOS A MODIFICAR: docs.
RESULTADO: docs mantenibles.

---

## Fase 23 — Deploy readiness

### Objetivo

Preparar release.

### Tipo

Deploy.

### Prioridad

Alta.

### Tarea

TAREA: Release runbook
ID: F23-T01
FASE: 23
AGENTE: Deploy/Integración
PRIORIDAD: Alta
RIESGO: Alto
ARCHIVOS A LEER: workflows, Dockerfile, env docs.
ARCHIVOS A MODIFICAR: runbooks/deploy docs.
COMANDOS: builds release locales.
RESULTADO: deploy checklist.

---

## Fase 24 — Revisión final production-ready

### Objetivo

Full-stack local RC.

### Tipo

Integración.

### Prioridad

Crítica.

### Tarea

TAREA: Local release candidate
ID: F24-T01
FASE: 24
AGENTE: Coordinador + QA
PRIORIDAD: Crítica
RIESGO: Alto
ARCHIVOS A LEER: todo manifiesto.
ARCHIVOS A MODIFICAR: final audit doc.
COMANDOS: full validation gateway/admin/frontend/security.
RESULTADO: `LOCAL RELEASE CANDIDATE: COMPLETE`.

---

## Fase 25 — Cierre Git: merge, limpieza, PRs, worktrees

### Objetivo

Cerrar remoto cuando billing esté resuelto.

### Tipo

Integración/limpieza.

### Prioridad

Crítica.

### Dependencias

F24 + GitHub Actions funcional.

### Tarea

TAREA: Remote merge and cleanup
ID: F25-T01
FASE: 25
AGENTE: Integración/Merge
PRIORIDAD: Crítica
RIESGO: Alto
CONTEXTO: no se puede cerrar remoto sin CI.
OBJETIVO: rerun, merge, limpiar.
ARCHIVOS A LEER: Git state, PRs.
ARCHIVOS A MODIFICAR: audit final.
ARCHIVOS PROHIBIDOS: código.
CAMBIOS PERMITIDOS: merge/cleanup.
CAMBIOS PROHIBIDOS: merge con CI real rojo.
PASOS: rerun PR #6, merge si verde, integrar F04, PR final, rerun, merge, limpiar ramas/worktrees.
CRITERIOS: CI verde y Git limpio.
COMANDOS: `git branch`, `git worktree list`, PR checks.
ROLLBACK: revert merge si falla post-merge.
RESULTADO: producción cerrada.

---

# 10. Protocolo Autopilot para IA Local Ejecutora

## 10.1 Reglas de Autonomía

La IA local debe:

* leer antes de modificar;
* inferir comandos desde manifests/CI;
* ejecutar gates antes de avanzar;
* no preguntar si puede verificar;
* reportar sólo bloqueos reales;
* mantener cambios pequeños;
* limpiar worktrees;
* eliminar ramas integradas;
* documentar rollback.

## 10.2 Reglas de Parada

Parar sólo si:

* build irrecuperable;
* tests fallan sin causa;
* secreto expuesto;
* migración destructiva;
* credencial externa indispensable;
* decisión legal/producto;
* conflicto Git no trivial.

No parar por billing de GitHub Actions.

## 10.3 Reglas de Git

* Rama integración: `prod/f04-autopilot-roadmap`.
* Commit por fase.
* Worktree sólo si hay paralelismo real.
* PR único final salvo excepción.
* Ramas temporales: mergear y `git branch -d`.
* Worktrees: `git worktree remove` + `git worktree prune`.
* PR obsoleto: cerrar con explicación.

## 10.4 Reporte por Tarea

Debe incluir:

* ID;
* archivos modificados;
* resumen;
* motivo;
* comandos;
* build/lint/typecheck/tests;
* errores;
* riesgos;
* rollback;
* siguiente tarea.

## 10.5 Reporte por Fase

Debe incluir:

* fase;
* rama;
* ramas creadas/mergeadas/eliminadas;
* PRs;
* worktrees;
* carpetas;
* archivos viejos;
* gates;
* riesgos;
* siguiente fase.

---

# 11. Primera Instrucción Ejecutable para IA Local

INSTRUCCIÓN PARA IA LOCAL

ID: F01-T01
FASE: 1 — Auditoría inicial del repositorio
PRIORIDAD: Crítica
RIESGO: Bajo
OBJETIVO: Crear baseline forense local antes de continuar roadmap.
CONTEXTO: PR #6 está abierto, mergeable, no mergeado; head `080593f1dc2fb8e6b101d2eb10926133d68eb181`; remote gate bloqueado por billing reportado, pero validación local F03A-10 está verde.
ARCHIVOS A LEER:

* `.github/workflows/*`
* `ai-gateway/pyproject.toml`
* `admin-web/package.json`
* `frontend/pubspec.yaml`
* `docs/plantmind/product/PRD_TECHNICAL.md`
* `docs/plantmind/architecture/C4_LITE.md`

ARCHIVOS A MODIFICAR:

* `docs/plantmind/audit/F04_01_REPO_FORENSIC_BASELINE.md`

ARCHIVOS PROHIBIDOS:

* código runtime;
* `.env`;
* workflows;
* lockfiles.

DEPENDENCIAS:

* repo local con Git metadata.

PASOS:

```bash
git fetch origin
git switch premium-plant/f00-ground-truth
git pull --ff-only
git rev-parse HEAD
git status --short
git branch
git branch -a
git worktree list
git log --oneline --decorate -n 30

git switch -c prod/f04-autopilot-roadmap || git switch prod/f04-autopilot-roadmap
```

Crear audit doc con:

* SHA base;
* ramas;
* worktrees;
* estado PR #6;
* estado CI remoto;
* módulos detectados;
* comandos de gates;
* riesgos;
* decisión: continuar local con remote gate pendiente.

CRITERIOS DE ACEPTACIÓN:

* audit doc completo;
* no se modifica código;
* `git status --short` limpio salvo audit doc;
* fase lista para commit.

COMANDOS DE VERIFICACIÓN:

```bash
git status --short
git diff -- docs/plantmind/audit/F04_01_REPO_FORENSIC_BASELINE.md
```

QUÉ REPORTAR AL FINAL:

* SHA;
* rama;
* worktrees;
* PRs abiertos;
* carpetas sospechosas;
* riesgos;
* siguiente fase.

ROLLBACK:

```bash
git checkout -- docs/plantmind/audit/F04_01_REPO_FORENSIC_BASELINE.md
```

---

# 12. Backlog Priorizado

| Prioridad | Fase | Tarea                 | Impacto        | Riesgo | Dependencia | Agente       | Estado esperado |
| --------- | ---: | --------------------- | -------------- | ------ | ----------- | ------------ | --------------- |
| Crítico   |    1 | Baseline forense      | Control        | Bajo   | Ninguna     | Auditor      | doc             |
| Crítico   |    2 | Git hygiene           | Cierre limpio  | Medio  | F1          | Integración  | inventario      |
| Crítico   |    3 | Full validation local | Calidad        | Medio  | F2          | QA           | baseline        |
| Crítico   |    4 | Fix gates             | Estabilidad    | Alto   | F3          | QA/área      | gates verdes    |
| Crítico   |   10 | Privacy persistence   | Seguridad      | Alto   | F4          | Datos/Seg    | tests verdes    |
| Crítico   |   11 | OpenAPI contracts     | Integración    | Alto   | F4          | Backend      | sync            |
| Crítico   |   12 | No mock prod          | Premium        | Alto   | F4          | Seguridad    | enforced        |
| Crítico   |   17 | Security gate         | Producción     | Alto   | F12         | Seguridad    | pass            |
| Crítico   |   21 | Testing closure       | Producción     | Medio  | F19         | QA           | coverage        |
| Crítico   |   24 | Local RC              | Cierre local   | Alto   | Todas       | Coordinador  | complete        |
| Crítico   |   25 | Remote merge          | Cierre remoto  | Alto   | Billing     | Integración  | done            |
| Alto      |    5 | Duplicados            | Mantenibilidad | Medio  | F4          | Auditor      | plan            |
| Alto      |    6 | Dependencies          | Seguridad      | Medio  | F4          | Seguridad    | audit           |
| Alto      |    7 | Layers                | Arquitectura   | Medio  | F4          | Arquitectura | clean           |
| Alto      |    9 | Data org              | Dominio        | Alto   | F8          | Datos        | normalized      |
| Alto      |   13 | Provider real         | IA             | Alto   | F12         | IA           | ready           |
| Alto      |   15 | Traceability          | Auditoría      | Bajo   | F1          | Docs         | template        |
| Alto      |   19 | UI premium            | Producto       | Medio  | F11         | Frontend     | polished        |
| Alto      |   23 | Deploy readiness      | Producción     | Alto   | F21         | Deploy       | runbook         |
| Medio     |    8 | DDD docs              | Mantenibilidad | Bajo   | F5          | Dominio      | doc             |
| Medio     |   14 | Prompts               | IA             | Medio  | F13         | IA           | registry        |
| Medio     |   16 | Logging               | Observabilidad | Medio  | F15         | Seguridad    | sanitized       |
| Medio     |   18 | Performance           | UX             | Medio  | F11         | Perf         | baseline        |
| Medio     |   20 | A11y                  | UX             | Bajo   | F19         | Frontend     | pass            |
| Medio     |   22 | Docs sync             | DX             | Bajo   | Todas       | Docs         | synced          |

---

# 13. Riesgos de Producción

| Riesgo              | Causa                        | Evidencia             | Impacto en Producción | Mitigación                             | Fase  | Gate         |
| ------------------- | ---------------------------- | --------------------- | --------------------- | -------------------------------------- | ----: | ------------ |
| PR abierto          | CI remoto/billing            | PR #6 no merged.      | no release remoto     | remote gate pendiente                  |    25 | CI           |
| Mock prod           | provider mock usado en tests | CI env mock.          | app no premium        | fail-fast prod                         |    12 | tests        |
| Contrato drift      | OpenAPI manual               | PR sync.              | frontend/admin rotos  | check_openapi                          |    11 | contract     |
| Seguridad histórica | gitleaks baseline            | PR security note.     | riesgo reputacional   | baseline estrecho + rotación si aplica |    17 | gitleaks     |
| Raw image           | IA con fotos                 | PRD prohíbe raw.      | privacidad            | sanitization tests                     |    10 | privacy      |
| Advice inseguro     | IA generativa                | PRD safety.           | daño usuario/legal    | safety/citation                        |    17 | adversarial  |
| DB dual             | SQLite/Postgres              | CI Postgres.          | fallos prod/test      | fixtures dual                          | 10/21 | postgres     |
| Duplicados legacy   | skeleton histórico           | search skeleton.      | confusión             | cuarentena                             |     5 | rg refs      |
| UI sin coverage     | gap PRD                      | PRD gap #5.           | regresión             | widget tests                           |    21 | Flutter      |
| Worktrees olvidados | multiagente                  | no verificable remoto | deuda local           | cleanup gate                           |    25 | git worktree |

---

# 14. Checklist Final Global

## Resumen Ejecutivo

El repositorio es full-stack real: Flutter + FastAPI + Next Admin. La estrategia correcta es **autopiloto local con gate remoto pendiente**, porque el bloqueo actual reportado de GitHub Actions es externo/billing y no debe frenar el roadmap local. El cierre remoto queda prohibido hasta que CI ejecute y pase.

## Diagnóstico Forense

* PR #6 abierto, mergeable, no merged.
* Head actual: `080593f1...`.
* Gateway/Admin/Frontend tienen workflows definidos.
* OpenAPI es autoridad contractual.
* Seguridad ya usa Bandit/pip-audit/gitleaks/npm audit.
* Hay riesgo mock/productivo y legacy duplication.
* Hay gaps explícitos en PRD: plant-to-space relation, grow-here grounding, identification grounding, backup restore, widget coverage.

## Arquitectura Actual

```text
Flutter frontend
→ AI service layer
→ FastAPI gateway
→ provider/rules/safety
→ Drift + gateway ops stores
→ Admin Web
→ GitHub Actions
```

## Arquitectura Objetivo

```text
Flutter premium UX
→ typed services
→ OpenAPI contracts
→ FastAPI production gateway
→ real provider / no mock prod
→ safety + citation guard
→ sanitized persistence
→ admin usage/cost/billing
→ full CI + deploy + rollback
```

## Técnica de Producción Recomendada

Auditoría forense + roadmap por gates + multiagente quirúrgico + una rama de integración + worktrees temporales sólo cuando reduzcan conflicto.

## Roadmap por Fases

25 fases: auditoría, Git hygiene, build, fixes, limpieza, deps, capas, DDD, datos, persistencia, contratos, mocks, IA, prompts, trazabilidad, logging, seguridad, rendimiento, UI, accesibilidad, testing, docs, deploy, RC local, cierre remoto.

## Primera Fase Recomendada

Fase 1: `F04_01_REPO_FORENSIC_BASELINE.md`.

## Primera Instrucción para IA Local

Usar la instrucción `F01-T01` incluida arriba.

## Riesgos Principales

* PR remoto abierto.
* Billing bloquea CI.
* Mock en producción.
* Contrato OpenAPI drift.
* Seguridad histórica.
* Raw image persistence.
* Safety insuficiente.
* Duplicados legacy.
* Worktrees locales no verificables.

## Verificaciones Obligatorias

```bash
cd ai-gateway
python scripts/check_openapi.py
python -m pytest -q
python -m bandit -q -r app
pip-audit --skip-editable --ignore-vuln CVE-2026-3219

cd ../admin-web
npm ci
npm audit --audit-level=high
npm run lint
npm run build
npm run test:e2e

cd ../frontend
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=ENV=prod

cd ..
gitleaks git --redact
git status --short
git worktree list
```

## Criterio de App Premium Production-Ready

La app sólo está production-ready si:

* build pasa;
* lint pasa;
* typecheck pasa;
* tests críticos pasan;
* no mocks prod;
* no secretos;
* safety/citation activo;
* raw image no persistido;
* OpenAPI sync;
* admin build/e2e;
* Flutter release build;
* rollback documentado;
* PRs/worktrees/ramas limpios.

## Criterio de Cierre Git/Merge/Limpieza

Antes de cerrar:

* PR #6 mergeado o cerrado con justificación;
* rama integración mergeada;
* ramas temporales eliminadas;
* worktrees eliminados;
* carpetas temporales eliminadas o justificadas;
* legacy auditado;
* CI remoto verde cuando billing permita ejecución.

---

# 15. Criterio de App Premium Production-Ready

```text
LOCAL PREMIUM READY:
- F1-F24 completas.
- Full validation local verde.
- No mock productivo.
- Security gates verdes.
- Rollback actualizado.
- Audit docs completos.

REMOTE PREMIUM READY:
- Billing GitHub Actions resuelto.
- PR #6 verde y mergeado.
- PR final F04 verde y mergeado.
- Sin ramas/worktrees/PRs huérfanos.
```

---

# 16. Criterio de Cierre Git/Merge/Limpieza

## Formato final obligatorio

```text
CIERRE FINAL DE PRODUCCIÓN

RAMA FINAL:
COMMIT FINAL SI EXISTE:
PR FINAL SI EXISTE:
RAMAS TEMPORALES RESTANTES:
JUSTIFICACIÓN:
WORKTREES RESTANTES:
JUSTIFICACIÓN:
DIRECTORIOS TEMPORALES RESTANTES:
JUSTIFICACIÓN:
ARCHIVOS OBSOLETOS RESTANTES:
JUSTIFICACIÓN:
BUILD:
LINT:
TYPECHECK:
TESTS:
RIESGOS ABIERTOS:
RECOMENDACIÓN FINAL:
```

## Estado actual recomendado

```text
CIERRE FINAL DE PRODUCCIÓN

RAMA FINAL: no aplicable todavía
COMMIT FINAL SI EXISTE: no aplicable todavía
PR FINAL SI EXISTE: PR #6 abierto como bloque base
RAMAS TEMPORALES RESTANTES: no puedo verificar localmente
JUSTIFICACIÓN: falta ejecución local de git branch/worktree
WORKTREES RESTANTES: no puedo verificar localmente
JUSTIFICACIÓN: GitHub no expone worktrees locales
DIRECTORIOS TEMPORALES RESTANTES: no puedo verificar sin scan local
JUSTIFICACIÓN: requiere find/rg local
ARCHIVOS OBSOLETOS RESTANTES: plantmind_ai_package pendiente de auditoría
JUSTIFICACIÓN: contiene skeleton/prompts históricos
BUILD: local F03A-10 reportado verde; remoto bloqueado
LINT: local reportado verde para gateway; pendiente full-stack F04
TYPECHECK: pendiente full-stack F04
TESTS: gateway local reportado 103 passed; full-stack pendiente
RIESGOS ABIERTOS: CI billing, PR #6 abierto, no-mock prod, legacy duplication
RECOMENDACIÓN FINAL: continuar autopiloto local F1-F24; no cerrar remoto hasta billing + CI verde
```
