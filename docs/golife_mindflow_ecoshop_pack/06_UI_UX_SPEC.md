# 06 — UI/UX Spec

## 1. Principio de producto

La UI debe reducir carga mental, no añadir paneles complejos.

## 2. Nueva navegación principal

### Bottom nav propuesto

```text
Today
Capture
Decisions
Shopping
Memory
```

### Drawer / More

```text
Tasks
Habits
Week
Money
Pantry
Closet
Journal
Calendar
Recipes
Copilot
Privacy
Settings
```

## 3. Today Command Center

Ruta actual:

```text
/dashboard
```

Mantener ruta pero cambiar contenido visual.

### Bloques

```text
Mental Load Overview
Top Decision Card
Support Decisions
Shopping / Pantry Alert
Privacy / Evidence Footer
```

### Mental Load Overview

Mostrar:

```text
Open loops: N
Need decision: N
Can wait: N
Shopping needs: N
Blocked from AI: N
```

### Top Decision Card

Campos:

```text
Title
Recommended action
Why today
Confidence
Effort
Evidence count
Privacy status
Buttons:
- Do now
- Add reminder
- Postpone
- Explain
- Not useful
```

## 4. Capture Inbox v2

Ruta:

```text
/capture
```

### Comportamiento

El usuario pega texto libre:

```text
“mañana tengo que pagar internet, comprar leche, usar espinaca antes que venza y revisar garantía del portátil”
```

El sistema crea drafts:

```text
1. Reminder/payment → finance
2. Shopping need → pantry/shopping
3. Pantry rescue → pantry/recipe
4. Warranty review → homememory
```

### Draft card

```text
Detected item
Type
Domain
Suggested action
Privacy
Confidence
Reason
Edit / Remove / Confirm
```

### Botones

```text
Parse
Save selected
Save all
Mark all local-only
Allow AI for selected
```

## 5. Decisions screen

Nueva ruta:

```text
/decisions
```

### Tabs

```text
Today
Waiting
Shopping
Calendar
Home
Done
```

### Card states

```text
draft
shown
accepted
done
postponed
rejected
```

## 6. Shopping screen

Nueva ruta:

```text
/shopping
```

### Tabs

```text
Pantry first
Shopping list
Purchase intentions
Product evidence
Sustainability
```

### Pantry first

Reutilizar `PantryScreen`, pero con bloque superior:

```text
Use before buying
Potential waste avoided
Missing ingredients
```

### Shopping list

Cards:

```text
Item
Need source
Priority
Budget hint
Evidence status
Add/remove
```

### Product evidence

En V1 mostrar local/manual.

```text
No external source connected
Insufficient verified data
```

## 7. Memory screen

Ruta actual:

```text
/homememory
```

Mantener, pero agregar:

```text
Decision impact
Warranty decisions
Maintenance due
Claim candidates
```

## 8. Privacy UI

En `/settings` o Privacy:

Agregar sección:

```text
AI data permissions
├─ Tasks
├─ Calendar
├─ Pantry
├─ Shopping
├─ Money
├─ Journal
├─ HomeMemory
├─ Cross-domain decisions
```

Cada dominio:

```text
Local only
Sync allowed
AI allowed
```

## 9. Explain sheet

El explanation sheet actual ya muestra:

- evidencia
- datos usados
- datos enviados a IA
- datos bloqueados
- siempre local
- cifrado local
- incertidumbre
- trace

Mantener y extender para `DecisionCard`.

## 10. Mensajes de UI obligatorios

### EcoShop sin evidencia

```text
No puedo verificar precio, disponibilidad o sostenibilidad con datos actuales.
Puedes guardar esta necesidad como lista local.
```

### Privacidad bloqueada

```text
Parte del contexto no se usó porque está marcado como local-only.
```

### Acción externa

```text
GoLife no ejecutará esta acción sin tu confirmación.
```

## 11. Visual hierarchy

- Today debe ser simple.
- DecisionCard debe ser dominante.
- Evidence debe estar en sheet/detalle, no saturar card principal.
- Shopping debe evitar aspecto de marketplace en V1.
- Usar lenguaje “sugerido”, no “óptimo” ni “mejor”.
