# 12 — Roadmap Checklist Enciclopédico

## Fase 0 — Preparación

### Producto

- [x] Aprobar PRD.
- [x] Aprobar DDD.
- [x] Aprobar ADRs.
- [x] Confirmar que no se creará app separada.
- [x] Definir pricing Free/Plus/Pro.
- [x] Definir mensajes de marketing sin claims exagerados.

### Código

- [x] Crear branch.
- [x] Ejecutar tests base.
- [x] Registrar baseline.
- [x] Identificar archivos tocados.
- [x] Revisar deuda técnica en Controller.
- [x] Revisar localizations.

### Riesgo

- [x] Evaluar privacidad.
- [x] Evaluar claims EcoShop.
- [x] Evaluar migración SQLite.
- [x] Evaluar fallback offline.

## Fase 1 — Contratos

### AI Gateway

- [x] Extender `Domain`.
- [x] Crear `MentalLoadItem`.
- [x] Crear `DecisionCard`.
- [x] Crear `ShoppingNeed`.
- [x] Crear `ProductEvidenceCard`.
- [x] Crear `PrivacySummary`.
- [x] Crear `ActionContract`.
- [x] Crear request/response schemas.

### Flutter

- [x] Crear DTOs.
- [x] Crear modelos locales.
- [x] Crear mappers.
- [x] Crear tests de serialización.

### Admin

- [x] Añadir types TS.
- [x] Añadir métricas nuevas.
- [x] Añadir feature flags.

## Fase 2 — Storage

- [x] Subir SQLite a v5.
- [x] Crear tabla `mental_load_items`.
- [x] Crear tabla `decision_cards`.
- [x] Crear tabla `shopping_needs`.
- [x] Crear tabla `product_evidence_cards`.
- [x] Crear índices.
- [x] Implementar load/save/upsert.
- [x] Implementar MemoryLocalStore.
- [x] Implementar ResilientLocalStore.
- [x] Test migración limpia.
- [x] Test migración con datos v4.
- [x] Test deleteAllData.
- [x] Test cifrado sensible.

## Fase 3 — Controller

- [x] Agregar estados nuevos.
- [x] Agregar getters.
- [x] Cargar nuevos modelos en bootstrap.
- [x] Extender `captureDrafts`.
- [x] Crear `refreshDecisionPlan`.
- [x] Crear `refreshShoppingPlan`.
- [x] Crear métodos accept/complete/postpone/reject.
- [x] Crear derivación local de ShoppingNeed.
- [x] Crear fallback local DecisionCard.
- [x] Crear fallback local ShoppingPlan.
- [x] Actualizar `gatewayStatusLabel`.
- [x] Actualizar trace.

## Fase 4 — Capture Inbox v2

- [x] Renombrar visualmente pantalla.
- [x] Agregar item type.
- [x] Agregar suggested action.
- [x] Agregar bulk privacy actions.
- [x] Mostrar confidence.
- [x] Mostrar rationale.
- [x] Confirmar múltiple draft.
- [x] Guardar LifeEvent.
- [x] Guardar MentalLoadItem.
- [x] Crear ShoppingNeed si aplica.
- [x] Crear ReminderCandidate si aplica.

## Fase 5 — Today Command Center

- [x] Agregar Mental Load Summary.
- [x] Mostrar DecisionCard principal.
- [x] Mostrar decisiones secundarias.
- [x] Mantener DailyMission fallback.
- [x] Agregar Postpone.
- [x] Agregar Create Reminder.
- [x] Agregar Shopping alert.
- [x] Extender Explain Sheet.
- [x] Mostrar data used/blocked.
- [x] Mostrar local-only collections.
- [x] Mostrar evidence status.

## Fase 6 — Decisions Screen

- [x] Crear ruta `/decisions`.
- [x] Crear tabs.
- [x] Crear DecisionCard widget.
- [x] Filtrar por estado.
- [x] Acciones accept/done/postpone/reject.
- [x] Explanation modal.
- [x] Empty states.
- [x] Offline fallback state.

## Fase 7 — Shopping Screen

- [x] Crear ruta `/shopping`.
- [x] Crear tabs.
- [x] Reutilizar Pantry.
- [x] Reutilizar Closet.
- [x] Reutilizar Recipes.
- [x] Crear ShoppingNeed list.
- [x] Crear ProductEvidence section.
- [x] Crear Sustainability section.
- [x] Mostrar insufficient verified data.
- [x] Bloquear external sources si flag false.

## Fase 8 — HomeMemory Integration

- [x] Agregar generated decisions.
- [x] Warranty ending soon → MentalLoadItem.
- [x] Maintenance due → MentalLoadItem.
- [x] Claim candidate → MentalLoadItem.
- [x] PurchaseProof → Shopping/Product evidence.
- [x] Tests.

## Fase 9 — AI Gateway MindFlow

- [x] Crear endpoint parse.
- [x] Crear endpoint decisions.
- [x] Crear graph.
- [x] Crear prompts.
- [x] Crear guardrails.
- [x] Crear fallback.
- [x] Tests privacy.
- [x] Tests confirmation.
- [x] Tests no unsafe output.

## Fase 10 — AI Gateway Shopping

- [x] Crear endpoint shopping needs.
- [x] Crear endpoint optimize list.
- [x] Crear endpoint product evidence.
- [x] Crear graph.
- [x] Crear no-claim guardrail.
- [x] Tests insufficient sustainability.
- [x] Tests no best price.
- [x] Tests no availability claim.

## Fase 11 — Admin / Ops

- [x] Backend schemas.
- [x] Repository methods.
- [x] Admin endpoints.
- [x] Admin types.
- [x] Admin pages.
- [x] Feature flags.
- [x] Metrics.
- [x] Quality breakdown.
- [x] Incident rules.

## Fase 12 — i18n

- [x] Inglés.
- [x] Español.
- [x] Portugués PT.
- [x] Portugués BR.
- [x] Japonés.
- [x] Chino simplificado.
- [x] Chino tradicional.
- [x] Francés.
- [x] Italiano.
- [x] Alemán.
- [x] Test fallback English.

## Fase 13 — QA

- [x] Offline first launch.
- [x] Gateway down.
- [x] All privacy local-only.
- [x] Mixed privacy.
- [x] Capture multi-item.
- [x] Decision accept.
- [x] Decision postpone.
- [x] Shopping no evidence.
- [x] HomeMemory warranty.
- [x] Delete all data.
- [x] Export data.
- [x] Admin no sensitive raw text.

## Fase 14 — Release readiness

- [x] All tests pass.
- [x] No unverified claims.
- [x] No privacy leak.
- [x] No external action without confirmation.
- [x] Mocks visible.
- [x] Feature flags set.
- [x] Rollback plan.
- [x] Documentation updated.
