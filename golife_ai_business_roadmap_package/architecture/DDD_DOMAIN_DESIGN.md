# DDD — Domain-Driven Design

## Bounded Contexts

### Identity Context

- UserProfile
- HouseholdProfile
- Preferences

### LifeGraph Context

- LifeEvent
- EventSource
- EventConfidence
- EventLink

### Task Context

- Task
- TaskBlocker
- TaskPriority
- TaskDecomposition

### Habit Context

- Habit
- HabitCheckIn
- HabitDifficulty
- RecoveryPlan

### Planning Context

- DayPlan
- WeekPlan
- Mission
- RiskSignal

### Money Context

- Expense
- Budget
- SpendingPattern
- MicroSpendInsight

### Pantry Context

- PantryItem
- ExpirySignal
- ShoppingList
- MealSuggestion

### Wardrobe Context

- ClothingItem
- Outfit
- DuplicateSignal
- NoBuyRecommendation

### AI Context

- AIRequest
- AIRecommendation
- AIExplanation
- SafetyDecision
- ProviderTrace

## Aggregate Roots

- UserProfile
- LifeEvent
- DayPlan
- WeekPlan
- Budget
- PantryInventory
- WardrobeInventory

## Domain Events

- TaskCreated
- TaskCompleted
- HabitChecked
- ExpenseLogged
- PantryItemAdded
- PantryItemExpiring
- MissionGenerated
- RecommendationAccepted
- RecommendationRejected

## Ubiquitous Language

- Mission: action small enough to complete today.
- LifeGraph: event memory of user life.
- RiskSignal: pattern requiring attention.
- ActionMinimum: smallest useful next step.
- Evidence: data used for recommendation.
- Uncertainty: explicit limitation of recommendation.
