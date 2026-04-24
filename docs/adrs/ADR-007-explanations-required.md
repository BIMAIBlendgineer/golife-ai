# ADR-007 — Toda sugerencia requiere explicación

## Estado
Aceptado.

## Contexto
Una IA que da órdenes sin justificar pierde confianza.

## Decisión
Toda `AISuggestion` debe incluir evidencia, incertidumbre y acción sugerida.

## Consecuencias
- Más coste de tokens.
- Mejor confianza.
- Mejor depuración.
