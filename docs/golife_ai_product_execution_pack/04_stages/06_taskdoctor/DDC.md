# DDC — TaskDoctor

## Contratos mínimos
- CRUD tareas
- subtareas
- deadline
- prioridad
- kanban
- bloqueos
- reescritura IA
- misión completa tarea

## Reglas
- IDs estables.
- Fechas ISO-8601.
- Payload mínimo.
- Trace para IA.
- Metadata operacional sin contenido sensible.

## Ejemplo
```json
{
  "id": "example",
  "user_id": "local-user",
  "created_at": "2026-04-25T10:00:00Z"
}
```
