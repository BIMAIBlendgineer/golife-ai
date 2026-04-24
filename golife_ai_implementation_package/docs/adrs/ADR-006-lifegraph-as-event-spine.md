# ADR-006 — LifeGraph como columna vertebral

## Estado
Aceptado.

## Contexto
La unión real no ocurre por UI, sino por datos transversales.

## Decisión
Todo dominio emite `LifeEvent`.

## Consecuencias
- La IA analiza eventos normalizados.
- Los dominios permanecen desacoplados.
- Se pueden crear patrones multi-dominio.
