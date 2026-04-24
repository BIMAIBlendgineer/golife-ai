from __future__ import annotations

from threading import Lock

from app.schemas import AITrace


class InMemoryTraceStore:
    def __init__(self) -> None:
        self._lock = Lock()
        self._items: list[AITrace] = []

    def persist(self, trace: AITrace) -> None:
        with self._lock:
            self._items.append(trace)

    def all(self) -> list[AITrace]:
        with self._lock:
            return list(self._items)

    def for_operation(self, operation: str) -> list[AITrace]:
        return [trace for trace in self.all() if trace.operation == operation]
