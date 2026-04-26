# Web Management Premium Runbook

Date: 2026-04-26

## Phase 0 Source of Truth

### PDR_PREESCRITO

Producto: Gestion web premium de GoLife AI.
Usuario: operador interno/admin de plataforma.
Objetivo: operar miles de usuarios, consumo IA, costes, privacidad, soporte, seguridad, OpenRouter, xInsightAI, HomeMemory agregada.
No objetivo: crear otra app, copiar template externo, crear `/control`, `/admin`, `/studio`.

### DDD_PREESCRITO

Dominio: Web Management.
Agregados:
- UserOps
- OrganizationOps
- AiUsageOps
- BillingOps
- StorageOps
- PrivacyOps
- SecurityOps
- SupportOps
- HomeMemoryAggregateOps

Reglas:
- Admin ve metadata, no contenido intimo.
- Secrets nunca salen del servidor.
- BYOK no debita creditos xInsightAI.
- xInsightAI si se cobra por tokens/creditos.
- Storage se cobra separado.

### DDC_PREESCRITO

Entradas:
- datos actuales de web_backend
- fallback-data actual
- telemetry de ai_gateway
- OpenRouter key events
- usage events

Salidas:
- paginas admin existentes mejoradas
- nuevas paginas permitidas
- contratos paginados/filtrables
- documentacion

Restricciones:
- sin raw journal/reflection/proof text
- sin secrets
- i18n preservado

### DDR_PREESCRITO

Decision de entrega:
- Crear rama separada.
- No tocar rutas prohibidas.
- Implementar por fases con commits pequenos.
- Validar admin/backend/gateway/mobile cuando aplique.
- Dejar CI verde antes de PR.

## Initial Git State

- repo root: `C:\0 Work\GoLife AI`
- current branch after phase-0 setup: `codex/premium-web-management`
- source base: `main` at `35bbe53`
- working tree at setup: clean
- `PR #3` HomeMemory status at setup: `open`, `draft`, `mergeable`, `not merged`
- consequence: premium web management must not assume HomeMemory is in `main`; only aggregate-safe compatibility is allowed until that PR merges

## Forbidden Routes

- `/control`
- `/admin`
- `/studio`

Do not create:
- `apps/admin_next/app/control`
- `apps/admin_next/app/admin`
- `apps/admin_next/app/studio`

## Allowed Existing Routes To Maintain/Improve

- `/dashboard`
- `/users`
- `/usage`
- `/ai-costs`
- `/openrouter-keys`
- `/missions`
- `/feedback`
- `/safety`
- `/routing-snapshots`
- `/feature-flags`
- `/settings/models`
- `/routing-profiles`
- `/model-catalog`
- `/support/export-delete`

## Allowed New Routes

- `/organizations`
- `/plans`
- `/billing`
- `/storage`
- `/privacy`
- `/security`
- `/audit`
- `/openrouter-byok`
- `/xinsightai`
- `/homememory`
- `/quality`
- `/incidents`
- `/login`
- `/logout`

## Delivery Constraints

- no raw private telemetry in admin surfaces
- no secrets in client bundles
- no personal HomeMemory content in management web
- use existing `apps/admin_next`, `services/web_backend`, and `services/ai_gateway`
- preserve current i18n structure
