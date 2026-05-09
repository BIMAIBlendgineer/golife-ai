# 18 — Risk Register

| ID | Riesgo | Severidad | Mitigación |
|---|---|---:|---|
| R01 | Dato local_only enviado a IA | Alta | Tests privacy + guardrail + payload audit |
| R02 | EcoShop hace claim sin fuente | Alta | no-claim guardrail |
| R03 | Migración SQLite borra datos | Alta | tests v4→v5 + backup |
| R04 | UI se vuelve compleja | Media | Today simple, details en sheet |
| R05 | Controller crece demasiado | Media | servicios internos y mappers |
| R06 | Fallback local pobre | Media | reglas mínimas para decision/shopping |
| R07 | Admin expone texto sensible | Alta | metadata only |
| R08 | Shopping parece marketplace falso | Media | V1 local-only shopping intelligence |
| R09 | Usuario interpreta IA como consejo financiero | Alta | disclaimers y bloqueo |
| R10 | Usuario interpreta reflection como terapia | Alta | safety guardrails |
| R11 | External sources legales | Alta | feature flag off en V1 |
| R12 | i18n incompleto | Media | fallback visible |
| R13 | Model routing caro | Media | capabilities separadas |
| R14 | Feedback loops sesgados | Media | trace + reset |
| R15 | Product scope creep | Alta | roadmap por fases |
