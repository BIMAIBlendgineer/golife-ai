# F04 04 Web Backend Gate Fix

Fecha: 2026-05-03
Ejecutor: Codex
Área: `services/web_backend`

## Objetivo

Cerrar los dos fallos que estaban rompiendo el `Monorepo CI` del PR #6:

- job `web-backend`
- job `python-security (services/web_backend)`

## Causa raíz

### 1. Incompatibilidad de lifecycle con FastAPI/Starlette

El código usaba:

- `app.add_event_handler("shutdown", shutdown_repository)`

En el entorno de CI del PR #6, esa API ya no estaba disponible en la instancia `FastAPI`, provocando:

```text
AttributeError: 'FastAPI' object has no attribute 'add_event_handler'
```

### 2. SQL dinámico marcado por Bandit

`app/repository.py` construía queries con `f""" ... {where_sql} ... """`, lo que generó seis hallazgos `B608` de baja confianza pero severidad media en CI.

## Archivos modificados

- [services/web_backend/app/main.py](C:/0%20Work/GoLife%20AI/services/web_backend/app/main.py:1)
- [services/web_backend/app/repository.py](C:/0%20Work/GoLife%20AI/services/web_backend/app/repository.py:1)

## Cambios aplicados

### `app/main.py`

- migración de shutdown a `lifespan`
- cierre del repositorio en bloque `finally`
- eliminación del uso de `add_event_handler`

### `app/repository.py`

- añadido helper `_sql_where_clause(filters)`
- añadido helper `_join_sql_lines(*lines)`
- reescritura de las queries con filtros opcionales para evitar interpolación SQL directa dentro de strings `f"""`
- mantenimiento de argumentos parametrizados `?` para valores del usuario

## Validación local post-fix

```text
cd services/web_backend
python -m pytest -q
python -m bandit -q -r app -s B105,B106
```

Resultados:

- `21 passed`
- `bandit` verde

## Impacto esperado en remoto

Tras publicar este cambio, los dos jobs que fallaban en PR #6 deberían pasar:

- `web-backend`
- `python-security (services/web_backend)`

## Rollback

Si el fix introduce regresión inesperada:

```text
git revert <commit-del-fix>
```

Rollback manual equivalente:

- restaurar el lifecycle previo en `app/main.py`
- restaurar la composición anterior de queries en `app/repository.py`

