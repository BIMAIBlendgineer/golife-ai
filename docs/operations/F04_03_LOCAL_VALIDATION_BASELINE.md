# F04 03 Local Validation Baseline

Fecha: 2026-05-03
Ejecutor: Codex
Objetivo: reproducir localmente los gates reales del monorepo y aislar rojos reproducibles.

## Resultado resumido

| Superficie | Gate | Estado | Notas |
| --- | --- | --- | --- |
| `services/web_backend` | `python -m pytest -q` | Verde | `21 passed` |
| `services/web_backend` | `python -m bandit -q -r app -s B105,B106` | Verde | sólo quedan dos `nosec` ya aceptados |
| `services/ai_gateway` | `python -m bandit -q -r app -s B105,B106` | Verde | sin hallazgos bloqueantes |
| `services/ai_gateway` | `python -m pytest -q` | Parcial | la suite completa excede timeout local en Python 3.14 |
| `apps/admin_next` | `npm run lint` | Verde | sin warnings |
| `apps/admin_next` | `npm run typecheck` | Verde | OK |
| `apps/admin_next` | `npm run build` | Verde | build productivo OK |
| `apps/admin_next` | `npm audit --omit=dev --audit-level=high` | Verde con riesgo aceptado | 2 moderadas transitive `postcss` bajo `next`; sin high |
| `apps/mobile_flutter` | `flutter pub get` | Verde con ruido externo | dependencias resueltas; pub.dev devolvió errores de advisories decoding |
| `apps/mobile_flutter` | `flutter analyze` | Verde | sin issues |
| `apps/mobile_flutter` | `flutter test` | Verde | `44 passed` |

## Comandos ejecutados

### `services/web_backend`

```text
python -m pip install -e .[dev] bandit pip-audit
python -m pytest -q
python -m bandit -q -r app -s B105,B106
```

Resultados:

- `21 passed`
- `bandit` verde
- warnings deprecados de FastAPI bajo Python 3.14, no bloqueantes

### `services/ai_gateway`

```text
python -m pip install -e .[dev] bandit pip-audit
python -m bandit -q -r app -s B105,B106
python -m pytest tests/test_openrouter_routing.py -q
python -m pytest tests/test_openrouter_normalization.py -q
python -m pytest tests/test_daily_mission_graph.py -q
python -m pytest tests/test_api.py -q
```

Resultados:

- `bandit` verde
- `tests/test_openrouter_routing.py`: `3 passed`
- `tests/test_openrouter_normalization.py`: `4 passed`
- `tests/test_daily_mission_graph.py`: no terminó dentro del timeout local
- `tests/test_api.py`: no terminó dentro del timeout local

Interpretación:

- el gateway ya pasó en CI remoto para PR #6 con Python 3.12
- la máquina local sólo tiene Python 3.14 y 3.15 alpha disponibles
- la combinación actual de `langchain_core`/`langgraph` emite warnings explícitos de compatibilidad con Python 3.14+
- por tanto, el rojo local del gateway se clasifica como `toolchain drift / performance incompatibility`, no como fallo funcional remoto confirmado

### `apps/admin_next`

```text
npm run lint
npm run typecheck
npm run build
npm audit --omit=dev --audit-level=high
```

Resultados:

- `lint`: OK
- `typecheck`: OK
- `build`: OK
- `npm audit`: sin high; permanece riesgo moderado transitivo de `postcss` dependiente de `next`

### `apps/mobile_flutter`

```text
flutter pub get
flutter analyze
flutter test
```

Resultados:

- `flutter pub get`: OK, con fallo externo del endpoint de advisories de pub.dev
- `flutter analyze`: OK
- `flutter test`: `44 passed`

## Estado remoto correlacionado

Workflow run: `25280815331`

- `ai-gateway`: success
- `flutter`: success
- `admin-next`: success
- `web-backend`: failure
- `python-security (services/web_backend)`: failure

Conclusión:

- el único rojo reproducible que estaba bloqueando el gate remoto de PR #6 estaba en `services/web_backend`
- ese rojo se convirtió en F04 fix quirúrgico

## Riesgos abiertos

- no existe Python 3.12 instalado localmente; la validación del gateway no replica exactamente CI
- `pip-audit` en esta máquina no es autoridad fiable fuera de un entorno limpio porque la instalación de usuario contiene paquetes ajenos al servicio
- `next lint` ya avisa de deprecación hacia Next 16; no bloquea el release actual

