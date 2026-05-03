# ADR-000 — Tratar el roadmap como delta sobre el repo real

- Estado: aceptado
- Fecha: 2026-05-03

## Contexto

El roadmap de producción asumía un repositorio mucho más verde de lo que realmente existe hoy. La auditoría local confirmó que el producto ya tiene:

- app Flutter funcional y testeada
- AI gateway separado
- backend operacional
- panel admin
- CI monorepo
- persistencia local, capture, misiones, privacidad y export/delete local

Trabajar como si el repo estuviera en fase cero llevaría a duplicar trabajo y abrir refactors innecesarios.

## Decisión

Las siguientes fases deben planificarse como cierre de brechas reales, no como reconstrucción total del producto.

Reglas derivadas:

- priorizar auditoría verificable antes de cada bloque
- cerrar gaps quirúrgicos por superficie
- no rehacer módulos que ya validan
- documentar deuda real de gateway/backend/contracts
- mantener mobile, gateway, backend y admin ejecutables por separado

## Consecuencias

Positivas:

- menos retrabajo
- menor riesgo de romper flujos ya operativos
- roadmap más honesto respecto al estado actual

Negativas:

- obliga a convivir temporalmente con decisiones ya tomadas
- algunas fases del roadmap original quedan fusionadas o marcadas como ya cubiertas

## Próximos focos

1. bugs operacionales en gateway/backend
2. contratos canónicos compartidos
3. export/delete admin real
4. aceleración y estabilización de la suite del AI gateway
