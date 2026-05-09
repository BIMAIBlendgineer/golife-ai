# 17 — Data Model Map

## Actual → Nuevo

| Actual | Nuevo uso |
|---|---|
| LifeEvent | Fuente primaria de MentalLoadItem |
| DailyMission | Vista compatible de DecisionCard |
| DailyRisk | Factor de ranking para DecisionCard |
| MissionFeedback | Feedback para DecisionCard |
| GoTask | Dominio task |
| Habit | Dominio habit |
| ExpenseRecord | Dominio finance / shopping budget |
| PantryItem | Dominio pantry / shopping need |
| PurchaseIntention | Dominio wardrobe / shopping need |
| WeekPlan | Dominio week / planning |
| JournalEntry | Dominio journal, local-only por defecto |
| QuickNote | Dominio journal/note, local-only por defecto |
| CalendarItem | Dominio calendar / reminder |
| RecipeRescue | Dominio recipe / pantry-first |
| OwnedItem | HomeMemory / product ownership |
| PurchaseProof | Evidence source, sensitive |
| WarrantyRecord | Reminder + Decision source |
| MaintenanceReminder | MentalLoadItem source |
| ClaimDraft | HomeMemory action |
| EvidenceAttachment | Evidence source, sensitive |

## Nuevos modelos

| Nuevo | Depende de |
|---|---|
| MentalLoadItem | LifeEvent, CaptureDraft |
| DecisionCard | MentalLoadItem, DailyRisk, AISuggestion |
| ShoppingNeed | PantryItem, PurchaseIntention, ExpenseRecord, RecipeRescue |
| ProductEvidenceCard | PurchaseProof, external source later |

## Estados

### MentalLoadItem

```text
inbox
parsed
needs_confirmation
scheduled
accepted
done
dismissed
```

### DecisionCard

```text
draft
shown
accepted
done
postponed
rejected
```

### ShoppingNeed

```text
draft
confirmed
shopping_list
dismissed
```
