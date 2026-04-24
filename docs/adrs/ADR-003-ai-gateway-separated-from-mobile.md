# ADR-003 — AI Gateway separado

## Estado
Aceptado.

## Contexto
Poner claves de IA dentro de la app móvil es inseguro y dificulta cambiar proveedor.

## Decisión
Crear `services/ai_gateway` con FastAPI.

## Consecuencias
- Claves protegidas en servidor.
- Más infraestructura.
- Mejor trazabilidad.
- Permite LangGraph, logs, guardrails y fallback de proveedores.
