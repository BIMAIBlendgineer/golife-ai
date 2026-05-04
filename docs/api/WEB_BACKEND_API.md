# Web Backend API

Base service: `services/web_backend`

The web backend is the operational and admin API surface for GoLife AI. It is not the canonical cloud store for the full local mobile LifeGraph.

## Common behavior

- admin routes require `x-admin-token`
- ingestion routes require `x-ingestion-token`
- internal routing routes require `x-internal-service-token`
- production rejects dev default secrets and weak token lengths

## `GET /health`

- Purpose: backend health snapshot
- Success: `200`
- Response model: `AdminHealth`
- Key fields:
  - `status`
  - `data_source`
  - `mode`
  - `storage_path`
  - `last_ingestion_at`

## `GET /public/mobile/runtime-config`

- Purpose: public runtime config for mobile clients
- Success: `200`
- Response model: `MobileRuntimeConfig`
- Privacy:
  - no secrets exposed
- Telemetry:
  - config is derived from backend routing and feature state

## `GET /admin/support/export-delete`

- Purpose: list privacy support requests
- Auth: admin token
- Success: `200`
- Response: support request rows with request type, status, and timestamps
- UI consumer: admin support page

## `GET /admin/support/export-delete/{request_id}/bundle`

- Purpose: generate and download an operational export bundle for an `export` request
- Auth: admin token
- Success: `200`
- Response model: `OperationalExportBundle`
- Errors:
  - `404` if request not found
  - `400` if request is not an export request
- Privacy:
  - metadata-only
  - no full local mobile graph
- Telemetry:
  - admin audit entry recorded for bundle download
- Tests: `services/web_backend/tests/test_admin_api.py`

## `POST /admin/support/export-delete/{request_id}/resolve`

- Purpose: mark an `export` request as completed after operational handling
- Auth: admin token
- Success: `200`
- Response model: `SupportRequestExecutionResult`
- Errors:
  - `404` if not found
  - `409` if already resolved
- Telemetry:
  - admin audit entry recorded
- Tests: `tests/test_admin_api.py`

## `POST /admin/support/export-delete/{request_id}/execute-delete`

- Purpose: execute operational delete for a `delete` request
- Auth: admin token
- Success: `200`
- Response model: `SupportRequestExecutionResult`
- Errors:
  - `404` if not found
  - `400` if request is not a delete request
  - `409` if already resolved
- Privacy:
  - deletes backend operational records only
  - does not delete local device data
- Telemetry:
  - admin audit entry recorded
- Tests: `tests/test_admin_api.py`

## `GET /admin/privacy/data-map`

- Purpose: operational privacy data-map view for admin
- Auth: admin token
- Success: `200`
- Response model: `PrivacyDataMap`

## `GET /admin/security/summary`

- Purpose: security configuration and readiness summary
- Auth: admin token
- Success: `200`
- Response model: `SecuritySummary`
- Includes:
  - token configuration state
  - production-ready boolean
  - key counts
  - dependency scan placeholder status

## `GET /admin/audit`

- Purpose: view admin audit log
- Auth: admin token
- Success: `200`
- Response model: paginated `AuditLogRow`
- Privacy:
  - safe diffs only

## `GET /admin/quality/summary`

- Purpose: quality summary for mission usefulness, fallback rate, parser success, and support escalations
- Auth: admin token
- Success: `200`
- Response model: `QualitySummary`

## `GET /admin/incidents`

- Purpose: view operational incidents
- Auth: admin token
- Success: `200`
- Response model: paginated `IncidentRow`

## `GET /admin/safety`

- Purpose: view safety event audits
- Auth: admin token
- Success: `200`
- Response model: paginated `SafetyAuditRecord`
- Privacy:
  - raw blocked input is not exposed

## Internal ingestion endpoints

These are not public admin endpoints, but they are operationally critical:

- `POST /internal/usage-events`
- `POST /internal/ai-invocations`
- `POST /internal/mission-audits`
- `POST /internal/feedback-audits`
- `POST /internal/safety-events`
- `POST /internal/model-settings`

They accept metadata-only payloads from the AI Gateway and feed admin reporting.

## Routing control-plane endpoints

- `GET /internal/ai-routing/config`
- `POST /internal/ai-routing/selection-refresh`
- `POST /internal/openrouter-key-events`

These are valid production surfaces only when the deployment actually uses control-plane routing with non-dev internal tokens.
