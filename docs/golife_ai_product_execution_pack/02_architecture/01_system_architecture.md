# Arquitectura del sistema

```text
GoLife AI
├── apps/
│   ├── mobile_flutter
│   └── admin_next
├── services/
│   ├── ai_gateway
│   └── web_backend
├── packages/
│   └── contracts
└── docs/
```

## App móvil

Responsabilidades:
- Home Today;
- Capture universal;
- LifeBoard;
- Domains;
- Review;
- SQLite local;
- privacidad por evento;
- feedback.

## AI Gateway

Responsabilidades:
- OpenRouter;
- mock fallback;
- clasificación;
- parser multi-evento;
- risk engine;
- mission engine;
- reflection coach;
- safety guardrails;
- operational telemetry.

## Web Backend

Responsabilidades:
- PostgreSQL;
- ingestion;
- users;
- usage;
- AI costs;
- mission audits;
- feedback audits;
- safety events;
- feature flags;
- support/export/delete.

## Admin Next.js

Responsabilidades:
- dashboards;
- users;
- usage;
- AI costs;
- missions;
- feedback;
- safety;
- feature flags;
- model settings;
- system health.
