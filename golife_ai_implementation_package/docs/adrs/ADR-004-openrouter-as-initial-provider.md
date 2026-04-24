# ADR-004 — OpenRouter como proveedor inicial

## Estado
Aceptado.

## Contexto
Se necesita iniciar rápido y poder cambiar de modelo.

## Decisión
Usar OpenRouter inicialmente mediante una interfaz `LLMProvider`.

## Consecuencias
- Un solo endpoint para múltiples modelos.
- Posible fallback.
- No atar la app a un proveedor.
- Mantener compatibilidad con SDK tipo OpenAI cuando sea posible.
