# F03 AI Gateway Production Runtime Closeout

Fecha: 2026-05-04
Rama: `hardening/f03-ai-gateway-production-runtime`
SHA base: `e186be3e648cf0775f8077148d93fbb86980a527`
Commit F03: el commit de cierre se crea en esta rama con el mensaje `hardening: close ai gateway production runtime anti-mock`

## Objetivo

Cerrar el riesgo de mock o fallback silencioso en el AI Gateway y validar IA real en runtime production local sin exponer secretos.

## Cambios

- Production validator anti-mock en `services/ai_gateway/app/settings.py`
- Provider factory sin ruta `production -> MockLLMProvider`
- OpenRouterProvider sin mock interno en production
- `/ready` production-aware en `services/ai_gateway/app/main.py`
- Observabilidad normalizada:
  - `effective_routing_mode`
  - `effective_config_source`
  - `active_key_source`
  - `control_plane_config_source`
- Test mobile que fija visibilidad de fallback degradado

## Archivos modificados

- `services/ai_gateway/app/main.py`
- `services/ai_gateway/app/settings.py`
- `services/ai_gateway/app/providers/factory.py`
- `services/ai_gateway/app/providers/openrouter.py`
- `services/ai_gateway/tests/test_api.py`
- `services/ai_gateway/tests/test_openrouter_normalization.py`
- `services/ai_gateway/tests/test_openrouter_routing.py`
- `apps/mobile_flutter/test/golife_app_test.dart`

## Smoke production local

Configuracion usada para la validacion local:

- `AI_GATEWAY_ENV=production`
- `AI_GATEWAY_ENABLE_MOCK=false`
- `LLM_PROVIDER=openrouter`
- `ROUTING_CONTROL_ENABLED=false`
- `OPERATIONAL_BACKEND_ENABLED=false` para este smoke local

Resultados:

- `/health`: `200`
  - `active_provider=openrouter`
  - `mock_mode=false`
  - `routing_mode=local_env_fallback`
  - `effective_routing_mode=single_key`
  - `config_source=local_env`
  - `effective_config_source=local_env`
  - `control_plane_config_source=fallback`
  - `active_key_source=local_env`
- `/ready`: `200`
  - `environment=production`
  - `status=ready`
  - `production_ready=true`
  - `effective_routing_mode=single_key`
- `POST /v1/missions/daily`: `200`
  - `provider=openrouter`
  - `model=google/gemini-2.0-flash-001`
  - `suggestions=3`
  - `mock=false`
  - `fallbackReason` ausente
  - `clientFallback` ausente

## Resultados

- mock encontrado: no
- fallback encontrado: no
- observabilidad health/request: coherente para estrategia single-key local
- secretos expuestos: no

## Gates

- `services/ai_gateway`: `python -m pytest -q` -> `72 passed`
- `apps/mobile_flutter`: `flutter analyze` -> verde
- `apps/mobile_flutter`: `flutter test` -> verde
- `apps/admin_next`: `npm run lint` -> verde
- `apps/admin_next`: `npm run typecheck` -> verde
- `apps/admin_next`: `npm run build` -> verde
- `gitleaks git` -> `no leaks found`

## Configuracion requerida para deploy production

El despliegue real debe replicar externamente, sin commitear secretos:

- `AI_GATEWAY_ENV=production`
- `AI_GATEWAY_ENABLE_MOCK=false`
- `LLM_PROVIDER=openrouter`
- `OPENROUTER_API_KEY` presente
- `ROUTING_CONTROL_ENABLED=false` para estrategia single-key

Alternativa permitida:

- `ROUTING_CONTROL_ENABLED=true` solo si existe control-plane real con `ROUTING_BACKEND_INTERNAL_TOKEN` no dev y configuracion live verificable

## Riesgos restantes

- El deploy real debe replicar la configuracion externa validada localmente.
- `OPERATIONAL_BACKEND_ENABLED=false` fue correcto para smoke local; si se habilita en produccion real necesita backend operativo vivo.
- La estrategia validada aqui es single-key; el control-plane multi-key queda fuera de este cierre si no hay backend real disponible.
- Persisten warnings upstream de FastAPI y `langchain_core` bajo Python 3.14+; no bloquean F03.

## Rollback

- Revertir el commit F03 en esta rama o cerrar el PR sin merge.
- Restaurar la configuracion externa previa del deploy.
