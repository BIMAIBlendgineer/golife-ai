# Local Setup

## Scope

This guide describes how to run the active GoLife AI runtime surfaces locally without exposing secrets and without relying on legacy package layouts.

## Active services

- `services/web_backend`
- `services/ai_gateway`
- `apps/admin_next`
- `apps/mobile_flutter`

## Toolchain

- Python `3.12` recommended
- Node `22`
- Flutter stable `>=3.22.0`

## Install

### AI Gateway

```bash
cd services/ai_gateway
python -m pip install -e .[dev]
```

### Web Backend

```bash
cd services/web_backend
python -m pip install -e .[dev]
```

### Admin Next

```bash
cd apps/admin_next
npm ci
```

### Mobile Flutter

```bash
cd apps/mobile_flutter
flutter pub get
```

## Environment files

Do not commit `.env` files.

Available examples:

- `services/ai_gateway/.env.example`
- `services/web_backend/.env.example`
- `apps/admin_next/.env.example`

The AI Gateway and web backend load `.env` from their own service folders. `apps/admin_next/.env` does not configure the AI Gateway.

## Dev mode

### Web Backend

```bash
cd services/web_backend
python -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
```

Typical dev environment:

- `ENVIRONMENT=dev`
- `ADMIN_TOKEN=<local dev token>`
- `INGESTION_TOKEN=<local dev token>`
- `OPERATIONAL_DATABASE_PATH=.runtime/web_backend.db`

### AI Gateway

```bash
cd services/ai_gateway
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Typical dev environment:

- `AI_GATEWAY_ENV=dev`
- `LLM_PROVIDER=openrouter`
- `OPENROUTER_API_KEY` optional for mock/dev fallback testing
- `AI_GATEWAY_ENABLE_MOCK` allowed in dev only

### Admin Next

```bash
cd apps/admin_next
npm run dev
```

Typical local config:

- `GOLIFE_ADMIN_API_BASE_URL=http://127.0.0.1:8010`
- `GOLIFE_ADMIN_API_TOKEN=<admin token for web_backend>`

### Mobile Flutter

```bash
cd apps/mobile_flutter
flutter run --dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://127.0.0.1:8000 --dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://127.0.0.1:8010
```

Useful local host mappings:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://127.0.0.1:8000`
- physical device: host machine LAN IP

## Production local single-key smoke

Use this when validating real OpenRouter behavior without a routing control plane:

### AI Gateway

- `AI_GATEWAY_ENV=production`
- `AI_GATEWAY_ENABLE_MOCK=false`
- `LLM_PROVIDER=openrouter`
- `OPENROUTER_API_KEY` required
- `ROUTING_CONTROL_ENABLED=false`
- `OPERATIONAL_BACKEND_ENABLED=false` if local operational backend is not running for the smoke

Then start:

```bash
cd services/ai_gateway
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

### Smoke checks

```bash
curl -s http://127.0.0.1:8000/health
curl -s http://127.0.0.1:8000/ready
```

Expected:

- `active_provider=openrouter`
- `mock_mode=false`
- `/ready` returns `200` in production-valid config

## Control-plane mode

Use only if the operational backend is actually configured with non-dev production tokens and live routing data.

Requirements:

- `ROUTING_CONTROL_ENABLED=true`
- `ROUTING_BACKEND_BASE_URL` points to a live backend
- `ROUTING_BACKEND_INTERNAL_TOKEN` is not the dev default
- web backend production validation passes

## Troubleshooting

- If AI Gateway still reports mock mode, inspect `services/ai_gateway/.env`, not `apps/admin_next/.env`.
- If admin shows fallback or offline, confirm `web_backend` is running and that `GOLIFE_ADMIN_API_TOKEN` matches `ADMIN_TOKEN`.
- If mobile falls back locally, inspect mission trace for `clientFallback` and `fallbackReason`.
- If Python tests behave differently from CI, align on Python `3.12`.
