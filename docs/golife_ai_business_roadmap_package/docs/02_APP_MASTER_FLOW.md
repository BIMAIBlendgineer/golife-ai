# 02 — App Master Flow

## Visión general

GoLife AI tiene seis dominios conectados:

1. **LifeQuest** — hábitos gamificados.
2. **TaskDoctor** — tareas y desbloqueo.
3. **WeekPilot** — planificación semanal.
4. **MoneyMirror** — gastos y conciencia financiera.
5. **FridgeZero** — despensa, compras y desperdicio.
6. **ClosetLess** — armario y anti-consumo.

La app no debe mostrar seis apps pegadas. Debe mostrar un sistema único:

```text
Home Today
  ├─ Misiones de hoy
  ├─ Riesgos de hoy
  ├─ Decisiones sugeridas
  ├─ Captura rápida
  └─ Chat explicativo con IA
```

## Flujo principal del usuario

### 1. Onboarding

El usuario elige objetivos:

- ahorrar dinero;
- organizar semana;
- crear hábitos;
- comer mejor;
- reducir compras impulsivas;
- reducir desperdicio;
- usar mejor su ropa.

La app no debe preguntar demasiado. Debe iniciar con datos mínimos.

### 2. Captura rápida

Pantalla central:

```text
+ Añadir
  ├─ tarea
  ├─ gasto
  ├─ alimento
  ├─ compra
  ├─ hábito
  ├─ ropa
  └─ nota/voz/foto
```

La IA clasifica la entrada.

Ejemplo:

> “compré café 4,50 y pan 2,10”

La app crea:

- gasto: café 4,50;
- gasto: pan 2,10;
- categoría: alimentación;
- posible patrón: microgasto.

### 3. Home Today

La IA produce un plan diario:

```json
{
  "today_missions": [
    "Completar tarea crítica de 20 min",
    "Usar alimento que vence mañana",
    "No comprar ropa hoy",
    "Registrar gasto del supermercado"
  ],
  "risks": [
    "Sobrecarga de tareas",
    "Despensa con 3 productos próximos a vencer",
    "Gasto repetido en café"
  ]
}
```

### 4. WeekPilot

Planificación semanal:

- distribuye tareas;
- detecta días sobrecargados;
- reduce metas irreales;
- protege tiempo para hábitos;
- recomienda compras mínimas.

### 5. MoneyMirror

La IA no da inversión. Solo analiza comportamiento:

- fugas pequeñas;
- compras repetidas;
- gastos impulsivos;
- presupuesto semanal;
- relación entre hábitos y gasto.

Ejemplo:

> “Tus microgastos de menos de 6 € sumaron 48 € esta semana.”

### 6. FridgeZero

La app registra:

- alimento;
- cantidad;
- fecha de compra;
- fecha estimada de vencimiento;
- ubicación: nevera, congelador, despensa.

La IA sugiere:

- receta simple;
- prioridad de uso;
- lista mínima de compra;
- alerta de desperdicio.

### 7. ClosetLess

La app registra prendas. La IA sugiere:

- outfits;
- duplicados;
- qué no comprar;
- combinaciones con clima/evento;
- piezas realmente faltantes.

### 8. LifeQuest

Convierte todo en juego:

- misiones;
- niveles;
- rachas flexibles;
- recuperación si fallas;
- dificultad adaptativa.

No debe castigar. Debe ajustar.

### 9. Explicación

Cada recomendación debe tener:

- evidencia usada;
- incertidumbre;
- alternativa;
- acción mínima.

Ejemplo:

```text
Recomendación: no compres más snacks esta semana.
Evidencia: 6 compras similares en 5 días.
Incertidumbre: no conozco eventos sociales futuros.
Acción mínima: cambia snack por alimento ya disponible.
```

## Pantallas mínimas del MVP

1. Home Today.
2. Capture.
3. Tasks.
4. Habits.
5. Money.
6. Pantry.
7. Wardrobe.
8. AI Explanation.
9. Settings/Privacy.

## Flujo de IA

```text
User Event
  → Normalizer
  → Domain Classifier
  → LifeGraph Writer
  → Context Retriever
  → Safety/Policy Guard
  → Agent Router
  → Recommendation Generator
  → Explanation Builder
  → UI Card
  → Feedback Collector
```
