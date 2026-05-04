# F04 15B Reflection Adversarial Coverage

Date: `2026-05-04`
Executor: `Codex`
Base branch: `main`
Base SHA: `32fed4212178d015314afe27976be4f979be73bd`

## Objective

Reduce the remaining safety gap documented for reflection checks: the guardrail needed to detect obfuscated adversarial variants, not only clean or accented phrases.

## Scope

- `services/ai_gateway/app/guardrails.py`
- `services/ai_gateway/tests/test_api.py`
- `docs/operations/EXECUTION_PACK_STATUS.md`
- `docs/operations/QUALITY_SECURITY_AUDIT_2026-04-25.md`

## Changes

- Added normalization with basic leetspeak substitution:
  - `0 -> o`
  - `1 -> i`
  - `3 -> e`
  - `4 -> a`
  - `5 -> s`
  - `7 -> t`
  - `@ -> a`
  - `$ -> s`
  - `! -> i`
- Normalization now collapses sequences of spaced letters to detect phrases such as:
  - `k.i.l.l myself`
  - `d i a g n o s i s`
  - `t h e r a p y`
- Added joined-token matching to catch split terms without degrading the normal reflection flow.
- Added tests for:
  - crisis leetspeak
  - crisis punctuation splitting
  - clinical language spaced letter by letter

## Validation

- `cd services/ai_gateway && python -m pytest -q tests/test_api.py -k "reflection or hyphenated or leetspeak or punctuation_split or letter_spaced"`
  - result: `15 passed`
- `cd services/ai_gateway && python -m pytest -q`
  - result: `75 passed`

## Residual risks

- this hardening remains rule-based and does not replace a broader adversarial corpus or clinical review
- this closure improved only the `reflection/check` surface by itself; it did not close all prompting or jailbreak risks across other routes

## Canonical follow-up docs

- [Safety review](../compliance/SAFETY_REVIEW.md)
- [Safety policy](../security/SAFETY_POLICY.md)
- [F04 adversarial input surfaces](F04_26_ADVERSARIAL_INPUT_SURFACES.md)

## Rollback

- revert the commit for this phase or restore `services/ai_gateway/app/guardrails.py` and `services/ai_gateway/tests/test_api.py`
