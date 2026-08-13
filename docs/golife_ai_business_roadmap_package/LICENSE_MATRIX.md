# GoLife AI License Matrix

Fecha: 2026-04-24

## Contexto del workspace

El prompt espera `references/`, pero en este workspace los repos auditables estan en la raiz:

- `C:\0 Work\GoLife AI\Habo`
- `C:\0 Work\GoLife AI\Taskly`
- `C:\0 Work\GoLife AI\wanna`
- `C:\0 Work\GoLife AI\weektodo`
- `C:\0 Work\GoLife AI\app` (repo local apuntando a `OpenWardrobe/app`)

`flow` y `openwardrobe-db` no existen localmente, por lo que quedan como `NO VERIFICADO`.

## Matriz

| Repo | Ruta local | Licencia verificada | Uso comercial cerrado recomendado |
|---|---|---|---|
| xpavle00/Habo | `Habo` | GPL-3.0 | No copiar codigo; usar solo como referencia o aceptar GPL |
| manuelernestog/weektodo | `weektodo` | GPL-3.0 | No copiar codigo; usar solo como referencia o aceptar GPL |
| flow-mn/flow | NO ENCONTRADO | NO VERIFICADO | Bloqueado hasta disponer del repo local |
| OpenWardrobe/app | `app` | MIT | Potencialmente reusable con atribucion, pero validar procedencia del repo local antes de copiar archivos |
| OpenWardrobe/db | NO ENCONTRADO | NO VERIFICADO | Bloqueado hasta disponer del repo local |
| leechy/wanna | `wanna` | MIT | Reutilizacion selectiva posible con atribucion |
| IMGIITRoorkee/Taskly | `Taskly` | MIT | Reutilizacion selectiva posible con atribucion |

## Reglas operativas para GoLife AI

1. Ruta por defecto: `clean-room rebuild`.
2. No copiar archivos GPL dentro de un producto comercial cerrado.
3. Permitir solo copia selectiva desde fuentes MIT y documentarla por archivo.
4. Validar la procedencia del repo local `app` antes de copiar codigo de armario.
5. No tomar decisiones sobre `Flow` ni `OpenWardrobe/db` sin codigo local verificable.

## Estado actual de migracion permitido

| Dominio GoLife | Fuente | Permiso |
|---|---|---|
| tasks | Taskly | `adapt/rewrite` |
| pantry | Wanna | `adapt/rewrite` |
| wardrobe | OpenWardrobe/app | `hold until provenance verified` |
| habits | Habo | `inspiration only` |
| planning | WeekToDo | `inspiration only` |
| money | Flow | `blocked` |

No es asesoramiento legal. Antes de distribuir comercialmente, revisar con counsel.
