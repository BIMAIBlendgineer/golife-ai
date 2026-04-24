from __future__ import annotations

from threading import Lock
from uuid import uuid4

from app.schemas import MissionFeedbackRequest


class MissionFeedbackStore:
    def __init__(self) -> None:
        self._lock = Lock()
        self._items: list[dict[str, object]] = []

    def record(self, payload: MissionFeedbackRequest) -> str:
        feedback_id = f"feedback-{uuid4()}"
        with self._lock:
            self._items.append(
                {
                    "feedback_id": feedback_id,
                    "user_id": payload.user_id,
                    "suggestion_id": payload.suggestion_id,
                    "status": payload.status,
                    "notes": payload.notes,
                    "trace": payload.trace,
                }
            )
        return feedback_id

    def all(self) -> list[dict[str, object]]:
        with self._lock:
            return list(self._items)
