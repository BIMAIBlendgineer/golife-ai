# PDR — Product Definition Report

## Nombre

**GoLife AI**

## Definición corta

App móvil de vida diaria asistida por IA que une hábitos, tareas, planificación semanal, gasto personal, armario y despensa en un único sistema de misiones explicables.

## Problema

Las apps personales suelen resolver problemas separados:

- hábitos;
- tareas;
- calendario;
- finanzas;
- listas de compra;
- armario;
- notas.

Ese aislamiento reduce utilidad. Un gasto puede afectar una compra. Una compra puede afectar comida disponible. La comida puede afectar hábitos. La semana puede estar mal planificada por tareas demasiado grandes. El usuario necesita coordinación, no solo registros separados.

## Hipótesis de producto

Una app será más útil si convierte datos personales dispersos en **acciones pequeñas y justificadas**.

Ejemplo:

> “Hoy no compres comida fuera. Tienes arroz, tomate y pollo; puedes cocinar en 20 minutos. Esto reduce gasto y evita desperdicio. Misión: cocinar cena simple.”

## Usuarios objetivo

1. Personas que quieren organizar vida diaria sin usar 6 apps.
2. Estudiantes y trabajadores con poco tiempo.
3. Personas que quieren ahorrar dinero sin hacer contabilidad pesada.
4. Personas que quieren comprar menos ropa y comida.
5. Usuarios que disfrutan gamificación tipo RPG, misiones y progreso.

## Propuesta de valor

GoLife AI no es un chatbot suelto. Es una app con memoria estructurada:

- sabe tus hábitos;
- sabe tus tareas;
- sabe tu semana;
- sabe tus gastos;
- sabe qué ropa tienes;
- sabe qué comida tienes;
- propone acciones;
- explica por qué;
- registra si funcionó.

## Módulos de producto

### 1. LifeGraph

Modelo central de eventos de vida:

- tarea creada;
- hábito cumplido;
- gasto registrado;
- compra añadida;
- prenda usada;
- comida próxima a vencer;
- misión aceptada;
- misión fallada;
- recomendación ignorada.

### 2. LifeQuest

Capa RPG:

- XP;
- niveles;
- misiones;
- streaks;
- penalización suave;
- recuperación cuando el usuario falla;
- dificultad adaptativa.

### 3. WeekPilot

Planificador semanal:

- reorganiza tareas;
- detecta sobrecarga;
- propone bloques de tiempo;
- separa tareas grandes en tareas mínimas;
- respeta privacidad local.

### 4. TaskDoctor

Diagnóstico de tareas:

- vaga;
- demasiado grande;
- sin fecha;
- sin dependencia;
- sin primer paso;
- imposible para el tiempo disponible.

### 5. MoneyMirror

Reflexión financiera:

- patrones de gasto;
- microcompras;
- gastos repetidos;
- comparación contra presupuesto;
- alerta de fuga de dinero.

No debe dar asesoría de inversión.

### 6. ClosetLess

Armario anti-consumo:

- combina ropa existente;
- detecta duplicados;
- recomienda no comprar;
- sugiere outfit según clima, agenda y presupuesto.

### 7. FridgeZero

Despensa y compra inteligente:

- lista mínima de compra;
- prioridad por vencimiento;
- recetas simples;
- reducción de desperdicio;
- conexión con gasto.

### 8. AI Copilot

Capa IA:

- explicación;
- memoria;
- recomendaciones;
- análisis de imágenes opcional;
- tareas de reescritura;
- resúmenes semanales;
- human-in-the-loop antes de cualquier acción irreversible.

## Límites del producto

GoLife AI no debe:

- diagnosticar enfermedades;
- dar asesoría financiera regulada;
- hacer compras automáticas sin confirmación;
- enviar datos sensibles sin consentimiento;
- borrar datos sin confirmación;
- manipular al usuario mediante culpa excesiva.

## Métricas del MVP

- tareas reducidas a pasos accionables;
- misiones completadas;
- ahorro estimado por no comprar;
- comida salvada de desperdicio;
- reducción de tareas vencidas;
- retención semanal;
- porcentaje de recomendaciones aceptadas;
- porcentaje de recomendaciones editadas por el usuario.

## MVP mínimo

1. Login local.
2. Dashboard.
3. Tareas.
4. Hábitos.
5. Gastos manuales.
6. Despensa manual.
7. Armario manual.
8. AI Gateway.
9. Generador de misión diaria.
10. Explicación de cada sugerencia.
