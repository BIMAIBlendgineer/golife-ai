from __future__ import annotations

import json
from pathlib import Path
from threading import Lock
from datetime import datetime, timezone
from uuid import uuid4

from app.learning_memory import (
    build_privacy_safe_feedback_summary,
    derive_effort_feedback,
    derive_rejection_reason_category,
    resolve_feedback_learning_key,
    summarize_feedback_items,
)
from app.schemas import MissionFeedbackRequest


class MissionFeedbackStore:
    def __init__(self, storage_path: str | Path) -> None:
        self._lock = Lock()
        self._storage_path = Path(storage_path)
        self._storage_path.parent.mkdir(parents=True, exist_ok=True)
        self._items, migrated = self._load()
        if migrated:
            self._persist()

    def record(self, payload: MissionFeedbackRequest) -> str:
        feedback_id = f"feedback-{uuid4()}"
        note_text = (payload.notes or "").strip()
        rejection_reason_category = derive_rejection_reason_category(
            status=payload.status,
            raw_category=payload.rejection_reason_category,
            note_text=note_text,
        )
        effort_feedback = derive_effort_feedback(
            status=payload.status,
            raw_effort_feedback=payload.effort_feedback,
            rejection_reason_category=rejection_reason_category,
        )
        learning_key, learning_key_source = resolve_feedback_learning_key(
            suggestion_id=payload.suggestion_id,
            domain_targets=payload.domain_targets,
            recommendation_type=payload.recommendation_type,
            trace=payload.trace,
        )
        recorded_at = (
            payload.timestamp.astimezone(timezone.utc).isoformat()
            if payload.timestamp is not None
            else datetime.now(timezone.utc).isoformat()
        )
        item = {
            "feedback_id": feedback_id,
            "user_id": payload.user_id,
            "suggestion_id": payload.suggestion_id,
            "status": payload.status,
            "notes_present": bool(note_text),
            "notes_char_count": len(note_text),
            "domain_targets": payload.domain_targets,
            "recommendation_type": payload.recommendation_type,
            "learning_key": learning_key,
            "learning_key_source": learning_key_source,
            "rejection_reason_category": rejection_reason_category,
            "effort_feedback": effort_feedback,
            "repeated_flag": payload.repeated_flag,
            "privacy_safe_summary": build_privacy_safe_feedback_summary(
                status=payload.status,
                domain_targets=payload.domain_targets,
                recommendation_type=payload.recommendation_type,
                rejection_reason_category=rejection_reason_category,
                effort_feedback=effort_feedback,
                repeated_flag=payload.repeated_flag,
            ),
            "recorded_at": recorded_at,
            "trace": payload.trace,
        }
        with self._lock:
            self._items.append(item)
            self._persist()
        return feedback_id

    def all(self) -> list[dict[str, object]]:
        with self._lock:
            return list(self._items)

    def summarize(self, user_id: str | None = None) -> dict[str, object]:
        with self._lock:
            return summarize_feedback_items(self._items, user_id=user_id)

    def _load(self) -> tuple[list[dict[str, object]], bool]:
        if not self._storage_path.exists():
            return [], False

        try:
            raw_data = json.loads(self._storage_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return [], False

        if not isinstance(raw_data, list):
            return [], False

        migrated = False
        items: list[dict[str, object]] = []
        for raw_item in raw_data:
            if not isinstance(raw_item, dict):
                continue
            item = dict(raw_item)
            legacy_notes = str(item.pop("notes", "") or "").strip()
            if "notes" in raw_item:
                migrated = True
            if "notes_present" not in item:
                item["notes_present"] = bool(legacy_notes)
                migrated = migrated or bool(legacy_notes)
            if "notes_char_count" not in item:
                item["notes_char_count"] = len(legacy_notes)
                migrated = migrated or bool(legacy_notes)
            item.setdefault("rejection_reason_category", None)
            item.setdefault("effort_feedback", "unknown")
            item.setdefault("repeated_flag", False)
            item.setdefault(
                "privacy_safe_summary",
                build_privacy_safe_feedback_summary(
                    status=item.get("status"),
                    domain_targets=item.get("domain_targets", []),
                    recommendation_type=item.get("recommendation_type"),
                    rejection_reason_category=item.get("rejection_reason_category"),
                    effort_feedback=str(item.get("effort_feedback", "unknown")),
                    repeated_flag=bool(item.get("repeated_flag", False)),
                ),
            )
            item.setdefault(
                "recorded_at",
                datetime.now(timezone.utc).isoformat(),
            )
            items.append(item)
        return items, migrated

    def _persist(self) -> None:
        temp_path = self._storage_path.with_suffix(self._storage_path.suffix + ".tmp")
        temp_path.write_text(
            json.dumps(self._items, indent=2, ensure_ascii=True),
            encoding="utf-8",
        )
        temp_path.replace(self._storage_path)
