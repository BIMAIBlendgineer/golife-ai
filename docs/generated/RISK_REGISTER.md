# GoLife AI Risk Register

Fecha: 2026-04-24

| ID | Riesgo | Probabilidad | Impacto | Mitigacion |
|---|---|---|---|---|
| R-001 | Copiar codigo GPL de Habo o WeekToDo dentro de GoLife | Alta | Alta | Politica de referencia solamente para GPL |
| R-002 | El repo `app` tenga procedencia/licencia distinta a la asumida | Media | Alta | Validar upstream antes de copiar archivos |
| R-003 | `Flow` ausente impida migrar `finance` con evidencia real | Alta | Media | Crear dominio financiero minimo propio y bloquear claims de paridad |
| R-004 | `OpenWardrobe db` ausente deje incompleta la estrategia de sync | Alta | Media | Diseñar sync opcional desacoplado y marcar schema como pendiente |
| R-005 | El prompt asume `source_repos/`, pero el workspace real difiere | Alta | Media | Documentar mapping real y trabajar sobre rutas verificadas |
| R-006 | Mezclar codigo de Flutter, Vue/Electron y Expo genere integraciones fragiles | Alta | Alta | Reescribir UI/estado por dominio bajo un shell Flutter nuevo |
| R-007 | Cobertura de tests insuficiente en Taskly y OpenWardrobe | Alta | Media | Añadir tests propios en cada migracion |
| R-008 | Integraciones externas (calendar, share, notifications, auth) violen la regla de confirmacion humana | Media | Alta | Encapsular acciones externas tras flujos de confirmacion |
| R-009 | Datos sensibles terminen expuestos al gateway IA sin permisos por dominio | Media | Alta | Implementar privacy gating antes de cualquier integracion IA |
| R-010 | Reescritura parcial de Habo rompa reglas de streak y sync | Media | Alta | Reimplementar con tests propios y sin copiar comportamiento ciegamente |
