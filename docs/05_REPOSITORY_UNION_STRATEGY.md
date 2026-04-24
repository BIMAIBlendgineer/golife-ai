# Estrategia de unión de repositorios

## Objetivo

Convertir varias bases open-source en un único producto coherente: **GoLife AI**.

## No hacer

No hacer esto:

```text
copiar todo /lib de cada repo en un solo /lib
```

Eso generaría:

- conflictos de dependencias;
- estilos de arquitectura mezclados;
- problemas de licencia;
- duplicación de modelos;
- UI incoherente;
- deuda técnica inmediata.

## Sí hacer

Crear un nuevo producto con arquitectura propia.

```text
source_repos/     # repos originales, intactos
new_app/          # app nueva
services/         # AI Gateway
docs/             # decisiones y contratos
```

## Uso por repositorio

### Habo

Extraer:

- modelo de hábito;
- estadísticas;
- recordatorios;
- notas;
- lógica de streak;
- UX simple.

Reescribir dentro de:

```text
lib/domains/habits/
```

### Taskly

Extraer:

- modelo simple de tarea;
- creación/edición;
- duración;
- voz;
- countdown;
- compartir;
- import/export.

Reescribir dentro de:

```text
lib/domains/tasks/
```

### Flow

Extraer:

- modelo financiero;
- cuentas;
- categorías;
- offline;
- charts;
- exportaciones;
- ObjectBox si se adopta.

Reescribir o portar dentro de:

```text
lib/domains/finance/
```

Atención: Flow ya menciona un parser de recibos con IA externo. GoLife no debe prometer que Flow no usa IA. La novedad es coordinación multi-dominio.

### OpenWardrobe

Extraer:

- closet item;
- outfit;
- Supabase sync;
- Hive local;
- BLoC si se mantiene;
- modelos de armario.

Reescribir dentro de:

```text
lib/domains/wardrobe/
```

### Wanna

No integrar React Native UI directamente. Extraer:

- lógica de lista compartida;
- Supabase realtime;
- concepto de “cart”;
- past purchases;
- compartir por link.

Reescribir dentro de:

```text
lib/domains/pantry/
```

### WeekToDo

No integrar Vue/Electron en mobile Flutter. Extraer:

- estructura semanal;
- recurrent rules;
- subtasks;
- colores;
- privacidad local;
- concepto calendario + lista.

Reescribir dentro de:

```text
lib/domains/week/
```

## Canonical data model

Todos los módulos deben emitir `LifeEvent`.

Ejemplo:

```dart
LifeEvent(
  domain: LifeDomain.finance,
  eventType: "expense.created",
  payload: {"amount": 4.50, "category": "coffee"}
)
```

La IA solo ve eventos autorizados.

## Adapter pattern

Para cada dominio:

```text
SourceRepoModel -> DomainModel -> LifeEvent -> AI Summary
```

Nunca pasar objetos internos crudos del repositorio original al AI Gateway.

## Integración incremental

1. Crear shell Flutter.
2. Implementar core LifeGraph.
3. Importar Taskly como tareas simples.
4. Importar Habo como hábitos.
5. Añadir WeekPilot reescrito.
6. Añadir FridgeZero reescrito desde Wanna.
7. Añadir ClosetLess desde OpenWardrobe.
8. Añadir MoneyMirror desde Flow.
9. Conectar AI Gateway.
10. Añadir gamificación LifeQuest.

## Criterio de aceptación

GoLife solo está “unido” cuando:

- un gasto puede afectar una misión;
- una tarea puede afectar semana;
- un alimento puede afectar presupuesto;
- una prenda puede evitar compra;
- un hábito fallido puede activar recovery;
- toda sugerencia tiene evidencia.
