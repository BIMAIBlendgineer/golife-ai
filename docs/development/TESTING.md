# Testing

## Goal

The release candidate is valid only if GoLife AI behaves as a daily decision system with explicit privacy, visible fallback, and no silent mock path in production.

## Local validation order

### 1. AI Gateway

```bash
cd services/ai_gateway
python -m pytest -q
```

Focused suites:

```bash
python -m pytest -q tests/test_api.py
python -m pytest -q tests/test_openrouter_routing.py
python -m pytest -q tests/test_openrouter_normalization.py
```

Production smoke:

```bash
curl -s http://127.0.0.1:8000/health
curl -s http://127.0.0.1:8000/ready
```

### 2. Web Backend

```bash
cd services/web_backend
python -m pytest -q
```

Focused export-delete validation:

```bash
python -m pytest -q tests/test_admin_api.py
```

### 3. Mobile Flutter

```bash
cd apps/mobile_flutter
flutter analyze
flutter test
```

Important coverage areas:

- fallback visibility
- protected export bundle
- submission asset vault
- delete-all local data
- capture safety parser behavior

### 4. Admin Next

```bash
cd apps/admin_next
npm run lint
npm run typecheck
npm run build
```

## Security gates

### Secret scan

```bash
cd C:/0 Work/GoLife AI
gitleaks git
```

### Python security

```bash
cd services/ai_gateway
bandit -q -r app -s B105,B106
pip-audit --ignore-vuln CVE-2026-3219

cd ../web_backend
bandit -q -r app -s B105,B106
pip-audit --ignore-vuln CVE-2026-3219
```

### Admin dependency audit

```bash
cd apps/admin_next
npm audit --omit=dev --audit-level=high
```

## CI baseline

The checked workflow is [ci.yml](../../.github/workflows/ci.yml).

Current CI expectations:

- Python `3.12`
- Node `22`
- Flutter stable
- jobs:
  - `ai-gateway`
  - `web-backend`
  - `admin-next`
  - `flutter`
  - `secret-scan`
  - `python-security`
  - `admin-security`

## Smoke expectations

### AI Gateway

- `/health` returns `200`
- `/ready` returns `200` in production-valid config
- live OpenRouter smoke returns `200`
- mission response must not contain `mock: true`

### Mobile

- fallback remains visible, not disguised as remote AI
- protected export writes `data.json` plus `assets/`

### Admin

- pages distinguish `live`, `fallback`, and `offline`
- support export/delete workflow is actionable, not read-only

## Failure handling

- Do not “fix” failed production readiness by turning mocks back on.
- Do not relax safety docs to hide open risks.
- If docs and code disagree, inspect code and update docs unless the mismatch reveals a real bug.
