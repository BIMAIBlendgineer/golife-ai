\# ADDENDUM UI/UX — CROQUIS DE PANTALLAS PARA GESTIÓN WEB PREMIUM



Este addendum complementa el pack anterior.



REGLA:

No crear /control, /admin ni /studio.

Implementar sobre la gestión web actual de GoLife AI.



Objetivo UI:

Crear una gestión web premium para miles de usuarios, con estética SaaS enterprise, usando nuestro admin actual.



Rutas principales:

\- /dashboard

\- /users

\- /organizations

\- /plans

\- /usage

\- /ai-costs

\- /openrouter-keys

\- /openrouter-byok

\- /xinsightai

\- /billing

\- /storage

\- /privacy

\- /security

\- /audit

\- /homememory

\- /quality

\- /incidents

\- /missions

\- /feedback

\- /safety

\- /feature-flags

\- /settings/models

\- /routing-profiles

\- /model-catalog

\- /support/export-delete

\- /login

\- /logout



============================================================

UI FOUNDATION — LAYOUT GLOBAL

============================================================



Todas las pantallas deben compartir esta estructura:



┌────────────────────────────────────────────────────────────────────┐

│ Topbar                                                             │

│ \[GoLife Admin] \[Search / Command] \[Env] \[Live/Fallback] \[Lang] \[Me]│

├───────────────┬────────────────────────────────────────────────────┤

│ Sidebar       │ Page Header                                        │

│               │ Title + Subtitle + Primary action + Last updated   │

│ Operate       ├────────────────────────────────────────────────────┤

│ - Dashboard   │ KPI cards                                          │

│ - Users       │ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │

│ - Usage       │ │ KPI 1  │ │ KPI 2  │ │ KPI 3  │ │ KPI 4  │        │

│ - Costs       │ └────────┘ └────────┘ └────────┘ └────────┘        │

│               ├────────────────────────────────────────────────────┤

│ AI            │ Main panel / table / charts                        │

│ - OpenRouter  │                                                    │

│ - BYOK        │                                                    │

│ - xInsightAI  │                                                    │

│               ├────────────────────────────────────────────────────┤

│ Trust         │ Secondary panels / detail drawer / audit timeline  │

│ - Privacy     │                                                    │

│ - Security    │                                                    │

│ - Audit       │                                                    │

└───────────────┴────────────────────────────────────────────────────┘



Global UX rules:

\- Sidebar persistente.

\- Topbar con search/command palette.

\- Cada página debe tener:

&#x20; - eyebrow

&#x20; - title

&#x20; - subtitle

&#x20; - primary action

&#x20; - data source badge

&#x20; - last updated

&#x20; - empty state

&#x20; - error state

&#x20; - loading state

&#x20; - privacy/sensitive-data note si aplica

\- Todas las tablas deben tener:

&#x20; - filtros

&#x20; - búsqueda

&#x20; - paginación

&#x20; - ordenamiento si simple

&#x20; - estado vacío

&#x20; - drawer de detalle cuando aplique

\- No mostrar secrets.

\- No mostrar raw sensitive data.

\- Mantener i18n.



============================================================

PANTALLA 1 — /dashboard

============================================================



PDR:

Dashboard debe ser el “estado general” de GoLife AI: usuarios, misiones, consumo IA, coste, privacidad, safety, soporte.



DDD:

Dominio: ExecutiveOps ligero.

Métricas:

\- active users

\- useful missions/user/week

\- AI cost/user

\- safety intervention rate

\- support queue

\- OpenRouter health

\- xInsightAI credits used

\- BYOK users



DDC:

Inputs:

\- dashboard metrics

\- usage

\- ai-costs

\- safety

\- support

\- feature flags



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Dashboard                                                    │

│ Operational pulse for GoLife AI                             │

│ \[LIVE DATA] \[Last ingestion: ...] \[Refresh]                  │

├──────────────────────────────────────────────────────────────┤

│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │

│ │ Active users│ │ Useful/week │ │ AI cost/user│ │ Safety % │ │

│ └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │

├────────────────────────────┬─────────────────────────────────┤

│ What to watch today        │ AI \& cost pressure              │

│ - Mission quality          │ chart: cost by endpoint         │

│ - Trust queue              │ chart: fallback rate            │

│ - Key health               │                                 │

├────────────────────────────┴─────────────────────────────────┤

│ Feature flags / rollout board                                │

│ \[semantic\_classifier] \[proof\_parser] \[homememory] \[...]      │

└──────────────────────────────────────────────────────────────┘



UX:

\- Dashboard no debe ser tabla pesada.

\- Debe responder: “¿está sano el producto hoy?”

\- Usar badges claros: GOOD / WARN / RISK.



============================================================

PANTALLA 2 — /users

============================================================



PDR:

Gestión premium de miles de usuarios.



DDD:

Entidad central:

\- AdminUserRow

\- UserDetailSummary

\- UserSupportState

\- UserPrivacyState



DDC:

Table rows:

\- user\_id

\- display\_name

\- email\_masked

\- plan

\- status

\- locale

\- last\_seen

\- ai\_calls

\- useful\_missions

\- fallback\_rate

\- support\_flags



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Users                                                        │

│ Account state, product usage and support signals             │

│ \[Search users...] \[Plan ▼] \[Status ▼] \[Locale ▼] \[Export]    │

├──────────────────────────────────────────────────────────────┤

│ ┌────────┐ ┌─────────┐ ┌─────────────┐ ┌──────────────────┐ │

│ │ Total  │ │ Active  │ │ Support q.  │ │ Privacy requests │ │

│ └────────┘ └─────────┘ └─────────────┘ └──────────────────┘ │

├──────────────────────────────────────────────────────────────┤

│ User table                                                   │

│ ┌──────┬──────┬──────┬──────┬──────┬──────┬──────────────┐ │

│ │User  │Plan  │Status│Locale│AI use│Useful│Support flags │ │

│ ├──────┼──────┼──────┼──────┼──────┼──────┼──────────────┤ │

│ │ ...  │ ...  │ ...  │ ...  │ ...  │ ...  │ ...          │ │

│ └──────┴──────┴──────┴──────┴──────┴──────┴──────────────┘ │

│ \[pagination]                                                 │

└──────────────────────────────────────────────────────────────┘



Detail drawer:

┌──────────────────────────────┐

│ User detail                  │

│ Plan / Status / Locale       │

│ Usage summary                │

│ Mission history metadata     │

│ Privacy/support state        │

│ Sensitive content excluded   │

└──────────────────────────────┘



UX:

\- Drawer abre al hacer click en fila.

\- No navegar a otra página salvo que ya exista user detail.

\- Email siempre masked si no es necesario.



============================================================

PANTALLA 3 — /organizations

============================================================



PDR:

Agrupar usuarios por organización/familia/equipo.



DDD:

Entidades:

\- Organization

\- OrganizationMember

\- OrganizationUsageSummary



DDC:

OrganizationRow:

\- organization\_id

\- name

\- plan

\- status

\- user\_count

\- storage\_used\_gb

\- ai\_mode\_default

\- monthly\_ai\_spend

\- created\_at



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Organizations                                                │

│ Groups, teams, families and enterprise accounts              │

│ \[Search org...] \[Plan ▼] \[AI mode ▼] \[Create org]            │

├──────────────────────────────────────────────────────────────┤

│ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐ │

│ │ Orgs total │ │ Team/Ent   │ │ BYOK orgs  │ │ Storage GB │ │

│ └────────────┘ └────────────┘ └────────────┘ └────────────┘ │

├──────────────────────────────────────────────────────────────┤

│ Organization table                                           │

│ Name | Plan | Users | AI mode | Storage | Status | Created  │

└──────────────────────────────────────────────────────────────┘



Drawer:

\- organization profile

\- members count

\- plan

\- AI mode default

\- storage

\- support flags

\- safe audit timeline



UX:

\- Aquí no se gestionan datos privados de usuario.

\- Solo estado organizacional.



============================================================

PANTALLA 4 — /plans

============================================================



PDR:

Mostrar planes disponibles y límites comerciales.



DDD:

Entidades:

\- Plan

\- PlanLimit

\- PlanFeature



DDC:

Plan:

\- id

\- name

\- price\_label

\- users\_limit

\- storage\_limit\_gb

\- ai\_credits\_policy

\- byok\_allowed

\- support\_level



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Plans                                                        │

│ Commercial packaging and product limits                      │

│ \[Free] \[Pro] \[Family] \[Team] \[Enterprise]                    │

├──────────────────────────────────────────────────────────────┤

│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │

│ │ Free    │ │ Pro     │ │ Family  │ │ Team    │ │ Ent.    │ │

│ │ limits  │ │ limits  │ │ limits  │ │ limits  │ │ custom  │ │

│ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ │

├──────────────────────────────────────────────────────────────┤

│ Feature comparison table                                     │

│ Feature | Free | Pro | Family | Team | Enterprise            │

└──────────────────────────────────────────────────────────────┘



UX:

\- Si no hay billing real, marcar “commercial configuration, not payment processor”.

\- No fingir cobros.



============================================================

PANTALLA 5 — /usage

============================================================



PDR:

Ver throughput de uso, captura, misiones, latencia y fallback.



DDD:

Entidad:

\- UsageSnapshot



DDC:

Fields:

\- user\_id

\- capture\_events

\- missions\_generated

\- missions\_completed

\- fallback\_rate

\- average\_latency\_ms

\- last\_active\_at



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Usage                                                        │

│ Capture volume, AI calls, fallback and latency               │

│ \[Date range ▼] \[Endpoint ▼] \[Locale ▼] \[Export metadata]     │

├──────────────────────────────────────────────────────────────┤

│ KPIs: Capture events | Missions | Avg latency | Fallback %   │

├──────────────────────────────────────────────────────────────┤

│ Chart: usage over time                                       │

├──────────────────────────────────────────────────────────────┤

│ Table: user / endpoint / count / latency / fallback          │

└──────────────────────────────────────────────────────────────┘



UX:

\- Fallback alto debe aparecer como warning.

\- Latencia p95 si está disponible.



============================================================

PANTALLA 6 — /ai-costs

============================================================



PDR:

Control de margen y gasto IA.



DDD:

Entidades:

\- AICostSnapshot

\- ProviderCost

\- EndpointCost



DDC:

Fields:

\- endpoint

\- provider

\- model

\- requests

\- estimated\_cost\_usd

\- avg\_latency\_ms

\- fallback\_rate



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ AI Costs                                                     │

│ Provider cost, endpoint pressure and margin control          │

│ \[Date range ▼] \[Provider ▼] \[AI mode ▼]                      │

├──────────────────────────────────────────────────────────────┤

│ ┌───────────┐ ┌────────────┐ ┌────────────┐ ┌──────────────┐│

│ │ Total cost│ │ Cost/user  │ │ Fallback % │ │ Cost forecast││

│ └───────────┘ └────────────┘ └────────────┘ └──────────────┘│

├─────────────────────────────┬────────────────────────────────┤

│ Chart: cost by endpoint     │ Chart: cost by model           │

├─────────────────────────────┴────────────────────────────────┤

│ Cost table                                                    │

└──────────────────────────────────────────────────────────────┘



UX:

\- BYOK usage debe mostrarse separado como “external billing”.

\- xInsightAI usage debe aparecer como revenue/credit debit, no solo cost.



============================================================

PANTALLA 7 — /openrouter-keys

============================================================



PDR:

Gestión de claves globales de plataforma.



DDD:

Entidad:

\- PlatformOpenRouterKey

Reglas:

\- server-side only

\- encrypted

\- last4 only

\- audit on create/disable/rotate/test



DDC:

Fields:

\- key\_id

\- label

\- last4

\- priority

\- status

\- last\_ok\_at

\- last\_error\_at

\- consecutive\_failures



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ OpenRouter Platform Keys                                     │

│ Server-side routing keys used by xInsightAI/platform mode    │

│ \[Add key] \[Refresh health]                                   │

├──────────────────────────────────────────────────────────────┤

│ Active keys | Disabled keys | Recent failures | Last rotate  │

├──────────────────────────────────────────────────────────────┤

│ Key pool table                                                │

│ Label | Last4 | Priority | Status | Last ok | Failures | ... │

├──────────────────────────────────────────────────────────────┤

│ Rotation / event timeline                                    │

└──────────────────────────────────────────────────────────────┘



UX:

\- SecretInput only on create/rotate.

\- Never display secret after save.



============================================================

PANTALLA 8 — /openrouter-byok

============================================================



PDR:

Gestión de claves OpenRouter propias del usuario/organización.



DDD:

Entidad:

\- OpenRouterByokKey

Reglas:

\- BYOK no debita créditos xInsightAI.

\- OpenRouter factura al usuario.

\- GoLife cobra plataforma/storage.

\- key cifrada.

\- last4 only.



DDC:

Fields:

\- key\_id

\- organization\_id

\- project\_id nullable

\- owner\_user\_id

\- label

\- last4

\- status

\- scopes

\- last\_used\_at

\- disabled\_at



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ OpenRouter BYOK                                              │

│ User-owned OpenRouter keys. External AI billing.             │

│ \[Add BYOK key] \[Billing explanation]                         │

├──────────────────────────────────────────────────────────────┤

│ ┌─────────┐ ┌──────────┐ ┌────────────┐ ┌─────────────────┐ │

│ │ BYOK org│ │ Active   │ │ Disabled   │ │ External billing│ │

│ └─────────┘ └──────────┘ └────────────┘ └─────────────────┘ │

├──────────────────────────────────────────────────────────────┤

│ BYOK table                                                   │

│ Org | Label | Last4 | Status | Last used | Scope | Actions  │

├──────────────────────────────────────────────────────────────┤

│ Info box:                                                    │

│ “BYOK usage is billed by OpenRouter directly. GoLife charges │

│ platform/storage only.”                                      │

└──────────────────────────────────────────────────────────────┘



Actions:

\- test key

\- rotate key

\- disable key

\- view audit events



UX:

\- Muy claro visualmente que BYOK ≠ xInsightAI credits.



============================================================

PANTALLA 9 — /xinsightai

============================================================



PDR:

Administrar uso vendido por GoLife/xInsightAI.



DDD:

Entidades:

\- XInsightCreditLedger

\- AiUsageLedger

\- XInsightPlan

Reglas:

\- xInsightAI debita créditos.

\- plataforma asume/rutea proveedor.

\- se puede calcular margen.

\- storage separado.



DDC:

Fields:

\- organization\_id

\- credits\_balance

\- credits\_debited

\- endpoint

\- model

\- cost\_usd

\- customer\_charge\_usd

\- margin\_estimate

\- created\_at



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ xInsightAI                                                   │

│ AI credits, usage ledger, model cost and revenue visibility  │

│ \[Date range ▼] \[Plan ▼] \[Export ledger]                      │

├──────────────────────────────────────────────────────────────┤

│ Credits used | Revenue est. | Platform cost | Margin est.    │

├────────────────────────────┬─────────────────────────────────┤

│ Chart: credits over time   │ Chart: margin by endpoint       │

├────────────────────────────┴─────────────────────────────────┤

│ Ledger table                                                  │

│ Org | Endpoint | Model | Tokens | Credits | Cost | Charge    │

└──────────────────────────────────────────────────────────────┘



UX:

\- Marcar estimaciones si no hay billing real.

\- No mezclar BYOK en revenue de tokens.



============================================================

PANTALLA 10 — /billing

============================================================



PDR:

Mostrar estado comercial sin fingir pagos reales.



DDD:

Entidades:

\- BillingAccount

\- SubscriptionState

\- InvoicePlaceholder

\- QuotaUsage



DDC:

Fields:

\- organization\_id

\- plan

\- billing\_status

\- ai\_mode

\- storage\_charge\_estimate

\- ai\_charge\_estimate

\- byok\_external\_billing



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Billing                                                      │

│ Plan, subscription state, credit and storage visibility      │

│ \[Plan ▼] \[Status ▼] \[Export summary]                         │

├──────────────────────────────────────────────────────────────┤

│ Active plans | Pro/Team | BYOK accounts | Storage revenue    │

├──────────────────────────────────────────────────────────────┤

│ Billing table                                                │

│ Org | Plan | AI mode | Credits | Storage | Status | Notes    │

├──────────────────────────────────────────────────────────────┤

│ Notice: Payment processor not active / configured            │

└──────────────────────────────────────────────────────────────┘



UX:

\- Si no hay Stripe/etc., mostrar “billing model configured, payment processor not connected”.



============================================================

PANTALLA 11 — /storage

============================================================



PDR:

Controlar almacenamiento vendido/separado.



DDD:

Entidades:

\- StorageUsage

\- StoragePlan

\- RetentionPolicy



DDC:

Fields:

\- organization\_id

\- user\_id

\- total\_gb

\- billable\_gb

\- encrypted\_collections

\- retention\_risk



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Storage                                                      │

│ Storage usage, billable GB and retention                     │

│ \[Org ▼] \[Plan ▼] \[Retention ▼]                               │

├──────────────────────────────────────────────────────────────┤

│ Total GB | Billable GB | Encrypted collections | Retention   │

├────────────────────────────┬─────────────────────────────────┤

│ Chart: storage by plan     │ Chart: storage growth           │

├────────────────────────────┴─────────────────────────────────┤

│ Table: Org/User | Total | Billable | Sensitive | Retention   │

└──────────────────────────────────────────────────────────────┘



UX:

\- HomeMemory storage only as aggregate.

\- No fileRef/raw evidence.



============================================================

PANTALLA 12 — /privacy

============================================================



PDR:

Operar confianza y privacidad.



DDD:

Entidades:

\- PrivacyRequest

\- DataCategoryMap

\- RetentionState



DDC:

Fields:

\- request\_id

\- user\_id

\- type: export | delete

\- status

\- created\_at

\- resolved\_at

\- data\_categories



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Privacy                                                      │

│ Export, delete, data categories and encryption state         │

│ \[Type ▼] \[Status ▼] \[Data category ▼]                        │

├──────────────────────────────────────────────────────────────┤

│ Export req. | Delete req. | Open | Resolved                  │

├────────────────────────────┬─────────────────────────────────┤

│ Data category map          │ Encrypted collections           │

│ - Journal                  │ - expenses                      │

│ - Notes                    │ - journal\_entries               │

│ - Finance                  │ - quick\_notes                   │

│ - HomeMemory               │ - purchase\_proofs               │

├────────────────────────────┴─────────────────────────────────┤

│ Privacy request queue                                         │

└──────────────────────────────────────────────────────────────┘



UX:

\- Mostrar estado operacional, no contenido.

\- Export/delete debe ser trazable.



============================================================

PANTALLA 13 — /security

============================================================



PDR:

Mostrar estado de seguridad operacional.



DDD:

Entidades:

\- SecuritySummary

\- KeyRotationEvent

\- ProductionGuardrailStatus



DDC:

Fields:

\- production\_safe

\- token\_configured

\- weak\_defaults\_detected

\- key\_rotation\_count

\- failed\_auth\_count

\- dependency\_scan\_status



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Security                                                     │

│ Production guardrails, key health and operational risk       │

│ \[Run checklist] \[View audit]                                 │

├──────────────────────────────────────────────────────────────┤

│ Prod safe | Dev tokens | Key rotations | Failed auth         │

├──────────────────────────────────────────────────────────────┤

│ Guardrails checklist                                         │

│ \[✓] No dev admin token in production                         │

│ \[✓] Secrets encrypted                                        │

│ \[!] Auth provider not enterprise-ready                       │

├──────────────────────────────────────────────────────────────┤

│ Security events table                                        │

└──────────────────────────────────────────────────────────────┘



UX:

\- Warnings deben ser claros y accionables.

\- No esconder que token-only no es enterprise auth.



============================================================

PANTALLA 14 — /audit

============================================================



PDR:

Auditar acciones administrativas.



DDD:

Entidad:

\- AuditLog



DDC:

Fields:

\- audit\_id

\- actor\_id

\- action

\- target\_type

\- target\_id

\- safe\_diff

\- correlation\_id

\- created\_at



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Audit                                                        │

│ Metadata-only administrative audit trail                     │

│ \[Actor ▼] \[Action ▼] \[Target ▼] \[Date range ▼]               │

├──────────────────────────────────────────────────────────────┤

│ Audit table                                                  │

│ Time | Actor | Action | Target | Correlation | Severity      │

├──────────────────────────────────────────────────────────────┤

│ Detail drawer: safe diff                                     │

│ { before: metadata, after: metadata }                        │

└──────────────────────────────────────────────────────────────┘



UX:

\- Safe diff only.

\- Prohibido secrets/raw private content.



============================================================

PANTALLA 15 — /homememory

============================================================



PDR:

Gestión agregada de HomeMemory sin datos personales.



DDD:

Entidad:

\- HomeMemoryAggregateOps



DDC:

Fields:

\- proof\_parse\_count

\- warranty\_reminder\_count

\- claim\_draft\_count

\- evidence\_attachment\_count

\- parser\_success\_rate

\- fallback\_rate

\- locale\_distribution

\- encrypted\_collections

\- storage\_impact\_estimate



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ HomeMemory                                                   │

│ Aggregated proof, warranty and claim telemetry               │

│ \[Locale ▼] \[Date range ▼]                                    │

├──────────────────────────────────────────────────────────────┤

│ Proof parses | Warranty reminders | Claim drafts | Fallback │

├────────────────────────────┬─────────────────────────────────┤

│ Parser success by locale   │ Encrypted collections           │

├────────────────────────────┴─────────────────────────────────┤

│ Metadata table                                                │

│ Date | Locale | Parses | Success | Fallback | No raw data    │

├──────────────────────────────────────────────────────────────┤

│ Notice: Item names, receipts, serials and claim bodies are    │

│ excluded from admin telemetry.                               │

└──────────────────────────────────────────────────────────────┘



UX:

\- Esta pantalla debe repetir que datos sensibles están excluidos.



============================================================

PANTALLA 16 — /quality

============================================================



PDR:

Medir si GoLife es útil.



DDD:

Entidades:

\- QualitySummary

\- MissionQuality

\- ParserQuality

\- LocaleQuality



DDC:

Fields:

\- usefulness\_rate

\- completion\_rate

\- rejection\_rate

\- fallback\_rate

\- parser\_success\_rate

\- locale

\- endpoint



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Quality                                                      │

│ Mission usefulness, parser success and fallback health       │

│ \[Domain ▼] \[Locale ▼] \[Endpoint ▼]                           │

├──────────────────────────────────────────────────────────────┤

│ Useful % | Completed % | Rejected % | Parser success %       │

├────────────────────────────┬─────────────────────────────────┤

│ Chart: mission quality     │ Chart: parser quality           │

├────────────────────────────┴─────────────────────────────────┤

│ Table by endpoint/domain/locale                              │

└──────────────────────────────────────────────────────────────┘



UX:

\- Debe permitir detectar locales problemáticos: ja, zh-Hans, pt-BR, es, en.

\- Mostrar “top failing locales”.



============================================================

PANTALLA 17 — /incidents

============================================================



PDR:

Centralizar incidentes operacionales.



DDD:

Entidades:

\- Incident

\- IncidentSource

\- IncidentSeverity



DDC:

Fields:

\- incident\_id

\- type

\- severity

\- source

\- status

\- safe\_summary

\- created\_at

\- resolved\_at



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Incidents                                                    │

│ Safety, cost, key, support and privacy incidents             │

│ \[Severity ▼] \[Source ▼] \[Status ▼]                           │

├──────────────────────────────────────────────────────────────┤

│ Open | High severity | Cost anomalies | Key failures         │

├──────────────────────────────────────────────────────────────┤

│ Incident table                                               │

│ Time | Severity | Source | Type | Status | Safe summary      │

├──────────────────────────────────────────────────────────────┤

│ Detail drawer: timeline + linked audit events                │

└──────────────────────────────────────────────────────────────┘



UX:

\- Incidentes nunca deben incluir texto sensible.

\- Usar colores: info/warn/danger.



============================================================

PANTALLA 18 — /login

============================================================



PDR:

Acceso visible a gestión web.



DDD:

Entidad:

\- AdminAuthScaffold



DDC:

Fields:

\- auth\_mode

\- environment

\- token\_configured

\- enterprise\_auth\_configured



Croqui:



┌────────────────────────────────────────┐

│ GoLife Admin                           │

│ Secure management access               │

├────────────────────────────────────────┤

│ Environment: development / production  │

│ Auth mode: token scaffold / enterprise │

├────────────────────────────────────────┤

│ Admin token / login field              │

│ \[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_]             │

│ \[Sign in]                              │

├────────────────────────────────────────┤

│ Warning: Token-only auth is not        │

│ enterprise-ready for production.       │

└────────────────────────────────────────┘



UX:

\- Si no hay auth real, decirlo.

\- No simular enterprise auth.



============================================================

PANTALLA 19 — /logout

============================================================



Croqui:



┌────────────────────────────────────────┐

│ Signed out                             │

│ Your local admin session was cleared.  │

│ \[Return to login]                      │

└────────────────────────────────────────┘



UX:

\- Limpiar cookie/session scaffold.

\- Redirigir a login si corresponde.



============================================================

PANTALLA 20 — /model-lab OPCIONAL

============================================================



Solo si ya existe base suficiente.



PDR:

Laboratorio simple para probar modelos/config sin crear `/studio`.



DDD:

Entidad:

\- ModelLabRun



DDC:

Fields:

\- capability

\- locale

\- sample\_type

\- model

\- trace

\- cost\_estimate

\- schema\_valid

\- safety\_result



Croqui:



┌──────────────────────────────────────────────────────────────┐

│ Model Lab                                                    │

│ Safe model testing without storing sensitive samples          │

│ \[Capability ▼] \[Locale ▼] \[Model ▼]                          │

├──────────────────────────────────────────────────────────────┤

│ Input panel                   │ Output panel                 │

│ \[sample payload]              │ response / trace / cost      │

├──────────────────────────────────────────────────────────────┤

│ Safety / schema validation / telemetry preview               │

└──────────────────────────────────────────────────────────────┘



UX:

\- No guardar sample por defecto.

\- Botón “save as eval” solo si sanitized.



============================================================

NAVIGATION CROQUI

============================================================



Sidebar final permitida:



┌─────────────────────────────┐

│ GoLife Admin                │

│ \[LIVE DATA] \[Locale]        │

├─────────────────────────────┤

│ Overview                    │

│ - Dashboard                 │

│ - Quality                   │

│ - Incidents                 │

├─────────────────────────────┤

│ Users \& Business            │

│ - Users                     │

│ - Organizations             │

│ - Plans                     │

│ - Billing                   │

│ - Storage                   │

├─────────────────────────────┤

│ AI Operations               │

│ - AI Costs                  │

│ - OpenRouter Keys           │

│ - OpenRouter BYOK           │

│ - xInsightAI                │

│ - Routing Profiles          │

│ - Routing Snapshots         │

│ - Model Catalog             │

│ - Model Settings            │

├─────────────────────────────┤

│ Product Quality             │

│ - Missions                  │

│ - Feedback                  │

│ - Safety                    │

│ - HomeMemory                │

├─────────────────────────────┤

│ Trust \& Support             │

│ - Support Queue             │

│ - Privacy                   │

│ - Security                  │

│ - Audit                     │

│ - Feature Flags             │

└─────────────────────────────┘



============================================================

MOBILE RESPONSIVE CROQUI

============================================================



En pantallas pequeñas:



┌─────────────────────────────┐

│ Topbar: Menu | Title | Env  │

├─────────────────────────────┤

│ KPI cards horizontal scroll │

├─────────────────────────────┤

│ Filters collapsed           │

│ \[Open filters]              │

├─────────────────────────────┤

│ Cards/list instead of wide  │

│ table                       │

└─────────────────────────────┘



Reglas:

\- Tables deben convertirse a cards si ancho < md.

\- Sidebar colapsa.

\- Drawers ocupan pantalla completa en mobile.



============================================================

EMPTY / ERROR / LOADING STATES

============================================================



Empty state estándar:



┌────────────────────────────────────┐

│ No data yet                        │

│ This area will populate when live  │

│ operational ingestion starts.      │

│ \[Check backend health]             │

└────────────────────────────────────┘



Error state estándar:



┌────────────────────────────────────┐

│ Backend unavailable                │

│ Showing fallback snapshot.         │

│ \[Retry] \[View health]              │

└────────────────────────────────────┘



Sensitive data excluded state:



┌────────────────────────────────────┐

│ Sensitive data excluded            │

│ This admin view only shows metadata│

│ and aggregate operational signals. │

└────────────────────────────────────┘



============================================================

DESIGN TOKENS

============================================================



Usar tokens coherentes:



Colors:

\- background: neutral warm/off-white or current app background

\- surface: white/soft

\- border: subtle

\- good: green

\- warn: amber

\- danger: red

\- info: blue/slate

\- muted: gray



Typography:

\- page title: 28–34px, semibold

\- section title: 18–20px

\- table text: 13–14px

\- metadata: 11–12px uppercase tracking



Spacing:

\- page gap: 24px

\- card padding: 20–24px

\- table row: 48–56px

\- sidebar item: 12–16px



Components:

\- rounded cards

\- subtle borders

\- no excessive shadows

\- compact badges

\- dense tables



============================================================

IMPLEMENTATION RULE

============================================================



Antes de implementar cada pantalla:

1\. Crear o actualizar su SPEC con el croqui.

2\. Implementar la UI.

3\. Añadir i18n.

4\. Añadir empty/error/loading.

5\. Validar build.

6\. Commit.



Los specs deben ir en:



docs/admin/specs/

&#x20; SPEC\_DASHBOARD\_UI.md

&#x20; SPEC\_USERS\_UI.md

&#x20; SPEC\_ORGANIZATIONS\_UI.md

&#x20; SPEC\_PLANS\_UI.md

&#x20; SPEC\_USAGE\_UI.md

&#x20; SPEC\_AI\_COSTS\_UI.md

&#x20; SPEC\_OPENROUTER\_KEYS\_UI.md

&#x20; SPEC\_OPENROUTER\_BYOK\_UI.md

&#x20; SPEC\_XINSIGHTAI\_UI.md

&#x20; SPEC\_BILLING\_UI.md

&#x20; SPEC\_STORAGE\_UI.md

&#x20; SPEC\_PRIVACY\_UI.md

&#x20; SPEC\_SECURITY\_UI.md

&#x20; SPEC\_AUDIT\_UI.md

&#x20; SPEC\_HOMEMEMORY\_ADMIN\_UI.md

&#x20; SPEC\_QUALITY\_UI.md

&#x20; SPEC\_INCIDENTS\_UI.md

&#x20; SPEC\_LOGIN\_LOGOUT\_UI.md



Commit sugerido para esta documentación UI:

docs: add premium web management screen croquis



Luego seguir con implementación por fases.

