# AI Store Claims Review

Date: `2026-05-08`
Branch: `release/play-store-readiness`
Phase: `9`
Status: `store-safe wording defined`

## Goal

Align product wording, store copy, and runtime posture with the repo's current AI safety boundary.

## Repo evidence reviewed

- `docs/security/SAFETY_POLICY.md`
- `docs/compliance/SAFETY_REVIEW.md`
- `services/ai_gateway/app/policy_engine.py`
- `services/ai_gateway/app/graphs/golife_graph.py`
- `docs/operations/RELEASE_RISK_REGISTER.md`

## Allowed product framing

- AI-assisted daily planning
- three realistic daily missions
- privacy-filtered suggestions
- supportive reflection and organization help
- local-first capture and decision support
- evidence-backed mission suggestions

## Blocked or forbidden framing

- medical diagnosis
- treatment recommendations
- therapy substitute
- legal advice
- regulated financial advice
- guaranteed outcomes
- enterprise-ready identity
- jailbreak-proof safety

## Engineering posture behind the copy

- safety enforcement is centralized and versioned
- the current policy engine is rule-based
- blocked categories include crisis, clinical framing, regulated finance, legal advice, prompt-injection attempts, and secret exposure
- mission outputs are reviewed before leaving the gateway

## Play policy interpretation

Inference from official Google Play AI guidance:

- GoLife AI is safer to present as an AI-assisted productivity app, not as an open-ended generative chatbot.
- Even if some features may fit the limited-scope productivity exception discussed in Play guidance, the app should still keep visible user feedback and reporting mechanisms for AI results.

This inference is based on the current product shape and must not be presented as a legal guarantee.

## Repo-backed user feedback surfaces

- mission feedback in mobile
- quality and safety operational views in admin
- privacy and support flows already documented in ops docs

## Required wording for future copy

Use phrases like:

- "AI-assisted"
- "suggests"
- "helps you review"
- "evidence-backed"
- "local-first"

Avoid phrases like:

- "diagnoses"
- "treats"
- "advises on law"
- "advises on investments"
- "guarantees"
- "enterprise secure"

## Gate decision

- Claims review gate: passed
- Store copy gate: depends on Phase 12 using this wording
