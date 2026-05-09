# 11 — Privacy, Safety and Evidence

## 1. Reglas centrales

```text
Privacy-before-AI
Evidence-before-claim
Human-confirmation-before-action
```

## 2. Datos sensibles por defecto

```text
JournalEntry
QuickNote
ExpenseRecord
PurchaseProof
ClaimDraft
EvidenceAttachment
CalendarItem
HomeMemory details
```

## 3. Niveles

```text
local_only
sync_allowed
ai_allowed
```

## 4. Reglas de AI payload

| Nivel | Sale a IA |
|---|---:|
| local_only | No |
| sync_allowed | No, salvo metadata operacional autorizada |
| ai_allowed | Sí, si dominio permitido |

## 5. Claims EcoShop

### Permitido sin fuente externa

```text
Usa primero lo que ya tienes.
Puedes crear una lista local.
No puedo verificar precio o sostenibilidad.
```

### Prohibido sin fuente

```text
Es el más barato.
Está disponible.
Es sostenible.
Es mejor para el ambiente.
Tiene certificación.
```

## 6. Product Evidence Status

```text
not_checked
insufficient_verified_data
partial
verified
```

## 7. Safety surfaces

Aplicar guardrails a:

```text
capture
mindflow_parse
decision_plan
task_rewrite
proof_parse
shopping_plan
reflection
```

## 8. Crisis/clinical content

Mantener bloqueo/redirect de contenido clínico o crisis. El sistema no debe actuar como terapia ni diagnóstico.

## 9. Financial boundary

GoLife puede:

```text
ayudar a reflexionar gasto
mostrar presupuesto local
sugerir pausar compra
```

No puede:

```text
dar consejo financiero regulado
invertir
prometer ahorro
```

## 10. Shopping boundary

GoLife puede:

```text
crear lista
sugerir usar pantry
comparar con datos locales
mostrar evidencia insuficiente
```

No puede en V1:

```text
comprar automáticamente
garantizar mejor precio
garantizar disponibilidad
certificar sostenibilidad
```

## 11. Evidence explanation UI

Cada decision debe responder:

```text
¿Por qué esto?
¿Qué datos usó?
¿Qué datos bloqueó?
¿Qué no sabe?
¿Qué acción requiere confirmación?
```

## 12. Release blockers

- [ ] Claim sin fuente.
- [ ] Dato local_only en payload IA.
- [ ] Acción externa sin confirmación.
- [ ] Admin muestra texto sensible crudo.
- [ ] Fallback inexistente.
