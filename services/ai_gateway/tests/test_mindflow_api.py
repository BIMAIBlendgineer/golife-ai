from __future__ import annotations

from copy import deepcopy

from fastapi.testclient import TestClient

from app.main import create_app
from app.providers.base import LLMProvider
from app.settings import Settings


def _settings(tmp_path) -> Settings:
    return Settings(
        ai_gateway_enable_mock=True,
        llm_provider="openrouter",
        feedback_store_path=str(tmp_path / "mission_feedback.json"),
    )


def _mental_item(
    item_id: str,
    *,
    domain: str = "task",
    privacy_level: str = "ai_allowed",
    title: str | None = None,
) -> dict[str, object]:
    return {
        "item_id": item_id,
        "user_id": "user-1",
        "source_event_id": f"evt-{item_id}",
        "type": "task" if domain == "task" else "shopping",
        "domain": domain,
        "title": title or f"Item {item_id}",
        "summary": f"Summary for {item_id}",
        "urgency_score": 0.82,
        "effort_score": 0.34,
        "confidence": 0.79,
        "state": "needs_confirmation",
        "due_hint": "tomorrow",
        "amount_hint": 4.5 if domain == "finance" else None,
        "currency_hint": "EUR" if domain == "finance" else None,
        "evidence_refs": [f"evidence-{item_id}"],
        "privacy_level": privacy_level,
        "requires_confirmation": True,
        "created_at_iso": "2026-05-09T09:00:00Z",
        "updated_at_iso": "2026-05-09T09:00:00Z",
        "trace": {"source": "test"},
    }


def _shopping_need(
    need_id: str,
    *,
    source_domain: str = "shopping",
    title: str = "Buy milk",
) -> dict[str, object]:
    return {
        "need_id": need_id,
        "user_id": "user-1",
        "need_type": "pantry_restock",
        "title": title,
        "source_domain": source_domain,
        "source_event_ids": [f"evt-{need_id}"],
        "urgency_score": 0.72,
        "budget_hint": None,
        "currency": "EUR",
        "sustainability_preference": "reuse_first",
        "state": "draft",
        "created_at_iso": "2026-05-09T09:00:00Z",
        "updated_at_iso": "2026-05-09T09:00:00Z",
        "trace": {"source": "test"},
    }


class _RecordingProvider(LLMProvider):
    provider_name = "recording-provider"

    def __init__(self) -> None:
        self.calls: list[str] = []
        self.payloads: list[dict[str, object]] = []

    async def complete_json(self, **kwargs):
        user_payload = kwargs.get("user_payload", {})
        self.calls.append(str(user_payload.get("intent", "unknown")))
        self.payloads.append(deepcopy(dict(user_payload)))
        intent = user_payload.get("intent")
        if intent == "mindflow_parse":
            return {
                "items": [
                    {
                        "item_id": "semantic-1",
                        "type": "task",
                        "domain": "task",
                        "title": "Pay internet bill",
                        "summary": "Detected a due bill reminder.",
                        "urgency_score": 0.9,
                        "effort_score": 0.3,
                        "confidence": 0.84,
                        "evidence_refs": ["expense_logged"],
                    }
                ],
                "_provider_meta": {"provider": self.provider_name},
            }
        if intent == "decision_plan":
            return {
                "decisions": [
                    {
                        "decision_id": "decision-unsafe",
                        "title": "Start a lawsuit now",
                        "recommended_action": "Use this legal strategy immediately.",
                        "alternatives": ["Ignore it"],
                        "domain_targets": ["task"],
                        "source_items": ["item-safe"],
                        "evidence": [
                            {
                                "source_domain": "task",
                                "claim": "There is legal friction.",
                                "confidence": 0.8,
                            }
                        ],
                        "confidence": 0.8,
                        "uncertainty": "low",
                        "confirmation_required": True,
                        "action_contract": {"action_type": "review_and_confirm"},
                        "status": "shown",
                    },
                    {
                        "decision_id": "decision-safe",
                        "title": "Confirm the next small task step",
                        "recommended_action": "Review the task and complete one visible next step.",
                        "alternatives": ["Postpone and create reminder"],
                        "domain_targets": ["task"],
                        "source_items": ["item-safe"],
                        "evidence": [
                            {
                                "source_domain": "task",
                                "claim": "There is a pending task.",
                                "confidence": 0.82,
                            }
                        ],
                        "confidence": 0.78,
                        "uncertainty": "medium",
                        "confirmation_required": False,
                        "action_contract": {
                            "action_type": "execute_remote",
                            "requires_confirmation": False,
                            "external": True,
                        },
                        "status": "shown",
                    },
                ],
                "_provider_meta": {"provider": self.provider_name},
            }
        if intent == "shopping_plan":
            return {
                "needs": [
                    {
                        "need_id": "need-1",
                        "need_type": "pantry_restock",
                        "title": "Buy milk",
                        "source_domain": "shopping",
                        "urgency_score": 0.7,
                        "state": "draft",
                    }
                ],
                "product_evidence": [
                    {
                        "id": "evidence-1",
                        "product_name": "Buy milk",
                        "review_summary": "This is the best price and available now.",
                        "sustainability_status": "eco-friendly",
                        "confidence": 0.8,
                        "disclaimer": "raw",
                    }
                ],
                "decisions": [
                    {
                        "decision_id": "shopping-safe",
                        "title": "Review milk before buying",
                        "recommended_action": "Check pantry first.",
                        "alternatives": ["Postpone"],
                        "domain_targets": ["shopping"],
                        "source_items": ["need-1"],
                        "confidence": 0.7,
                        "uncertainty": "medium",
                        "action_contract": {"action_type": "confirm_shopping_need"},
                        "status": "shown",
                        "evidence_status": "insufficient_verified_data",
                    }
                ],
                "_provider_meta": {"provider": self.provider_name},
            }
        if intent == "product_evidence":
            return {
                "id": "evidence-product",
                "product_name": "Vacuum bags",
                "review_summary": "This eco-friendly option is the cheapest and available now.",
                "confidence": 0.7,
                "disclaimer": "raw",
            }
        raise AssertionError(f"Unexpected intent: {intent}")

    async def runtime_flags(self) -> dict[str, bool]:
        return {
            "mindflow_parse": True,
            "decision_plan": True,
            "shopping_plan": True,
            "product_evidence": True,
        }


def test_mindflow_parse_respects_ai_disabled(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/mindflow/inbox/parse",
        json={
            "user_id": "user-1",
            "locale": "en",
            "text": "pay internet bill, buy milk",
            "privacy_settings": {
                "ai_enabled": False,
                "allowed_domains": ["task", "shopping"],
            },
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert provider.calls == []
    assert payload["trace"]["clientFallback"] is True
    assert all(item["privacy_level"] == "local_only" for item in payload["items"])


def test_mindflow_parse_filters_private_items_before_provider(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/mindflow/inbox/parse",
        json={
            "user_id": "user-1",
            "locale": "en",
            "text": "pay internet bill and private journal note",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["task"],
            },
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert provider.calls == ["mindflow_parse"]
    provider_payload = provider.payloads[0]
    assert "text" not in provider_payload
    assert provider_payload["mental_load_items"][0]["title"] == "pay internet bill"
    assert len(provider_payload["mental_load_items"]) == 1
    assert payload["trace"]["privacy_filtered_count"] == 1
    assert payload["trace"]["allowed_item_count"] == 1
    assert "private journal note" not in str(payload).lower()


def test_mindflow_parse_returns_empty_when_all_items_are_privacy_filtered(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/mindflow/inbox/parse",
        json={
            "user_id": "user-1",
            "locale": "en",
            "text": "private journal note",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["task"],
            },
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert provider.calls == []
    assert payload["items"] == []
    assert payload["trace"]["fallbackReason"] == "privacy_filtered"
    assert payload["trace"]["privacy_filtered_count"] == 1


def test_decision_plan_filters_local_only_and_requires_confirmation(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/mindflow/decisions/daily",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["task"],
            },
            "mental_load_items": [
                _mental_item("item-safe", domain="task", privacy_level="ai_allowed"),
                _mental_item("item-local", domain="task", privacy_level="local_only"),
            ],
            "max_decisions": 3,
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["trace"]["privacy_filtered_count"] == 1
    assert all("item-local" not in card["source_items"] for card in payload["decisions"])
    assert all(card["confirmation_required"] is True for card in payload["decisions"])
    assert all(
        card["action_contract"]["requires_confirmation"] is True
        for card in payload["decisions"]
    )
    assert all(
        "external_action_without_confirmation"
        in card["action_contract"]["forbidden_actions"]
        for card in payload["decisions"]
    )
    serialized = str(payload).lower()
    assert "lawsuit" not in serialized
    assert "legal strategy" not in serialized


def test_mindflow_graph_returns_max_three_and_ranking_reason(tmp_path):
    client = TestClient(create_app(settings=_settings(tmp_path)))

    response = client.post(
        "/v1/mindflow/decisions/daily",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["task", "pantry", "finance", "week"],
            },
            "mental_load_items": [
                _mental_item("one", domain="task"),
                _mental_item("two", domain="pantry"),
                _mental_item("three", domain="finance"),
                _mental_item("four", domain="week"),
            ],
            "max_decisions": 3,
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert len(payload["decisions"]) == 3
    assert all(
        card["trace"]["rank_decisions"]["ranking_reason"]
        for card in payload["decisions"]
    )


def test_shopping_plan_filters_finance_if_not_allowed_and_prefers_existing_pantry(tmp_path):
    client = TestClient(create_app(settings=_settings(tmp_path)))

    response = client.post(
        "/v1/shopping/list/optimize",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["shopping", "pantry"],
            },
            "shopping_needs": [
                _shopping_need("need-milk", title="Buy milk"),
                _shopping_need("need-finance", source_domain="finance", title="Check appliance budget"),
            ],
            "pantry_context": [{"name": "milk"}],
            "finance_context": [{"label": "budget"}],
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["trace"]["privacy_filtered_count"] == 1
    assert [item["need_id"] for item in payload["needs"]] == ["need-milk"]
    assert "existing pantry item" in payload["decisions"][0]["recommended_action"].lower()
    assert payload["product_evidence"][0]["sustainability_status"] == "insufficient_verified_data"


def test_shopping_plan_guardrails_remove_unverified_price_and_sustainability_claims(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/shopping/list/optimize",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["shopping"],
            },
            "shopping_needs": [_shopping_need("need-1")],
        },
    )

    assert response.status_code == 200
    payload = response.json()
    evidence = payload["product_evidence"][0]
    assert evidence["price"] is None
    assert evidence["merchant_name"] is None
    assert evidence["source"] is None
    assert evidence["sustainability_status"] == "insufficient_verified_data"
    assert "best price" not in (evidence["review_summary"] or "").lower()
    assert "available now" not in (evidence["review_summary"] or "").lower()
    assert "eco-friendly" not in (evidence["review_summary"] or "").lower()


def test_shopping_plan_filters_and_sanitizes_sensitive_contexts_before_provider(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/shopping/list/optimize",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["shopping", "pantry"],
            },
            "shopping_needs": [_shopping_need("need-1")],
            "pantry_context": [{"name": "milk", "raw_text": "local pantry note"}],
            "finance_context": [{"label": "budget", "receipt_text": "private finance receipt"}],
            "wardrobe_context": [{"title": "winter jacket", "file_ref": "file-1"}],
            "homememory_context": [{"title": "Vacuum", "serial_number": "SN-123", "claim_body": "private"}],
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert provider.calls == ["shopping_plan"]
    provider_payload = provider.payloads[0]
    assert provider_payload["pantry_context"] == [{"name": "milk"}]
    assert provider_payload["finance_context"] == []
    assert provider_payload["wardrobe_context"] == []
    assert provider_payload["homememory_context"] == []
    assert payload["trace"]["context_filtered_count"] > 0
    assert payload["trace"]["context_redacted_field_count"] > 0


def test_product_evidence_requires_disclaimer_and_no_best_price_claim(tmp_path):
    provider = _RecordingProvider()
    client = TestClient(create_app(settings=_settings(tmp_path), provider=provider))

    response = client.post(
        "/v1/shopping/product/evidence",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["shopping"],
            },
            "product_name": "Vacuum bags",
            "merchant_name": "Local shop",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["disclaimer"]
    assert payload["price"] is None
    assert payload["source"] is None
    assert "cheapest" not in (payload["review_summary"] or "").lower()
    assert "available now" not in (payload["review_summary"] or "").lower()


def test_shopping_needs_extract_schema(tmp_path):
    client = TestClient(create_app(settings=_settings(tmp_path)))

    response = client.post(
        "/v1/shopping/needs/extract",
        json={
            "user_id": "user-1",
            "locale": "en",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["shopping"],
            },
            "shopping_needs": [_shopping_need("need-1")],
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["needs"][0]["need_id"] == "need-1"
    assert payload["product_evidence"] == []
    assert payload["decisions"] == []
