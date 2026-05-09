# ADR-003 — Privacy-before-AI

## Estado

Aprobado.

## Contexto

GoLife ya implementa `filter_ai_events`, `PrivacySettings`, `PrivacyLevel` y dominios permitidos.

## Decisión

Todo payload IA debe pasar por filtro de privacidad antes de salir del dispositivo o del contexto local.

## Invariantes

```text
local_only → nunca IA
sync_allowed → puede sincronizar metadata si usuario permite, no IA
ai_allowed → puede enviarse a IA si dominio permitido
```

## Consecuencias positivas

- Diferencial de mercado.
- Reduce riesgo de datos sensibles.
- Permite explicación transparente.

## Consecuencias negativas

- Algunas recomendaciones serán menos precisas.
- La UI debe explicar “datos bloqueados”.

## Regla

Ningún endpoint nuevo puede aceptar datos sin `PrivacySettings`.
