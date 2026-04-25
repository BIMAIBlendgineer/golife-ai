from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any

from app.i18n import normalize_locale
from app.schemas import ProofParseRequest, ProofParseResponse

_DATE_RE = re.compile(r"(?P<date>20\d{2}[-/](?:0[1-9]|1[0-2])[-/](?:0[1-9]|[12]\d|3[01]))")
_WARRANTY_RE = re.compile(
    r"(?P<months>\d{1,3})\s*(?:months?|meses?|mes|mo|か月|ヶ月|个月|個月|月)",
    re.IGNORECASE,
)
_AMOUNT_PATTERNS = (
    re.compile(
        r"(?P<currency>USD|EUR|GBP|BRL|JPY|CNY|RMB)\s*(?P<amount>\d+(?:[.,]\d{1,2})?)",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?P<amount>\d+(?:[.,]\d{1,2})?)\s*(?P<currency>USD|EUR|GBP|BRL|JPY|CNY|RMB|元|円|¥|€|\$)",
        re.IGNORECASE,
    ),
)
_KNOWN_BRANDS = (
    "Dyson",
    "Philips",
    "Mondial",
    "Xiaomi",
    "Apple",
    "Samsung",
    "LG",
    "Zojirushi",
    "象印",
    "小米",
)
_STRINGS = {
    "en": {
        "rationale": "Parsed proof fields with deterministic local patterns.",
        "disclaimer": "Estimated fields from proof text. Verify with seller or manufacturer.",
    },
    "es": {
        "rationale": "Se extrajeron campos del comprobante con reglas locales deterministas.",
        "disclaimer": "Campos estimados desde el comprobante. Verifica con el vendedor o fabricante.",
    },
    "pt-BR": {
        "rationale": "Os campos do comprovante foram extraidos com regras locais deterministicas.",
        "disclaimer": "Campos estimados a partir do comprovante. Verifique com o vendedor ou fabricante.",
    },
    "ja": {
        "rationale": "決定的なローカル規則で証跡の項目を抽出しました。",
        "disclaimer": "証跡テキストから推定した項目です。販売店またはメーカーで確認してください。",
    },
    "zh-Hans": {
        "rationale": "已用确定性的本地规则提取凭证字段。",
        "disclaimer": "这些字段是根据凭证文本估算的，请向商家或制造商核实。",
    },
}


@dataclass(frozen=True)
class ParsedProofFields:
    product_name: str | None = None
    brand: str | None = None
    model: str | None = None
    merchant_name: str | None = None
    purchase_date: str | None = None
    total_amount: float | None = None
    currency: str | None = None
    warranty_months: int | None = None
    confidence: float = 0.55


def parse_purchase_proof_request(request: ProofParseRequest) -> ProofParseResponse:
    locale = normalize_locale(request.locale)
    text = " ".join(request.text.split()).strip()
    parsed = _parse_with_locale(text, locale)
    extracted_count = sum(
        1
        for value in (
            parsed.product_name,
            parsed.merchant_name,
            parsed.purchase_date,
            parsed.total_amount,
            parsed.warranty_months,
        )
        if value not in (None, "")
    )
    confidence = max(parsed.confidence, min(0.94, 0.46 + extracted_count * 0.1))
    strings = _STRINGS[locale]
    return ProofParseResponse(
        product_name=parsed.product_name,
        brand=parsed.brand,
        model=parsed.model,
        merchant_name=parsed.merchant_name,
        purchase_date=parsed.purchase_date,
        total_amount=parsed.total_amount,
        currency=parsed.currency,
        warranty_months=parsed.warranty_months,
        confidence=round(confidence, 2),
        rationale=strings["rationale"],
        disclaimer=strings["disclaimer"],
        trace={
            "parser": "deterministic_proof_parser",
            "locale": locale,
            "region": request.region,
            "has_amount": parsed.total_amount is not None,
            "has_date": bool(parsed.purchase_date),
            "has_warranty_hint": parsed.warranty_months is not None,
            "field_count": extracted_count,
        },
    )


def _parse_with_locale(text: str, locale: str) -> ParsedProofFields:
    parsers = [_parse_en, _parse_es, _parse_pt, _parse_ja, _parse_zh]
    prioritized = {
        "en": [_parse_en],
        "es": [_parse_es],
        "pt-BR": [_parse_pt],
        "ja": [_parse_ja],
        "zh-Hans": [_parse_zh],
    }.get(locale, [])
    seen: set[int] = set()
    for parser in [*prioritized, *parsers]:
        if id(parser) in seen:
            continue
        seen.add(id(parser))
        result = parser(text)
        if result.product_name or result.merchant_name or result.total_amount is not None:
            return result
    return _generic_parse(text)


def _parse_en(text: str) -> ParsedProofFields:
    pattern = re.compile(
        r"(?:bought|purchased)\s+(?P<product>.+?)(?:\s+from\s+(?P<merchant>.+?))?(?:\s+on\s+(?P<date>20\d{2}[-/]\d{2}[-/]\d{2}))?(?:\s+for\b|$)",
        re.IGNORECASE,
    )
    match = pattern.search(text)
    return _build_result(
        text=text,
        product=_group(match, "product"),
        merchant=_group(match, "merchant"),
        purchase_date=_group(match, "date"),
    )


def _parse_es(text: str) -> ParsedProofFields:
    pattern = re.compile(
        r"(?:compre|compré)\s+(?P<product>.+?)(?:\s+en\s+(?P<merchant>.+?))?(?:\s+el\s+(?P<date>20\d{2}[-/]\d{2}[-/]\d{2}))?(?:\s+por\b|$)",
        re.IGNORECASE,
    )
    match = pattern.search(text)
    return _build_result(
        text=text,
        product=_group(match, "product"),
        merchant=_group(match, "merchant"),
        purchase_date=_group(match, "date"),
    )


def _parse_pt(text: str) -> ParsedProofFields:
    pattern = re.compile(
        r"(?:comprei)\s+(?P<product>.+?)(?:\s+n[ao]\s+(?P<merchant>.+?))?(?:\s+em\s+(?P<date>20\d{2}[-/]\d{2}[-/]\d{2}))?(?:\s+por\b|$)",
        re.IGNORECASE,
    )
    match = pattern.search(text)
    return _build_result(
        text=text,
        product=_group(match, "product"),
        merchant=_group(match, "merchant"),
        purchase_date=_group(match, "date"),
    )


def _parse_ja(text: str) -> ParsedProofFields:
    pattern = re.compile(
        r"(?:(?P<date>20\d{2}[-/]\d{2}[-/]\d{2})に)?(?P<merchant>.+?)で(?P<product>.+?)を",
    )
    match = pattern.search(text)
    return _build_result(
        text=text,
        product=_group(match, "product"),
        merchant=_group(match, "merchant"),
        purchase_date=_group(match, "date"),
    )


def _parse_zh(text: str) -> ParsedProofFields:
    pattern = re.compile(
        r"(?:(?P<date>20\d{2}[-/]\d{2}[-/]\d{2})\s*)?在(?P<merchant>.+?)(?:购买|买了)(?P<product>.+?)(?:，|,|。|价格|价钱)",
    )
    match = pattern.search(text)
    return _build_result(
        text=text,
        product=_group(match, "product"),
        merchant=_group(match, "merchant"),
        purchase_date=_group(match, "date"),
    )


def _generic_parse(text: str) -> ParsedProofFields:
    date_match = _DATE_RE.search(text)
    amount, currency = _extract_amount_currency(text)
    warranty_months = _extract_warranty_months(text)
    product = _cleanup_product_name(
        re.sub(_DATE_RE, "", text).strip(" ,.;:"),
    )
    brand, model = _extract_brand_model(product)
    return ParsedProofFields(
        product_name=product or None,
        brand=brand,
        model=model,
        purchase_date=date_match.group("date") if date_match else None,
        total_amount=amount,
        currency=currency,
        warranty_months=warranty_months,
        confidence=0.52,
    )


def _build_result(
    *,
    text: str,
    product: str | None,
    merchant: str | None,
    purchase_date: str | None,
) -> ParsedProofFields:
    amount, currency = _extract_amount_currency(text)
    warranty_months = _extract_warranty_months(text)
    fallback_date = _DATE_RE.search(text)
    cleaned_product = _cleanup_product_name(product or "")
    brand, model = _extract_brand_model(cleaned_product)
    return ParsedProofFields(
        product_name=cleaned_product or None,
        brand=brand,
        model=model,
        merchant_name=_clean_value(merchant),
        purchase_date=purchase_date or (fallback_date.group("date") if fallback_date else None),
        total_amount=amount,
        currency=currency,
        warranty_months=warranty_months,
        confidence=0.62,
    )


def _extract_amount_currency(text: str) -> tuple[float | None, str | None]:
    for pattern in _AMOUNT_PATTERNS:
        match = pattern.search(text)
        if not match:
            continue
        amount_raw = match.group("amount").replace(",", ".")
        try:
            amount = float(amount_raw)
        except ValueError:
            continue
        return amount, _normalize_currency(match.group("currency"))
    return None, None


def _extract_warranty_months(text: str) -> int | None:
    match = _WARRANTY_RE.search(text)
    if not match:
        return None
    return int(match.group("months"))


def _normalize_currency(raw: str | None) -> str | None:
    if not raw:
        return None
    value = raw.strip().upper()
    aliases = {
        "$": "USD",
        "€": "EUR",
        "¥": "JPY",
        "円": "JPY",
        "元": "CNY",
        "RMB": "CNY",
    }
    return aliases.get(value, value)


def _extract_brand_model(product_name: str) -> tuple[str | None, str | None]:
    if not product_name:
        return None, None
    for known_brand in _KNOWN_BRANDS:
        if known_brand.lower() in product_name.lower():
            brand = known_brand
            model = product_name.replace(known_brand, "", 1).strip(" -")
            return brand, model or None
    parts = product_name.split()
    if len(parts) >= 2:
        return parts[0], " ".join(parts[1:])
    return None, None


def _cleanup_product_name(value: str) -> str:
    cleaned = value.strip(" ,.;:")
    cleaned = re.sub(
        r"\b(?:for|por|com|with|from|en|na|no|em)\b.*$",
        "",
        cleaned,
        flags=re.IGNORECASE,
    ).strip(" ,.;:")
    return cleaned


def _group(match: re.Match[str] | None, key: str) -> str | None:
    if not match:
        return None
    return _clean_value(match.group(key))


def _clean_value(value: str | None) -> str | None:
    if value is None:
        return None
    cleaned = value.strip().strip(" ,.;:")
    return cleaned or None
