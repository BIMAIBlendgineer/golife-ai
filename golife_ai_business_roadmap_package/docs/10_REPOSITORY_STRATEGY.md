# 10 — Repository Strategy

## Repos base para auditoría

| Módulo | Repo | URL | Stack observado | Licencia observada |
|---|---|---|---|---|
| LifeQuest AI | Habo | `https://github.com/xpavle00/Habo.git` | Flutter/Dart | GPL-3.0 verified from LICENSE |
| WeekPilot AI | WeekToDo | `https://github.com/manuelernestog/weektodo.git` | Vue/Electron | GPL-3.0 verified from LICENSE |
| MoneyMirror AI | Flow | `https://github.com/flow-mn/flow.git` | Flutter/Dart | GPL-3.0 verified from LICENSE |
| ClosetLess AI | OpenWardrobe/app | `https://github.com/OpenWardrobe/app.git` | Flutter/Supabase | MIT verified from LICENSE; repository observed as archived in metadata |
| FridgeZero AI | Wanna | `https://github.com/leechy/wanna.git` | Expo/React Native/Supabase | MIT verified from LICENSE |
| TaskDoctor AI | Taskly | `https://github.com/IMGIITRoorkee/Taskly.git` | Flutter/Dart | MIT verified from LICENSE |

## Comando de clonación

Ver `scripts/clone_repos.sh` y `scripts/clone_repos.ps1`.

## Estrategia recomendada

### No hacer

No unir carpetas de seis repos directamente.

Eso crea problemas:

- dependencias incompatibles;
- licencias incompatibles;
- arquitectura fragmentada;
- UX inconsistente;
- deuda técnica inmediata.

### Hacer

1. Clonar repos en carpeta `references/`.
2. Auditar funcionalidades.
3. Extraer conceptos, no copiar código.
4. Crear GoLife desde cero si quieres control comercial.
5. Reutilizar código solo donde licencia y arquitectura sean compatibles.
6. Documentar cada archivo copiado o adaptado.

## Ruta legal recomendada

### Si quieres producto cerrado/comercial

Usar ruta **clean-room**:

- no copiar código GPL;
- diseñar modelos propios;
- usar dependencias permisivas;
- mantener registro de inspiración funcional;
- crear app desde cero.

### Si aceptas open-source GPL

Puedes forkear módulos GPL, pero debes asumir obligaciones GPL si distribuyes trabajo derivado.

## Capa de unión

GoLife no debe ser una mezcla visual de apps. Debe tener una capa nueva:

```text
LifeGraph
  ├─ Task events
  ├─ Habit events
  ├─ Money events
  ├─ Pantry events
  ├─ Wardrobe events
  └─ AI recommendations
```

Los módulos antiguos son referencias funcionales. El producto real es el LifeGraph + agentes IA.
