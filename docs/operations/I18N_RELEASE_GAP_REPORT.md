# I18N Release Gap Report

## Baseline

- Command used: `flutter gen-l10n`
- Template locale: `app_en.arb`
- Scope reviewed:
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_es.arb`
  - `lib/l10n/app_pt.arb`
  - `lib/l10n/app_pt_BR.arb`
  - `lib/l10n/app_ja.arb`
  - `lib/l10n/app_zh.arb`
  - `lib/l10n/app_zh_Hans.arb`

## Summary

| Locale | Missing keys | Release impact | Decision |
| --- | ---: | --- | --- |
| `es` | 65 | HomeMemory-only strings fall back to English | Accept temporarily |
| `pt_BR` | 65 | HomeMemory-only strings fall back to English | Accept temporarily |
| `pt` | 196 | Broad partial localization gap | Accept temporarily |
| `ja` | 195 | Broad partial localization gap | Accept temporarily |
| `zh` | 195 | Broad partial localization gap | Accept temporarily |
| `zh_Hans` | 195 | Broad partial localization gap | Accept temporarily |

## Shared HomeMemory key set

These 65 keys are missing in both `es` and `pt_BR`, and are also part of the larger gap in `pt`, `ja`, `zh`, and `zh_Hans`.

```text
collectionOwnedItems
collectionPurchaseProofs
collectionClaimDrafts
collectionEvidenceAttachments
homeMemoryEyebrow
homeMemoryTitle
homeMemorySubtitle
homeMemoryDisclosureTitle
homeMemoryDisclosureBody
homeMemoryWarrantySoonTitle
homeMemoryWarrantySoonEmpty
homeMemoryRecentProofsTitle
homeMemoryRecentProofsEmpty
homeMemoryRemindersTitle
homeMemoryRemindersEmpty
homeMemoryClaimsTitle
homeMemoryClaimsEmpty
homeMemoryActionAddItem
homeMemoryActionAddProof
homeMemoryActionCreateReminder
homeMemoryActionDraftClaim
homeMemoryActionOpen
homeMemoryItemsTitle
homeMemoryItemsEmpty
homeMemoryWarrantyUntilLabel
homeMemoryItemNoMeta
homeMemorySectionItem
homeMemorySectionProofs
homeMemorySectionWarranty
homeMemorySectionReminders
homeMemorySectionClaims
homeMemorySectionEvidence
homeMemoryFieldProductName
homeMemoryFieldBrand
homeMemoryFieldModel
homeMemoryFieldSerialNumber
homeMemoryFieldStore
homeMemoryFieldPurchaseDate
homeMemoryFieldPrice
homeMemoryFieldCurrency
homeMemoryFieldWarrantyMonths
homeMemoryFieldWarrantyUntil
homeMemoryFieldDueDate
homeMemoryFieldRecurrence
homeMemoryFieldIssueDescription
homeMemoryFieldRecipientHint
homeMemoryCreateWarrantyReminder
homeMemoryDefaultReminderTitle
homeMemorySelectItem
homeMemoryClaimDisclaimer
homeMemoryNoNotes
homeMemoryUnknownMerchant
homeMemoryUnknownDate
homeMemoryUnknownValue
homeMemoryNoProofs
homeMemoryWarrantyUnknown
homeMemoryNoReminders
homeMemoryNoClaims
homeMemoryNoEvidence
homeMemoryEvidencePresent
homeMemoryWarrantyStatusUnknown
homeMemoryWarrantyStatusExpired
homeMemoryWarrantyStatusActive
homeMemoryEverydaySubtitle
homeMemoryEverydayBody
```

## Shared broad-surface key set

These 130 keys are missing in `ja`, `zh`, and `zh_Hans`, and are also missing in `pt` alongside the HomeMemory key set.

```text
navJournal
navCalendar
navRecipes
entityTask
entityHabit
entityExpense
entityPantryItem
entityPurchaseIntention
entityWeekPlan
entityJournalEntry
entityQuickNote
entityCalendarItem
entityRecipeRescue
actionNewEntity
actionEditEntity
actionComplete
actionDone
actionCheckIn
actionReflect
actionMarkUsed
actionUsed
actionPause24h
actionReplan
actionReview
actionKeepLocal
actionOpenJournal
actionOpenCalendar
actionOpenRecipes
actionCookNow
actionCooked
actionTimeBlock
actionSaving
domainTasksEyebrow
domainTasksDescription
domainHabitsEyebrow
domainHabitsDescription
domainMoneyEyebrow
domainMoneyDescription
domainPantryEyebrow
domainPantryDescription
domainClosetEyebrow
domainClosetDescription
domainWeekEyebrow
domainWeekDescription
domainJournalEyebrow
domainJournalDescription
domainCalendarEyebrow
domainCalendarDescription
domainRecipesEyebrow
domainRecipesDescription
domainEverydayEyebrow
domainEverydayDescription
tasksEmpty
habitsEmpty
moneyEmpty
pantryEmpty
closetEmpty
weekEmpty
journalEmpty
quickNotesEmpty
calendarEmpty
recipesEmpty
calendarOverloadTitle
calendarOverloadBody
calendarCalmTitle
calendarCalmBody
everydayContextTitle
everydayJournalBody
everydayCalendarBody
everydayRecipesBody
fieldTitle
fieldEstimatedMinutes
fieldPriority
fieldNotes
fieldCue
fieldCadence
fieldLabel
fieldAmount
fieldCategory
fieldName
fieldQuantity
fieldRescueHint
fieldReason
fieldTheme
fieldFocus
fieldMood
fieldBody
fieldNote
fieldStartIso
fieldEndIso
fieldLocation
fieldEnergy
fieldSummary
fieldIngredientsCommaSeparated
chipRescue
chipPurchaseIntention
chipJournal
chipNote
chipLocalOnly
statusTaskInbox
statusTaskActive
statusTaskDone
priorityGentle
priorityStandard
priorityCritical
cadenceDaily
cadenceWeekdays
cadenceWeekly
recipeStatusDraft
recipeStatusCooked
unitMinutesShort
journalQuickNotesTitle
messageTaskUpdated
messageHabitCheckedIn
messageExpenseRevisited
messagePantryItemUpdated
messagePurchaseIntentionPaused
messageWeekPlanUpdated
messageJournalLocalOnly
messageNoteLocalOnly
messageOpeningEditor
messageRecipeUpdated
messageEntitySaved
taskTimeboxFirstBlock
habitStreakDays
everydayJournalSubtitle
overloadDetected
overloadNotDetected
everydayCalendarSubtitle
everydayRecipesSubtitle
```

## Locale-by-locale decision

- `es`
  - Missing keys: shared HomeMemory key set only
  - Decision by key: keep English fallback temporarily for all 65 keys
  - Release impact: not blocking for the premium release candidate, but blocks calling Spanish HomeMemory fully localized

- `pt_BR`
  - Missing keys: shared HomeMemory key set only
  - Decision by key: keep English fallback temporarily for all 65 keys
  - Release impact: not blocking for the premium release candidate, but blocks calling Brazilian Portuguese HomeMemory fully localized

- `pt`
  - Missing keys: shared HomeMemory key set + shared broad-surface key set + `everydayContextBody`
  - Decision by key: keep English fallback temporarily for all missing keys
  - Release impact: not blocking for the premium release candidate because the in-app picker targets `pt-BR`, but generic Portuguese remains incomplete

- `ja`
  - Missing keys: shared HomeMemory key set + shared broad-surface key set
  - Decision by key: keep English fallback temporarily for all missing keys
  - Release impact: not blocking for the premium release candidate, but Japanese is not release-complete

- `zh`
  - Missing keys: shared HomeMemory key set + shared broad-surface key set
  - Decision by key: keep English fallback temporarily for all missing keys
  - Release impact: not blocking for the premium release candidate, but Chinese is not release-complete

- `zh_Hans`
  - Missing keys: shared HomeMemory key set + shared broad-surface key set
  - Decision by key: keep English fallback temporarily for all missing keys
  - Release impact: not blocking for the premium release candidate, but Simplified Chinese is not release-complete

## Recommendation

- Do not add mass machine-translated strings in a hardening pass.
- Prioritize a human review pass for:
  - `es` HomeMemory keys
  - `pt_BR` HomeMemory keys
  - the broad-surface shared set for `ja`, `zh`, and `zh_Hans`
- Release stance: acceptable temporary gap for a premium ops release, not acceptable for a locale-completeness milestone.
