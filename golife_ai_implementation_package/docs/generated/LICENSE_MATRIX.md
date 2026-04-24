# GoLife AI License Matrix

Fecha: 2026-04-24

## Resumen

| Repo / fuente | Ruta local | Licencia verificada | Tipo | Estado de copia directa hacia GoLife |
|---|---|---|---|---|
| Habo | `C:\0 Work\GoLife AI\Habo` | GPL-3.0 | Copyleft fuerte | NO RECOMENDADA |
| Taskly | `C:\0 Work\GoLife AI\Taskly` | MIT | Permisiva | POSIBLE CON ATRIBUCION Y TRAZABILIDAD |
| WeekToDo | `C:\0 Work\GoLife AI\weektodo` | GPL-3.0 | Copyleft fuerte | NO RECOMENDADA |
| Wanna | `C:\0 Work\GoLife AI\wanna` | MIT | Permisiva | POSIBLE CON ATRIBUCION Y ADAPTACION |
| OpenWardrobe app (`app`) | `C:\0 Work\GoLife AI\app` | MIT | Permisiva | POSIBLE, PERO PRIMERO VALIDAR PROCEDENCIA |
| Flow | NO ENCONTRADO | NO VERIFICADO | NO VERIFICADO | BLOQUEADO |
| OpenWardrobe db | NO ENCONTRADO | NO VERIFICADO | NO VERIFICADO | BLOQUEADO |

## Detalle por fuente

| Fuente | Evidencia local | Observacion | Decision operativa |
|---|---|---|---|
| Habo | `LICENSE` + README con GPL v3 | Copiar codigo convertiria el trabajo derivado en GPL en la practica | Usar solo como referencia funcional |
| Taskly | `LICENSE` MIT | Permite copia, modificacion y sublicencia con aviso | Se permite copia selectiva de utilidades y patrones |
| WeekToDo | `LICENSE` + README GPL | Ademas del problema GPL, el stack es Vue/Electron | Solo referencia conceptual |
| Wanna | `LICENSE` MIT | Stack Expo/React Native, no portable directo a Flutter | Copia puntual solo si el beneficio supera el costo de adaptacion |
| OpenWardrobe app | `LICENSE` MIT | El README indica OpenWardrobe, pero el copyright local dice `SUGGESTIED ✨` | Validar upstream antes de copiar archivos |
| Flow | NO VERIFICADO | No existe codigo local para auditar | No tomar decisiones hasta clonar o recibir repo |
| OpenWardrobe db | NO VERIFICADO | No existe codigo local para auditar | No tomar decisiones hasta clonar o recibir repo |

## Politica para GoLife

1. No copiar archivos GPL de Habo ni WeekToDo al nuevo producto.
2. Permitir solo copia selectiva y justificada desde repos MIT.
3. Registrar en cada archivo copiado:
   - repo origen;
   - ruta origen;
   - licencia;
   - modificaciones realizadas.
4. Si se valida posteriormente Flow y resulta GPL-3.0, tratar `finance` igual que Habo/WeekToDo: referencia, no copia.
5. OpenWardrobe app queda en estado `MIT pero con procedencia a validar`; no copiar hasta verificar que el repo local corresponde al proyecto upstream esperado.

## Advertencia

Esta matriz es tecnica y operativa. No sustituye revision legal formal antes de distribuir comercialmente GoLife.

## Estado de migracion en `new_app/golife_flutter`

Durante la implementacion inicial del prompt 04:

- no se copio ningun archivo fuente completo dentro de `new_app/golife_flutter`;
- los modelos de `tasks`, `pantry` y `wardrobe` se reescribieron como archivos propios tomando conceptos de repos MIT auditados;
- los modelos de `habits` y `week` se reescribieron en limpio y se marcaron en cabecera como `No GPL source copied`;
- `finance` se implemento como placeholder propio porque `Flow` no esta disponible localmente.
