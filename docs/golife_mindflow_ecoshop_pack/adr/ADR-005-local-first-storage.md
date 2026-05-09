# ADR-005 — Local-first storage SQLite v5

## Estado

Aprobado.

## Contexto

GoLife usa SQLite local, almacenamiento resiliente y cifrado para blobs sensibles.

## Decisión

Subir SQLite a versión 5 y agregar tablas:

```text
mental_load_items
decision_cards
shopping_needs
product_evidence_cards
```

## Regla

`mental_load_items` y `decision_cards` deben cifrarse si contienen payload sensible.

## Consecuencias positivas

- Funciona offline.
- Mantiene privacidad.
- Permite fallback local.

## Consecuencias negativas

- Migración debe ser cuidadosamente probada.
- Admin no tendrá acceso completo a datos locales.
