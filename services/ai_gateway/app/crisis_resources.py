from __future__ import annotations

import json
from pathlib import Path

DEFAULT_CRISIS_RESOURCES: dict[str, list[dict[str, str]]] = {
    "global": [
        {
            "label": "Emergency services",
            "contact": "Call your local emergency number now",
            "description": "Use the official emergency number in your location if there is immediate danger or risk of self-harm.",
            "region": "global",
        },
        {
            "label": "Trusted person nearby",
            "contact": "Call or go to someone you trust right now",
            "description": "Stay with another person while the immediate crisis is active.",
            "region": "global",
        },
        {
            "label": "Local crisis line",
            "contact": "Use the official crisis or suicide prevention line available where you live",
            "description": "If you are outside the listed regions, use the local crisis service published by your health authority.",
            "region": "global",
        },
    ],
    "us": [
        {
            "label": "Emergency services",
            "contact": "911",
            "description": "Use 911 if there is immediate danger or you might act on self-harm right now.",
            "region": "us",
        },
        {
            "label": "988 Suicide and Crisis Lifeline",
            "contact": "Call or text 988",
            "description": "The official US 988 Lifeline offers free crisis support by phone or text, 24/7.",
            "region": "us",
        },
        {
            "label": "Someone with you now",
            "contact": "Ask a trusted person to stay with you",
            "description": "Do not stay alone while the immediate crisis is active.",
            "region": "us",
        },
    ],
    "es": [
        {
            "label": "Emergencias",
            "contact": "112",
            "description": "Usa el 112 si hay peligro inmediato o riesgo de hacerte dano ahora mismo.",
            "region": "es",
        },
        {
            "label": "Linea 024",
            "contact": "024",
            "description": "La linea 024 del Ministerio de Sanidad ofrece ayuda para conducta suicida las 24 horas.",
            "region": "es",
        },
        {
            "label": "Persona de confianza",
            "contact": "Llama o ve con alguien cercano ahora mismo",
            "description": "No te quedes solo mientras el riesgo inmediato siga activo.",
            "region": "es",
        },
    ],
    "br": [
        {
            "label": "Emergencia",
            "contact": "192 ou o numero de emergencia local",
            "description": "Use o servico de emergencia local se houver perigo imediato ou risco de se machucar agora.",
            "region": "br",
        },
        {
            "label": "CVV",
            "contact": "188",
            "description": "O CVV oferece apoio emocional e prevencao do suicidio por telefone, gratuitamente, 24 horas por dia.",
            "region": "br",
        },
        {
            "label": "Pessoa de confianca",
            "contact": "Ligue ou va para perto de alguem agora",
            "description": "Nao fique sozinho enquanto a crise imediata estiver ativa.",
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
