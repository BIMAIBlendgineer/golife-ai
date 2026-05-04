# F04 05 Legacy Duplication Audit

Date: `2026-05-03`
Executor: `Codex`
Objective: determine whether `golife_ai_business_roadmap_package/ai-gateway-skeleton` participates in runtime or only preserves documentary value.

## Scope audited

- `golife_ai_business_roadmap_package/`
- repo-wide references to `golife_ai_business_roadmap_package` and `ai-gateway-skeleton`
- legacy manifest:
  - `golife_ai_business_roadmap_package/ai-gateway-skeleton/pyproject.toml`

## Findings

### 1. The skeleton was still technically executable

The legacy tree contained:

- `app/`
- `tests/`
- `pyproject.toml`
- `.env.example`

That means it was not just documentation; technically it could be run and confused with the real gateway.

### 2. There were no active runtime references from the current product

Repo-wide search found references only in:

- `README_START_HERE.md`
- `golife_ai_business_roadmap_package/ROADMAP.md`
- `golife_ai_business_roadmap_package/AI_API.md`
- F04 audit docs added during that phase

No imports or CI paths pointed to that skeleton.

### 3. Internal documentary conflict existed

- the root runtime docs stated that the only production gateway was `services/ai_gateway`
- `golife_ai_business_roadmap_package/AI_API.md` still claimed the old skeleton as runtime source of truth

That claim was no longer valid for the active product.

## Classification

- status: `legacy executable reference`
- current risk: `medium`
- main risk: source-of-truth confusion and duplicated maintenance
- direct runtime risk: `low`, because active CI and manifests did not use it

## Decision

- do not delete in that phase
- keep in documentation quarantine
- treat `services/ai_gateway` as the only valid runtime gateway
- correction executed then:
  - `golife_ai_business_roadmap_package/AI_API.md` stopped declaring the skeleton as runtime source of truth
- recommended next step:
  - mark the skeleton explicitly as archived reference only
  - consider moving or further quarantining it in future cleanup passes
