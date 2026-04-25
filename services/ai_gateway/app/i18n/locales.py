from __future__ import annotations

SUPPORTED_LOCALES = ("en", "es", "pt-BR", "ja", "zh-Hans")

_LOCALE_ALIASES = {
    "en": "en",
    "en-us": "en",
    "en-gb": "en",
    "es": "es",
    "es-es": "es",
    "es-419": "es",
    "pt": "pt-BR",
    "pt-br": "pt-BR",
    "ja": "ja",
    "ja-jp": "ja",
    "zh": "zh-Hans",
    "zh-cn": "zh-Hans",
    "zh-hans": "zh-Hans",
}


def normalize_locale(locale: str | None) -> str:
    if not locale:
        return "en"

    normalized = locale.strip().replace("_", "-")
    if not normalized:
        return "en"

    lowered = normalized.lower()
    if lowered in _LOCALE_ALIASES:
        return _LOCALE_ALIASES[lowered]

    language = lowered.split("-", maxsplit=1)[0]
    if language in _LOCALE_ALIASES:
        return _LOCALE_ALIASES[language]

    return "en"
