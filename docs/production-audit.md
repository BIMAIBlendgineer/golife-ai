# Production Audit

Fecha: 2026-05-03

## Git actual

- Branch activa: `codex/premium-web-management`
- Worktrees detectados: `1`
- Cambio no trackeado previo al trabajo: `docs/DesignUI/`

## Estructura real

```text
apps/
  admin_next/        Next.js 15 admin panel
  mobile_flutter/    Flutter mobile shell + local-first product logic
services/
  ai_gateway/        FastAPI AI gateway
  web_backend/       FastAPI operational backend
packages/
  contracts/         JSON schemas compartidos
.github/workflows/
  ci.yml             Monorepo CI
```

## Stack detectado

- Mobile: Flutter 3.41.7 / Dart 3.11.5
- AI Gateway: Python 3.14.2 + FastAPI + LangGraph/LangChain
- Web backend: Python 3.14.2 + FastAPI
- Admin: Next.js 15.5.15 + React 19 + TypeScript 5.8

## Estado real frente al roadmap

Ya existe y está implementado:

- Persistencia local fuerte con SQLite, cifrado sensible y fallback resiliente en `apps/mobile_flutter`
- Capture libre con confirmación y parseo multi-item
- Home Today con 3 misiones, evidencia, incertidumbre y fallback local
- Privacy dashboard con permisos por dominio, export JSON local y delete all
- CRUD local para Task/Habit/Money/Pantry/Closet/Week/Journal/Calendar/Recipes
- AI gateway con consent filtering, guardrails y trazabilidad por nodos
- Backend operacional con auditoría, usage, missions, feedback y safety
- Admin panel con build productivo, lint y typecheck
- CI monorepo en `.github/workflows/ci.yml`

Sigue abierto o incompleto:

- `services/ai_gateway` tiene una suite `tests/test_api.py` demasiado lenta en este entorno local Python 3.14
- Los contratos de `packages/contracts` no gobiernan todavía de forma canónica a gateway/backend
- Export/delete admin no ejecuta jobs reales de export o borrado
- No hay `correlation_id` end-to-end consistente gateway -> backend -> admin
- El `README` de `apps/mobile_flutter` estaba desalineado con el estado actual

## Cambios ejecutados en esta fase

- Se añadió delete por entidad en el móvil:
  - storage interface
  - memory/shared prefs/sqlite/resilient stores
  - controller
  - editors de dominio
  - tests de controller y SQLite
- Se alineó la localización para la acción de borrar por entidad
- Se actualiza la documentación de auditoría y comandos

## Validación ejecutada

### Mobile Flutter

- `flutter pub get` -> OK
- `flutter gen-l10n` -> OK con warnings de traducciones faltantes ya existentes
- `flutter analyze` -> OK
- `flutter test` -> OK (`35` tests)

### Web backend

- `python -m pytest` en `services/web_backend` -> OK (`21 passed`)

### Admin Next

- `npm run lint` -> OK
- `npm run typecheck` -> OK
- `npm run build` -> OK

### AI gateway

- `python -m pytest tests/test_openrouter_routing.py -q` -> OK (`3 passed`)
- `python -m pytest tests/test_openrouter_normalization.py -q` -> OK (`4 passed`)
- `python -m pytest tests/test_daily_mission_graph.py -q` -> OK (`4 passed`)
- `python -m pytest tests/test_api.py` -> no terminó en el timeout local usado; se trata como riesgo de rendimiento/compatibilidad local, no como fallo funcional confirmado

## Riesgos críticos detectados

- `mission_audit_records` en backend parece vulnerable a colisión por `mission_id` reutilizado entre usuarios/sesiones
- El gateway puede degradarse mal si routing control fuerza OpenRouter sin key local resoluble
- La telemetría del parse semántico no queda categorizada de forma consistente
- El feedback learning del gateway sigue siendo local por archivo, no compartido con el backend operacional

## Secretos y archivos sensibles

- Se detectó existencia de `.env` en `services/ai_gateway`
- No se leyó contenido de `.env` ni de archivos de credenciales

## Siguiente fase recomendada

1. Corregir bugs operacionales del backend/gateway detectados en auditoría
2. Formalizar contratos canónicos compartidos
3. Convertir export/delete admin en jobs reales
4. Reducir tiempo de la suite `services/ai_gateway/tests/test_api.py` para CI/local
