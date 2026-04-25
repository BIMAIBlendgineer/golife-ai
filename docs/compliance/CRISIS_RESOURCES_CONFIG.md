# Crisis Resources Config

GoLife reflection safety uses configurable crisis resources. The goal is to return immediate support options without storing the user's raw reflection text in operational audit logs.

## Environment

- `CRISIS_RESOURCES_REGION`
  - selects the active region key
  - defaults to `global`
- `CRISIS_RESOURCES_CATALOG_PATH`
  - optional JSON file path
  - if present and valid, GoLife loads region resources from that file
  - if missing or invalid, GoLife falls back to the built-in catalog
  - repository sample: `services/ai_gateway/config/crisis_resources.catalog.json`

## JSON Shape

```json
{
  "global": [
    {
      "label": "Emergency services",
      "contact": "Your local emergency number",
      "description": "Use this if you might act on self-harm or feel in immediate danger.",
      "region": "global"
    }
  ],
  "tenant-es": [
    {
      "label": "Ayuda inmediata",
      "contact": "112-custom",
      "description": "Usa este recurso configurado por entorno.",
      "region": "tenant-es"
    }
  ]
}
```

## Built-in Regions

- `global`
- `us`
- `es`
- `br`

The built-in catalog ships with official or authority-backed crisis routes for the supported regions and a generic global fallback.

## Safety Boundary

- Reflection mode supports organization and reflection, not therapy or diagnosis.
- Crisis responses should return region-aware support resources.
- Operational audit should keep metadata only:
  - category
  - safe/unsafe result
  - endpoint
  - timestamp
- Raw crisis text must not be stored in admin telemetry.
- Mission feedback notes must not be copied into operational admin views either.
