from __future__ import annotations

import json
from pathlib import Path
from threading import Lock
from uuid import uuid4

from app.schemas import MissionFeedbackRequest


class MissionFeedbackStore:
    def __init__(self, storage_path: str | Path) -> None:
        self._lock = Lock()
        self._storage_path = Path(storage_path)
        self._storage_path.parent.mkdir(parents=True, exist_ok=True)
        self._items = self._load()

    def record(self, payload: MissionFeedbackRequest) -> str:
        feedback_id = f"feedback-{uuid4()}"
        item = {
            "feedback_id": feedback_id,
            "user_id": payload.user_id,
            "suggestion_id": payload.suggestion_id,
            "status": payload.status,
            "notes": payload.notes,
            "trace": payload.trace,
        }
        with self._lock:
            self._items.append(item)
            self._persist()
        return feedback_id

    def all(self) -> list[dict[str, object]]:
        with self._lock:
            return list(self._items)

    def _load(self) -> list[dict[str, object]]:
        if not self._storage_path.exists():
            return []

        try:
            raw_data = json.loads(self._storage_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return []

        if not isinstance(raw_data, list):
            return []
        return [item for item in raw_data if isinstance(item, dict)]

    def _persist(self) -> None:
        temp_path = self._storage_path.with_suffix(self._storage_path.suffix + ".tmp")
        temp_path.write_text(
            json.dumps(self._items, indent=2, ensure_ascii=True),
            encoding="utf-8",
        )
        temp_path.replace(self._storage_path)
