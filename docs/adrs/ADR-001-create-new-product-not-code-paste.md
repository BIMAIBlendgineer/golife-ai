# ADR-001 — Crear producto nuevo, no pegar repositorios

## Estado
Aceptado.

## Contexto
Los repositorios base tienen stacks, licencias y arquitecturas distintas.

## Decisión
Crear **GoLife AI** como producto nuevo. Mantener repositorios en `source_repos/` y migrar por dominios.

## Consecuencias
- Menos deuda técnica.
- Mayor tiempo inicial.
- Mejor coherencia.
- Permite auditar licencias y dependencias antes de copiar código.
