# ADR-009 — Privacidad por dominio

## Estado
Aceptado.

## Contexto
Finanzas, despensa, ropa y tareas tienen sensibilidad distinta.

## Decisión
Cada dominio define permisos:

- local_only;
- sync_allowed;
- ai_allowed.

## Consecuencias
- Usuario controla qué datos ve la IA.
- Implementación más compleja.
- Diferenciación fuerte del producto.
