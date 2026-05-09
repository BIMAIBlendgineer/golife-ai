# XAIBIM CI/Deploy Policy

This copy is intentionally duplicated across XAIBIM repos so the same baseline is visible from each worktree.

## Baseline

- Vercel only for frontend-only or clearly isolated frontend roots.
- Backend, API, CDE, control_tower, runtime, IFC, worker, and smoke surfaces stay out of Vercel.
- Automatic CI only on `pull_request` to `main`.
- Manual runs stay available through `workflow_dispatch`.
- Branch-push CI is disabled by default.
- `schedule` and `workflow_run` stay disabled unless separately justified.
- Heavy smoke, eval, load, runtime, and visual QA runs stay manual only.

## Inventory And Classification

| Surface | Local repo/path | Type | Workflows | Vercel policy | Deploy target |
| --- | --- | --- | --- | --- | --- |
| `0 XAIBIM` | `0 XAIBIM` | umbrella mixed repo with admin/runtime/frontend surfaces | `a002-runtime-smoke.yml`, `integrity-enforcement.yml` | blocked | Cloud Run/container for backend/runtime |
| `admin` | `0 XAIBIM/admin` | Python backend/API | `admin-ci.yml` | blocked | Cloud Run/container |
| `control` | `0 XAIBIM/control` | Next.js frontend | none | allowed if frontend-only | Vercel |
| `studio` | `0 XAIBIM/studio` | Next.js frontend | none | allowed | Vercel |
| `AECOClip` | `AECOClip` | mixed server + UI + CDE/IFC services | multiple | repo-level blocked | Cloud Run/container |
| `AR Studio` | `AR Studio` | mixed backend + admin UI + mobile + AI gateway | `premium-v2-rc.yml` | repo-level blocked | Cloud Run/container |
| `Big-Bang` | `Big-Bang` | mixed backend + frontend + mobile/expo | `ci.yml`, `ci-ping.yml`, `main-observable.yml` | repo-level blocked | Cloud Run/container |
| `Control Tower` | `Control Tower` | mixed Python backend + Next.js frontend | `ci.yml`, `premium-ci.yml` | repo-level blocked | Cloud Run/container |
| `FrameMind-AI` | `FrameMind-AI` | mixed backend + frontend + runtime/evals | `ci.yml` | repo-level blocked | Cloud Run/container |
| `GoLife AI` | `GoLife AI` | mixed Python services + admin frontend + Flutter app | `ci.yml` | repo-level blocked | Cloud Run/container |
| `newXAIBIM` | `newXAIBIM` | Next.js frontend | none | allowed | Vercel |
| `NutriSynergy` | `NutriSynergy` | mixed web + admin + integration/backend services | `admin-ci.yml`, `ci.yml`, `integration.yml`, `security.yml` | repo-level blocked | Cloud Run/container |
| `plant-it-f01` | `plant-it-f01` | mixed admin-web + ai-gateway + Flutter frontend | multiple | repo-level blocked | Cloud Run/container |
| `PlantMIND` | `PlantMIND` | mixed admin-web + mobile + ai-gateway | `validate.yml` | repo-level blocked | Cloud Run/container |
| `SoulSound AI` | `SoulSound AI` | mixed web + API + AI gateway + workers | `ci.yml` | repo-level blocked | Cloud Run/container |
| `XAIBIM_FULL` | `XAIBIM_FULL` | Next.js frontend | none | allowed | Vercel |
| `cde` | standalone repo not found in this workspace on 2026-05-08 | backend/data surface | none | blocked when present | Cloud Run/container |

Frontend roots inside mixed repos are only Vercel-eligible after they are isolated or their Vercel project stops deploying backend/runtime paths.

## Final Triggers

- `0 XAIBIM`: `integrity-enforcement.yml` runs on PR to `main` plus manual dispatch; `a002-runtime-smoke.yml` is manual-only.
- `admin`: `admin-ci.yml` runs on PR to `main` plus manual dispatch.
- `control`: no tracked workflow exists today.
- `studio`: no tracked workflow exists today.
- `AECOClip`: `aecoclip-ci.yml` and `pr.yml` run on PR to `main` plus manual dispatch; `aecoclip-release-candidate.yml`, `docker.yml`, `e2e.yml`, `refresh-lockfile.yml`, `release-smoke.yml`, and `release.yml` are manual-only.
- `AR Studio`: `premium-v2-rc.yml` runs on PR to `main` plus manual dispatch.
- `Big-Bang`: `ci-ping.yml`, `ci.yml`, and `main-observable.yml` run on PR to `main` plus manual dispatch; heavy runtime corpus smoke, backend full, and dependency audit are manual-only inside `ci.yml`.
- `Control Tower`: `ci.yml` and `premium-ci.yml` run on PR to `main` plus manual dispatch.
- `FrameMind-AI`: `ci.yml` runs on PR to `main` plus manual dispatch; heavy eval, smoke, and visual QA steps are manual-only inside the workflow.
- `GoLife AI`: `ci.yml` runs on PR to `main` plus manual dispatch; load smoke remains manual-only inside the workflow.
- `newXAIBIM`: no tracked workflow exists today.
- `NutriSynergy`: `admin-ci.yml`, `ci.yml`, `integration.yml`, and `security.yml` run on PR to `main` plus manual dispatch.
- `plant-it-f01`: `admin-web-ci.yml`, `gateway-ci.yml`, and `main.yml` run on PR to `main` plus manual dispatch; load smoke is manual-only inside `gateway-ci.yml`; `create-app.yml` and `release.yml` are manual-only; PR-close automations keep `pull_request` on `main` plus manual dispatch.
- `PlantMIND`: `validate.yml` runs on PR to `main` plus manual dispatch.
- `SoulSound AI`: `ci.yml` runs on PR to `main` plus manual dispatch.
- `XAIBIM_FULL`: no tracked workflow exists today.

## Manual GitHub And Vercel Actions

- Remove Vercel App access for `0 XAIBIM`, `admin`, `AECOClip`, `AR Studio`, `Big-Bang`, `Control Tower`, `FrameMind-AI`, `GoLife AI`, `NutriSynergy`, `plant-it-f01`, `PlantMIND`, `SoulSound AI`, and `cde` unless the frontend is split into a frontend-only repo or project.
- Disconnect Git for any Vercel project that still points at a mixed or backend repo.
- Keep Vercel only for `control`, `studio`, `newXAIBIM`, and `XAIBIM_FULL` frontend projects.
- Route blocked repos to Cloud Run or another container platform.
- Remove `Vercel` as a required GitHub check on blocked repos.

## Residual Risks

- `control`, `studio`, `newXAIBIM`, and `XAIBIM_FULL` still have no tracked workflows.
- `cde` was not present locally as a standalone repo, so its dashboard cleanup remains manual and unverified.
- `plant-it-f01` points to a missing Git worktree base (`C:\0 Work\plant-it`), so Git commit operations from that worktree are blocked until the worktree metadata is repaired.
- Mixed repos can still show stale Vercel statuses until GitHub and Vercel dashboard cleanup is completed.
