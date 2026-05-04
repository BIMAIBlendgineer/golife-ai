# Commands

Date: `2026-05-04`

This file is the short command reference. Use [Local setup](development/LOCAL_SETUP.md) and [Testing](development/TESTING.md) for full context.

## Monorepo

```bash
git status --short --branch
git worktree list
git log --oneline --decorate -n 10
```

## AI Gateway

Install and run:

```bash
cd services/ai_gateway
python -m pip install -e .[dev]
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Tests:

```bash
python -m pytest -q
python -m pytest -q tests/test_api.py tests/test_openrouter_routing.py tests/test_openrouter_normalization.py
```

Production smoke:

```bash
curl -s http://127.0.0.1:8000/health
curl -s http://127.0.0.1:8000/ready
```

## Web Backend

Install and run:

```bash
cd services/web_backend
python -m pip install -e .[dev]
python -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
```

Tests:

```bash
python -m pytest -q
python -m pytest -q tests/test_admin_api.py
```

## Admin Next

Install and run:

```bash
cd apps/admin_next
npm ci
npm run dev
```

Validation:

```bash
npm run lint
npm run typecheck
npm run build
npm audit --omit=dev --audit-level=high
```

## Mobile Flutter

Install and run:

```bash
cd apps/mobile_flutter
flutter pub get
flutter run --dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://127.0.0.1:8000 --dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://127.0.0.1:8010
```

Validation:

```bash
flutter analyze
flutter test
```

Notes:

- secure export bundle and submission-asset vault are covered by Flutter tests
- the repo still lacks checked-in Android, iOS, and desktop runner projects

## Security

```bash
gitleaks git
```

```bash
cd services/ai_gateway
bandit -q -r app -s B105,B106
pip-audit --ignore-vuln CVE-2026-3219
```

```bash
cd ../web_backend
bandit -q -r app -s B105,B106
pip-audit --ignore-vuln CVE-2026-3219
```

## CI

Workflow:

```text
.github/workflows/ci.yml
```
