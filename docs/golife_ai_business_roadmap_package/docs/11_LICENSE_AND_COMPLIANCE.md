# 11 — License and Compliance Strategy

## Estado observado

Verificación parcial de licencias mediante archivos `LICENSE` públicos:

- Habo: GPL-3.0.
- WeekToDo: GPL-3.0.
- Flow: GPL-3.0.
- OpenWardrobe/app: MIT.
- Wanna: MIT.
- Taskly: MIT.

## Implicación

### GPL-3.0

La GPL-3.0 permite usar, estudiar, modificar y distribuir el software bajo las condiciones de esa licencia. Si se distribuye una obra derivada, normalmente se debe distribuir bajo GPL-3.0 y ofrecer código fuente correspondiente.

### MIT

MIT es permisiva. Permite uso, copia, modificación, distribución, sublicencia y venta, manteniendo copyright y licencia.

## Recomendación para GoLife

### Para producto comercial cerrado

No copiar código GPL. Usar GPL solo como inspiración visual/funcional de alto nivel, sin copiar estructura, nombres internos, archivos, lógica específica ni assets.

### Para producto open-source

Puedes usar GPL como base, pero GoLife probablemente quedaría bajo GPL si integra código derivado GPL.

## Checklist obligatoria antes de codificar

- Crear `LICENSE_MATRIX.md`.
- Crear `COPYRIGHT_NOTICES.md`.
- Crear `THIRD_PARTY_ATTRIBUTIONS.md`.
- Crear `CLEAN_ROOM_LOG.md`.
- Marcar cada archivo como:
  - original;
  - adaptado;
  - copiado;
  - inspirado;
  - dependencia.

## Prohibiciones internas

- No copiar assets sin licencia clara.
- No copiar pantallas completas GPL si se busca app cerrada.
- No copiar modelos de datos internos sin revisión.
- No usar marcas de los repos originales.
- No decir que GoLife es continuación oficial de esos proyectos.

## Política de IA

El proveedor IA no debe recibir datos personales innecesarios.

Enviar solo contexto mínimo:

- eventos recientes;
- metas activas;
- preferencias;
- datos agregados.

No enviar:

- datos bancarios completos;
- información sensible sin consentimiento;
- fotos personales sin permiso explícito;
- ubicación precisa salvo necesidad clara.
