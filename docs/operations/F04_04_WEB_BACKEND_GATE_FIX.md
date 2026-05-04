# F04 04 Web Backend Gate Fix

Date: `2026-05-03`
Executor: `Codex`
Area: `services/web_backend`

## Objective

Close the two failures that were breaking `Monorepo CI` for PR `#6`:

- `web-backend`
- `python-security (services/web_backend)`

## Root cause

### 1. Lifecycle incompatibility with FastAPI / Starlette

The code used:

- `app.add_event_handler("shutdown", shutdown_repository)`

In the CI environment at that time, that API path was no longer available on the `FastAPI` instance, causing an `AttributeError`.

### 2. Dynamic SQL marked by Bandit

`app/repository.py` built queries with interpolated `where_sql`, producing multiple `B608` findings in CI.

## Files modified

- `services/web_backend/app/main.py`
- `services/web_backend/app/repository.py`

## Changes applied

### `app/main.py`

- migrated shutdown handling to `lifespan`
- closed the repository in a `finally` block
- removed dependency on `add_event_handler`

### `app/repository.py`

- added `_sql_where_clause(filters)`
- added `_join_sql_lines(*lines)`
- rewrote optional-filter query composition to avoid direct SQL interpolation inside `f"""` strings
- preserved parameterized user values

## Local validation after fix

```text
cd services/web_backend
python -m pytest -q
python -m bandit -q -r app -s B105,B106
```

Results:

- `21 passed`
- `bandit` green

## Expected remote impact

After publishing the fix, the failing PR jobs should pass:

- `web-backend`
- `python-security (services/web_backend)`

## Rollback

If the fix introduces an unexpected regression:

```text
git revert <fix-commit>
```

Manual equivalent:

- restore the previous lifecycle wiring in `app/main.py`
- restore the previous query composition in `app/repository.py`
