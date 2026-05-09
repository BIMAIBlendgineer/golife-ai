# 09 — Mobile Flutter Spec

## 1. Archivos afectados

```text
apps/mobile_flutter/lib/app/router/app_router.dart
apps/mobile_flutter/lib/features/app_state/golife_controller.dart
apps/mobile_flutter/lib/features/dashboard/dashboard_screen.dart
apps/mobile_flutter/lib/features/capture/capture_screen.dart
apps/mobile_flutter/lib/features/domains/domain_screens.dart
apps/mobile_flutter/lib/features/homememory/homememory_screen.dart
apps/mobile_flutter/lib/core/storage/local_store.dart
apps/mobile_flutter/lib/core/storage/sqlite_local_store.dart
apps/mobile_flutter/lib/core/ai_client/ai_gateway_client.dart
apps/mobile_flutter/lib/core/ai_client/dto/
```

## 2. Nuevas carpetas

```text
apps/mobile_flutter/lib/domains/mindflow/
apps/mobile_flutter/lib/domains/shopping/
apps/mobile_flutter/lib/features/decisions/
apps/mobile_flutter/lib/features/shopping/
apps/mobile_flutter/lib/core/mindflow/
```

## 3. Nuevos modelos Dart

```text
MentalLoadItem
DecisionCard
ShoppingNeed
ProductEvidenceCard
PrivacySummary
ActionContract
```

## 4. Router

Agregar rutas:

```dart
GoRoute(
  path: '/decisions',
  builder: (context, state) => DecisionsScreen(controller: controller),
),

GoRoute(
  path: '/shopping',
  builder: (context, state) => ShoppingScreen(controller: controller),
),
```

Opcional:

```text
/dashboard se mantiene como Today.
```

## 5. GoLifeController

Agregar estado:

```dart
List<MentalLoadItem> _mentalLoadItems = <MentalLoadItem>[];
List<DecisionCard> _decisionCards = <DecisionCard>[];
List<ShoppingNeed> _shoppingNeeds = <ShoppingNeed>[];
List<ProductEvidenceCard> _productEvidenceCards = <ProductEvidenceCard>[];
```

Agregar métodos:

```dart
Future<void> refreshDecisionPlan()
Future<void> refreshShoppingPlan()
Future<void> acceptDecision(String id)
Future<void> completeDecision(String id)
Future<void> postponeDecision(String id)
Future<void> rejectDecision(String id)
Future<void> confirmShoppingNeed(String id)
Future<void> addShoppingNeedToList(String id)
```

## 6. CaptureScreen

Cambios:

- Renombrar visualmente a Capture Inbox.
- Mantener selector de dominio.
- Agregar selector de tipo.
- Mostrar `MentalLoadItemDraft`.
- Guardar `LifeEvent` + `MentalLoadItem`.

## 7. DashboardScreen

Cambios:

- Renombrar visualmente a Today.
- Agregar mental load summary.
- Usar `DecisionCard` como card principal.
- Mantener explicación de datos usados/bloqueados.
- Mantener `DailyMission` como fallback.

## 8. DecisionsScreen

Nueva pantalla:

```text
Tabs:
- Today
- Waiting
- Shopping
- Calendar
- Home
- Done
```

## 9. ShoppingScreen

Nueva pantalla:

```text
Tabs:
- Pantry first
- Shopping list
- Purchase intentions
- Product evidence
- Sustainability
```

## 10. HomeMemoryScreen

Agregar bloque:

```text
Generated decisions:
- warranty ending soon
- maintenance due
- claim candidate
```

## 11. LocalStore

Agregar métodos:

```dart
Future<List<MentalLoadItem>> loadMentalLoadItems();
Future<void> saveMentalLoadItems(List<MentalLoadItem> items);
Future<void> upsertMentalLoadItem(MentalLoadItem item);

Future<List<DecisionCard>> loadDecisionCards();
Future<void> saveDecisionCards(List<DecisionCard> cards);
Future<void> upsertDecisionCard(DecisionCard card);

Future<List<ShoppingNeed>> loadShoppingNeeds();
Future<void> upsertShoppingNeed(ShoppingNeed need);

Future<List<ProductEvidenceCard>> loadProductEvidenceCards();
Future<void> upsertProductEvidenceCard(ProductEvidenceCard card);
```

## 12. AI Client

Agregar:

```dart
Future<MindFlowParseResponseDto?> parseMindFlowInbox(...)
Future<DecisionPlanDto> fetchDecisionPlan(...)
Future<ShoppingPlanDto> optimizeShoppingList(...)
Future<ProductEvidenceCardDto?> fetchProductEvidence(...)
```

## 13. i18n

Agregar claves:

```text
navToday
navDecisions
navShopping
mentalLoadTitle
openLoops
decisionCardTitle
whyThisToday
dataUsed
dataBlocked
shoppingNeed
useExistingFirst
insufficientVerifiedData
sustainabilityNotChecked
```

## 14. QA móvil

Probar:

- first launch
- offline mode
- gateway unavailable
- privacy all local-only
- capture multi-item
- decision accept/postpone
- shopping no evidence
- HomeMemory warranty decision
