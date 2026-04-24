# Modelo de datos y privacidad

## Principio

GoLife maneja datos personales. Por defecto:

- local primero;
- mínima exposición a IA;
- permisos por dominio;
- exportación y borrado.

## Privacy levels

```text
local_only
sync_allowed
ai_allowed
```

### local_only

Dato solo local. No se sincroniza. No se envía a IA.

### sync_allowed

Dato puede sincronizarse con backend elegido por usuario.

### ai_allowed

Dato puede ser resumido y enviado al AI Gateway.

## Resumen antes de IA

No enviar datos crudos si basta un resumen.

Ejemplo incorrecto:

```json
{
  "all_transactions": [...]
}
```

Ejemplo correcto:

```json
{
  "finance_summary": {
    "period": "last_7_days",
    "food_outside_total": 43.20,
    "unusual_micro_purchases": 8
  }
}
```

## Datos por dominio

| Dominio | Sensibilidad | Enviar a IA por defecto |
|---|---:|---|
| Tasks | media | no |
| Habits | media | no |
| Finance | alta | no |
| Pantry | baja-media | no |
| Wardrobe | media | no |
| Missions | baja | sí, si no contiene datos sensibles |
| AI Trace | alta | no |

## Exportación

Formato mínimo:

```text
export/
  life_events.json
  tasks.json
  habits.json
  expenses.json
  pantry.json
  wardrobe.json
  missions.json
  ai_traces.json
```

## Derecho de borrado

Debe existir:

- borrar evento;
- borrar dominio;
- borrar memoria IA;
- borrar cuenta;
- revocar permiso IA.

## Logs

No guardar:

- texto completo de tareas sensibles;
- gasto con identificación excesiva;
- ubicaciones precisas sin necesidad;
- fotos sin consentimiento.

Guardar:

- hashes;
- contadores;
- estado de éxito/error;
- modelo usado;
- timestamp.
