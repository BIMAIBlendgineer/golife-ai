# GoLife AI — MindFlow Core + EcoShop Domain Implementation Pack

Fecha: 2026-05-09  
Estado: paquete de implementación funcional, no evidencia de código ejecutado.

## Objetivo

Este pack define cómo transformar GoLife AI desde un sistema local-first de misiones diarias hacia:

```text
GoLife AI
= MindFlow Core
+ EcoShop Domain
+ HomeMemory
+ Privacy-before-AI
+ Evidence-based decisions
```

## Contenido

| Archivo | Propósito |
|---|---|
| `00_SOURCE_BASIS.md` | Base verificada del repositorio inspeccionado. |
| `01_PRD.md` | Product Requirements Document. |
| `02_DDD.md` | Domain-Driven Design. |
| `03_DDC.md` | Development/Delivery Contract. |
| `04_ADR_INDEX.md` | Índice de decisiones arquitectónicas. |
| `adr/ADR-001-mindflow-core.md` | MindFlow como núcleo, no app separada. |
| `adr/ADR-002-ecoshop-domain.md` | EcoShop como dominio interno. |
| `adr/ADR-003-privacy-before-ai.md` | Privacidad antes de IA. |
| `adr/ADR-004-evidence-cards.md` | Evidence Cards para decisiones y compras. |
| `adr/ADR-005-local-first-storage.md` | SQLite local-first + cifrado sensible. |
| `05_SPEC_TECHNICAL.md` | Especificación técnica end-to-end. |
| `06_UI_UX_SPEC.md` | Cambios de UI/UX por pantalla. |
| `07_CONTRACTS.md` | Contratos funcionales en español. |
| `contracts/mindflow_contracts.py` | Pydantic base para AI Gateway. |
| `contracts/mindflow_dto.dart` | DTOs Flutter base. |
| `contracts/sqlite_migration_v5.sql` | Migración SQLite propuesta. |
| `contracts/openapi_paths.yaml` | Endpoints propuestos. |
| `08_AI_GATEWAY_SPEC.md` | Cambios en AI Gateway, LangGraph y prompts. |
| `09_MOBILE_FLUTTER_SPEC.md` | Cambios en Flutter app. |
| `10_ADMIN_OPS_SPEC.md` | Cambios en admin/backend/ops. |
| `11_PRIVACY_SAFETY_EVIDENCE.md` | Privacidad, seguridad, claims y evidencia. |
| `12_ROADMAP_CHECKLIST.md` | Checklist enciclopédico tipo roadmap. |
| `13_TEST_PLAN.md` | Plan de pruebas. |
| `14_RELEASE_READINESS.md` | Criterios de release y bloqueo. |
| `15_IMPLEMENTATION_PROMPT.md` | Prompt maestro para IA local o equipo. |
| `16_BACKLOG_EPICS.md` | Épicas, historias y tareas. |
| `17_DATA_MODEL_MAP.md` | Mapa de datos actual → nuevo. |
| `18_RISK_REGISTER.md` | Registro de riesgos. |
| `19_ACCEPTANCE_CRITERIA.md` | Criterios de aceptación. |
| `20_ROLLOUT_PLAN.md` | Plan de despliegue progresivo. |

## Cómo usar

1. Leer `00_SOURCE_BASIS.md`.
2. Aprobar o editar `01_PRD.md`.
3. Usar `02_DDD.md` y `07_CONTRACTS.md` como autoridad funcional.
4. Implementar siguiendo `12_ROADMAP_CHECKLIST.md`.
5. Validar con `13_TEST_PLAN.md`.
6. No promover release si falla `14_RELEASE_READINESS.md`.

## Regla central

No implementar EcoShop como app separada todavía. Implementar:

```text
GoLife AI → MindFlow Core
GoLife AI → EcoShop Domain
```
