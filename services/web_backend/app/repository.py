from __future__ import annotations

import json
import sqlite3
from datetime import UTC, datetime, timedelta
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit

try:
    import psycopg
    from psycopg.rows import dict_row
except ImportError:  # pragma: no cover - dependency presence is environment-specific
    psycopg = None
    dict_row = None

from app.schemas import (
    AICostSnapshot,
    AIInvocationRecord,
    AdminHealth,
    AdminUser,
    DashboardMetrics,
    FeatureFlag,
    FeedbackAuditRecord,
    FeedbackAuditUpsert,
    MissionAuditRecord,
    MissionAuditUpsert,
    PaginatedResponse,
    ModelSettingsSnapshot,
    ModelSettingsUpsert,
    ModelCatalogEntry,
    ModelSelectionSnapshot,
    OrganizationDetail,
    OrganizationRow,
    OpenRouterApiKeyCreate,
    OpenRouterApiKeyPatch,
    OpenRouterApiKeyRecord,
    OpenRouterKeyEventRecord,
    OpenRouterKeyEventUpsert,
    PlanRow,
    RoutingCapability,
    RoutingProfile,
    RoutingProfilePatch,
    SafetyAuditRecord,
    SafetyAuditUpsert,
    SupportRequest,
    UserManagementRow,
    UserPrivacySummary,
    UserSummary,
    UserSupportSummary,
    UserUsageSummary,
    UsageEventRecord,
    UsageSnapshot,
)
from app.routing import build_default_routing_profiles

REDACTED_FEEDBACK_REASON = "private_note_redacted"


def _utcnow() -> datetime:
    return datetime.now(UTC)


def _to_iso(value: datetime) -> str:
    return value.astimezone(UTC).isoformat()


def _from_iso(value: str | None) -> datetime | None:
    if not value:
        return None
    return datetime.fromisoformat(value)


def _json_dumps(value: object) -> str:
    return json.dumps(value, ensure_ascii=False)


def _json_loads(value: str | None, *, default: object) -> object:
    if not value:
        return default
    return json.loads(value)


def _sanitize_feedback_reason(reason: str | None) -> str | None:
    if not reason or not reason.strip():
        return None
    return REDACTED_FEEDBACK_REASON


def _mask_email(email: str) -> str:
    local, _, domain = email.partition("@")
    if not local or not domain:
        return email
    if len(local) <= 2:
        return f"{local[0]}***@{domain}"
    return f"{local[:2]}***@{domain}"


def _sqlite_in_placeholders(values: tuple[object, ...]) -> str:
    if not values:
        raise ValueError("values must not be empty")
    return ", ".join("?" for _ in values)


class OperationalRepository:
    def __init__(
        self,
        db_path: str = ":memory:",
        *,
        seed_demo_data: bool = False,
    ) -> None:
        self.db_path = db_path
        self.seed_demo_data = seed_demo_data
        self._dialect = (
            "postgres"
            if db_path.startswith("postgresql://") or db_path.startswith("postgres://")
            else "sqlite"
        )
        if self._dialect == "sqlite" and db_path != ":memory:":
            Path(db_path).parent.mkdir(parents=True, exist_ok=True)
        if self._dialect == "postgres":
            if psycopg is None:  # pragma: no cover
                raise RuntimeError("psycopg is required for PostgreSQL support.")
            self._connection = psycopg.connect(
                db_path,
                autocommit=False,
                row_factory=dict_row,
            )
        else:
            self._connection = sqlite3.connect(db_path, check_same_thread=False)
            self._connection.row_factory = sqlite3.Row
        self._create_schema()
        self._ensure_defaults()
        if seed_demo_data:
            self._seed_demo_data_if_empty()
        self._sanitize_existing_feedback_reasons()

    def _sql(self, query: str) -> str:
        if self._dialect == "postgres":
            return query.replace("?", "%s")
        return query

    def _execute(self, query: str, args: tuple[object, ...] = ()):
        return self._connection.execute(self._sql(query), args)

    def _fetchone(self, query: str, args: tuple[object, ...] = ()) -> object | None:
        return self._execute(query, args).fetchone()

    def _fetchall(self, query: str, args: tuple[object, ...] = ()) -> list[object]:
        return self._execute(query, args).fetchall()

    def _commit(self) -> None:
        self._connection.commit()

    def _display_storage_path(self) -> str:
        if self._dialect != "postgres":
            return self.db_path
        parts = urlsplit(self.db_path)
        return urlunsplit((parts.scheme, parts.hostname or "", parts.path, "", ""))

    def _create_schema(self) -> None:
        schema = """
                CREATE TABLE IF NOT EXISTS admin_users (
                    user_id TEXT PRIMARY KEY,
                    email TEXT NOT NULL,
                    plan TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    last_seen_at TEXT NOT NULL,
                    support_flags_json TEXT NOT NULL,
                    export_requested INTEGER NOT NULL DEFAULT 0,
                    delete_requested INTEGER NOT NULL DEFAULT 0
                );
                CREATE TABLE IF NOT EXISTS user_profiles (
                    user_id TEXT PRIMARY KEY,
                    display_name TEXT NOT NULL,
                    locale TEXT NOT NULL DEFAULT 'en',
                    organization_id TEXT
                );
                CREATE INDEX IF NOT EXISTS idx_user_profiles_locale
                    ON user_profiles(locale);
                CREATE TABLE IF NOT EXISTS plans (
                    plan_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    price_label TEXT NOT NULL,
                    user_limit INTEGER NOT NULL,
                    storage_limit_gb REAL NOT NULL,
                    ai_credit_policy TEXT NOT NULL,
                    byok_allowed INTEGER NOT NULL,
                    support_level TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS organizations (
                    organization_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    status TEXT NOT NULL,
                    plan_id TEXT NOT NULL,
                    storage_used_gb REAL NOT NULL DEFAULT 0,
                    ai_mode_default TEXT NOT NULL,
                    created_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_organizations_status
                    ON organizations(status);
                CREATE INDEX IF NOT EXISTS idx_organizations_plan
                    ON organizations(plan_id);

                CREATE TABLE IF NOT EXISTS usage_events (
                    event_id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    endpoint TEXT,
                    domain TEXT,
                    quantity INTEGER NOT NULL,
                    created_at TEXT NOT NULL,
                    metadata_json TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_usage_events_user_time
                    ON usage_events(user_id, created_at);

                CREATE TABLE IF NOT EXISTS ai_invocations (
                    invocation_id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    endpoint TEXT NOT NULL,
                    provider TEXT NOT NULL,
                    model TEXT,
                    latency_ms REAL NOT NULL,
                    fallback INTEGER NOT NULL,
                    suggestions_count INTEGER NOT NULL,
                    estimated_cost_usd REAL NOT NULL,
                    schema_valid INTEGER NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    metadata_json TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_ai_invocations_user_time
                    ON ai_invocations(user_id, created_at);
                CREATE INDEX IF NOT EXISTS idx_ai_invocations_endpoint_time
                    ON ai_invocations(endpoint, created_at);

                CREATE TABLE IF NOT EXISTS mission_audit_records (
                    mission_id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    title TEXT NOT NULL,
                    status TEXT NOT NULL,
                    usefulness TEXT,
                    domains_json TEXT NOT NULL,
                    matched_risks_json TEXT NOT NULL,
                    final_score REAL NOT NULL,
                    created_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_missions_user_time
                    ON mission_audit_records(user_id, created_at);

                CREATE TABLE IF NOT EXISTS feedback_audit_records (
                    feedback_id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    suggestion_id TEXT NOT NULL,
                    status TEXT NOT NULL,
                    reason TEXT,
                    domains_json TEXT NOT NULL,
                    created_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_feedback_user_time
                    ON feedback_audit_records(user_id, created_at);

                CREATE TABLE IF NOT EXISTS safety_events (
                    event_id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    category TEXT NOT NULL,
                    rule TEXT NOT NULL,
                    severity TEXT NOT NULL,
                    endpoint TEXT,
                    created_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_safety_user_time
                    ON safety_events(user_id, created_at);

                CREATE TABLE IF NOT EXISTS feature_flags (
                    key TEXT PRIMARY KEY,
                    enabled INTEGER NOT NULL,
                    description TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS support_requests (
                    request_id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    request_type TEXT NOT NULL,
                    status TEXT NOT NULL,
                    requested_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS model_settings (
                    id INTEGER PRIMARY KEY CHECK (id = 1),
                    active_provider TEXT NOT NULL,
                    primary_model TEXT NOT NULL,
                    fallback_model TEXT NOT NULL,
                    classification_model TEXT NOT NULL,
                    weekly_summary_model TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS openrouter_api_keys (
                    key_id TEXT PRIMARY KEY,
                    label TEXT NOT NULL,
                    secret_ciphertext TEXT NOT NULL,
                    secret_last4 TEXT NOT NULL,
                    enabled INTEGER NOT NULL,
                    priority INTEGER NOT NULL,
                    status TEXT NOT NULL,
                    last_ok_at TEXT,
                    last_error_at TEXT,
                    consecutive_failures INTEGER NOT NULL DEFAULT 0,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_openrouter_keys_priority
                    ON openrouter_api_keys(enabled, priority, created_at);

                CREATE TABLE IF NOT EXISTS routing_profiles (
                    capability TEXT PRIMARY KEY,
                    strategy TEXT NOT NULL,
                    min_context_length INTEGER NOT NULL,
                    required_parameters_json TEXT NOT NULL,
                    preferred_max_latency_seconds REAL NOT NULL,
                    preferred_min_throughput_tokens_per_second REAL NOT NULL,
                    max_prompt_price_usd_per_million REAL,
                    max_completion_price_usd_per_million REAL,
                    retry_policy_json TEXT NOT NULL,
                    enabled INTEGER NOT NULL,
                    updated_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS model_catalog_cache (
                    model_id TEXT PRIMARY KEY,
                    canonical_slug TEXT,
                    name TEXT NOT NULL,
                    description TEXT,
                    context_length INTEGER NOT NULL,
                    output_modalities_json TEXT NOT NULL,
                    supported_parameters_json TEXT NOT NULL,
                    prompt_price_usd_per_million REAL NOT NULL,
                    completion_price_usd_per_million REAL NOT NULL,
                    request_price_usd REAL NOT NULL,
                    top_provider_json TEXT NOT NULL,
                    architecture_json TEXT NOT NULL,
                    expiration_date TEXT,
                    refreshed_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_model_catalog_refreshed
                    ON model_catalog_cache(refreshed_at);

                CREATE TABLE IF NOT EXISTS model_selection_snapshots (
                    capability TEXT NOT NULL,
                    rank_index INTEGER NOT NULL,
                    model_id TEXT NOT NULL,
                    score REAL NOT NULL,
                    selection_reason_json TEXT NOT NULL,
                    generated_at TEXT NOT NULL,
                    expires_at TEXT NOT NULL,
                    PRIMARY KEY (capability, rank_index)
                );

                CREATE TABLE IF NOT EXISTS openrouter_key_events (
                    event_id TEXT PRIMARY KEY,
                    key_id TEXT NOT NULL,
                    key_label TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    endpoint TEXT,
                    model TEXT,
                    error_code TEXT,
                    notes TEXT,
                    created_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_openrouter_key_events_time
                    ON openrouter_key_events(key_id, created_at);
                """
        if self._dialect == "sqlite":
            with self._connection:
                self._connection.executescript(schema)
            return

        statements = [item.strip() for item in schema.split(";") if item.strip()]
        for statement in statements:
            self._execute(statement)
        self._commit()

    def _ensure_defaults(self) -> None:
        now = _utcnow()
        default_flags = [
            FeatureFlag(
                key="daily_risk_engine",
                enabled=True,
                description="Expose risks in Home Today and admin trace.",
                updated_at=now,
            ),
            FeatureFlag(
                key="sqlite_domain_entities",
                enabled=True,
                description="Persist entities and missions locally in mobile.",
                updated_at=now,
            ),
            FeatureFlag(
                key="multi_event_capture",
                enabled=False,
                description="Split one capture into multiple entities and events.",
                updated_at=now,
            ),
            FeatureFlag(
                key="semantic_classifier",
                enabled=False,
                description="Allow semantic capture parsing beyond deterministic keywords.",
                updated_at=now,
            ),
            FeatureFlag(
                key="admin_live_metrics",
                enabled=True,
                description="Show backend live/offline state and ingestion timestamp in admin.",
                updated_at=now,
            ),
            FeatureFlag(
                key="openrouter_enabled",
                enabled=True,
                description="Allow remote LLM traffic when provider credentials are configured.",
                updated_at=now,
            ),
        ]
        for flag in default_flags:
            self._execute(
                """
                INSERT INTO feature_flags(key, enabled, description, updated_at)
                VALUES (?, ?, ?, ?)
                ON CONFLICT(key) DO NOTHING
                """,
                (
                    flag.key,
                    int(flag.enabled),
                    flag.description,
                    _to_iso(flag.updated_at),
                ),
            )

        model_settings = ModelSettingsSnapshot(
            active_provider="openrouter",
            primary_model="openai/gpt-4.1-mini",
            fallback_model="mock",
            classification_model="deterministic_capture_router",
            weekly_summary_model="openai/gpt-4.1-mini",
        )
        self._execute(
            """
            INSERT INTO model_settings(
                id,
                active_provider,
                primary_model,
                fallback_model,
                classification_model,
                weekly_summary_model,
                updated_at
            )
            VALUES (1, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO NOTHING
            """,
            (
                model_settings.active_provider,
                model_settings.primary_model,
                model_settings.fallback_model,
                model_settings.classification_model,
                model_settings.weekly_summary_model,
                _to_iso(now),
            ),
        )

        for profile in build_default_routing_profiles(now):
            self._execute(
                """
                INSERT INTO routing_profiles(
                    capability,
                    strategy,
                    min_context_length,
                    required_parameters_json,
                    preferred_max_latency_seconds,
                    preferred_min_throughput_tokens_per_second,
                    max_prompt_price_usd_per_million,
                    max_completion_price_usd_per_million,
                    retry_policy_json,
                    enabled,
                    updated_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(capability) DO NOTHING
                """,
                (
                    profile.capability,
                    profile.strategy,
                    profile.min_context_length,
                    _json_dumps(profile.required_parameters),
                    profile.preferred_max_latency_seconds,
                    profile.preferred_min_throughput_tokens_per_second,
                    profile.max_prompt_price_usd_per_million,
                    profile.max_completion_price_usd_per_million,
                    _json_dumps(profile.retry_policy),
                    int(profile.enabled),
                    _to_iso(profile.updated_at),
                ),
            )
        self._commit()

    def _seed_demo_data_if_empty(self) -> None:
        user_count = self._scalar("SELECT COUNT(*) FROM admin_users")
        if user_count:
            return

        now = _utcnow()
        demo_users = [
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
        for user in demo_users:
            self.upsert_user(user)
        self.upsert_user_profile(
            user_id="local-user",
            display_name="Local User",
            locale="en",
            organization_id="org-household",
        )
        self.upsert_user_profile(
            user_id="user-2",
            display_name="Marta L",
            locale="es",
            organization_id="org-household",
        )
        self.upsert_user_profile(
            user_id="user-3",
            display_name="Ops Internal",
            locale="ja",
            organization_id="org-internal",
        )
        self._execute(
            """
            INSERT INTO plans(
                plan_id, name, price_label, user_limit, storage_limit_gb,
                ai_credit_policy, byok_allowed, support_level
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(plan_id) DO NOTHING
            """,
            (
                "free",
                "Free",
                "$0",
                1,
                1.0,
                "No bundled credits",
                0,
                "community",
                "pro",
                "Pro",
                "$19 / month",
                1,
                20.0,
                "Bundled xInsightAI credits",
                1,
                "standard",
                "family",
                "Family",
                "$29 / month",
                5,
                50.0,
                "Shared household credits",
                1,
                "priority",
                "team",
                "Team",
                "$79 / month",
                25,
                250.0,
                "Seat pool + org ledger",
                1,
                "priority",
                "enterprise",
                "Enterprise",
                "Custom",
                500,
                5000.0,
                "Contracted credit policy",
                1,
                "dedicated",
            ),
        )
        self._execute(
            """
            INSERT INTO organizations(
                organization_id, name, status, plan_id, storage_used_gb,
                ai_mode_default, created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(organization_id) DO NOTHING
            """,
            (
                "org-household",
                "Household Alpha",
                "active",
                "family",
                12.4,
                "hybrid",
                _to_iso(now - timedelta(days=60)),
                "org-internal",
                "GoLife Internal Ops",
                "active",
                "enterprise",
                48.9,
                "xinsightai",
                _to_iso(now - timedelta(days=140)),
            ),
        )

        usage_events = [
            UsageEventRecord(
                event_id="usage-001",
                user_id="local-user",
                event_type="capture_classification_requested",
                endpoint="/v1/events/classify",
                domain="finance",
                quantity=28,
                created_at=now - timedelta(hours=2),
                metadata={"source": "seed"},
            ),
            UsageEventRecord(
                event_id="usage-002",
                user_id="user-2",
                event_type="capture_classification_requested",
                endpoint="/v1/events/classify",
                domain="pantry",
                quantity=10,
                created_at=now - timedelta(hours=18),
                metadata={"source": "seed"},
            ),
            UsageEventRecord(
                event_id="usage-003",
                user_id="user-3",
                event_type="capture_classification_requested",
                endpoint="/v1/events/classify",
                domain="task",
                quantity=4,
                created_at=now - timedelta(days=1, hours=2),
                metadata={"source": "seed"},
            ),
        ]
        for usage_event in usage_events:
            self.record_usage_event(usage_event)

        invocations = [
            AIInvocationRecord(
                invocation_id="invoke-001",
                user_id="local-user",
                endpoint="/v1/missions/daily",
                provider="openrouter",
                model="openai/gpt-4.1-mini",
                latency_ms=840,
                fallback=False,
                suggestions_count=3,
                estimated_cost_usd=4.78,
                schema_valid=True,
                status="success",
                created_at=now - timedelta(hours=2),
                metadata={"source": "seed"},
            ),
            AIInvocationRecord(
                invocation_id="invoke-002",
                user_id="user-2",
                endpoint="/v1/missions/daily",
                provider="openrouter",
                model="openai/gpt-4.1-mini",
                latency_ms=950,
                fallback=True,
                suggestions_count=3,
                estimated_cost_usd=0.42,
                schema_valid=True,
                status="success",
                created_at=now - timedelta(hours=18),
                metadata={"source": "seed"},
            ),
            AIInvocationRecord(
                invocation_id="invoke-003",
                user_id="user-3",
                endpoint="/v1/feedback",
                provider="system",
                model=None,
                latency_ms=55,
                fallback=False,
                suggestions_count=0,
                estimated_cost_usd=0.0,
                schema_valid=True,
                status="success",
                created_at=now - timedelta(days=1, hours=2),
                metadata={"source": "seed"},
            ),
        ]
        for invocation in invocations:
            self.record_ai_invocation(invocation)

        for mission in [
            MissionAuditUpsert(
                mission_id="mission-001",
                user_id="local-user",
                title="Use pantry before buying lunch",
                status="completed",
                usefulness="completed",
                domains=["finance", "pantry"],
                matched_risks=["food_spend_overlap"],
                final_score=0.82,
                created_at=now - timedelta(hours=6),
            ),
            MissionAuditUpsert(
                mission_id="mission-002",
                user_id="local-user",
                title="Protect one recovery habit",
                status="accepted",
                usefulness="accepted",
                domains=["task", "habit"],
                matched_risks=["task_habit_tradeoff"],
                final_score=0.77,
                created_at=now - timedelta(hours=4),
            ),
            MissionAuditUpsert(
                mission_id="mission-003",
                user_id="user-2",
                title="Pause a wardrobe buy for 24 hours",
                status="rejected",
                usefulness="rejected",
                domains=["wardrobe"],
                matched_risks=["purchase_intention_active"],
                final_score=0.69,
                created_at=now - timedelta(hours=3),
            ),
        ]:
            self.record_mission_audit(mission)

        for feedback in [
            FeedbackAuditUpsert(
                feedback_id="feedback-001",
                user_id="local-user",
                suggestion_id="mission-001",
                status="completed",
                reason="Pantry rescue prevented another spend.",
                domains=["finance", "pantry"],
                created_at=now - timedelta(hours=6),
            ),
            FeedbackAuditUpsert(
                feedback_id="feedback-002",
                user_id="local-user",
                suggestion_id="mission-002",
                status="accepted",
                reason="Habit mission matched energy.",
                domains=["task", "habit"],
                created_at=now - timedelta(hours=4),
            ),
            FeedbackAuditUpsert(
                feedback_id="feedback-003",
                user_id="user-2",
                suggestion_id="mission-003",
                status="rejected",
                reason="Already owned a similar jacket.",
                domains=["wardrobe"],
                created_at=now - timedelta(hours=3),
            ),
        ]:
            self.record_feedback_audit(feedback)

        for safety_event in [
            SafetyAuditUpsert(
                event_id="safety-001",
                user_id="user-2",
                category="finance",
                rule="regulated_advice",
                severity="medium",
                endpoint="/v1/finance/reflect",
                created_at=now - timedelta(hours=12),
            ),
            SafetyAuditUpsert(
                event_id="safety-002",
                user_id="user-3",
                category="external_action",
                rule="external_action_without_confirmation",
                severity="low",
                endpoint="/v1/missions/daily",
                created_at=now - timedelta(hours=9),
            ),
        ]:
            self.record_safety_event(safety_event)

        for request in [
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
        ]:
            self.record_support_request(request)

    def _scalar(self, query: str, args: tuple[object, ...] = ()) -> object:
        row = self._fetchone(query, args)
        if row is None:
            return 0
        if isinstance(row, dict):
            return next(iter(row.values()), 0)
        return row[0]

    def _ensure_user(self, user_id: str) -> None:
        existing = self._fetchone(
            "SELECT user_id FROM admin_users WHERE user_id = ?",
            (user_id,),
        )
        if existing:
            return
        now = _utcnow()
        self.upsert_user(
            AdminUser(
                user_id=user_id,
                email=f"{user_id}@golife.local",
                plan="free",
                status="active",
                created_at=now,
                last_seen_at=now,
                weekly_active=True,
                ai_calls=0,
                useful_missions_completed=0,
                support_flags=[],
                export_requested=False,
                delete_requested=False,
            )
        )

    def _update_last_seen(self, user_id: str, at: datetime) -> None:
        self._execute(
            """
            UPDATE admin_users
            SET last_seen_at = CASE
                WHEN last_seen_at > ? THEN last_seen_at
                ELSE ?
            END
            WHERE user_id = ?
            """,
            (_to_iso(at), _to_iso(at), user_id),
        )
        self._commit()

    def upsert_user(self, user: AdminUser) -> None:
        self._execute(
            """
            INSERT INTO admin_users(
                user_id,
                email,
                plan,
                status,
                created_at,
                last_seen_at,
                support_flags_json,
                export_requested,
                delete_requested
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(user_id) DO UPDATE SET
                email = excluded.email,
                plan = excluded.plan,
                status = excluded.status,
                created_at = excluded.created_at,
                last_seen_at = excluded.last_seen_at,
                support_flags_json = excluded.support_flags_json,
                export_requested = excluded.export_requested,
                delete_requested = excluded.delete_requested
            """,
            (
                user.user_id,
                user.email,
                user.plan,
                user.status,
                _to_iso(user.created_at),
                _to_iso(user.last_seen_at),
                _json_dumps(user.support_flags),
                int(user.export_requested),
                int(user.delete_requested),
            ),
        )
        self._commit()

    def upsert_user_profile(
        self,
        *,
        user_id: str,
        display_name: str,
        locale: str = "en",
        organization_id: str | None = None,
    ) -> None:
        self._execute(
            """
            INSERT INTO user_profiles(user_id, display_name, locale, organization_id)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(user_id) DO UPDATE SET
                display_name = excluded.display_name,
                locale = excluded.locale,
                organization_id = excluded.organization_id
            """,
            (user_id, display_name, locale, organization_id),
        )
        self._commit()

    def record_usage_event(self, event: UsageEventRecord) -> None:
        self._ensure_user(event.user_id)
        self._execute(
            """
            INSERT INTO usage_events(
                event_id,
                user_id,
                event_type,
                endpoint,
                domain,
                quantity,
                created_at,
                metadata_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(event_id) DO UPDATE SET
                user_id = excluded.user_id,
                event_type = excluded.event_type,
                endpoint = excluded.endpoint,
                domain = excluded.domain,
                quantity = excluded.quantity,
                created_at = excluded.created_at,
                metadata_json = excluded.metadata_json
            """,
            (
                event.event_id,
                event.user_id,
                event.event_type,
                event.endpoint,
                event.domain,
                event.quantity,
                _to_iso(event.created_at),
                _json_dumps(event.metadata),
            ),
        )
        self._commit()
        self._update_last_seen(event.user_id, event.created_at)

    def record_ai_invocation(self, invocation: AIInvocationRecord) -> None:
        self._ensure_user(invocation.user_id)
        self._execute(
            """
            INSERT INTO ai_invocations(
                invocation_id,
                user_id,
                endpoint,
                provider,
                model,
                latency_ms,
                fallback,
                suggestions_count,
                estimated_cost_usd,
                schema_valid,
                status,
                created_at,
                metadata_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(invocation_id) DO UPDATE SET
                user_id = excluded.user_id,
                endpoint = excluded.endpoint,
                provider = excluded.provider,
                model = excluded.model,
                latency_ms = excluded.latency_ms,
                fallback = excluded.fallback,
                suggestions_count = excluded.suggestions_count,
                estimated_cost_usd = excluded.estimated_cost_usd,
                schema_valid = excluded.schema_valid,
                status = excluded.status,
                created_at = excluded.created_at,
                metadata_json = excluded.metadata_json
            """,
            (
                invocation.invocation_id,
                invocation.user_id,
                invocation.endpoint,
                invocation.provider,
                invocation.model,
                invocation.latency_ms,
                int(invocation.fallback),
                invocation.suggestions_count,
                invocation.estimated_cost_usd,
                int(invocation.schema_valid),
                invocation.status,
                _to_iso(invocation.created_at),
                _json_dumps(invocation.metadata),
            ),
        )
        self._commit()
        self._update_last_seen(invocation.user_id, invocation.created_at)

    def record_mission_audit(self, mission: MissionAuditUpsert) -> None:
        self._ensure_user(mission.user_id)
        self._execute(
            """
            INSERT INTO mission_audit_records(
                mission_id,
                user_id,
                title,
                status,
                usefulness,
                domains_json,
                matched_risks_json,
                final_score,
                created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(mission_id) DO UPDATE SET
                user_id = excluded.user_id,
                title = excluded.title,
                status = excluded.status,
                usefulness = excluded.usefulness,
                domains_json = excluded.domains_json,
                matched_risks_json = excluded.matched_risks_json,
                final_score = excluded.final_score,
                created_at = excluded.created_at
            """,
            (
                mission.mission_id,
                mission.user_id,
                mission.title,
                mission.status,
                mission.usefulness,
                _json_dumps(mission.domains),
                _json_dumps(mission.matched_risks),
                mission.final_score,
                _to_iso(mission.created_at),
            ),
        )
        self._commit()
        self._update_last_seen(mission.user_id, mission.created_at)

    def record_feedback_audit(self, feedback: FeedbackAuditUpsert) -> None:
        self._ensure_user(feedback.user_id)
        sanitized_reason = _sanitize_feedback_reason(feedback.reason)
        self._execute(
            """
            INSERT INTO feedback_audit_records(
                feedback_id,
                user_id,
                suggestion_id,
                status,
                reason,
                domains_json,
                created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(feedback_id) DO UPDATE SET
                user_id = excluded.user_id,
                suggestion_id = excluded.suggestion_id,
                status = excluded.status,
                reason = excluded.reason,
                domains_json = excluded.domains_json,
                created_at = excluded.created_at
            """,
            (
                feedback.feedback_id,
                feedback.user_id,
                feedback.suggestion_id,
                feedback.status,
                sanitized_reason,
                _json_dumps(feedback.domains),
                _to_iso(feedback.created_at),
            ),
        )
        self._commit()
        self._update_last_seen(feedback.user_id, feedback.created_at)

    def _sanitize_existing_feedback_reasons(self) -> None:
        self._execute(
            """
            UPDATE feedback_audit_records
            SET reason = ?
            WHERE reason IS NOT NULL
              AND TRIM(reason) <> ''
              AND reason <> ?
            """,
            (REDACTED_FEEDBACK_REASON, REDACTED_FEEDBACK_REASON),
        )
        self._commit()

    def record_safety_event(self, safety_event: SafetyAuditUpsert) -> None:
        self._ensure_user(safety_event.user_id)
        self._execute(
            """
            INSERT INTO safety_events(
                event_id,
                user_id,
                category,
                rule,
                severity,
                endpoint,
                created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(event_id) DO UPDATE SET
                user_id = excluded.user_id,
                category = excluded.category,
                rule = excluded.rule,
                severity = excluded.severity,
                endpoint = excluded.endpoint,
                created_at = excluded.created_at
            """,
            (
                safety_event.event_id,
                safety_event.user_id,
                safety_event.category,
                safety_event.rule,
                safety_event.severity,
                safety_event.endpoint,
                _to_iso(safety_event.created_at),
            ),
        )
        self._commit()
        self._update_last_seen(safety_event.user_id, safety_event.created_at)

    def record_support_request(self, request: SupportRequest) -> None:
        self._ensure_user(request.user_id)
        self._execute(
            """
            INSERT INTO support_requests(
                request_id,
                user_id,
                request_type,
                status,
                requested_at
            )
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(request_id) DO UPDATE SET
                user_id = excluded.user_id,
                request_type = excluded.request_type,
                status = excluded.status,
                requested_at = excluded.requested_at
            """,
            (
                request.request_id,
                request.user_id,
                request.request_type,
                request.status,
                _to_iso(request.requested_at),
            ),
        )
        self._commit()

    def set_model_settings(self, model_settings: ModelSettingsUpsert) -> None:
        self._execute(
            """
            INSERT INTO model_settings(
                id,
                active_provider,
                primary_model,
                fallback_model,
                classification_model,
                weekly_summary_model,
                updated_at
            )
            VALUES (1, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                active_provider = excluded.active_provider,
                primary_model = excluded.primary_model,
                fallback_model = excluded.fallback_model,
                classification_model = excluded.classification_model,
                weekly_summary_model = excluded.weekly_summary_model,
                updated_at = excluded.updated_at
            """,
            (
                model_settings.active_provider,
                model_settings.primary_model,
                model_settings.fallback_model,
                model_settings.classification_model,
                model_settings.weekly_summary_model,
                _to_iso(_utcnow()),
            ),
        )
        self._commit()

    def health(self) -> AdminHealth:
        last_ingestion_at = self._latest_activity()
        return AdminHealth(
            status="ok",
            data_source=f"{self._dialect}_operational_repository",
            mode="seeded" if self.seed_demo_data else "live",
            storage_path=self._display_storage_path(),
            last_ingestion_at=last_ingestion_at,
        )

    def dashboard(self) -> DashboardMetrics:
        users = self.list_users()
        now = _utcnow()
        daily_active = [
            user for user in users if user.last_seen_at >= now - timedelta(days=1)
        ]
        weekly_active = [
            user for user in users if user.last_seen_at >= now - timedelta(days=7)
        ]
        active_user_count = max(1, len(weekly_active))
        useful_feedback = self._count_feedback_statuses(
            ("useful", "accepted", "completed")
        )
        rejected_feedback = self._count_feedback_statuses(("rejected",))
        total_feedback = max(1, useful_feedback + rejected_feedback + self._count_feedback_statuses(("edited",)))
        total_missions = int(self._scalar("SELECT COUNT(*) FROM mission_audit_records"))
        completed_missions = self._count_feedback_statuses(("completed",))
        total_capture_events = self._sum_usage_events("capture_classification_requested")
        total_cost = float(
            self._scalar("SELECT COALESCE(SUM(estimated_cost_usd), 0) FROM ai_invocations")
        )
        avg_latency = float(
            self._scalar("SELECT COALESCE(AVG(latency_ms), 0) FROM ai_invocations")
        )
        avg_fallback = float(
            self._scalar(
                "SELECT COALESCE(AVG(CAST(fallback AS REAL)), 0) FROM ai_invocations"
            )
        )
        safety_count = int(self._scalar("SELECT COUNT(*) FROM safety_events"))
        active_key_count = int(
            self._scalar(
                "SELECT COUNT(*) FROM openrouter_api_keys WHERE enabled = 1"
            )
        )
        disabled_key_count = int(
            self._scalar(
                "SELECT COUNT(*) FROM openrouter_api_keys WHERE enabled = 0"
            )
        )
        privacy_requests = int(
            self._scalar("SELECT COUNT(*) FROM support_requests WHERE status = 'open'")
        )
        latest_snapshot = self._fetchone(
            "SELECT MAX(generated_at) AS generated_at FROM model_selection_snapshots"
        )
        snapshot_generated_at = (
            _from_iso(latest_snapshot["generated_at"])
            if latest_snapshot and latest_snapshot["generated_at"]
            else None
        )
        snapshot_age_seconds = (
            int((now - snapshot_generated_at).total_seconds())
            if snapshot_generated_at
            else None
        )

        return DashboardMetrics(
            dau=len(daily_active),
            wau=len(weekly_active),
            new_users_7d=len(
                [user for user in users if user.created_at >= now - timedelta(days=7)]
            ),
            useful_missions_per_active_user_week=round(
                sum(user.useful_missions_completed for user in weekly_active)
                / active_user_count,
                2,
            ),
            mission_completion_rate=round(
                completed_missions / max(1, total_missions),
                4,
            ),
            recommendation_usefulness_rate=round(useful_feedback / total_feedback, 4),
            rejection_rate=round(rejected_feedback / total_feedback, 4),
            capture_events_per_active_user=round(
                total_capture_events / active_user_count,
                2,
            ),
            fallback_rate=round(avg_fallback, 4),
            ai_latency_ms_avg=round(avg_latency, 2),
            ai_cost_total_usd=round(total_cost, 2),
            ai_cost_per_active_user_usd=round(total_cost / active_user_count, 2),
              safety_intervention_rate=round(
                  safety_count / max(1, total_missions),
                  4,
              ),
              privacy_concern_rate=round(
                  privacy_requests / active_user_count,
                  4,
              ),
              active_key_count=active_key_count,
              disabled_key_count=disabled_key_count,
              routing_snapshot_age_seconds=snapshot_age_seconds,
          )

    @staticmethod
    def _privacy_status_from_counts(
        *,
        open_export_count: int,
        open_delete_count: int,
    ) -> str:
        if open_export_count and open_delete_count:
            return "mixed_open"
        if open_export_count:
            return "export_open"
        if open_delete_count:
            return "delete_open"
        return "none"

    def list_user_management(
        self,
        *,
        limit: int = 25,
        offset: int = 0,
        query: str | None = None,
        status: str | None = None,
        plan: str | None = None,
        locale: str | None = None,
    ) -> PaginatedResponse[UserManagementRow]:
        filters: list[str] = []
        args: list[object] = []
        if query:
            like = f"%{query.strip()}%"
            filters.append(
                "(u.user_id LIKE ? OR u.email LIKE ? OR COALESCE(p.display_name, u.user_id) LIKE ?)"
            )
            args.extend([like, like, like])
        if status:
            filters.append("u.status = ?")
            args.append(status)
        if plan:
            filters.append("u.plan = ?")
            args.append(plan)
        if locale:
            filters.append("COALESCE(p.locale, 'en') = ?")
            args.append(locale)

        where_sql = f"WHERE {' AND '.join(filters)}" if filters else ""
        total = int(
            self._scalar(
                f"""
                SELECT COUNT(*)
                FROM admin_users u
                LEFT JOIN user_profiles p ON p.user_id = u.user_id
                {where_sql}
                """,
                tuple(args),
            )
        )
        rows = self._fetchall(
            f"""
            SELECT
                u.user_id,
                u.email,
                u.plan,
                u.status,
                u.last_seen_at,
                u.support_flags_json,
                COALESCE(p.display_name, u.user_id) AS display_name,
                COALESCE(p.locale, 'en') AS locale,
                (
                    SELECT COUNT(*)
                    FROM ai_invocations ai
                    WHERE ai.user_id = u.user_id
                ) AS ai_calls_count,
                (
                    SELECT COUNT(*)
                    FROM feedback_audit_records fb
                    WHERE fb.user_id = u.user_id
                      AND fb.status IN ('useful', 'accepted', 'completed')
                ) AS useful_missions_count,
                (
                    SELECT COALESCE(AVG(CAST(ai.fallback AS REAL)), 0)
                    FROM ai_invocations ai
                    WHERE ai.user_id = u.user_id
                ) AS fallback_rate,
                (
                    SELECT COUNT(*)
                    FROM support_requests sr
                    WHERE sr.user_id = u.user_id
                      AND sr.status = 'open'
                      AND sr.request_type = 'export'
                ) AS open_export_count,
                (
                    SELECT COUNT(*)
                    FROM support_requests sr
                    WHERE sr.user_id = u.user_id
                      AND sr.status = 'open'
                      AND sr.request_type = 'delete'
                ) AS open_delete_count
            FROM admin_users u
            LEFT JOIN user_profiles p ON p.user_id = u.user_id
            {where_sql}
            ORDER BY u.last_seen_at DESC, u.created_at DESC
            LIMIT ? OFFSET ?
            """,
            tuple([*args, limit, offset]),
        )
        items = [
            UserManagementRow(
                user_id=row["user_id"],
                display_name=row["display_name"],
                email_masked=_mask_email(row["email"]),
                plan=row["plan"],
                status=row["status"],
                locale=row["locale"],
                last_seen_at=_from_iso(row["last_seen_at"]) or _utcnow(),
                ai_calls_count=int(row["ai_calls_count"]),
                useful_missions_count=int(row["useful_missions_count"]),
                fallback_rate=round(float(row["fallback_rate"]), 4),
                support_flags=list(_json_loads(row["support_flags_json"], default=[])),
                privacy_request_status=self._privacy_status_from_counts(
                    open_export_count=int(row["open_export_count"]),
                    open_delete_count=int(row["open_delete_count"]),
                ),
            )
            for row in rows
        ]
        next_offset = offset + limit if offset + limit < total else None
        return PaginatedResponse[UserManagementRow](
            items=items,
            total=total,
            limit=limit,
            offset=offset,
            next_offset=next_offset,
            fetched_at=_utcnow(),
        )

    def get_user_summary(self, user_id: str) -> UserSummary | None:
        row = self._fetchone(
            """
            SELECT
                u.user_id,
                u.email,
                u.plan,
                u.status,
                u.created_at,
                u.last_seen_at,
                u.support_flags_json,
                COALESCE(p.display_name, u.user_id) AS display_name,
                COALESCE(p.locale, 'en') AS locale,
                p.organization_id,
                (
                    SELECT COUNT(*)
                    FROM support_requests sr
                    WHERE sr.user_id = u.user_id
                      AND sr.status = 'open'
                      AND sr.request_type = 'export'
                ) AS open_export_count,
                (
                    SELECT COUNT(*)
                    FROM support_requests sr
                    WHERE sr.user_id = u.user_id
                      AND sr.status = 'open'
                      AND sr.request_type = 'delete'
                ) AS open_delete_count
            FROM admin_users u
            LEFT JOIN user_profiles p ON p.user_id = u.user_id
            WHERE u.user_id = ?
            """,
            (user_id,),
        )
        if row is None:
            return None
        return UserSummary(
            user_id=row["user_id"],
            display_name=row["display_name"],
            email_masked=_mask_email(row["email"]),
            plan=row["plan"],
            status=row["status"],
            locale=row["locale"],
            created_at=_from_iso(row["created_at"]) or _utcnow(),
            last_seen_at=_from_iso(row["last_seen_at"]) or _utcnow(),
            organization_id=row["organization_id"],
            support_flags=list(_json_loads(row["support_flags_json"], default=[])),
            privacy_request_status=self._privacy_status_from_counts(
                open_export_count=int(row["open_export_count"]),
                open_delete_count=int(row["open_delete_count"]),
            ),
        )

    def get_user_usage_summary(self, user_id: str) -> UserUsageSummary | None:
        user = self.get_user_summary(user_id)
        if user is None:
            return None
        fallback_rate = float(
            self._scalar(
                """
                SELECT COALESCE(AVG(CAST(fallback AS REAL)), 0)
                FROM ai_invocations
                WHERE user_id = ?
                """,
                (user_id,),
            )
        )
        latency = float(
            self._scalar(
                "SELECT COALESCE(AVG(latency_ms), 0) FROM ai_invocations WHERE user_id = ?",
                (user_id,),
            )
        )
        return UserUsageSummary(
            user_id=user_id,
            capture_events=int(
                self._scalar(
                    """
                    SELECT COALESCE(SUM(quantity), 0)
                    FROM usage_events
                    WHERE user_id = ? AND event_type = 'capture_classification_requested'
                    """,
                    (user_id,),
                )
            ),
            missions_generated=int(
                self._scalar(
                    "SELECT COUNT(*) FROM mission_audit_records WHERE user_id = ?",
                    (user_id,),
                )
            ),
            missions_completed=int(
                self._scalar(
                    """
                    SELECT COUNT(*)
                    FROM feedback_audit_records
                    WHERE user_id = ? AND status = 'completed'
                    """,
                    (user_id,),
                )
            ),
            ai_calls_count=int(
                self._scalar(
                    "SELECT COUNT(*) FROM ai_invocations WHERE user_id = ?",
                    (user_id,),
                )
            ),
            fallback_rate=round(fallback_rate, 4),
            latency_ms_avg=round(latency, 2),
        )

    def get_user_privacy_summary(self, user_id: str) -> UserPrivacySummary | None:
        user = self.get_user_summary(user_id)
        if user is None:
            return None
        open_requests = [
            request.request_type
            for request in self.list_support_requests()
            if request.user_id == user_id and request.status == "open"
        ]
        return UserPrivacySummary(
            user_id=user_id,
            privacy_request_status=user.privacy_request_status,
            open_requests=sorted(set(open_requests)),
            encrypted_collections=[
                "expenses",
                "journal_entries",
                "quick_notes",
            ],
            sensitive_data_excluded=True,
        )

    def get_user_support_summary(self, user_id: str) -> UserSupportSummary | None:
        user = self.get_user_summary(user_id)
        if user is None:
            return None
        requests = [
            request
            for request in self.list_support_requests()
            if request.user_id == user_id
        ]
        return UserSupportSummary(
            user_id=user_id,
            support_flags=user.support_flags,
            open_request_count=sum(1 for request in requests if request.status == "open"),
            requests=requests,
        )

    def list_organizations(self) -> list[OrganizationRow]:
        rows = self._fetchall(
            """
            SELECT
                o.organization_id,
                o.name,
                o.status,
                o.plan_id,
                o.storage_used_gb,
                o.ai_mode_default,
                o.created_at,
                (
                    SELECT COUNT(*)
                    FROM user_profiles p
                    WHERE p.organization_id = o.organization_id
                ) AS user_count
            FROM organizations o
            ORDER BY o.created_at DESC, o.name ASC
            """
        )
        return [
            OrganizationRow(
                organization_id=row["organization_id"],
                name=row["name"],
                status=row["status"],
                plan=row["plan_id"],
                user_count=int(row["user_count"]),
                storage_used_gb=float(row["storage_used_gb"]),
                ai_mode_default=row["ai_mode_default"],
                created_at=_from_iso(row["created_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def get_organization(self, organization_id: str) -> OrganizationDetail | None:
        base = self._fetchone(
            """
            SELECT organization_id, name, status, plan_id, storage_used_gb, ai_mode_default, created_at
            FROM organizations
            WHERE organization_id = ?
            """,
            (organization_id,),
        )
        if base is None:
            return None
        member_rows = self._fetchall(
            """
            SELECT u.user_id
            FROM admin_users u
            JOIN user_profiles p ON p.user_id = u.user_id
            WHERE p.organization_id = ?
            ORDER BY u.last_seen_at DESC
            """,
            (organization_id,),
        )
        members = [
            summary
            for summary in (
                self.get_user_summary(row["user_id"])
                for row in member_rows
            )
            if summary is not None
        ]
        return OrganizationDetail(
            organization_id=base["organization_id"],
            name=base["name"],
            status=base["status"],
            plan=base["plan_id"],
            user_count=len(members),
            storage_used_gb=float(base["storage_used_gb"]),
            ai_mode_default=base["ai_mode_default"],
            created_at=_from_iso(base["created_at"]) or _utcnow(),
            members=members,
        )

    def list_plans(self) -> list[PlanRow]:
        rows = self._fetchall(
            """
            SELECT
                plan_id,
                name,
                price_label,
                user_limit,
                storage_limit_gb,
                ai_credit_policy,
                byok_allowed,
                support_level
            FROM plans
            ORDER BY user_limit ASC
            """
        )
        return [
            PlanRow(
                plan_id=row["plan_id"],
                name=row["name"],
                price_label=row["price_label"],
                user_limit=int(row["user_limit"]),
                storage_limit_gb=float(row["storage_limit_gb"]),
                ai_credit_policy=row["ai_credit_policy"],
                byok_allowed=bool(row["byok_allowed"]),
                support_level=row["support_level"],
            )
            for row in rows
        ]

    def list_users(self) -> list[AdminUser]:
        rows = self._fetchall(
            """
            SELECT user_id, email, plan, status, created_at, last_seen_at,
                   support_flags_json, export_requested, delete_requested
            FROM admin_users
            ORDER BY last_seen_at DESC, created_at DESC
            """
        )
        users: list[AdminUser] = []
        now = _utcnow()
        for row in rows:
            last_seen_at = _from_iso(row["last_seen_at"]) or now
            ai_calls = int(
                self._scalar(
                    "SELECT COUNT(*) FROM ai_invocations WHERE user_id = ?",
                    (row["user_id"],),
                )
            )
            useful_missions_completed = int(
                self._scalar(
                    """
                    SELECT COUNT(*)
                    FROM feedback_audit_records
                    WHERE user_id = ? AND status IN ('useful', 'accepted', 'completed')
                    """,
                    (row["user_id"],),
                )
            )
            users.append(
                AdminUser(
                    user_id=row["user_id"],
                    email=row["email"],
                    plan=row["plan"],
                    status=row["status"],
                    created_at=_from_iso(row["created_at"]) or now,
                    last_seen_at=last_seen_at,
                    weekly_active=last_seen_at >= now - timedelta(days=7),
                    ai_calls=ai_calls,
                    useful_missions_completed=useful_missions_completed,
                    support_flags=list(
                        _json_loads(
                            row["support_flags_json"],
                            default=[],
                        )
                    ),
                    export_requested=bool(row["export_requested"]),
                    delete_requested=bool(row["delete_requested"]),
                )
            )
        return users

    def get_user(self, user_id: str) -> AdminUser | None:
        return next((user for user in self.list_users() if user.user_id == user_id), None)

    def list_usage(self) -> list[UsageSnapshot]:
        usage_items: list[UsageSnapshot] = []
        for user in self.list_users():
            fallback_rate = float(
                self._scalar(
                    """
                    SELECT COALESCE(AVG(CAST(fallback AS REAL)), 0)
                    FROM ai_invocations
                    WHERE user_id = ?
                    """,
                    (user.user_id,),
                )
            )
            latency = float(
                self._scalar(
                    "SELECT COALESCE(AVG(latency_ms), 0) FROM ai_invocations WHERE user_id = ?",
                    (user.user_id,),
                )
            )
            usage_items.append(
                UsageSnapshot(
                    user_id=user.user_id,
                    capture_events=int(
                        self._scalar(
                            """
                            SELECT COALESCE(SUM(quantity), 0)
                            FROM usage_events
                            WHERE user_id = ? AND event_type = 'capture_classification_requested'
                            """,
                            (user.user_id,),
                        )
                    ),
                    missions_generated=int(
                        self._scalar(
                            "SELECT COUNT(*) FROM mission_audit_records WHERE user_id = ?",
                            (user.user_id,),
                        )
                    ),
                    missions_completed=int(
                        self._scalar(
                            """
                            SELECT COUNT(*)
                            FROM feedback_audit_records
                            WHERE user_id = ? AND status = 'completed'
                            """,
                            (user.user_id,),
                        )
                    ),
                    fallback_rate=round(fallback_rate, 4),
                    latency_ms_avg=round(latency, 2),
                    last_active_at=user.last_seen_at,
                )
            )
        return usage_items

    def list_ai_costs(self) -> list[AICostSnapshot]:
        rows = self._fetchall(
            """
            SELECT endpoint,
                   provider,
                   COUNT(*) AS requests,
                   COALESCE(SUM(estimated_cost_usd), 0) AS estimated_cost_usd,
                   COALESCE(AVG(latency_ms), 0) AS avg_latency_ms,
                   COALESCE(AVG(fallback), 0) AS fallback_rate
            FROM ai_invocations
            GROUP BY endpoint, provider
            ORDER BY requests DESC, endpoint ASC
            """
        )
        return [
            AICostSnapshot(
                endpoint=row["endpoint"],
                provider=row["provider"],
                requests=int(row["requests"]),
                estimated_cost_usd=float(row["estimated_cost_usd"]),
                avg_latency_ms=float(row["avg_latency_ms"]),
                fallback_rate=float(row["fallback_rate"]),
            )
            for row in rows
        ]

    def list_missions(self) -> list[MissionAuditRecord]:
        rows = self._fetchall(
            """
            SELECT mission_id, user_id, title, status, usefulness,
                   domains_json, matched_risks_json, final_score
            FROM mission_audit_records
            ORDER BY created_at DESC
            """
        )
        return [
            MissionAuditRecord(
                mission_id=row["mission_id"],
                user_id=row["user_id"],
                title=row["title"],
                status=row["status"],
                usefulness=row["usefulness"],
                domains=list(_json_loads(row["domains_json"], default=[])),
                matched_risks=list(_json_loads(row["matched_risks_json"], default=[])),
                final_score=float(row["final_score"]),
            )
            for row in rows
        ]

    def list_feedback(self) -> list[FeedbackAuditRecord]:
        rows = self._fetchall(
            """
            SELECT feedback_id, user_id, suggestion_id, status, reason, domains_json, created_at
            FROM feedback_audit_records
            ORDER BY created_at DESC
            """
        )
        return [
            FeedbackAuditRecord(
                feedback_id=row["feedback_id"],
                user_id=row["user_id"],
                suggestion_id=row["suggestion_id"],
                status=row["status"],
                reason=row["reason"],
                domains=list(_json_loads(row["domains_json"], default=[])),
                created_at=_from_iso(row["created_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def list_safety(self) -> list[SafetyAuditRecord]:
        rows = self._fetchall(
            """
            SELECT event_id, user_id, category, rule, severity, created_at
            FROM safety_events
            ORDER BY created_at DESC
            """
        )
        return [
            SafetyAuditRecord(
                event_id=row["event_id"],
                user_id=row["user_id"],
                category=row["category"],
                rule=row["rule"],
                severity=row["severity"],
                created_at=_from_iso(row["created_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def list_feature_flags(self) -> list[FeatureFlag]:
        rows = self._fetchall(
            """
            SELECT key, enabled, description, updated_at
            FROM feature_flags
            ORDER BY key ASC
            """
        )
        return [
            FeatureFlag(
                key=row["key"],
                enabled=bool(row["enabled"]),
                description=row["description"],
                updated_at=_from_iso(row["updated_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def update_feature_flag(self, key: str, enabled: bool) -> FeatureFlag | None:
        existing = self._fetchone(
            "SELECT description FROM feature_flags WHERE key = ?",
            (key,),
        )
        if existing is None:
            return None
        updated_at = _utcnow()
        with self._connection:
            self._execute(
                """
                UPDATE feature_flags
                SET enabled = ?, updated_at = ?
                WHERE key = ?
                """,
                (int(enabled), _to_iso(updated_at), key),
            )
        self._commit()
        return FeatureFlag(
            key=key,
            enabled=enabled,
            description=existing["description"],
            updated_at=updated_at,
        )

    def model_settings(self) -> ModelSettingsSnapshot:
        row = self._fetchone(
            """
            SELECT active_provider, primary_model, fallback_model,
                   classification_model, weekly_summary_model
            FROM model_settings
            WHERE id = 1
            """
        )
        if row is None:
            return ModelSettingsSnapshot(
                active_provider="mock",
                primary_model="mock",
                fallback_model="mock",
                classification_model="deterministic_capture_router",
                weekly_summary_model="mock",
            )
        return ModelSettingsSnapshot(
            active_provider=row["active_provider"],
            primary_model=row["primary_model"],
            fallback_model=row["fallback_model"],
            classification_model=row["classification_model"],
            weekly_summary_model=row["weekly_summary_model"],
        )

    def list_openrouter_keys(self) -> list[OpenRouterApiKeyRecord]:
        rows = self._fetchall(
            """
            SELECT key_id, label, secret_last4, enabled, priority, status,
                   last_ok_at, last_error_at, consecutive_failures, created_at, updated_at
            FROM openrouter_api_keys
            ORDER BY enabled DESC, priority ASC, created_at ASC
            """
        )
        return [
            OpenRouterApiKeyRecord(
                key_id=row["key_id"],
                label=row["label"],
                secret_last4=row["secret_last4"],
                enabled=bool(row["enabled"]),
                priority=int(row["priority"]),
                status=row["status"],
                last_ok_at=_from_iso(row["last_ok_at"]),
                last_error_at=_from_iso(row["last_error_at"]),
                consecutive_failures=int(row["consecutive_failures"]),
                created_at=_from_iso(row["created_at"]) or _utcnow(),
                updated_at=_from_iso(row["updated_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def create_openrouter_key(
        self,
        payload: OpenRouterApiKeyCreate,
        *,
        secret_ciphertext: str,
        secret_last4: str,
        key_id: str,
    ) -> OpenRouterApiKeyRecord:
        now = _utcnow()
        self._execute(
            """
            INSERT INTO openrouter_api_keys(
                key_id, label, secret_ciphertext, secret_last4, enabled, priority, status,
                last_ok_at, last_error_at, consecutive_failures, created_at, updated_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                key_id,
                payload.label,
                secret_ciphertext,
                secret_last4,
                int(payload.enabled),
                payload.priority,
                "unknown" if payload.enabled else "disabled",
                None,
                None,
                0,
                _to_iso(now),
                _to_iso(now),
            ),
        )
        self._commit()
        return OpenRouterApiKeyRecord(
            key_id=key_id,
            label=payload.label,
            secret_last4=secret_last4,
            enabled=payload.enabled,
            priority=payload.priority,
            status="unknown" if payload.enabled else "disabled",
            last_ok_at=None,
            last_error_at=None,
            consecutive_failures=0,
            created_at=now,
            updated_at=now,
        )

    def patch_openrouter_key(
        self,
        key_id: str,
        payload: OpenRouterApiKeyPatch,
        *,
        secret_ciphertext: str | None = None,
        secret_last4: str | None = None,
    ) -> OpenRouterApiKeyRecord | None:
        existing = self._fetchone(
            """
            SELECT key_id, label, secret_last4, enabled, priority, status,
                   last_ok_at, last_error_at, consecutive_failures, created_at, updated_at
            FROM openrouter_api_keys
            WHERE key_id = ?
            """,
            (key_id,),
        )
        if existing is None:
            return None
        now = _utcnow()
        next_label = payload.label or existing["label"]
        next_enabled = bool(existing["enabled"]) if payload.enabled is None else payload.enabled
        next_priority = int(existing["priority"]) if payload.priority is None else payload.priority
        next_secret_ciphertext = secret_ciphertext
        next_secret_last4 = secret_last4 or existing["secret_last4"]

        if next_secret_ciphertext is None:
            self._execute(
                """
                UPDATE openrouter_api_keys
                SET label = ?, enabled = ?, priority = ?, status = ?, secret_last4 = ?, updated_at = ?
                WHERE key_id = ?
                """,
                (
                    next_label,
                    int(next_enabled),
                    next_priority,
                    "disabled" if not next_enabled else existing["status"],
                    next_secret_last4,
                    _to_iso(now),
                    key_id,
                ),
            )
        else:
            self._execute(
                """
                UPDATE openrouter_api_keys
                SET label = ?, enabled = ?, priority = ?, status = ?, secret_ciphertext = ?, secret_last4 = ?, updated_at = ?
                WHERE key_id = ?
                """,
                (
                    next_label,
                    int(next_enabled),
                    next_priority,
                    "disabled" if not next_enabled else existing["status"],
                    next_secret_ciphertext,
                    next_secret_last4,
                    _to_iso(now),
                    key_id,
                ),
            )
        self._commit()
        return OpenRouterApiKeyRecord(
            key_id=key_id,
            label=next_label,
            secret_last4=next_secret_last4,
            enabled=next_enabled,
            priority=next_priority,
            status="disabled" if not next_enabled else existing["status"],
            last_ok_at=_from_iso(existing["last_ok_at"]),
            last_error_at=_from_iso(existing["last_error_at"]),
            consecutive_failures=int(existing["consecutive_failures"]),
            created_at=_from_iso(existing["created_at"]) or now,
            updated_at=now,
        )

    def disable_openrouter_key(self, key_id: str) -> OpenRouterApiKeyRecord | None:
        return self.patch_openrouter_key(key_id, OpenRouterApiKeyPatch(enabled=False))

    def get_active_key_materials(self) -> list[dict[str, object]]:
        rows = self._fetchall(
            """
            SELECT key_id, label, secret_ciphertext, secret_last4, enabled, priority, status
            FROM openrouter_api_keys
            WHERE enabled = 1
            ORDER BY priority ASC, created_at ASC
            """
        )
        return [
            {
                "key_id": row["key_id"],
                "label": row["label"],
                "secret_ciphertext": row["secret_ciphertext"],
                "secret_last4": row["secret_last4"],
                "enabled": bool(row["enabled"]),
                "priority": int(row["priority"]),
                "status": row["status"],
            }
            for row in rows
        ]

    def list_routing_profiles(self) -> list[RoutingProfile]:
        rows = self._fetchall(
            """
            SELECT capability, strategy, min_context_length, required_parameters_json,
                   preferred_max_latency_seconds, preferred_min_throughput_tokens_per_second,
                   max_prompt_price_usd_per_million, max_completion_price_usd_per_million,
                   retry_policy_json, enabled, updated_at
            FROM routing_profiles
            ORDER BY capability ASC
            """
        )
        return [
            RoutingProfile(
                capability=row["capability"],
                strategy=row["strategy"],
                min_context_length=int(row["min_context_length"]),
                required_parameters=list(
                    _json_loads(row["required_parameters_json"], default=[])
                ),
                preferred_max_latency_seconds=float(row["preferred_max_latency_seconds"]),
                preferred_min_throughput_tokens_per_second=float(
                    row["preferred_min_throughput_tokens_per_second"]
                ),
                max_prompt_price_usd_per_million=(
                    float(row["max_prompt_price_usd_per_million"])
                    if row["max_prompt_price_usd_per_million"] is not None
                    else None
                ),
                max_completion_price_usd_per_million=(
                    float(row["max_completion_price_usd_per_million"])
                    if row["max_completion_price_usd_per_million"] is not None
                    else None
                ),
                retry_policy=dict(_json_loads(row["retry_policy_json"], default={})),
                enabled=bool(row["enabled"]),
                updated_at=_from_iso(row["updated_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def update_routing_profile(
        self,
        capability: RoutingCapability,
        payload: RoutingProfilePatch,
    ) -> RoutingProfile | None:
        existing = self._fetchone(
            """
            SELECT capability, strategy, min_context_length, required_parameters_json,
                   preferred_max_latency_seconds, preferred_min_throughput_tokens_per_second,
                   max_prompt_price_usd_per_million, max_completion_price_usd_per_million,
                   retry_policy_json, enabled, updated_at
            FROM routing_profiles
            WHERE capability = ?
            """,
            (capability,),
        )
        if existing is None:
            return None
        current = RoutingProfile(
            capability=existing["capability"],
            strategy=existing["strategy"],
            min_context_length=int(existing["min_context_length"]),
            required_parameters=list(_json_loads(existing["required_parameters_json"], default=[])),
            preferred_max_latency_seconds=float(existing["preferred_max_latency_seconds"]),
            preferred_min_throughput_tokens_per_second=float(existing["preferred_min_throughput_tokens_per_second"]),
            max_prompt_price_usd_per_million=(
                float(existing["max_prompt_price_usd_per_million"])
                if existing["max_prompt_price_usd_per_million"] is not None
                else None
            ),
            max_completion_price_usd_per_million=(
                float(existing["max_completion_price_usd_per_million"])
                if existing["max_completion_price_usd_per_million"] is not None
                else None
            ),
            retry_policy=dict(_json_loads(existing["retry_policy_json"], default={})),
            enabled=bool(existing["enabled"]),
            updated_at=_from_iso(existing["updated_at"]) or _utcnow(),
        )
        updated = current.model_copy(
            update={
                "strategy": payload.strategy or current.strategy,
                "min_context_length": payload.min_context_length or current.min_context_length,
                "required_parameters": payload.required_parameters or current.required_parameters,
                "preferred_max_latency_seconds": (
                    payload.preferred_max_latency_seconds
                    if payload.preferred_max_latency_seconds is not None
                    else current.preferred_max_latency_seconds
                ),
                "preferred_min_throughput_tokens_per_second": (
                    payload.preferred_min_throughput_tokens_per_second
                    if payload.preferred_min_throughput_tokens_per_second is not None
                    else current.preferred_min_throughput_tokens_per_second
                ),
                "max_prompt_price_usd_per_million": (
                    payload.max_prompt_price_usd_per_million
                    if payload.max_prompt_price_usd_per_million is not None
                    else current.max_prompt_price_usd_per_million
                ),
                "max_completion_price_usd_per_million": (
                    payload.max_completion_price_usd_per_million
                    if payload.max_completion_price_usd_per_million is not None
                    else current.max_completion_price_usd_per_million
                ),
                "retry_policy": payload.retry_policy or current.retry_policy,
                "enabled": current.enabled if payload.enabled is None else payload.enabled,
                "updated_at": _utcnow(),
            }
        )
        self._execute(
            """
            UPDATE routing_profiles
            SET strategy = ?, min_context_length = ?, required_parameters_json = ?,
                preferred_max_latency_seconds = ?, preferred_min_throughput_tokens_per_second = ?,
                max_prompt_price_usd_per_million = ?, max_completion_price_usd_per_million = ?,
                retry_policy_json = ?, enabled = ?, updated_at = ?
            WHERE capability = ?
            """,
            (
                updated.strategy,
                updated.min_context_length,
                _json_dumps(updated.required_parameters),
                updated.preferred_max_latency_seconds,
                updated.preferred_min_throughput_tokens_per_second,
                updated.max_prompt_price_usd_per_million,
                updated.max_completion_price_usd_per_million,
                _json_dumps(updated.retry_policy),
                int(updated.enabled),
                _to_iso(updated.updated_at),
                capability,
            ),
        )
        self._commit()
        return updated

    def replace_model_catalog(self, entries: list[ModelCatalogEntry]) -> None:
        self._execute("DELETE FROM model_catalog_cache")
        for entry in entries:
            self._execute(
                """
                INSERT INTO model_catalog_cache(
                    model_id, canonical_slug, name, description, context_length,
                    output_modalities_json, supported_parameters_json,
                    prompt_price_usd_per_million, completion_price_usd_per_million,
                    request_price_usd, top_provider_json, architecture_json,
                    expiration_date, refreshed_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    entry.model_id,
                    entry.canonical_slug,
                    entry.name,
                    entry.description,
                    entry.context_length,
                    _json_dumps(entry.output_modalities),
                    _json_dumps(entry.supported_parameters),
                    entry.prompt_price_usd_per_million,
                    entry.completion_price_usd_per_million,
                    entry.request_price_usd,
                    _json_dumps(entry.top_provider_json),
                    _json_dumps(entry.architecture_json),
                    _to_iso(entry.expiration_date) if entry.expiration_date else None,
                    _to_iso(entry.refreshed_at),
                ),
            )
        self._commit()

    def list_model_catalog(self) -> list[ModelCatalogEntry]:
        rows = self._fetchall(
            """
            SELECT model_id, canonical_slug, name, description, context_length,
                   output_modalities_json, supported_parameters_json,
                   prompt_price_usd_per_million, completion_price_usd_per_million,
                   request_price_usd, top_provider_json, architecture_json,
                   expiration_date, refreshed_at
            FROM model_catalog_cache
            ORDER BY name ASC
            """
        )
        return [
            ModelCatalogEntry(
                model_id=row["model_id"],
                canonical_slug=row["canonical_slug"],
                name=row["name"],
                description=row["description"],
                context_length=int(row["context_length"]),
                output_modalities=list(_json_loads(row["output_modalities_json"], default=[])),
                supported_parameters=list(_json_loads(row["supported_parameters_json"], default=[])),
                prompt_price_usd_per_million=float(row["prompt_price_usd_per_million"]),
                completion_price_usd_per_million=float(row["completion_price_usd_per_million"]),
                request_price_usd=float(row["request_price_usd"]),
                top_provider_json=dict(_json_loads(row["top_provider_json"], default={})),
                architecture_json=dict(_json_loads(row["architecture_json"], default={})),
                expiration_date=_from_iso(row["expiration_date"]),
                refreshed_at=_from_iso(row["refreshed_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def replace_selection_snapshots(self, snapshots: list[ModelSelectionSnapshot]) -> None:
        self._execute("DELETE FROM model_selection_snapshots")
        for snapshot in snapshots:
            self._execute(
                """
                INSERT INTO model_selection_snapshots(
                    capability, rank_index, model_id, score, selection_reason_json,
                    generated_at, expires_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    snapshot.capability,
                    snapshot.rank_index,
                    snapshot.model_id,
                    snapshot.score,
                    _json_dumps(snapshot.selection_reason),
                    _to_iso(snapshot.generated_at),
                    _to_iso(snapshot.expires_at),
                ),
            )
        self._commit()

    def list_selection_snapshots(self) -> list[ModelSelectionSnapshot]:
        rows = self._fetchall(
            """
            SELECT capability, rank_index, model_id, score, selection_reason_json,
                   generated_at, expires_at
            FROM model_selection_snapshots
            ORDER BY capability ASC, rank_index ASC
            """
        )
        return [
            ModelSelectionSnapshot(
                capability=row["capability"],
                rank_index=int(row["rank_index"]),
                model_id=row["model_id"],
                score=float(row["score"]),
                selection_reason=dict(_json_loads(row["selection_reason_json"], default={})),
                generated_at=_from_iso(row["generated_at"]) or _utcnow(),
                expires_at=_from_iso(row["expires_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def list_openrouter_key_events(self) -> list[OpenRouterKeyEventRecord]:
        rows = self._fetchall(
            """
            SELECT event_id, key_id, key_label, event_type, endpoint, model, error_code, notes, created_at
            FROM openrouter_key_events
            ORDER BY created_at DESC
            """
        )
        return [
            OpenRouterKeyEventRecord(
                event_id=row["event_id"],
                key_id=row["key_id"],
                key_label=row["key_label"],
                event_type=row["event_type"],
                endpoint=row["endpoint"],
                model=row["model"],
                error_code=row["error_code"],
                notes=row["notes"],
                created_at=_from_iso(row["created_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def record_openrouter_key_event(self, payload: OpenRouterKeyEventUpsert) -> None:
        self._execute(
            """
            INSERT INTO openrouter_key_events(
                event_id, key_id, key_label, event_type, endpoint, model, error_code, notes, created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(event_id) DO UPDATE SET
                key_label = excluded.key_label,
                event_type = excluded.event_type,
                endpoint = excluded.endpoint,
                model = excluded.model,
                error_code = excluded.error_code,
                notes = excluded.notes,
                created_at = excluded.created_at
            """,
            (
                payload.event_id,
                payload.key_id,
                payload.key_label,
                payload.event_type,
                payload.endpoint,
                payload.model,
                payload.error_code,
                payload.notes,
                _to_iso(payload.created_at),
            ),
        )
        if payload.event_type == "success":
            self._execute(
                """
                UPDATE openrouter_api_keys
                SET status = 'healthy', last_ok_at = ?, consecutive_failures = 0, updated_at = ?
                WHERE key_id = ?
                """,
                (_to_iso(payload.created_at), _to_iso(payload.created_at), payload.key_id),
            )
        elif payload.event_type == "failure":
            self._execute(
                """
                UPDATE openrouter_api_keys
                SET status = 'degraded', last_error_at = ?, consecutive_failures = consecutive_failures + 1, updated_at = ?
                WHERE key_id = ?
                """,
                (_to_iso(payload.created_at), _to_iso(payload.created_at), payload.key_id),
            )
        elif payload.event_type == "disabled":
            self._execute(
                """
                UPDATE openrouter_api_keys
                SET enabled = 0, status = 'disabled', updated_at = ?
                WHERE key_id = ?
                """,
                (_to_iso(payload.created_at), payload.key_id),
            )
        elif payload.event_type == "enabled":
            self._execute(
                """
                UPDATE openrouter_api_keys
                SET enabled = 1, status = 'unknown', updated_at = ?
                WHERE key_id = ?
                """,
                (_to_iso(payload.created_at), payload.key_id),
            )
        self._commit()

    def list_ai_invocations_for_capability(
        self,
        capability: RoutingCapability,
        *,
        limit: int = 200,
    ) -> list[AIInvocationRecord]:
        endpoint_filters = {
            "daily_plan": (
                "/v1/missions/daily",
                "/v1/suggestions/generate",
                "/v1/finance/reflect",
                "/v1/pantry/rescue",
                "/v1/closet/decision",
            ),
            "task_rewrite": ("/v1/tasks/rewrite",),
            "semantic_classify": ("/v1/events/classify",),
            "weekly_summary": (),
        }
        endpoints = endpoint_filters[capability]
        if not endpoints:
            return []
        placeholders = _sqlite_in_placeholders(endpoints)
        query = (
            "SELECT invocation_id, user_id, endpoint, provider, model, latency_ms, fallback, "
            "suggestions_count, estimated_cost_usd, schema_valid, status, created_at, metadata_json "
            "FROM ai_invocations "
            f"WHERE endpoint IN ({placeholders}) "  # nosec B608
            "ORDER BY created_at DESC "
            "LIMIT ?"
        )
        rows = self._fetchall(query, (*endpoints, limit))
        return [
            AIInvocationRecord(
                invocation_id=row["invocation_id"],
                user_id=row["user_id"],
                endpoint=row["endpoint"],
                provider=row["provider"],
                model=row["model"],
                latency_ms=float(row["latency_ms"]),
                fallback=bool(row["fallback"]),
                suggestions_count=int(row["suggestions_count"]),
                estimated_cost_usd=float(row["estimated_cost_usd"]),
                schema_valid=bool(row["schema_valid"]),
                status=row["status"],
                created_at=_from_iso(row["created_at"]) or _utcnow(),
                metadata=dict(_json_loads(row["metadata_json"], default={})),
            )
            for row in rows
        ]

    def list_support_requests(self) -> list[SupportRequest]:
        rows = self._fetchall(
            """
            SELECT request_id, user_id, request_type, status, requested_at
            FROM support_requests
            ORDER BY requested_at DESC
            """
        )
        return [
            SupportRequest(
                request_id=row["request_id"],
                user_id=row["user_id"],
                request_type=row["request_type"],
                status=row["status"],
                requested_at=_from_iso(row["requested_at"]) or _utcnow(),
            )
            for row in rows
        ]

    def _latest_activity(self) -> datetime | None:
        timestamps = [
            self._scalar("SELECT MAX(created_at) FROM ai_invocations"),
            self._scalar("SELECT MAX(created_at) FROM mission_audit_records"),
            self._scalar("SELECT MAX(created_at) FROM feedback_audit_records"),
            self._scalar("SELECT MAX(created_at) FROM safety_events"),
            self._scalar("SELECT MAX(created_at) FROM usage_events"),
        ]
        parsed = [value for value in (_from_iso(item) if isinstance(item, str) else None for item in timestamps) if value]
        return max(parsed) if parsed else None

    def _count_feedback_statuses(self, statuses: tuple[str, ...]) -> int:
        placeholders = _sqlite_in_placeholders(statuses)
        query = (
            f"SELECT COUNT(*) FROM feedback_audit_records WHERE status IN ({placeholders})"  # nosec B608
        )
        return int(
            self._scalar(
                query,
                statuses,
            )
        )

    def _sum_usage_events(self, event_type: str) -> int:
        return int(
            self._scalar(
                """
                SELECT COALESCE(SUM(quantity), 0)
                FROM usage_events
                WHERE event_type = ?
                """,
                (event_type,),
            )
        )
