# 19 — Acceptance Criteria

## AC-001 Capture Inbox

Dado texto libre con múltiples obligaciones, cuando el usuario pulsa Parse, entonces la app muestra múltiples drafts editables.

## AC-002 Privacy

Dado un draft marcado local-only, cuando se genera una decisión, entonces ese dato no aparece en payload IA.

## AC-003 DecisionCard

Dada una decisión generada, entonces debe mostrar título, acción, evidencia, confianza, incertidumbre, privacidad y confirmación.

## AC-004 Confirmation

Dada cualquier decisión, cuando el usuario no confirma, entonces no se crea acción final ni recordatorio ni lista.

## AC-005 EcoShop no evidence

Dada una compra sugerida sin fuente externa, entonces la UI muestra `insufficient verified data`.

## AC-006 No best price

Dado que no hay fuente de precio, entonces ninguna respuesta puede decir “mejor precio” o equivalente.

## AC-007 HomeMemory

Dado un objeto con garantía próxima, entonces se crea o propone un MentalLoadItem/DecisionCard.

## AC-008 Offline

Dado gateway caído, cuando el usuario captura texto, entonces la app guarda localmente y genera fallback.

## AC-009 Admin

Dado el dashboard admin, entonces muestra métricas agregadas sin texto personal crudo.

## AC-010 Release

Dado el build final, entonces tests, privacy, no-claim, fallback y migración deben pasar.
