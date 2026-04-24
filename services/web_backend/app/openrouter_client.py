from __future__ import annotations

from datetime import UTC, datetime

import httpx

from app.schemas import ModelCatalogEntry


async def fetch_openrouter_model_catalog(base_url: str) -> list[ModelCatalogEntry]:
    async with httpx.AsyncClient(timeout=20.0) as client:
        response = await client.get(f"{base_url.rstrip('/')}/models")
        response.raise_for_status()
        payload = response.json()

    refreshed_at = datetime.now(UTC)
    entries: list[ModelCatalogEntry] = []
    for raw in payload.get("data", []):
        if not isinstance(raw, dict):
            continue
        pricing = raw.get("pricing") or {}
        architecture = raw.get("architecture") or {}
        top_provider = raw.get("top_provider") or {}
        expiration_date = raw.get("expiration_date")
        entries.append(
            ModelCatalogEntry(
                model_id=str(raw.get("id") or ""),
                canonical_slug=raw.get("canonical_slug"),
                name=str(raw.get("name") or raw.get("id") or ""),
                description=raw.get("description"),
                context_length=int(raw.get("context_length") or 0),
                output_modalities=[
                    str(item)
                    for item in architecture.get("output_modalities", []) or []
                ],
                supported_parameters=[
                    str(item)
                    for item in raw.get("supported_parameters", []) or []
                ],
                prompt_price_usd_per_million=_per_million(pricing.get("prompt")),
                completion_price_usd_per_million=_per_million(pricing.get("completion")),
                request_price_usd=_as_float(pricing.get("request")),
                top_provider_json=top_provider if isinstance(top_provider, dict) else {},
                architecture_json=architecture if isinstance(architecture, dict) else {},
                expiration_date=(
                    datetime.fromisoformat(expiration_date.replace("Z", "+00:00"))
                    if isinstance(expiration_date, str) and expiration_date
                    else None
                ),
                refreshed_at=refreshed_at,
            )
        )
    return entries


def _per_million(value: object) -> float:
    return round(_as_float(value) * 1_000_000, 6)


def _as_float(value: object) -> float:
    if value is None:
        return 0.0
    try:
        return float(str(value))
    except (TypeError, ValueError):
        return 0.0

