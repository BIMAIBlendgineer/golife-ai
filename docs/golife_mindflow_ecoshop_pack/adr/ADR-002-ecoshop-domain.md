# ADR-002 — EcoShop como dominio interno

## Estado

Aprobado.

## Contexto

EcoShop tiene valor pero depende de datos externos para precio, disponibilidad y sostenibilidad. GoLife ya posee dominios relacionados: pantry, finance, wardrobe, recipes y HomeMemory.

## Decisión

Implementar EcoShop como dominio interno:

```text
GoLife AI → EcoShop Domain
```

No crear app independiente en V1.

## Consecuencias positivas

- Permite validar valor con datos locales.
- Evita scraping prematuro.
- Reutiliza pantry, finance, wardrobe y HomeMemory.
- Reduce riesgo legal/comercial.

## Consecuencias negativas

- No ofrece comparación real-time en V1.
- Menor atractivo inicial si se comunica mal.

## Regla

V1 debe decir “shopping intelligence”, no “best price engine”.
