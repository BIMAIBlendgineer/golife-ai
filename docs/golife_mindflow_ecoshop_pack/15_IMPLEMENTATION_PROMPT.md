# 15 — Prompt maestro para IA local / equipo de desarrollo

Actúa como arquitecto full-stack senior, Flutter developer, FastAPI developer y QA lead.

Tienes acceso al repositorio `golife-ai`. Implementa `GoLife AI → MindFlow Core + EcoShop Domain` siguiendo este paquete.

## Reglas obligatorias

1. No crear app separada.
2. No eliminar rutas existentes.
3. Mantener local-first.
4. Mantener fallback local.
5. Todo dato enviado a IA debe pasar por privacidad.
6. Toda decisión requiere confirmación.
7. EcoShop no puede afirmar mejor precio, disponibilidad o sostenibilidad sin fuente.
8. Usar feature flags.
9. Agregar tests.
10. No exponer datos personales crudos en admin.

## Fases

### Fase 0 — Baseline

- Ejecuta tests existentes.
- Documenta estado.
- No cambies producto.

### Fase 1 — Contratos

- Extiende AI Gateway schemas.
- Crea modelos Dart.
- Crea DTOs.
- Tests de serialización.

### Fase 2 — Storage

- SQLite v5.
- Nuevas tablas.
- LocalStore methods.
- MemoryStore methods.
- Tests de migración.

### Fase 3 — Controller

- Estados nuevos.
- Bootstrap.
- Capture → MentalLoad.
- Decision plan.
- Shopping plan.
- Fallback.

### Fase 4 — UI

- Today Command Center.
- Capture Inbox v2.
- Decisions Screen.
- Shopping Screen.
- HomeMemory integration.

### Fase 5 — AI Gateway

- Endpoints MindFlow.
- Endpoints Shopping.
- LangGraph.
- Guardrails.
- Tests.

### Fase 6 — Admin

- Métricas.
- Feature flags.
- Evidence quality.
- Safety/privacy.

### Fase 7 — Validation

- Unit tests.
- Integration tests.
- Manual QA.
- Release readiness.

## Criterio de cierre

El trabajo solo termina cuando:

```text
- tests pasan
- privacidad validada
- no-claim guardrails pasan
- fallback validado
- UI funcional
- docs actualizadas
```

Si encuentras bloqueador serio, detente y reporta con:

```text
BLOCKER:
file:
reason:
risk:
recommended fix:
```
