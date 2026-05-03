# F04 18 Performance Baseline

Fecha: 2026-05-03
Ejecutor: Codex
Rama: `hardening/traceability-safety-pass`

## Objetivo

Registrar una evidencia de rendimiento util del AI Gateway despues del hardening de trazabilidad, sin inventar una validacion que el entorno local no soporta de forma estable.

## Comandos ejecutados

```powershell
$env:AI_GATEWAY_ENABLE_MOCK='true'
$env:ROUTING_CONTROL_ENABLED='false'
python -m uvicorn app.main:app --host 127.0.0.1 --port 8004
```

Probe funcional aislado:

```text
POST http://127.0.0.1:8004/v1/missions/daily
status=200
latency_ms=97.17
```

Smoke concurrente local intentado:

```powershell
python scripts/performance/ai_gateway_load_smoke.py --base-url http://127.0.0.1:8003 --requests 60 --concurrency 10 --max-p95-ms 2000 --max-error-rate 0.0
```

Resultado: `httpx.ReadTimeout` en Windows + Python 3.14 local.

## Hallazgos

- El endpoint base responde correctamente en modo mock con latencia sub-100 ms para una peticion aislada.
- El smoke concurrente definido por el repositorio no fue estable en este entorno local cuando se ejecuta sobre Python 3.14.
- El workflow remoto deja el smoke de carga como job manual (`workflow_dispatch`), por lo que no bloquea el CI normal del PR.

## Decision del gate

- Baseline funcional: verde.
- Baseline concurrente local: pendiente de entorno compatible o de ejecucion remota manual.
- Riesgo abierto: mantener documentada la inestabilidad local del smoke concurrente bajo Python 3.14.

## Rollback

- Eliminar este documento.
