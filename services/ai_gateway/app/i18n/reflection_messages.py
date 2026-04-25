from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

from app.i18n.locales import normalize_locale

_DEFAULT_CATALOG_PATH = (
    Path(__file__).resolve().parents[2] / "config" / "reflection_safety_messages.json"
)


@lru_cache(maxsize=4)
def _load_catalog(path: str | None = None) -> dict[str, dict[str, str]]:
    catalog_path = Path(path) if path else _DEFAULT_CATALOG_PATH
    return json.loads(catalog_path.read_text(encoding="utf-8"))


def resolve_reflection_messages(
    locale: str | None,
    *,
    catalog_path: str | None = None,
) -> dict[str, str]:
    catalog = _load_catalog(catalog_path)
    normalized = normalize_locale(locale)
    return catalog.get(normalized) or catalog["en"]
