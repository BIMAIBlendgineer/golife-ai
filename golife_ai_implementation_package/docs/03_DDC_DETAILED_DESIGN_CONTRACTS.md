# DDC — Detailed Design Contracts

## Principio

La IA no debe modificar datos directamente. Debe producir propuestas estructuradas. La app valida, muestra y solicita confirmación.

## Contrato: LifeEvent

```json
{
  "event_id": "evt_...",
  "user_id": "usr_...",
  "domain": "task|habit|finance|wardrobe|pantry|mission|ai",
  "event_type": "task.created",
  "timestamp": "2026-04-24T12:00:00Z",
  "payload": {},
  "source": "manual|import|ai|system",
  "privacy_level": "local_only|sync_allowed|ai_allowed",
  "evidence_hash": "sha256..."
}
```

## Contrato: AISuggestion

```json
{
  "suggestion_id": "sug_...",
  "user_id": "usr_...",
  "title": "Cocina primero el pollo y tomate",
  "domain_targets": ["pantry", "finance", "habit"],
  "recommendation_type": "mission|plan_adjustment|task_rewrite|warning|reflection",
  "body": "Tienes pollo y tomate próximos a vencer y gastaste más de lo previsto en comida fuera.",
  "evidence": [
    {
      "source_domain": "pantry",
      "entity_id": "pantry_123",
      "claim": "pollo registrado hace 4 días",
      "confidence": 0.75
    }
  ],
  "confidence": 0.68,
  "uncertainty": "No hay fecha exacta de vencimiento; se usa estimación declarada.",
  "requires_confirmation": true,
  "forbidden_actions": ["purchase_without_confirmation", "delete_without_confirmation"],
  "status": "draft|shown|accepted|rejected|edited|expired"
}
```

## Contrato: Mission

```json
{
  "mission_id": "mis_...",
  "title": "Cena sin compra extra",
  "description": "Usa dos ingredientes disponibles y evita gasto externo.",
  "difficulty": "tiny|easy|medium|hard",
  "estimated_minutes": 20,
  "xp_reward": 25,
  "linked_domains": ["pantry", "finance"],
  "steps": [
    "Revisar pollo",
    "Cocinar arroz",
    "Registrar resultado"
  ],
  "success_metric": "user_marked_done",
  "expires_at": "2026-04-24T22:00:00Z"
}
```

## Contrato: ProviderInvocation

```json
{
  "provider": "openrouter",
  "model": "configurable",
  "request_id": "prov_...",
  "purpose": "mission_generation",
  "input_hash": "sha256...",
  "output_hash": "sha256...",
  "tokens_input": 0,
  "tokens_output": 0,
  "cost_estimate": null,
  "latency_ms": null,
  "fallback_used": false
}
```

## API AI Gateway

### POST `/v1/suggestions/generate`

Entrada:

```json
{
  "user_id": "usr_...",
  "scope": "daily|weekly|domain",
  "allowed_domains": ["task", "habit", "finance", "pantry"],
  "life_events": [],
  "constraints": {
    "max_suggestions": 3,
    "no_medical": true,
    "no_investment_advice": true,
    "requires_explanation": true
  }
}
```

Salida:

```json
{
  "suggestions": [],
  "trace": {
    "graph_run_id": "run_...",
    "provider_invocations": []
  }
}
```

### POST `/v1/tasks/rewrite`

Convierte tarea vaga en tareas pequeñas.

### POST `/v1/week/plan`

Propone planificación semanal editable.

### POST `/v1/missions/daily`

Genera una misión diaria.

### POST `/v1/pantry/rescue`

Propone acciones para reducir desperdicio.

### POST `/v1/finance/reflect`

Genera reflexión financiera no regulada.

### POST `/v1/closet/decision`

Evalúa intención de compra o outfit.

## Estados de sugerencia

```text
draft -> shown -> accepted -> completed
draft -> shown -> rejected
draft -> shown -> edited -> accepted
draft -> expired
```

## Reglas de seguridad

1. No borrar datos sin confirmación.
2. No comprar sin confirmación.
3. No enviar datos a IA si `privacy_level != ai_allowed`.
4. No dar diagnóstico médico.
5. No dar asesoría de inversión.
6. Toda recomendación debe incluir evidencias.
7. Toda confianza menor a 0.5 debe mostrarse como tentativa.
