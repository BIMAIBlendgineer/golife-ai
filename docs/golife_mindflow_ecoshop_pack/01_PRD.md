# 01 — PRD: GoLife AI MindFlow Core + EcoShop Domain

## 1. Resumen

GoLife AI debe evolucionar desde una app local-first de misiones diarias hacia un sistema de reducción de carga mental y decisiones cotidianas.

La nueva propuesta:

```text
GoLife AI no es un chatbot.
Es un sistema local-first para capturar vida real,
convertir información dispersa en decisiones,
reducir carga mental,
y guiar compras/tareas con privacidad y evidencia.
```

## 2. Problema

Usuarios tienen información fragmentada en:

- notas
- memoria personal
- calendario
- tareas
- gastos
- despensa
- intenciones de compra
- recibos
- garantías
- documentos del hogar

El problema no es solo recordar. Es decidir:

- qué hago ahora
- qué puedo posponer
- qué debo comprar
- qué ya tengo
- qué dato falta
- qué información puede enviarse a IA
- qué decisión necesita confirmación humana

## 3. Objetivos

### Objetivo principal

Crear `MindFlow Core` como núcleo de GoLife AI.

### Objetivos secundarios

- Crear `EcoShop Domain` como dominio interno de compras inteligentes.
- Conectar `HomeMemory` con decisiones y compras.
- Mantener diseño local-first.
- Garantizar privacidad antes de IA.
- Exigir evidencia para recomendaciones de compra.
- Evitar claims no verificados.

## 4. No objetivos

No hacer en V1:

- compra automática
- scraping masivo
- claim de mejor precio sin fuente
- claim de sostenibilidad sin fuente
- integración bancaria real
- diagnóstico médico/psicológico
- consejo financiero regulado
- app EcoShop separada

## 5. Usuarios objetivo

### Usuario primario

Persona con alta carga mental diaria que necesita:

- capturar rápido
- decidir rápido
- no olvidar
- no comprar de más
- mantener privacidad

### Usuario secundario

Hogar/familia con:

- compras domésticas
- despensa
- garantías
- recibos
- mantenimiento
- planificación semanal

## 6. Propuesta de valor

```text
Captura todo.
GoLife separa, prioriza y convierte en decisiones seguras.
Tus datos sensibles permanecen locales salvo permiso explícito.
```

## 7. Pilares

| Pilar | Descripción |
|---|---|
| Capture Inbox | Volcado mental sin estructura inicial. |
| Mental Load Graph | Grafo de tareas, decisiones, compras, fechas y documentos. |
| Decision Cards | Recomendaciones accionables con evidencia y privacidad visible. |
| EcoShop Domain | Compras guiadas por necesidad, presupuesto, pantry y evidencia. |
| HomeMemory | Memoria de compras, garantías, recibos y reclamaciones. |
| Privacy-before-AI | Filtrado antes de cualquier llamada IA. |
| Evidence-first | No claim sin evidencia. |

## 8. Funcionalidades V1

### F1 — Capture Inbox v2

El usuario introduce texto libre.

El sistema produce drafts:

- tarea
- recordatorio
- decisión
- compra
- documento
- calendario
- nota
- item de HomeMemory

Cada draft muestra:

- texto detectado
- dominio
- tipo
- privacidad
- acción propuesta
- confianza
- razón
- confirmación

### F2 — MentalLoadItem

Crear entidad local que representa carga mental accionable.

Estados:

```text
inbox
parsed
needs_confirmation
scheduled
accepted
done
dismissed
```

### F3 — Decision Cards

Generar decisiones con:

- acción recomendada
- alternativas
- evidencia
- incertidumbre
- datos enviados a IA
- datos bloqueados
- botón explicar
- botones aceptar, hacer, posponer, rechazar

### F4 — EcoShop Domain

En V1 usar solo datos locales:

- pantry
- finance
- wardrobe
- recipes
- homememory

Salida:

- usar lo que ya existe
- comprar mínimo necesario
- posponer compra
- crear lista
- marcar sostenibilidad como insuficiente si no hay fuente

### F5 — HomeMemory Integration

Los recibos, garantías, objetos y claims deben generar decisiones y recordatorios.

### F6 — Admin Metrics

Añadir métricas:

- open loops por usuario activo
- decision acceptance rate
- decision completion rate
- postpone rate
- privacy filtered decision rate
- shopping evidence rate
- insufficient sustainability data rate

## 9. Requisitos funcionales

### RF-001

El usuario debe poder capturar texto libre y recibir múltiples drafts.

### RF-002

Cada draft debe permitir cambiar dominio, tipo y privacidad antes de guardar.

### RF-003

El sistema debe crear `MentalLoadItem` al guardar captura relevante.

### RF-004

El sistema debe generar hasta 3 `DecisionCard` diarias.

### RF-005

Cada `DecisionCard` debe exigir confirmación antes de ejecutar o transformar datos.

### RF-006

EcoShop no puede generar recomendaciones de producto externo sin evidencia.

### RF-007

Si no hay evidencia de sostenibilidad, la UI debe mostrar `insufficient verified data`.

### RF-008

HomeMemory debe alimentar decisiones sobre garantías, mantenimiento y claims.

### RF-009

El usuario debe poder ver qué datos se enviaron a IA y qué datos fueron bloqueados.

### RF-010

Toda llamada a IA debe respetar `PrivacySettings`.

## 10. Requisitos no funcionales

| Código | Requisito |
|---|---|
| RNF-001 | Local-first por defecto. |
| RNF-002 | Funcionalidad básica offline. |
| RNF-003 | Cifrado local para datos sensibles. |
| RNF-004 | Fallback local si AI Gateway falla. |
| RNF-005 | Ninguna acción externa sin confirmación. |
| RNF-006 | Latencia objetivo para capture parse: < 2 s si local, < 5 s si remoto. |
| RNF-007 | Trazabilidad mínima por decisión. |
| RNF-008 | Feature flags para activar gradualmente. |

## 11. Métricas de éxito

| Métrica | Meta inicial |
|---|---:|
| decision_acceptance_rate | > 25% |
| decision_completion_rate | > 15% |
| capture_to_decision_conversion | > 20% |
| privacy_explanation_open_rate | medible |
| shopping_need_completion_rate | > 10% |
| unverified_claim_rate | 0% para claims fuertes |
| fallback_success_rate | > 95% |
| crash-free sessions | > 99% |

## 12. Criterios de aceptación

- La app puede usarse sin conexión.
- La captura genera drafts editables.
- Las decisiones muestran evidencia y privacidad.
- EcoShop no afirma precio/sostenibilidad sin fuente.
- HomeMemory genera recordatorios y decisiones.
- Admin muestra métricas nuevas.
- Tests cubren privacidad, fallback y no-claims.
