# ADR-001 — MindFlow Core como núcleo de GoLife AI

## Estado

Aprobado.

## Contexto

GoLife AI ya contiene:

- LifeGraph
- misiones diarias
- captura
- privacidad
- feedback
- dominios de vida diaria
- AI Gateway

Crear MindFlow como app separada duplicaría arquitectura y datos.

## Decisión

Implementar MindFlow como núcleo interno:

```text
GoLife AI → MindFlow Core
```

## Consecuencias positivas

- Reutiliza código existente.
- Reduce fragmentación.
- Mejora posicionamiento de producto.
- Mantiene local-first.
- Facilita monetización por planes.

## Consecuencias negativas

- Requiere reorganización UI.
- Aumenta responsabilidad de `GoLifeController`.
- Exige migración de contratos y storage.

## Regla

No crear repositorio separado para MindFlow en V1.
