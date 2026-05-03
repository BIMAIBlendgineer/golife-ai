# Commands

Fecha: 2026-05-03

## Mobile Flutter

```bash
cd apps/mobile_flutter
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Notas:

- El shell Flutter valida y testea bien en este entorno.
- Siguen faltando runners `android/`, `ios/`, `web/`, etc.; para `flutter run` hay que generarlos primero con `flutter create .` o incorporar runners del producto final.

## AI Gateway

```bash
cd services/ai_gateway
python -m pip install -e .[dev]
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
python -m pytest -q
```

Si la suite completa local tarda demasiado en Python 3.14, usar validación focalizada:

```bash
python -m pytest tests/test_openrouter_routing.py -q
python -m pytest tests/test_openrouter_normalization.py -q
python -m pytest tests/test_daily_mission_graph.py -q
python -m pytest tests/test_api.py -q
```

## Web Backend

```bash
cd services/web_backend
python -m pip install -e .[dev]
python -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
python -m pytest
```

## Admin Next

```bash
cd apps/admin_next
npm ci
npm run lint
npm run typecheck
npm run build
npm run dev
```

Variables útiles del panel:

```bash
GOLIFE_ADMIN_API_BASE_URL=http://127.0.0.1:8010
GOLIFE_ADMIN_API_TOKEN=golife-admin-dev
```

## Monorepo

```bash
git status --short
git worktree list
```

CI existente:

```text
.github/workflows/ci.yml
```
