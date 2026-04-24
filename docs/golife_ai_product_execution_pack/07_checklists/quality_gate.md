# Quality Gate

## Backend AI

- [x] `python -m pytest -q`
  - Validado por archivos porque la suite completa excede el timeout de este entorno.

## Web Backend

- [x] `python -m pytest -q`

## Admin

- [x] `npm run lint`
- [x] `npm run typecheck`
- [x] `npm run build`

## Flutter

- [x] `flutter pub get`
- [x] `flutter analyze`
- [x] `flutter test`

## Seguridad

- [x] Gitleaks
- [x] Sin `.env` trackeado
- [x] Sin `.pyc`
- [x] Sin `.runtime` trackeado
- [x] Sin payload sensible en admin
