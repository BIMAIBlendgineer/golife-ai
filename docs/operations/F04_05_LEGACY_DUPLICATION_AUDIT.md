# F04 05 Legacy Duplication Audit

Fecha: 2026-05-03
Ejecutor: Codex
Objetivo: determinar si `golife_ai_business_roadmap_package/ai-gateway-skeleton` participa en runtime o sólo conserva valor documental.

## Alcance auditado

- `golife_ai_business_roadmap_package/`
- referencias repo-wide a `golife_ai_business_roadmap_package` y `ai-gateway-skeleton`
- manifiesto legacy:
  - [golife_ai_business_roadmap_package/ai-gateway-skeleton/pyproject.toml](C:/0%20Work/GoLife%20AI/golife_ai_business_roadmap_package/ai-gateway-skeleton/pyproject.toml:1)

## Hallazgos

### 1. El skeleton sigue siendo ejecutable como paquete Python

El árbol legacy contiene:

- `app/`
- `tests/`
- `pyproject.toml`
- `.env.example`

Eso significa que no es sólo documentación; técnicamente puede ejecutarse y confundirse con el gateway real.

### 2. No hay referencias runtime activas desde el producto actual

La búsqueda repo-wide sólo encontró referencias en:

- [README_START_HERE.md](C:/0%20Work/GoLife AI/README_START_HERE.md:125)
- [golife_ai_business_roadmap_package/ROADMAP.md](C:/0%20Work/GoLife AI/golife_ai_business_roadmap_package/ROADMAP.md:84)
- [golife_ai_business_roadmap_package/AI_API.md](C:/0%20Work/GoLife AI/golife_ai_business_roadmap_package/AI_API.md:54)
- docs de auditoría F04 recién añadidas

No se encontraron imports ni rutas de CI que apunten a ese skeleton.

### 3. Existe conflicto documental interno

- el README raíz declara que el runtime productivo único es `services/ai_gateway`
- `golife_ai_business_roadmap_package/AI_API.md` todavía afirma que la fuente de verdad runtime vive en `ai-gateway-skeleton/app/schemas.py`

Esa afirmación ya no es válida para el producto activo.

## Clasificación

- estado: `legacy executable reference`
- riesgo actual: `medio`
- riesgo principal: confusión de fuente de verdad y mantenimiento duplicado
- riesgo runtime directo: `bajo`, porque CI y manifests activos no lo usan

## Decisión

- no borrar en esta fase
- mantener en cuarentena documental
- tratar `services/ai_gateway` como única implementación runtime válida
- corrección ejecutada en esta fase:
  - [golife_ai_business_roadmap_package/AI_API.md](C:/0%20Work/GoLife%20AI/golife_ai_business_roadmap_package/AI_API.md:54) dejó de declarar al skeleton como source-of-truth runtime
- plan recomendado posterior:
  - marcar explícitamente el skeleton como `archived reference only`
  - evaluar si conviene mover el paquete legacy a `docs/archive/` o excluirlo de futuros audits de runtime
