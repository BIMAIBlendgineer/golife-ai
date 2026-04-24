# ADR-018 — Sin IA silenciosa sobre datos sensibles

## Estado
Aceptado.

## Contexto
La app procesa finanzas, rutinas y comida.

## Decisión
La IA solo analiza datos de dominios con permiso `ai_allowed` y debe mostrar estado de análisis.

## Consecuencias
- Privacidad fuerte.
- Menos magia.
- Mejor aceptación para usuarios técnicos.
