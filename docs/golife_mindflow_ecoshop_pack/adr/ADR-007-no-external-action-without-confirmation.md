# ADR-007 — No external action without confirmation

## Estado

Aprobado.

## Decisión

Toda acción que cambie estado, cree recordatorio, genere lista, cree claim, compre o comparta datos debe requerir confirmación humana.

## Regla

`confirmation_required=true` en `DecisionCard`, `ShoppingNeed` y `AISuggestion`.

## Bloqueador

Cualquier test que detecte acción externa sin confirmación bloquea release.
