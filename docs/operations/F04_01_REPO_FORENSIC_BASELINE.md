# F04 01 Repo Forensic Baseline

Fecha: 2026-05-03
Ejecutor: Codex
Rama de integración: `prod/f04-autopilot-roadmap`
SHA base verificado: `dd14fa3cf30c879bfe23e1b9012e3b1ba25a553c`

## Identidad real del repositorio

- `origin`: `https://github.com/BIMAIBlendgineer/golife-ai.git`
- repositorio remoto real: `BIMAIBlendgineer/golife-ai`
- default branch: `main`
- PR abierto relevante: `#6` `hardening/post-merge-release-readiness`
- estado PR #6 a 2026-05-03:
  - `open`
  - `merged: false`
  - `mergeable: true`
  - `draft: false`
  - head branch: `hardening/post-merge-release-readiness`
  - head SHA: `dd14fa3cf30c879bfe23e1b9012e3b1ba25a553c`

## Desalineaciones detectadas frente a `docs/autocopilot.md`

- el documento habla de `BIMAIBlendgineer/plant`; el repo real es `BIMAIBlendgineer/golife-ai`
- el documento habla de `frontend/`; la app móvil real está en `apps/mobile_flutter/`
- el documento habla de `admin-web/`; el panel real está en `apps/admin_next/`
- el documento habla de `ai-gateway/`; el gateway real está en `services/ai_gateway/`
- existe una cuarta superficie activa no modelada en el documento: `services/web_backend/`
- `docs/plantmind/` no existe; la documentación operativa viva está en `docs/operations/`, `docs/product/`, `docs/security/`, `docs/admin/` y `docs/compliance/`
- `packages/contracts/` contiene JSON Schemas compartidos, no `openapi.yaml`

## Superficies activas verificadas

```text
apps/
  admin_next/        Next.js 15 + React 19 + TypeScript
  mobile_flutter/    Flutter mobile shell
services/
  ai_gateway/        FastAPI AI gateway
  web_backend/       FastAPI operational backend
packages/
  contracts/         JSON schemas compartidos
.github/workflows/
  ci.yml             Monorepo CI
```

## Manifests detectados

- `apps/mobile_flutter/pubspec.yaml`
- `apps/admin_next/package.json`
- `services/ai_gateway/pyproject.toml`
- `services/web_backend/pyproject.toml`
- `packages/contracts/*.schema.json`
- `golife_ai_business_roadmap_package/ai-gateway-skeleton/pyproject.toml` como referencia legacy

## Gates reales definidos en CI

Fuente: [`.github/workflows/ci.yml`](C:/0%20Work/GoLife%20AI/.github/workflows/ci.yml)

- `ai-gateway`
  - `python -m pip install -e .[dev]`
  - `python -m pytest -q`
- `web-backend`
  - `python -m pip install -e .[dev]`
  - `python -m pytest -q`
- `admin-next`
  - `npm ci`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
- `flutter`
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
- `secret-scan`
  - `gitleaks/gitleaks-action@v2`
- `python-security`
  - `python -m pip install -e .[dev] bandit pip-audit`
  - `bandit -q -r app -s B105,B106`
  - `pip-audit --ignore-vuln CVE-2026-3219`
- `admin-security`
  - `npm audit --omit=dev --audit-level=high`
- `ai-gateway-load-smoke`
  - manual only

## Estado remoto verificado al iniciar F04

- workflow run relevante: `Monorepo CI` run `25280815331`
- fecha del run: 2026-05-03
- conclusión global: `failure`
- jobs exitosos:
  - `flutter`
  - `ai-gateway`
  - `admin-next`
  - `secret-scan`
  - `admin-security`
  - `python-security (services/ai_gateway)`
- jobs fallidos:
  - `web-backend`
  - `python-security (services/web_backend)`

## Hallazgo operativo crítico

El gate remoto no está bloqueado por billing. Está bloqueado por fallos reales en `services/web_backend`:

- `pytest` rompía por uso de `FastAPI.add_event_handler` contra una versión más nueva de FastAPI/Starlette en CI.
- `bandit` rompía por seis avisos `B608` en queries con `where_sql` dinámico en `app/repository.py`.

## Decisión de ejecución

- continuar el roadmap en autopiloto local sobre `prod/f04-autopilot-roadmap`
- usar `docs/operations/` para la trazabilidad F04
- priorizar F01-F04 contra la estructura real del repo
- tratar `golife_ai_business_roadmap_package/ai-gateway-skeleton` como legacy en cuarentena, no como runtime activo

