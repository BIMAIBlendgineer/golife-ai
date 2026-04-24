# GoLife AI — Business + Implementation Roadmap Package

Fecha: 2026-04-24

## Propósito

Este paquete define cómo convertir la idea **GoLife AI** en un producto móvil nuevo: una app única que une hábitos, tareas, planificación semanal, dinero, despensa y armario en un sistema de vida asistido por IA.

La tesis del producto:

> GoLife AI no es otra app de productividad. Es un sistema operativo personal que transforma datos cotidianos en misiones pequeñas, decisiones mejores y ahorro real.

## Decisión crítica

No se recomienda mezclar directamente código de todos los repositorios en un único producto sin auditoría legal y técnica. Este paquete propone dos rutas:

1. **Ruta A — Fork GPL/open-source**: usar repos GPL como base y aceptar obligaciones GPL.
2. **Ruta B — Clean-room comercial**: usar repos como inspiración funcional/documental, pero reconstruir GoLife desde cero con código propio y dependencias permisivas.

## Índice

- `docs/01_PRODUCT_VISION.md`
- `docs/02_APP_MASTER_FLOW.md`
- `docs/03_BUSINESS_STRATEGY.md`
- `docs/04_MONETIZATION.md`
- `docs/05_FODA.md`
- `docs/06_CAME.md`
- `docs/07_ROADMAP_MASTER.md`
- `docs/08_ROADMAP_90_DAYS.md`
- `docs/09_MVP_SCOPE.md`
- `docs/10_REPOSITORY_STRATEGY.md`
- `docs/11_LICENSE_AND_COMPLIANCE.md`
- `architecture/PDR_PRODUCT_DEFINITION.md`
- `architecture/DDD_DOMAIN_DESIGN.md`
- `architecture/DDC_CONTRACTS.md`
- `architecture/SPEC_AI_SYSTEM.md`
- `architecture/adr/`
- `prompts/MASTER_PROMPT_FOR_AI_CODER.md`
- `scripts/clone_repos.sh`
- `scripts/clone_repos.ps1`

## Resultado esperado del MVP

Una app móvil con:

- captura rápida de tareas, hábitos, gastos, compras, despensa y ropa;
- panel diario tipo “misiones”;
- agente IA que organiza la semana;
- agente IA que detecta bloqueos de tareas;
- agente IA de gasto consciente;
- agente IA de compra mínima;
- explicaciones simples, no mágicas;
- provider inicial OpenRouter;
- AI Gateway aislado para poder cambiar proveedor;
- memoria `LifeGraph` basada en eventos.

## Advertencia

No es asesor financiero, médico, psicológico ni legal. GoLife AI debe usar lenguaje asistivo y explicable. Las recomendaciones deben ser presentadas como apoyo a la decisión del usuario.
