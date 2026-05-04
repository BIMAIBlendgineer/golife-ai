# F04 01 Repo Forensic Baseline

Date: `2026-05-03`
Executor: `Codex`
Integration branch: `prod/f04-autopilot-roadmap`
Verified base SHA: `dd14fa3cf30c879bfe23e1b9012e3b1ba25a553c`

## Real repository identity

- `origin`: `https://github.com/BIMAIBlendgineer/golife-ai.git`
- real remote repo: `BIMAIBlendgineer/golife-ai`
- default branch: `main`
- relevant open PR at the time: `#6` `hardening/post-merge-release-readiness`

## Misalignments detected versus `docs/autocopilot.md`

- old repo name references
- old paths such as `frontend/`, `admin-web/`, and `ai-gateway/`
- missing explicit `services/web_backend/` surface
- old `docs/plantmind/` references instead of the live docs structure

## Verified active surfaces

```text
apps/
  admin_next/
  mobile_flutter/
services/
  ai_gateway/
  web_backend/
packages/
  contracts/
.github/workflows/
  ci.yml
```

## Manifests detected

- `apps/mobile_flutter/pubspec.yaml`
- `apps/admin_next/package.json`
- `services/ai_gateway/pyproject.toml`
- `services/web_backend/pyproject.toml`
- `packages/contracts/*.schema.json`
- `golife_ai_business_roadmap_package/ai-gateway-skeleton/pyproject.toml` as legacy reference

## Real CI gates

Source: `.github/workflows/ci.yml`

- `ai-gateway`
- `web-backend`
- `admin-next`
- `flutter`
- `secret-scan`
- `python-security`
- `admin-security`
- `ai-gateway-load-smoke` as workflow-dispatch only

## Historical critical finding

The remote gate at that point was not blocked by billing; it was blocked by real `services/web_backend` failures:

- lifecycle incompatibility with newer FastAPI/Starlette behavior
- Bandit findings around dynamic SQL composition

## Execution decision

- continue the roadmap locally against the real repo structure
- use `docs/operations/` for F04 traceability
- treat `golife_ai_business_roadmap_package/ai-gateway-skeleton` as quarantined legacy reference, not active runtime
