# 03 — DDC: Development / Delivery Contract

## 1. Objetivo

Definir las reglas de entrega para implementar MindFlow Core + EcoShop Domain sin romper GoLife AI existente.

## 2. Principios de entrega

1. No crear app separada.
2. No eliminar rutas actuales.
3. No romper `DashboardScreen`, `CaptureScreen`, `GoLifeController`, `LocalStore`, `AiGatewayClient`.
4. Introducir cambios por feature flags.
5. Mantener fallback local.
6. Mantener privacidad antes de IA.
7. Mantener confirmación humana.
8. No claims de precio/sostenibilidad sin evidencia.

## 3. Branch strategy

```text
feature/golife-mindflow-core-v1
```

Sub-branches opcionales:

```text
feature/mindflow-contracts
feature/mindflow-mobile-ui
feature/mindflow-ai-gateway
feature/ecoshop-domain
feature/admin-mindflow-ops
```

Merge interno por fases, una PR final si se requiere control.

## 4. Definition of Ready

Antes de codificar:

- PRD aprobado.
- DDD aprobado.
- Contratos base aprobados.
- Feature flags definidos.
- Migración SQLite revisada.
- No claims comerciales no verificados.
- Test plan aceptado.

## 5. Definition of Done

Una fase está cerrada cuando:

- compila
- lint pasa
- tests pasan
- fallback local probado
- privacidad probada
- screenshots/manual QA realizados
- admin no muestra datos sensibles
- release readiness actualizado

## 6. Entregables por fase

### Fase 0 — Contratos

Archivos:

```text
services/ai_gateway/app/schemas.py
apps/mobile_flutter/lib/core/ai_client/dto/
apps/mobile_flutter/lib/domains/mindflow/
apps/mobile_flutter/lib/domains/shopping/
```

Cierre:

- contratos Pydantic
- DTOs Dart
- tests de serialización
- sin integración UI obligatoria

### Fase 1 — Storage

Archivos:

```text
apps/mobile_flutter/lib/core/storage/local_store.dart
apps/mobile_flutter/lib/core/storage/sqlite_local_store.dart
apps/mobile_flutter/lib/core/storage/memory_local_store.dart
apps/mobile_flutter/lib/core/storage/resilient_local_store.dart
```

Cierre:

- `_databaseVersion = 5`
- tablas nuevas
- load/save/upsert/delete
- datos sensibles cifrados
- migración idempotente

### Fase 2 — Controller

Archivo:

```text
apps/mobile_flutter/lib/features/app_state/golife_controller.dart
```

Cierre:

- getters nuevos
- bootstrap nuevo
- captureDrafts crea mental load
- refreshDecisionPlan
- shopping needs derivados
- no bloqueo de app si gateway falla

### Fase 3 — UI

Archivos:

```text
dashboard_screen.dart
capture_screen.dart
domain_screens.dart
homememory_screen.dart
app_router.dart
```

Nuevas pantallas:

```text
features/decisions/decision_screen.dart
features/shopping/shopping_screen.dart
```

Cierre:

- Today Command Center
- Capture Inbox v2
- Decision Queue
- Shopping Intelligence
- HomeMemory integrado

### Fase 4 — AI Gateway

Archivos:

```text
services/ai_gateway/app/main.py
services/ai_gateway/app/schemas.py
services/ai_gateway/app/use_cases.py
services/ai_gateway/app/graphs/mindflow_graph.py
services/ai_gateway/app/graphs/shopping_graph.py
services/ai_gateway/app/guardrails.py
```

Cierre:

- endpoints nuevos
- prompts nuevos
- LangGraph nuevo
- guardrail no-claim
- tests

### Fase 5 — Admin/Ops

Archivos:

```text
services/web_backend/app/main.py
services/web_backend/app/schemas.py
services/web_backend/app/repository.py
apps/admin_next/lib/types.ts
apps/admin_next/lib/api.ts
```

Cierre:

- métricas nuevas
- feature flags
- evidence quality
- privacy filtered decision rate
- admin UI sin contenido personal crudo

## 7. Bloqueadores obligatorios

No avanzar a release si:

- una decisión no exige confirmación
- un dato `local_only` llega al payload IA
- EcoShop muestra claim sin fuente
- fallback local no funciona
- migración SQLite borra datos
- admin expone contenido personal crudo
- tests de guardrails fallan

## 8. Política de mocks

Mocks permitidos solo si:

- están marcados visualmente
- no activan `production_ready`
- no alimentan claims de release
- no se mezclan con datos reales

## 9. Políticas de naming

Usar nombres explícitos:

```text
MindFlowCore
MentalLoadItem
DecisionCard
ShoppingNeed
ProductEvidenceCard
PrivacyEvidenceSummary
```

Evitar nombres ambiguos:

```text
SmartAI
MagicDecision
AutoBuy
BestProduct
```

## 10. Checklist de PR

- [ ] ¿No rompe rutas actuales?
- [ ] ¿No elimina entidades existentes?
- [ ] ¿No envía datos bloqueados a IA?
- [ ] ¿Tiene tests?
- [ ] ¿Tiene fallback?
- [ ] ¿Tiene i18n?
- [ ] ¿Actualiza docs?
- [ ] ¿Actualiza feature flags?
- [ ] ¿Actualiza admin/ops si aplica?
- [ ] ¿No introduce claims comerciales no verificados?
