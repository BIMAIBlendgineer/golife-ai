# GoLife AI

GoLife AI is not a generic chatbot and not a bundle of unrelated mini-apps. It is a local-first daily decision system built around:

- a personal `LifeGraph`
- three actionable daily missions
- explicit evidence and traceability
- privacy filters before AI
- feedback and learning over time

The active runtime surface in this repository is:

- `apps/mobile_flutter`: local-first mobile app
- `services/ai_gateway`: AI gateway and safety layer
- `services/web_backend`: operational backend and admin APIs
- `apps/admin_next`: operational admin panel
- `packages/contracts`: shared contract snapshots

## Current release state

The hardening blocks closed so far are summarized in:

- [Final release summary](docs/operations/FINAL_RELEASE_SUMMARY.md)
- [Release risk register](docs/operations/RELEASE_RISK_REGISTER.md)
- [Documentation inventory](docs/operations/DOCUMENTATION_INVENTORY.md)

Key release-readiness closures already documented:

- AI Gateway production anti-mock hardening
- OpenRouter live validation in local production mode
- admin/backend export-delete workflow
- secure mobile export bundle with private submission-asset vault
- adversarial safety coverage across reflection, capture, proof, and task-rewrite surfaces
- deterministic mission ranking plus metadata-only feedback memory
- explicit mobile/admin fallback visibility

## Product thesis

GoLife AI should produce small daily decisions from real user evidence, not act like a freeform assistant with hidden behavior. The current product center is:

1. Capture reality quickly.
2. Structure that reality into local events and domain entities.
3. Filter what AI is allowed to see.
4. Generate a small number of actionable missions with trace.
5. Learn from user feedback without silently expanding data exposure.

## Requirements

Recommended local toolchain:

- Python `3.12`
- Node `22`
- Flutter stable, `>=3.22.0`

The Python services declare `>=3.11`, but the checked CI baseline is Python `3.12`.

## Monorepo quick start

Install and run the active surfaces:

```bash
cd services/ai_gateway
python -m pip install -e .[dev]

cd ../web_backend
python -m pip install -e .[dev]

cd ../../apps/admin_next
npm ci

cd ../mobile_flutter
flutter pub get
```

Local startup order:

1. `services/web_backend`
2. `services/ai_gateway`
3. `apps/admin_next`
4. `apps/mobile_flutter`

Detailed setup:

- [Local setup](docs/development/LOCAL_SETUP.md)
- [Testing and validation](docs/development/TESTING.md)
- [Command reference](docs/commands.md)

## Runtime modes

### Dev mode

Use local defaults and explicit test data only. Mock and client fallback paths remain allowed in development so they can be tested and observed.

### Production local single-key mode

For local production smoke without a routing control plane:

- `AI_GATEWAY_ENV=production`
- `AI_GATEWAY_ENABLE_MOCK=false`
- `LLM_PROVIDER=openrouter`
- `OPENROUTER_API_KEY` must be set externally
- `ROUTING_CONTROL_ENABLED=false`

See:

- [Deployment runbook](docs/operations/DEPLOYMENT_RUNBOOK.md)
- [Environment matrix](docs/operations/ENVIRONMENT_MATRIX.md)

## Validation gates

Primary local gates:

```bash
cd services/ai_gateway
python -m pytest -q

cd ../web_backend
python -m pytest -q

cd ../../apps/mobile_flutter
flutter analyze
flutter test

cd ../admin_next
npm run lint
npm run typecheck
npm run build

cd ../..
gitleaks git
```

The checked CI workflow is [ci.yml](.github/workflows/ci.yml).

Full release validation is tracked in:

- [Final release readiness checklist](docs/operations/FINAL_RELEASE_READINESS_CHECKLIST.md)
- [Validation matrix](docs/operations/VALIDATION_MATRIX.md)

## Privacy and safety

Canonical current-state docs:

- [Privacy review](docs/compliance/PRIVACY_REVIEW.md)
- [Data map](docs/compliance/DATA_MAP.md)
- [Safety review](docs/compliance/SAFETY_REVIEW.md)
- [Safety policy](docs/security/SAFETY_POLICY.md)

Important boundary:

- raw personal graph data stays local by default
- admin receives operational metadata, not raw personal payloads
- safety blocking is centralized in a versioned policy engine, but it remains rule-based rather than jailbreak-proof

## Release locale scope

The current premium-production release scope supports:

- `en`
- `es`

Other locale assets may remain in the repo for future completion, but they are not part of the current release claim.

## API and operations docs

- [AI Gateway API](docs/api/AI_GATEWAY_API.md)
- [Web Backend API](docs/api/WEB_BACKEND_API.md)
- [Admin operations](docs/admin/ADMIN_OPERATIONS.md)

## Historical material

This repo still contains older roadmap packages and legacy planning documents. They are kept for provenance, not as runtime source of truth.

Start here when in doubt:

- [Documentation inventory](docs/operations/DOCUMENTATION_INVENTORY.md)
- [Archive index](docs/archive/README.md)
