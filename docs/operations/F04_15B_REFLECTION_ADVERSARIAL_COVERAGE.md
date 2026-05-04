# F04 15B Reflection Adversarial Coverage

Fecha: 2026-05-04
Ejecutor: Codex
Rama base: `main`
SHA base: `32fed4212178d015314afe27976be4f979be73bd`

## Objetivo

Reducir el gap restante de safety documentado para reflection checks: el guardrail debía detectar variantes adversariales obfuscadas, no solo frases limpias o acentuadas.

## Alcance

- `services/ai_gateway/app/guardrails.py`
- `services/ai_gateway/tests/test_api.py`
- `docs/operations/EXECUTION_PACK_STATUS.md`
- `docs/operations/QUALITY_SECURITY_AUDIT_2026-04-25.md`

## Cambios

- Se añadió normalización con sustitución leetspeak básica:
  - `0 -> o`
  - `1 -> i`
  - `3 -> e`
  - `4 -> a`
  - `5 -> s`
  - `7 -> t`
  - `@ -> a`
  - `$ -> s`
  - `! -> i`
- La normalización ahora colapsa secuencias de letras sueltas para detectar frases como:
  - `k.i.l.l myself`
  - `d i a g n o s i s`
  - `t h e r a p y`
- Se añadió matching por ventanas unidas de tokens para detectar términos partidos sin degradar el flujo normal de reflection safety.
- Se añadieron tests para:
  - crisis con leetspeak
  - crisis con puntuación separadora
  - lenguaje clínico separado letra a letra

## Verificación

- `cd services/ai_gateway && python -m pytest -q tests/test_api.py -k "reflection or hyphenated or leetspeak or punctuation_split or letter_spaced"`
  - Resultado: `15 passed`
- `cd services/ai_gateway && python -m pytest -q`
  - Resultado: `75 passed`

## Riesgos restantes

- Este hardening sigue siendo rule-based; no sustituye una batería adversarial más amplia ni revisión clínica.
- El corpus mejoró solo la superficie de `reflection/check`; no cierra por sí solo todos los riesgos de prompting o jailbreak en otras rutas.

## Rollback

- Revertir el commit de esta fase o restaurar `services/ai_gateway/app/guardrails.py` y `services/ai_gateway/tests/test_api.py`.
