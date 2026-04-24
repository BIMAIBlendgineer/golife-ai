# PDR — Product Definition Requirements

## Producto

GoLife AI.

## Objetivo

Crear una app móvil que transforma eventos de vida cotidiana en misiones diarias y planes semanales mediante IA explicable.

## Usuarios

- usuarios saturados;
- usuarios que quieren ahorrar;
- usuarios que quieren reducir desperdicio;
- usuarios que quieren sostener hábitos;
- familias en fase posterior.

## Requisitos funcionales

### RF-001 Captura rápida

El usuario puede añadir texto libre. La app clasifica el evento.

### RF-002 LifeGraph

Todo se guarda como `LifeEvent`.

### RF-003 Misiones diarias

La app genera 3–5 misiones diarias.

### RF-004 Planner semanal

La app redistribuye tareas y hábitos.

### RF-005 Gasto consciente

La app detecta patrones de gasto.

### RF-006 Despensa

La app prioriza alimentos próximos a vencer.

### RF-007 Explicación

Cada recomendación incluye evidencia, incertidumbre y acción mínima.

### RF-008 Feedback

El usuario puede marcar una recomendación como útil, incorrecta o no aplicable.

## Requisitos no funcionales

- local-first cuando posible;
- latencia IA < 8 segundos para plan diario;
- fallback sin IA;
- provider de IA intercambiable;
- datos exportables;
- logs sin datos sensibles.

## Fuera de alcance

- inversión;
- terapia;
- diagnóstico médico;
- nutrición clínica;
- integración bancaria en MVP.
