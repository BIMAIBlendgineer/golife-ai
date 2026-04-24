# ADR-013 — Abstracción de proveedor IA

## Estado
Aceptado.

## Contexto
El usuario quiere iniciar con OpenRouter pero poder cambiar proveedor.

## Decisión
Definir interfaz:

```python
class LLMProvider:
    async def complete(self, request): ...
```

Implementaciones:

- OpenRouterProvider;
- OpenAIProvider futuro;
- AnthropicProvider futuro;
- LocalModelProvider futuro.

## Consecuencias
- Menos lock-in.
- Más pruebas necesarias.
