# ADR-004 — Evidence Cards

## Estado

Aprobado.

## Contexto

GoLife ya usa evidencia en `AISuggestion` y ranking. EcoShop requiere evidencia más fuerte para precio, producto y sostenibilidad.

## Decisión

Crear `DecisionCard` y `ProductEvidenceCard`.

## Regla

Toda recomendación visible debe mostrar:

- evidencia usada
- incertidumbre
- confianza
- privacidad
- confirmación requerida

## Para EcoShop

Toda recomendación de compra debe declarar:

```text
source
checked_at
confidence
sustainability_status
disclaimer
```

Si no hay datos:

```text
sustainability_status = insufficient_verified_data
```

## Consecuencia

Se evita marketing falso y se refuerza confianza.
