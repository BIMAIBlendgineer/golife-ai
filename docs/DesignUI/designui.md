\# GoLife AI — Storyboard Premium Mobile-First



\## Propósito



Este storyboard define cómo debe verse y sentirse la app móvil premium de GoLife AI. No es un plan para añadir features. Es una guía de rediseño UI/UX para que la IA local, el equipo y el propietario del producto trabajen con la misma imagen mental.



\## Restricciones obligatorias



\* No tocar `/admin`.

\* No tocar `/studio`.

\* No tocar `/control`.

\* No añadir funcionalidades nuevas.

\* No convertir la app en dashboard web.

\* No mostrar todos los módulos al usuario como navegación principal.

\* No usar la plantilla externa como base directa si ya existe UI propia; usarla solo como referencia visual si hace falta.

\* Mantener Flutter mobile como foco.

\* Mantener Material 3.

\* Mantener lógica existente siempre que sea posible.

\* Cambiar solo diseño, UX, navegación, jerarquía visual, componentes y copy visible.



\## Tesis UX



GoLife AI debe sentirse como un sistema operativo personal de decisiones diarias.



La interfaz no debe decir:



> “Aquí tienes muchas apps: tareas, hábitos, dinero, despensa, calendario, armario, compras, diario.”



Debe decir:



> “Hoy estas son tus 3 decisiones importantes. Haz una ahora. Captura lo siguiente. Yo mantengo memoria y evidencia.”



\## Principio de navegación premium



\### Navegación principal móvil



Máximo 5 destinos visibles:



1\. \*\*Today\*\*

2\. \*\*Capture\*\*

3\. \*\*Memory\*\*

4\. \*\*Coach\*\*

5\. \*\*Settings\*\*



\### Módulos ocultos como subpantallas



Estos no deben estar en la navegación principal:



\* Tasks

\* Habits

\* Money

\* Pantry

\* Week

\* Closet

\* Shopping

\* Decisions

\* Everyday

\* Calendar

\* Recipes

\* Journal

\* HomeMemory

\* LifeGraph técnico



Deben aparecer dentro de Memory, Coach o shortcuts contextuales.



\---



\# Mapa general de experiencia



```text

Onboarding / Premium Gate

&#x20;       ↓

Today

&#x20;       ↓

Capture ←→ Draft Confirmation

&#x20;       ↓

Today updated

&#x20;       ↓

Mission explanation

&#x20;       ↓

Do now / Complete / Not useful

&#x20;       ↓

Memory learns

&#x20;       ↓

Coach can explain or replan

```



\---



\# Arquitectura visual común



\## Shell móvil



```text

┌─────────────────────────┐

│ Safe area               │

│                         │

│ \[Page content]          │

│                         │

│                         │

├─────────────────────────┤

│ Today Capture Memory    │

│ Coach Settings          │

└─────────────────────────┘

```



\## Reglas visuales



\* Fondo calmado, premium, claro.

\* Cards grandes, respiradas, táctiles.

\* Una acción primaria por pantalla.

\* Máximo dos acciones secundarias visibles en hero card.

\* Evitar grids densos en la home.

\* No usar chips horizontales como navegación principal.

\* No mostrar más de 3–5 elementos importantes por bloque.

\* Mostrar evidencia como resumen corto, no como panel técnico.

\* Privacidad siempre visible, pero compacta.



\## Componentes base necesarios



```text

GoLifeMobileShell

GoLifeBottomNav

TodayHeader

MissionHeroCard

MissionSecondaryCard

EvidenceStrip

RiskCompactCard

QuickCaptureBox

PrivacyStatusChip

MemoryTimelineCard

DomainShortcutGrid

CoachPromptCard

PremiumPlanCard

SettingsSectionCard

```



\---



\# Storyboard completo de pantallas premium



\## 00 — Splash / Bootstrap



\### Objetivo



Mostrar que la app está cargando de forma premium y tranquila.



\### Croquis



```text

┌─────────────────────────┐

│                         │

│          ⚡             │

│       GoLife AI         │

│                         │

│  Preparando tu día...   │

│                         │

│  \[small progress state] │

│                         │

└─────────────────────────┘

```



\### UX



\* Duración corta.

\* Si hay fallo de gateway, no asustar.

\* Mensaje posible: “Modo local activo. Tus misiones siguen disponibles.”



\---



\## 01 — Onboarding: promesa



\### Objetivo



Explicar la app en una frase.



\### Croquis



```text

┌─────────────────────────┐

│ GoLife AI               │

│                         │

│ 3 decisiones claras     │

│ para hoy.               │

│                         │

│ Basadas en tus tareas,  │

│ hábitos, dinero y       │

│ comida.                 │

│                         │

│ \[Empezar]               │

│ \[Ya tengo cuenta]       │

└─────────────────────────┘

```



\### Copy



\* Título: “Tu día, convertido en 3 acciones claras.”

\* Subtítulo: “Captura lo que pasa. GoLife prioriza lo importante.”



\---



\## 02 — Onboarding: privacidad



\### Objetivo



Crear confianza antes de pedir datos.



\### Croquis



```text

┌─────────────────────────┐

│ Privacidad primero      │

│                         │

│ ○ Local only            │

│ ○ Sync allowed          │

│ ○ AI allowed            │

│                         │

│ Tú decides qué puede    │

│ usar la IA.             │

│                         │

│ \[Configurar después]    │

│ \[Continuar]             │

└─────────────────────────┘

```



\### UX



\* No meter texto legal largo.

\* Mostrar 3 niveles de permiso.

\* Reforzar que cada evento puede tener privacidad propia.



\---



\## 03 — Onboarding: dominios iniciales



\### Objetivo



Permitir personalización sin fatigar.



\### Croquis



```text

┌─────────────────────────┐

│ ¿Qué quieres ordenar?   │

│                         │

│ \[✓] Tareas              │

│ \[✓] Hábitos             │

│ \[✓] Comida              │

│ \[ ] Dinero              │

│ \[ ] Compras             │

│ \[ ] Semana              │

│                         │

│ Puedes cambiarlo luego. │

│                         │

│ \[Crear mi Today]        │

└─────────────────────────┘

```



\### UX



\* Máximo 6 opciones.

\* Default recomendado: Tasks, Habits, Pantry.

\* No explicar cada módulo todavía.



\---



\## 04 — Premium Gate / Plan



\### Objetivo



Presentar el valor premium sin parecer bloqueo agresivo.



\### Croquis



```text

┌─────────────────────────┐

│ GoLife Premium          │

│                         │

│ ✓ 3 misiones diarias    │

│ ✓ Captura inteligente   │

│ ✓ Memoria LifeGraph     │

│ ✓ Explicación con datos │

│ ✓ Privacidad granular   │

│                         │

│ \[Continuar con Premium] │

│ \[Usar modo básico]      │

└─────────────────────────┘

```



\### UX



\* Debe vender resultado, no features técnicas.

\* No decir “chatbot”.

\* Decir “misiones”, “memoria”, “decisiones”.



\---



\## 05 — Today: estado nuevo sin datos



\### Objetivo



Evitar pantalla vacía.



\### Croquis



```text

┌─────────────────────────┐

│ Today                   │

│                         │

│ Todavía no sé suficiente│

│ de tu día.              │

│                         │

│ Captura una frase:      │

│                         │

│ \[ Tengo que pagar... ]  │

│                         │

│ \[Entender mi día]       │

│                         │

│ Ejemplos:               │

│ • compré café 4,50      │

│ • la lechuga vence      │

│ • llamar al médico      │

└─────────────────────────┘

```



\### UX



\* No mostrar módulos vacíos.

\* El primer objetivo es capturar.

\* CTA principal: “Entender mi día”.



\---



\## 06 — Today: Home principal premium



\### Objetivo



Pantalla central de la app.



\### Croquis



```text

┌─────────────────────────┐

│ Today        Local/AI ✓ │

│                         │

│ Tu foco de hoy          │

│                         │

│ ┌─────────────────────┐ │

│ │ Usa la espinaca hoy │ │

│ │ 15 min · ahorro     │ │

│ │ Reduce desperdicio  │ │

│ │                     │ │

│ │ \[Hacer ahora]       │ │

│ │ \[Por qué] \[No útil] │ │

│ └─────────────────────┘ │

│                         │

│ Por qué hoy             │

│ • vence pronto          │

│ • gasto comida alto     │

│ • día con poco tiempo   │

│                         │

│ Otras misiones          │

│ \[Pagar internet]        │

│ \[Caminar 10 min]        │

└─────────────────────────┘

```



\### UX



\* Esta pantalla no debe parecer dashboard.

\* La misión hero domina.

\* Riesgos y señales quedan debajo.

\* El usuario entiende “qué hago ahora” en 3 segundos.



\---



\## 07 — Today: misión completada



\### Objetivo



Reforzar progreso y aprendizaje.



\### Croquis



```text

┌─────────────────────────┐

│ Misión completada       │

│                         │

│ ✓ Espinaca usada        │

│                         │

│ Impacto estimado        │

│ • comida salvada        │

│ • compra evitada        │

│ • hábito reforzado      │

│                         │

│ ¿Fue útil?              │

│ \[Sí] \[No] \[Más tarde]   │

│                         │

│ \[Volver a Today]        │

└─────────────────────────┘

```



\### UX



\* Feedback rápido.

\* No gamificación infantil.

\* Mostrar aprendizaje: “usaré esto para priorizar mejor”.



\---



\## 08 — Today: explicación de misión



\### Objetivo



Mostrar evidencia, incertidumbre y datos usados sin abrumar.



\### Croquis



```text

┌─────────────────────────┐

│ Por qué esta misión     │

│                         │

│ Te recomiendo esto      │

│ porque combina 3 señales│

│                         │

│ Evidencia               │

│ • Pantry: espinaca      │

│ • Money: gasto comida   │

│ • Week: poco tiempo     │

│                         │

│ Incertidumbre           │

│ No sé si ya cocinaste.  │

│                         │

│ Datos enviados a IA     │

│ \[Ver detalles]          │

│                         │

│ \[Entendido]             │

└─────────────────────────┘

```



\### UX



\* Bottom sheet o pantalla modal.

\* Default: resumen simple.

\* Detalles técnicos colapsados.



\---



\## 09 — Capture: entrada libre premium



\### Objetivo



Capturar más rápido que pensar.



\### Croquis



```text

┌─────────────────────────┐

│ Capture                 │

│                         │

│ Suelta lo que tienes    │

│ en la cabeza.           │

│                         │

│ ┌─────────────────────┐ │

│ │ Compré café 4,50,   │ │

│ │ pagar internet,     │ │

│ │ lechuga vence...    │ │

│ └─────────────────────┘ │

│                         │

│ \[Entender]              │

│                         │

│ Opciones                │

│ \[Auto] \[Tarea] \[Gasto]  │

└─────────────────────────┘

```



\### UX



\* Auto por defecto.

\* Chips de dominio secundarios.

\* Input grande.

\* Botón primario único.



\---



\## 10 — Capture: drafts detectados



\### Objetivo



Permitir confirmar antes de guardar.



\### Croquis



```text

┌─────────────────────────┐

│ Confirmar captura       │

│                         │

│ Detecté 3 cosas         │

│                         │

│ ┌ Tarea ──────────────┐ │

│ │ Pagar internet      │ │

│ │ Privacidad: Local   │ │

│ │ \[Editar] \[Quitar]   │ │

│ └─────────────────────┘ │

│                         │

│ ┌ Gasto ──────────────┐ │

│ │ Café · 4,50         │ │

│ │ Privacidad: AI ok   │ │

│ └─────────────────────┘ │

│                         │

│ \[Guardar 3 items]       │

└─────────────────────────┘

```



\### UX



\* Cada draft es una card.

\* Permitir cambiar dominio.

\* Permitir cambiar privacidad.

\* Acción final clara.



\---



\## 11 — Capture: guardado exitoso



\### Objetivo



Cerrar loop y volver a Today.



\### Croquis



```text

┌─────────────────────────┐

│ Guardado                │

│                         │

│ ✓ 3 eventos añadidos    │

│                         │

│ GoLife actualizará tus  │

│ misiones con esto.      │

│                         │

│ \[Ver Today actualizado] │

│ \[Capturar otra cosa]    │

└─────────────────────────┘

```



\---



\## 12 — Memory: resumen



\### Objetivo



Mostrar memoria como valor, no como consola técnica.



\### Croquis



```text

┌─────────────────────────┐

│ Memory                  │

│                         │

│ Tu vida reciente        │

│                         │

│ \[Buscar en memoria]     │

│                         │

│ Esta semana             │

│ • 12 eventos            │

│ • 4 usados por IA       │

│ • 3 protegidos local    │

│                         │

│ Dominios                │

│ \[Tasks] \[Money] \[Food]  │

│ \[Habits] \[Closet]       │

└─────────────────────────┘

```



\### UX



\* LifeGraph se renombra visualmente como Memory.

\* Métricas simples.

\* Dominios como shortcuts, no navegación principal.



\---



\## 13 — Memory: timeline



\### Objetivo



Revisar eventos recientes.



\### Croquis



```text

┌─────────────────────────┐

│ Timeline                │

│                         │

│ Hoy                     │

│ ┌─────────────────────┐ │

│ │ Task                │ │

│ │ Pagar internet      │ │

│ │ Local only          │ │

│ │ \[Detalles]          │ │

│ └─────────────────────┘ │

│                         │

│ Ayer                    │

│ ┌─────────────────────┐ │

│ │ Pantry              │ │

│ │ Lechuga vence       │ │

│ │ AI allowed          │ │

│ └─────────────────────┘ │

└─────────────────────────┘

```



\---



\## 14 — Memory: detalle de evento



\### Objetivo



Explicar qué sabe GoLife y cómo lo usa.



\### Croquis



```text

┌─────────────────────────┐

│ Evento                  │

│                         │

│ Lechuga vence mañana    │

│                         │

│ Dominio: Pantry         │

│ Privacidad: AI allowed  │

│ Fuente: Capture         │

│                         │

│ Usado en misión:        │

│ “Usa la lechuga hoy”    │

│                         │

│ \[Cambiar privacidad]    │

│ \[Eliminar evento]       │

└─────────────────────────┘

```



\---



\## 15 — Memory: dominios



\### Objetivo



Dar acceso a módulos sin convertirlos en navegación principal.



\### Croquis



```text

┌─────────────────────────┐

│ Dominios                │

│                         │

│ ┌ Tasks ┐ ┌ Habits ┐    │

│ └───────┘ └────────┘    │

│ ┌ Money ┐ ┌ Pantry ┐    │

│ └───────┘ └────────┘    │

│ ┌ Week  ┐ ┌ Closet ┐    │

│ └───────┘ └────────┘    │

│                         │

│ Estos alimentan tus     │

│ misiones diarias.       │

└─────────────────────────┘

```



\---



\# Pantallas de dominio premium



Todas las pantallas de dominio deben seguir este patrón:



```text

┌─────────────────────────┐

│ \[Dominio]               │

│ Frase clara de valor    │

│                         │

│ \[Acción primaria]       │

│                         │

│ Insight del dominio     │

│ ┌─────────────────────┐ │

│ │ Qué importa ahora   │ │

│ └─────────────────────┘ │

│                         │

│ Lista simple            │

│ \[Card]                  │

│ \[Card]                  │

└─────────────────────────┘

```



No deben parecer tablas administrativas.



\---



\## 16 — Tasks



\### Objetivo



Tareas que alimentan misiones.



\### Croquis



```text

┌─────────────────────────┐

│ Tasks                   │

│ Lo pendiente, sin ruido │

│                         │

│ \[Nueva tarea]           │

│                         │

│ Crítica hoy             │

│ ┌─────────────────────┐ │

│ │ Pagar internet      │ │

│ │ 12 min · crítico    │ │

│ │ \[Completar] \[Editar]│ │

│ └─────────────────────┘ │

│                         │

│ Otras tareas            │

│ \[Card compacta]         │

└─────────────────────────┘

```



\---



\## 17 — Habits



\### Objetivo



Hábitos flexibles, sin culpa.



\### Croquis



```text

┌─────────────────────────┐

│ Habits                  │

│ Continuidad, no presión │

│                         │

│ \[Nuevo hábito]          │

│                         │

│ Recuperar hoy           │

│ ┌─────────────────────┐ │

│ │ Caminar 10 min      │ │

│ │ Racha flexible      │ │

│ │ \[Check-in]          │ │

│ └─────────────────────┘ │

└─────────────────────────┘

```



\---



\## 18 — Money



\### Objetivo



Reflexión de gasto, no asesoría financiera.



\### Croquis



```text

┌─────────────────────────┐

│ Money                   │

│ Microgastos visibles    │

│                         │

│ \[Añadir gasto]          │

│                         │

│ Señal de la semana      │

│ ┌─────────────────────┐ │

│ │ Comida fuera subió  │ │

│ │ Acción: usar pantry │ │

│ │ \[Reflexionar]       │ │

│ └─────────────────────┘ │

│                         │

│ Últimos gastos          │

│ \[Card] \[Card]           │

└─────────────────────────┘

```



\### Regla legal/producto



\* No dar consejo financiero profesional.

\* Usar lenguaje de reflexión y patrones personales.



\---



\## 19 — Pantry



\### Objetivo



Evitar desperdicio y compras innecesarias.



\### Croquis



```text

┌─────────────────────────┐

│ Pantry                  │

│ Usa lo que ya tienes    │

│                         │

│ \[Añadir alimento]       │

│                         │

│ Urgente                 │

│ ┌─────────────────────┐ │

│ │ Lechuga             │ │

│ │ vence mañana        │ │

│ │ \[Marcar usado]      │ │

│ └─────────────────────┘ │

│                         │

│ Ideas rápidas           │

│ \[Ensalada 10 min]       │

└─────────────────────────┘

```



\---



\## 20 — Week



\### Objetivo



Semana realista, no calendario completo.



\### Croquis



```text

┌─────────────────────────┐

│ Week                    │

│ Tu semana realista      │

│                         │

│ \[Replanificar]          │

│                         │

│ Carga por día           │

│ Lun ▓▓▓                 │

│ Mar ▓▓                  │

│ Mié ▓▓▓▓                │

│                         │

│ Riesgo                  │

│ Miércoles sobrecargado  │

└─────────────────────────┘

```



\---



\## 21 — Closet



\### Objetivo



Anti-compra, no catálogo pesado.



\### Croquis



```text

┌─────────────────────────┐

│ Closet                  │

│ Compra con pausa        │

│                         │

│ \[Nueva intención]       │

│                         │

│ Intención activa        │

│ ┌─────────────────────┐ │

│ │ Zapatillas nuevas   │ │

│ │ Espera 24h          │ │

│ │ \[Pausar compra]     │ │

│ └─────────────────────┘ │

└─────────────────────────┘

```



\---



\## 22 — Shopping



\### Objetivo



Decisiones de compra con evidencia y límites.



\### Croquis



```text

┌─────────────────────────┐

│ Shopping                │

│ Antes de comprar        │

│                         │

│ Alerta                  │

│ ┌─────────────────────┐ │

│ │ Compra impulsiva?   │ │

│ │ Espera 24 horas     │ │

│ │ \[Ver evidencia]     │ │

│ └─────────────────────┘ │

│                         │

│ \[Añadir intención]      │

└─────────────────────────┘

```



\---



\## 23 — Decisions



\### Objetivo



Resolver conflictos cotidianos entre dominios.



\### Croquis



```text

┌─────────────────────────┐

│ Decisions               │

│ Trade-offs claros       │

│                         │

│ Decisión principal      │

│ ┌─────────────────────┐ │

│ │ Cocinar vs comprar  │ │

│ │ Recomendación:      │ │

│ │ cocinar 15 min      │ │

│ │ \[Por qué] \[Aceptar] │ │

│ └─────────────────────┘ │

└─────────────────────────┘

```



\---



\## 24 — Calendar



\### Objetivo



Mostrar carga temporal, no competir con Google Calendar.



\### Croquis



```text

┌─────────────────────────┐

│ Calendar                │

│ Tiempo y energía        │

│                         │

│ Hoy                     │

│ 09:00 Trabajo           │

│ 13:00 Comida            │

│ 18:00 Bloque personal   │

│                         │

│ Riesgo: poco espacio    │

│ para tarea larga        │

└─────────────────────────┘

```



\---



\## 25 — Recipes



\### Objetivo



Recetas de rescate con pantry, no app culinaria completa.



\### Croquis



```text

┌─────────────────────────┐

│ Recipes                 │

│ Cocina lo que vence     │

│                         │

│ Rescate recomendado     │

│ ┌─────────────────────┐ │

│ │ Ensalada rápida     │ │

│ │ 10 min              │ │

│ │ usa lechuga         │ │

│ │ \[Cocinar ahora]     │ │

│ └─────────────────────┘ │

└─────────────────────────┘

```



\---



\## 26 — Journal



\### Objetivo



Captura personal local, no terapia.



\### Croquis



```text

┌─────────────────────────┐

│ Journal                 │

│ Notas privadas          │

│                         │

│ \[Nueva nota]            │

│                         │

│ Local only              │

│ ┌─────────────────────┐ │

│ │ Hoy me siento...    │ │

│ │ No enviado a IA     │ │

│ └─────────────────────┘ │

└─────────────────────────┘

```



\### Regla legal/producto



\* No diagnóstico.

\* No terapia.

\* No prometer salud mental.



\---



\## 27 — Everyday



\### Objetivo



Vista de rutinas simples y repetibles.



\### Croquis



```text

┌─────────────────────────┐

│ Everyday                │

│ Pequeñas acciones       │

│                         │

│ Mañana                  │

│ \[Agua] \[Tarea crítica]  │

│                         │

│ Tarde                   │

│ \[Caminar 10 min]        │

│                         │

│ Noche                   │

│ \[Revisión breve]        │

└─────────────────────────┘

```



\---



\## 28 — HomeMemory



\### Objetivo



Recordatorios y memoria doméstica sin saturar.



\### Croquis



```text

┌─────────────────────────┐

│ Home Memory             │

│ Cosas que no quieres    │

│ olvidar                 │

│                         │

│ ┌─────────────────────┐ │

│ │ Filtro de agua      │ │

│ │ revisar viernes     │ │

│ └─────────────────────┘ │

│                         │

│ \[Añadir recuerdo]       │

└─────────────────────────┘

```



\---



\## 29 — Coach



\### Objetivo



IA explicativa, no chat vacío.



\### Croquis



```text

┌─────────────────────────┐

│ Coach                   │

│ Pregunta sobre tu día   │

│                         │

│ Sugerencias             │

│ \[¿Por qué esta misión?] │

│ \[Estoy cansado, ajusta] │

│ \[Qué no comprar hoy]    │

│                         │

│ ┌─────────────────────┐ │

│ │ Escribe aquí...     │ │

│ └─────────────────────┘ │

│                         │

│ \[Enviar]                │

└─────────────────────────┘

```



\### UX



\* La IA debe partir de contexto.

\* Mostrar privacidad: “Usando datos permitidos”.

\* No parecer ChatGPT genérico.



\---



\## 30 — Coach: respuesta explicable



\### Objetivo



Respuesta con acción, evidencia y límite.



\### Croquis



```text

┌─────────────────────────┐

│ Coach                   │

│                         │

│ Recomendación           │

│ Haz solo la tarea de    │

│ 12 minutos y mueve la   │

│ larga a mañana.         │

│                         │

│ Evidencia               │

│ • día sobrecargado      │

│ • hábito frágil         │

│ • poco tiempo libre     │

│                         │

│ Incertidumbre           │

│ No conozco tu energía   │

│ real ahora.             │

│                         │

│ \[Aplicar] \[No útil]     │

└─────────────────────────┘

```



\---



\## 31 — Settings: índice



\### Objetivo



Organizar ajustes sin ruido.



\### Croquis



```text

┌─────────────────────────┐

│ Settings                │

│                         │

│ Cuenta                  │

│ Premium                 │

│ Privacidad              │

│ IA y datos              │

│ Idioma                  │

│ Tema                    │

│ Exportar datos          │

│ Borrar datos            │

└─────────────────────────┘

```



\---



\## 32 — Privacy Dashboard



\### Objetivo



Mostrar control real de datos.



\### Croquis



```text

┌─────────────────────────┐

│ Privacy                 │

│                         │

│ Datos locales           │

│ 42 eventos              │

│                         │

│ Permitidos para IA      │

│ 18 eventos              │

│                         │

│ Bloqueados              │

│ 24 eventos              │

│                         │

│ Permisos por dominio    │

│ Tasks      AI allowed   │

│ Journal    Local only   │

│ Money      Local only   │

└─────────────────────────┘

```



\---



\## 33 — AI/Data Detail



\### Objetivo



Mostrar qué sale del dispositivo.



\### Croquis



```text

┌─────────────────────────┐

│ IA y datos              │

│                         │

│ Última misión           │

│ Datos usados:           │

│ • task summary          │

│ • pantry item           │

│                         │

│ No enviados:            │

│ • journal notes         │

│ • local-only finance    │

│                         │

│ \[Cambiar permisos]      │

└─────────────────────────┘

```



\---



\## 34 — Subscription / Billing



\### Objetivo



Estado claro del premium.



\### Croquis



```text

┌─────────────────────────┐

│ Premium                 │

│                         │

│ Estado: activo          │

│ Plan: mensual/anual     │

│                         │

│ Incluye                 │

│ ✓ misiones premium      │

│ ✓ memoria avanzada      │

│ ✓ explicaciones IA      │

│                         │

│ \[Gestionar suscripción] │

│ \[Restaurar compra]      │

└─────────────────────────┘

```



\---



\## 35 — Error / Offline / Fallback



\### Objetivo



Evitar pérdida de confianza cuando falla IA o red.



\### Croquis



```text

┌─────────────────────────┐

│ Modo local activo       │

│                         │

│ No pude conectar con IA │

│ ahora. Tus datos siguen │

│ en el dispositivo.      │

│                         │

│ Puedes seguir:          │

│ ✓ capturando            │

│ ✓ viendo memoria        │

│ ✓ usando misiones local │

│                         │

│ \[Reintentar]            │

└─────────────────────────┘

```



\---



\# Flujos principales



\## Flujo A — Primer uso ideal



```text

Splash

→ Onboarding promesa

→ Privacidad

→ Dominios iniciales

→ Premium Gate

→ Today vacío

→ Capture

→ Draft confirmation

→ Today con primera misión

```



\## Flujo B — Uso diario premium



```text

Open app

→ Today

→ Ver misión principal

→ Por qué hoy

→ Hacer ahora

→ Completar

→ Feedback

→ Today actualizado

```



\## Flujo C — Captura rápida



```text

Open app

→ Capture

→ Escribir frase

→ Entender

→ Confirmar drafts

→ Guardar

→ Today actualizado

```



\## Flujo D — Confianza y privacidad



```text

Today

→ Por qué

→ Datos usados

→ Privacy detail

→ Cambiar permiso

→ Volver a Today

```



\## Flujo E — Explorar dominios



```text

Memory

→ Dominios

→ Pantry / Tasks / Money

→ Ver item

→ Completar o editar

→ Volver a Today

```



\---



\# Prioridad de rediseño



\## P0 — Imprescindible



1\. Reemplazar top tabs móviles por bottom nav.

2\. Reducir navegación principal a 5 destinos.

3\. Rediseñar Today como pantalla central.

4\. Rediseñar Capture como input libre premium.

5\. Convertir LifeGraph visible en Memory.

6\. Compactar privacidad/evidencia.



\## P1 — Premium polish



1\. Componentes compartidos.

2\. Estados vacíos buenos.

3\. Estados offline/local.

4\. Animaciones suaves.

5\. Mejora de copy.

6\. Consistencia visual.



\## P2 — Después, solo si no abre nuevas features



1\. Mejor presentación de dominios.

2\. Más claridad en Coach.

3\. Mejor detalle de billing.

4\. Golden tests visuales.



\---



\# Definition of Done del redesign



La tarea se considera terminada cuando:



\* En móvil no aparecen 14 destinos principales.

\* La primera pantalla responde “qué hago ahora”.

\* Capture permite entender la app sin leer documentación.

\* Memory permite revisar datos sin parecer panel técnico.

\* Coach explica decisiones, no actúa como chat genérico.

\* Settings contiene privacidad y premium sin invadir Today.

\* Las pantallas de dominio existen, pero no dominan la experiencia.

\* El diseño se siente premium, claro, calmado y mobile-first.

\* No se añadieron features nuevas.

\* No se tocó `/admin`, `/studio` ni `/control`.



\---



\# Prompt final para IA local



```text

Trabaja solo sobre la app móvil Flutter de GoLife AI.

No toques /admin, /studio ni /control.

No añadas funcionalidades nuevas.

No cambies la lógica de negocio salvo lo mínimo para adaptar navegación y composición visual.



Objetivo:

Rediseñar la UI/UX mobile-first premium usando este storyboard.

La app debe dejar de sentirse como un dashboard con muchos módulos y pasar a sentirse como un sistema operativo personal de decisiones diarias.



Cambios centrales:

\- Shell móvil con bottom navigation de máximo 5 destinos: Today, Capture, Memory, Coach, Settings.

\- Ocultar módulos secundarios dentro de Memory/Domains o rutas internas.

\- Rediseñar Dashboard como Today.

\- Rediseñar Capture como entrada libre rápida.

\- Rediseñar LifeGraph como Memory.

\- Hacer Coach explicativo, no chat genérico.

\- Mantener privacidad/evidencia visibles pero compactas.

\- Crear componentes compartidos para consistencia premium.



Respeta:

\- Material 3.

\- Touch targets móviles.

\- Contraste y legibilidad.

\- Estados vacíos, offline y fallback.

\- Premium visual calmado, claro y profesional.



Entrega esperada:

1\. Cambios Flutter UI/UX.

2\. Sin features nuevas.

3\. Sin cambios en admin/studio/control.

4\. Tests básicos de navegación si existen.

5\. Resumen final de archivos tocados y verificación.

```



