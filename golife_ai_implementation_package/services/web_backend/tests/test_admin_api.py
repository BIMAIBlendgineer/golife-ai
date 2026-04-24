def _admin_headers() -> dict[str, str]:
    return {"x-admin-token": "test-admin-token"}


def test_health_is_public(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_admin_routes_require_token(client):
    response = client.get("/admin/dashboard")
    assert response.status_code == 401


def test_dashboard_returns_operational_metrics(client):
    response = client.get("/admin/dashboard", headers=_admin_headers())
    assert response.status_code == 200
    data = response.json()
    assert data["wau"] >= 1
    assert "ai_cost_total_usd" in data


def test_users_and_detail_are_available(client):
    users_response = client.get("/admin/users", headers=_admin_headers())
    assert users_response.status_code == 200
    users = users_response.json()
    assert len(users) >= 1

    detail_response = client.get(
        f"/admin/users/{users[0]['user_id']}",
        headers=_admin_headers(),
    )
    assert detail_response.status_code == 200
    assert detail_response.json()["user_id"] == users[0]["user_id"]


def test_feature_flag_can_be_updated(client):
    response = client.patch(
        "/admin/feature-flags/multi_event_capture",
        headers=_admin_headers(),
        json={"enabled": True},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["key"] == "multi_event_capture"
    assert body["enabled"] is True


def test_models_and_support_routes_exist(client):
    models = client.get("/admin/models", headers=_admin_headers())
    support = client.get("/admin/support/export-delete", headers=_admin_headers())
    assert models.status_code == 200
    assert support.status_code == 200
    assert models.json()["active_provider"] == "openrouter"
    assert len(support.json()) >= 1
