from __future__ import annotations

from datetime import datetime, timedelta, timezone

from app.schemas import (
    AICostSnapshot,
    AdminUser,
    DashboardMetrics,
    FeatureFlag,
    FeedbackAuditRecord,
    MissionAuditRecord,
    ModelSettingsSnapshot,
    SafetyAuditRecord,
    SupportRequest,
    UsageSnapshot,
)


class OperationalRepository:
    def __init__(self) -> None:
        now = datetime.now(timezone.utc)
        self._users = [
            AdminUser(
                user_id="local-user",
                email="local-user@golife.ai",
                plan="plus",
                status="active",
                created_at=now - timedelta(days=14),
                last_seen_at=now - timedelta(hours=2),
                weekly_active=True,
                ai_calls=42,
                useful_missions_completed=9,
                support_flags=["high_value_feedback"],
                export_requested=False,
                delete_requested=False,
            ),
            AdminUser(
                user_id="user-2",
                email="user-2@golife.ai",
                plan="free",
                status="active",
                created_at=now - timedelta(days=4),
                last_seen_at=now - timedelta(hours=18),
                weekly_active=True,
                ai_calls=16,
                useful_missions_completed=3,
                support_flags=[],
                export_requested=True,
                delete_requested=False,
            ),
            AdminUser(
                user_id="user-3",
                email="user-3@golife.ai",
                plan="internal",
                status="trial",
                created_at=now - timedelta(days=2),
                last_seen_at=now - timedelta(days=1, hours=2),
                weekly_active=False,
                ai_calls=7,
                useful_missions_completed=1,
                support_flags=["safety_review"],
                export_requested=False,
                delete_requested=True,
            ),
        ]
        self._usage = [
            UsageSnapshot(
                user_id="local-user",
                capture_events=28,
                missions_generated=18,
                missions_completed=9,
                fallback_rate=0.08,
                latency_ms_avg=840,
                last_active_at=now - timedelta(hours=2),
            ),
            UsageSnapshot(
                user_id="user-2",
                capture_events=10,
                missions_generated=8,
                missions_completed=3,
                fallback_rate=0.18,
                latency_ms_avg=950,
                last_active_at=now - timedelta(hours=18),
            ),
            UsageSnapshot(
                user_id="user-3",
                capture_events=4,
                missions_generated=4,
                missions_completed=1,
                fallback_rate=0.04,
                latency_ms_avg=720,
                last_active_at=now - timedelta(days=1, hours=2),
            ),
        ]
        self._ai_costs = [
            AICostSnapshot(
                endpoint="/v1/missions/daily",
                provider="openrouter",
                requests=26,
                estimated_cost_usd=4.78,
                avg_latency_ms=910,
                fallback_rate=0.11,
            ),
            AICostSnapshot(
                endpoint="/v1/events/classify",
                provider="mock_or_small_model",
                requests=22,
                estimated_cost_usd=0.42,
                avg_latency_ms=180,
                fallback_rate=0.03,
            ),
            AICostSnapshot(
                endpoint="/v1/feedback",
                provider="system",
                requests=13,
                estimated_cost_usd=0.0,
                avg_latency_ms=55,
                fallback_rate=0.0,
            ),
        ]
        self._missions = [
            MissionAuditRecord(
                mission_id="mission-001",
                user_id="local-user",
                title="Use pantry before buying lunch",
                status="completed",
                usefulness="completed",
                domains=["finance", "pantry"],
                matched_risks=["food_spend_overlap"],
                final_score=0.82,
            ),
            MissionAuditRecord(
                mission_id="mission-002",
                user_id="local-user",
                title="Protect one recovery habit",
                status="accepted",
                usefulness="accepted",
                domains=["task", "habit"],
                matched_risks=["task_habit_tradeoff"],
                final_score=0.77,
            ),
            MissionAuditRecord(
                mission_id="mission-003",
                user_id="user-2",
                title="Pause a wardrobe buy for 24 hours",
                status="rejected",
                usefulness="rejected",
                domains=["wardrobe"],
                matched_risks=["purchase_intention_active"],
                final_score=0.69,
            ),
        ]
        self._feedback = [
            FeedbackAuditRecord(
                feedback_id="feedback-001",
                user_id="local-user",
                suggestion_id="mission-001",
                status="completed",
                reason="Pantry rescue prevented another spend.",
                domains=["finance", "pantry"],
                created_at=now - timedelta(hours=6),
            ),
            FeedbackAuditRecord(
                feedback_id="feedback-002",
                user_id="local-user",
                suggestion_id="mission-002",
                status="accepted",
                reason="Habit mission matched energy.",
                domains=["task", "habit"],
                created_at=now - timedelta(hours=4),
            ),
            FeedbackAuditRecord(
                feedback_id="feedback-003",
                user_id="user-2",
                suggestion_id="mission-003",
                status="rejected",
                reason="Already owned a similar jacket.",
                domains=["wardrobe"],
                created_at=now - timedelta(hours=3),
            ),
        ]
        self._safety = [
            SafetyAuditRecord(
                event_id="safety-001",
                user_id="user-2",
                category="finance",
                rule="regulated_advice",
                severity="medium",
                created_at=now - timedelta(hours=12),
            ),
            SafetyAuditRecord(
                event_id="safety-002",
                user_id="user-3",
                category="external_action",
                rule="external_action_without_confirmation",
                severity="low",
                created_at=now - timedelta(hours=9),
            ),
        ]
        self._feature_flags = {
            "daily_risk_engine": FeatureFlag(
                key="daily_risk_engine",
                enabled=True,
                description="Expose risks in Home Today and admin trace.",
                updated_at=now - timedelta(days=1),
            ),
            "sqlite_domain_entities": FeatureFlag(
                key="sqlite_domain_entities",
                enabled=True,
                description="Persist entities and missions locally in mobile.",
                updated_at=now - timedelta(hours=5),
            ),
            "multi_event_capture": FeatureFlag(
                key="multi_event_capture",
                enabled=False,
                description="Split one capture into multiple entities and events.",
                updated_at=now - timedelta(hours=2),
            ),
        }
        self._model_settings = ModelSettingsSnapshot(
            active_provider="openrouter",
            primary_model="openai/gpt-4.1-mini",
            fallback_model="mock",
            classification_model="deterministic_capture_router",
            weekly_summary_model="openai/gpt-4.1-mini",
        )
        self._support_requests = [
            SupportRequest(
                request_id="support-001",
                user_id="user-2",
                request_type="export",
                status="open",
                requested_at=now - timedelta(hours=10),
            ),
            SupportRequest(
                request_id="support-002",
                user_id="user-3",
                request_type="delete",
                status="open",
                requested_at=now - timedelta(hours=7),
            ),
        ]

    def health(self) -> dict[str, str]:
        return {"status": "ok", "data_source": "seeded_operational_repository"}

    def dashboard(self) -> DashboardMetrics:
        active_users = [user for user in self._users if user.weekly_active]
        active_user_count = max(1, len(active_users))
        total_captures = sum(item.capture_events for item in self._usage)
        total_generated = sum(item.missions_generated for item in self._usage)
        total_completed = sum(item.missions_completed for item in self._usage)
        total_cost = sum(item.estimated_cost_usd for item in self._ai_costs)
        avg_latency = (
            sum(item.avg_latency_ms for item in self._ai_costs) / len(self._ai_costs)
            if self._ai_costs
            else 0.0
        )
        feedback_total = max(1, len(self._feedback))
        useful_count = len(
            [
                item
                for item in self._feedback
                if item.status in {"useful", "accepted", "completed"}
            ]
        )
        rejected_count = len([item for item in self._feedback if item.status == "rejected"])
        safety_rate = len(self._safety) / max(1, total_generated)
        privacy_requests = len(self._support_requests)

        return DashboardMetrics(
            dau=len([item for item in self._usage if item.last_active_at >= datetime.now(timezone.utc) - timedelta(days=1)]),
            wau=len(active_users),
            new_users_7d=len(
                [
                    user
                    for user in self._users
                    if user.created_at >= datetime.now(timezone.utc) - timedelta(days=7)
                ]
            ),
            useful_missions_per_active_user_week=round(
                sum(user.useful_missions_completed for user in active_users) / active_user_count,
                2,
            ),
            mission_completion_rate=round(total_completed / max(1, total_generated), 4),
            recommendation_usefulness_rate=round(useful_count / feedback_total, 4),
            rejection_rate=round(rejected_count / feedback_total, 4),
            capture_events_per_active_user=round(total_captures / active_user_count, 2),
            fallback_rate=round(
                sum(item.fallback_rate for item in self._usage) / len(self._usage),
                4,
            ),
            ai_latency_ms_avg=round(avg_latency, 2),
            ai_cost_total_usd=round(total_cost, 2),
            ai_cost_per_active_user_usd=round(total_cost / active_user_count, 2),
            safety_intervention_rate=round(safety_rate, 4),
            privacy_concern_rate=round(privacy_requests / active_user_count, 4),
        )

    def list_users(self) -> list[AdminUser]:
        return list(self._users)

    def get_user(self, user_id: str) -> AdminUser | None:
        return next((user for user in self._users if user.user_id == user_id), None)

    def list_usage(self) -> list[UsageSnapshot]:
        return list(self._usage)

    def list_ai_costs(self) -> list[AICostSnapshot]:
        return list(self._ai_costs)

    def list_missions(self) -> list[MissionAuditRecord]:
        return list(self._missions)

    def list_feedback(self) -> list[FeedbackAuditRecord]:
        return list(self._feedback)

    def list_safety(self) -> list[SafetyAuditRecord]:
        return list(self._safety)

    def list_feature_flags(self) -> list[FeatureFlag]:
        return list(self._feature_flags.values())

    def update_feature_flag(self, key: str, enabled: bool) -> FeatureFlag | None:
        current = self._feature_flags.get(key)
        if current is None:
            return None
        updated = current.model_copy(
            update={
                "enabled": enabled,
                "updated_at": datetime.now(timezone.utc),
            }
        )
        self._feature_flags[key] = updated
        return updated

    def model_settings(self) -> ModelSettingsSnapshot:
        return self._model_settings

    def list_support_requests(self) -> list[SupportRequest]:
        return list(self._support_requests)
