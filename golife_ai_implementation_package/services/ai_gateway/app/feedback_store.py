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
            "domain_targets": payload.domain_targets,
            "recommendation_type": payload.recommendation_type,
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
            by_suggestion: dict[str, dict[str, int]] = {}
            by_domain: dict[str, dict[str, int]] = {}
            totals: dict[str, int] = {}
            matching_items = 0

            for item in self._items:
                if user_id and str(item.get("user_id", "")) != user_id:
                    continue

                status = str(item.get("status", "unknown"))
                suggestion_id = str(item.get("suggestion_id", ""))
                matching_items += 1
                totals[status] = totals.get(status, 0) + 1

                suggestion_stats = by_suggestion.setdefault(suggestion_id, {})
                suggestion_stats[status] = suggestion_stats.get(status, 0) + 1

                for domain in item.get("domain_targets", []) or []:
                    domain_name = str(domain)
                    domain_stats = by_domain.setdefault(domain_name, {})
                    domain_stats[status] = domain_stats.get(status, 0) + 1

            return {
                "user_id": user_id,
                "item_count": matching_items,
                "totals": totals,
                "by_suggestion": by_suggestion,
                "by_domain": by_domain,
            }

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
