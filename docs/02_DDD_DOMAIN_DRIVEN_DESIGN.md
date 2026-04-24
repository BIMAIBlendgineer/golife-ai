# DDD — Domain-Driven Design

## Dominio principal

**Personal Life Orchestration**

El dominio central no es “hábitos” ni “tareas”, sino coordinación de decisiones pequeñas de la vida diaria.

## Bounded Contexts

### 1. Identity & Privacy Context

Responsable de:

- usuario;
- perfil;
- permisos;
- consentimiento;
- modo local/cloud;
- políticas de retención de datos.

Entidades:

- `UserProfile`
- `ConsentPolicy`
- `PrivacySetting`
- `DataExportRequest`

### 2. LifeGraph Context

Responsable de eventos transversales.

Entidades:

- `LifeEvent`
- `LifeSignal`
- `LifePattern`
- `EvidenceLink`
- `DomainReference`

Ejemplos:

- `habit.completed`
- `task.overdue`
- `expense.created`
- `pantry.expiring`
- `closet.item_unused`
- `ai.suggestion.accepted`

### 3. Task Context

Responsable de tareas accionables.

Entidades:

- `Task`
- `TaskDependency`
- `TaskBlocker`
- `TaskRewrite`
- `TaskEstimate`

Invariantes:

- una tarea accionable debe tener verbo;
- si duración estimada > 90 minutos, TaskDoctor debe sugerir división;
- si prioridad alta y fecha vencida, aparece en WeekPilot.

### 4. Habit Context

Responsable de hábitos, streaks y rutina.

Entidades:

- `Habit`
- `HabitLog`
- `HabitStreak`
- `HabitNote`
- `HabitReminder`

Invariantes:

- un hábito no debe transformarse en castigo;
- fallos repetidos reducen dificultad sugerida.

### 5. Mission / RPG Context

Responsable de gamificación.

Entidades:

- `Mission`
- `Quest`
- `XPEvent`
- `Level`
- `Reward`
- `RecoveryPlan`

Tipos de misión:

- `micro_task`
- `habit_recovery`
- `budget_save`
- `fridge_rescue`
- `closet_reuse`
- `weekly_reset`

### 6. Week Planning Context

Responsable de agenda semanal.

Entidades:

- `WeekPlan`
- `DayPlan`
- `TimeBlock`
- `RecurringRule`
- `PlanConflict`

Reglas:

- no planificar más trabajo que el tiempo disponible;
- marcar incertidumbre de estimaciones;
- permitir edición humana.

### 7. Finance Context

Responsable de gastos personales.

Entidades:

- `Account`
- `Expense`
- `Income`
- `Category`
- `Budget`
- `SpendingPattern`

Restricción:

- no emitir asesoría financiera regulada;
- solo reflexión, alerta, presupuesto y educación general.

### 8. Wardrobe Context

Responsable de ropa y outfits.

Entidades:

- `ClosetItem`
- `Outfit`
- `Occasion`
- `WeatherConstraint`
- `PurchaseIntention`

Reglas:

- antes de comprar, comparar contra inventario;
- explicar duplicados;
- permitir override humano.

### 9. Pantry / Grocery Context

Responsable de comida, despensa y compras.

Entidades:

- `PantryItem`
- `GroceryItem`
- `ShoppingList`
- `RecipeCandidate`
- `WasteRisk`

Reglas:

- priorizar vencimiento;
- no inventar disponibilidad;
- diferenciar “estimado” de “verificado”.

### 10. AI Copilot Context

Responsable de recomendaciones.

Entidades:

- `AIObservation`
- `AISuggestion`
- `AIDecisionTrace`
- `ProviderInvocation`
- `HumanReview`

Invariantes:

- toda sugerencia debe tener evidencias;
- toda acción externa requiere confirmación;
- todo modelo debe ser reemplazable.

## Agregados

### Aggregate: UserLifeProfile

Raíz: `UserProfile`

Contiene referencias a:

- hábitos activos;
- categorías de gasto;
- preferencias alimentarias;
- preferencias de armario;
- objetivos actuales.

### Aggregate: Mission

Raíz: `Mission`

Incluye:

- objetivo;
- evidencia;
- dificultad;
- recompensa;
- estado;
- resultado.

### Aggregate: WeekPlan

Raíz: `WeekPlan`

Incluye:

- días;
- bloques;
- tareas;
- conflictos;
- revisiones IA.

### Aggregate: AISuggestion

Raíz: `AISuggestion`

Incluye:

- recomendación;
- evidencia;
- confianza;
- límites;
- confirmación requerida;
- estado de aceptación.

## Ubiquitous Language

| Término | Definición |
|---|---|
| LifeGraph | Grafo/event log central de acciones de vida |
| Mission | Acción recomendada, pequeña y medible |
| Quest | Conjunto de misiones conectadas |
| Signal | Evento relevante para IA |
| Evidence | Dato usado para justificar una sugerencia |
| Recovery | Replanificación cuando el usuario falla |
| Anti-consumption | Recomendación para no comprar innecesariamente |
| Fridge rescue | Acción para usar comida antes de perderla |
| Money leak | Patrón de gasto repetido y poco visible |
