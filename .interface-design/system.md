# GoLife Interface Design System

## Intent
- Human: operador interno que necesita ver rapido si GoLife esta generando misiones utiles, seguras y sostenibles en coste.
- Job: detectar degradacion de calidad, riesgo de confianza, presion de soporte y drift operacional sin navegar pantallas decorativas.
- Feel: tablero de campo sereno y tecnico, con calidez suficiente para no parecer fintech agresiva ni consola generica.

## Domain
- briefing diario
- mision util
- riesgo detectado
- soporte de privacidad
- coste IA
- rollout operacional
- trazabilidad
- ingestiones y latencia

## Color World
- `sand` / papel tibio para el canvas
- `paper` / superficie clara para paneles
- `ink` / texto principal y estructura
- `sage` / sistema sano, continuidad, utilidad
- `clay` / riesgo, error, friccion, intervencion
- `bronze` / coste, consumo, presion economica
- `sky` / informacion neutral y estado tecnico

## Signature
- El admin se comporta como una mesa operativa, no como una galeria de cards.
- Siempre hay tres capas visibles:
  - que esta pasando
  - por que importa
  - que accion operacional habilita

## Defaults Rejected
- Sidebar oscura SaaS generica -> sidebar del mismo mundo cromatico que el canvas, separada por borde suave.
- Grid de metric cards identicas sin narrativa -> metricas con tono semantico y nota explicativa operativa.
- Dashboard blanco/azul de template -> paleta tierra/sage/clay/bronze ligada a decisiones diarias, coste y confianza.

## Tokens
- `--paper`: fondo base del producto
- `--paper-strong`: superficie clara
- `--paper-soft`: panel elevado suave
- `--ink`: texto principal
- `--ink-soft`: texto secundario
- `--ink-muted`: metadatos
- `--line`: borde suave
- `--line-strong`: borde de accion
- `--sage`: positivo
- `--clay`: riesgo/error
- `--bronze`: coste/finance
- `--sky`: informacion

## Depth Strategy
- Solo bordes suaves + cambios minimos de superficie.
- Sin sombras dramaticas.
- El contraste debe salir de la jerarquia de contenido, no del efecto visual.

## Typography
- Sans principal: `IBM Plex Sans` o equivalente sobrio.
- Monospace: `IBM Plex Mono` para ids, endpoints, scores y numeros operativos.
- Headings compactos, tracking negativo leve.
- Labels en uppercase pequenas para reforzar lectura de tablero.

## Spacing
- Base: `4px`
- Ritmos frecuentes:
  - `8px` micro gap
  - `12px` gap de control
  - `16px` bloque corto
  - `20px`/`24px` panel y card
  - `32px+` separacion de secciones

## Primitives
- `PageShell`
  - barra superior con estado global del backend
  - sidebar fija en desktop
  - contenido principal con ritmo vertical consistente
- `PageHeader`
  - eyebrow operativo
  - titulo directo
  - descripcion de por que importa
  - badge corto si aporta contexto
- `Panel`
  - modulo con encabezado breve y nota operativa
  - fondo `paper-soft`
  - borde suave
- `MetricCard`
  - numero dominante
  - nota que explica la accion o el riesgo
  - tono semantico solo si tiene significado real
- `StatusPill`
  - `good`, `warn`, `danger`, `info`, `neutral`
  - nunca usar mas de lo necesario por fila
- `ErrorBanner`
  - para fallback snapshot o degradacion
  - debe dejar claro que no es dato live

## Data States
- `LIVE DATA`
  - backend operacional disponible
  - usar tono `sage`
- `FALLBACK SNAPSHOT`
  - pagina renderizada con snapshot local
  - usar tono `bronze` o `clay` segun gravedad
- `BACKEND OFFLINE`
  - backend no accesible
  - usar tono `clay`
- `EMPTY`
  - explicar ausencia de datos y la proxima accion esperada
- `ERROR`
  - explicar el problema sin exponer payload sensible

## Page Rule
Cada pagina admin debe responder en menos de un scroll:
1. que esta pasando
2. por que importa
3. que accion operacional permite

## Content Rules
- No mostrar payload sensible completo.
- Los textos deben sonar a operacion de producto, no a marketing.
- Las metricas deben incluir significado, no solo numero.
- Si una vista usa fallback, debe decirlo explicitamente.

## Reusable Patterns
- Summary strip arriba del contenido con estado global de backend y ultima ingestion.
- Cards de tres o cuatro columnas para north star + health + cost + trust.
- Listas auditables en bloques blandos con pills de estado.
- IDs tecnicos en monospace y texto explicativo en secondary ink.
