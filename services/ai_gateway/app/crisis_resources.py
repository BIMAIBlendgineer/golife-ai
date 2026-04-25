from __future__ import annotations

import json
from pathlib import Path

DEFAULT_CRISIS_RESOURCES: dict[str, list[dict[str, str]]] = {
    "global": [
        {
            "label": "Emergency services",
            "contact": "Your local emergency number",
            "description": "Use this if you might act on self-harm or feel in immediate danger.",
            "region": "global",
        },
        {
            "label": "Local crisis line",
            "contact": "Your local crisis or suicide prevention line",
            "description": "Use the official crisis line available in your country or city.",
            "region": "global",
        },
        {
            "label": "Trusted person nearby",
            "contact": "Call or go to someone you trust right now",
            "description": "Stay with another person until immediate danger has passed.",
            "region": "global",
        },
    ],
    "es": [
        {
            "label": "Emergencias",
            "contact": "Tu numero local de emergencias",
            "description": "Usalo si crees que puedes hacerte dano o si hay peligro inmediato.",
            "region": "es",
        },
        {
            "label": "Linea de crisis local",
            "contact": "Tu recurso local de crisis o prevencion del suicidio",
            "description": "Busca la linea oficial de tu comunidad o pais si necesitas apoyo inmediato.",
            "region": "es",
        },
        {
            "label": "Persona de confianza",
            "contact": "Llama o ve con alguien cercano ahora mismo",
            "description": "No te quedes solo si sientes riesgo inmediato.",
            "region": "es",
        },
    ],
    "us": [
        {
            "label": "Emergency services",
            "contact": "Local emergency number",
            "description": "Use this if you might act on self-harm or face immediate danger.",
            "region": "us",
        },
        {
            "label": "Crisis support",
            "contact": "Local crisis or suicide prevention service",
            "description": "Use the official crisis resource available where you live.",
            "region": "us",
        },
        {
            "label": "Trusted person nearby",
            "contact": "Call or go to someone you trust now",
            "description": "Stay near another person until the immediate crisis eases.",
            "region": "us",
        },
    ],
    "br": [
        {
            "label": "Emergencia",
            "contact": "Numero local de emergencia",
            "description": "Use se houver risco imediato de se machucar ou perigo urgente.",
            "region": "br",
        },
        {
            "label": "Apoio de crise",
            "contact": "Servico local de crise ou prevencao ao suicidio",
            "description": "Use o recurso oficial disponivel na sua regiao.",
            "region": "br",
        },
        {
            "label": "Pessoa de confianca",
            "contact": "Ligue ou va para perto de alguem agora",
            "description": "Nao fique sozinho se estiver em risco imediato.",
            "region": "br",
        },
    ],
}


def resolve_crisis_resources(
    *,
    region: str,
    catalog_path: str | None = None,
) -> list[dict[str, str]]:
    normalized_region = (region or "global").strip().lower()
    catalog = _load_catalog_override(catalog_path) or DEFAULT_CRISIS_RESOURCES
    return list(catalog.get(normalized_region) or catalog.get("global") or [])


def _load_catalog_override(catalog_path: str | None) -> dict[str, list[dict[str, str]]] | None:
    if not catalog_path:
        return None

    path = Path(catalog_path)
    if not path.exists():
        return None

    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None

    if not isinstance(raw, dict):
        return None

    parsed: dict[str, list[dict[str, str]]] = {}
    for key, value in raw.items():
        if not isinstance(key, str) or not isinstance(value, list):
            continue
        items: list[dict[str, str]] = []
        for item in value:
            if not isinstance(item, dict):
                continue
            items.append(
                {
                    "label": str(item.get("label", "")).strip(),
                    "contact": str(item.get("contact", "")).strip(),
                    "description": str(item.get("description", "")).strip(),
                    "region": str(item.get("region", key)).strip().lower(),
                }
            )
        if items:
            parsed[key.strip().lower()] = items
    return parsed or None
