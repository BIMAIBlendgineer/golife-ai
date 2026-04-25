from __future__ import annotations

import argparse
import asyncio
import statistics
import time
from collections import Counter

import httpx


def build_payload() -> dict[str, object]:
    return {
        "user_id": "load-user",
        "allowed_domains": ["finance", "pantry", "task"],
        "privacy_settings": {
            "ai_enabled": True,
            "allowed_domains": ["finance", "pantry", "task"],
        },
        "life_events": [
            {
                "event_id": "evt-finance",
                "user_id": "load-user",
                "domain": "finance",
                "event_type": "expense_logged",
                "timestamp": "2026-04-25T09:00:00Z",
                "payload": {"value": 12.4},
                "source": "manual",
                "privacy_level": "ai_allowed",
            },
            {
                "event_id": "evt-pantry",
                "user_id": "load-user",
                "domain": "pantry",
                "event_type": "ingredient_flagged",
                "timestamp": "2026-04-25T09:02:00Z",
                "payload": {"value": 1},
                "source": "manual",
                "privacy_level": "ai_allowed",
            },
        ],
    }


async def run_request(
    client: httpx.AsyncClient,
    base_url: str,
    endpoint: str,
) -> tuple[int, float]:
    started_at = time.perf_counter()
    response = await client.post(f"{base_url.rstrip('/')}{endpoint}", json=build_payload())
    latency_ms = (time.perf_counter() - started_at) * 1000
    return response.status_code, latency_ms


async def worker(
    *,
    client: httpx.AsyncClient,
    base_url: str,
    endpoint: str,
    iterations: int,
    statuses: Counter[int],
    latencies: list[float],
) -> None:
    for _ in range(iterations):
        status_code, latency_ms = await run_request(client, base_url, endpoint)
        statuses[status_code] += 1
        latencies.append(latency_ms)


def percentile(values: list[float], ratio: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    index = min(len(ordered) - 1, max(0, round((len(ordered) - 1) * ratio)))
    return ordered[index]


async def main() -> int:
    parser = argparse.ArgumentParser(description="GoLife AI Gateway load smoke test")
    parser.add_argument("--base-url", default="http://127.0.0.1:8000")
    parser.add_argument("--endpoint", default="/v1/missions/daily")
    parser.add_argument("--requests", type=int, default=60)
    parser.add_argument("--concurrency", type=int, default=10)
    parser.add_argument("--timeout-seconds", type=float, default=10.0)
    parser.add_argument("--max-p95-ms", type=float, default=2000.0)
    parser.add_argument("--max-error-rate", type=float, default=0.0)
    args = parser.parse_args()

    total_requests = max(1, args.requests)
    concurrency = max(1, min(args.concurrency, total_requests))
    base_iterations = total_requests // concurrency
    extra = total_requests % concurrency

    latencies: list[float] = []
    statuses: Counter[int] = Counter()

    async with httpx.AsyncClient(timeout=args.timeout_seconds) as client:
        tasks = []
        for index in range(concurrency):
            iterations = base_iterations + (1 if index < extra else 0)
            tasks.append(
                worker(
                    client=client,
                    base_url=args.base_url,
                    endpoint=args.endpoint,
                    iterations=iterations,
                    statuses=statuses,
                    latencies=latencies,
                )
            )
        started_at = time.perf_counter()
        await asyncio.gather(*tasks)
        total_duration = time.perf_counter() - started_at

    total_completed = sum(statuses.values())
    error_count = sum(count for status, count in statuses.items() if status >= 400)
    error_rate = error_count / total_completed if total_completed else 1.0
    p50 = percentile(latencies, 0.50)
    p95 = percentile(latencies, 0.95)
    max_latency = max(latencies, default=0.0)
    avg_latency = statistics.fmean(latencies) if latencies else 0.0
    rps = total_completed / total_duration if total_duration > 0 else 0.0

    print("GoLife AI Gateway load smoke")
    print(f"endpoint={args.endpoint}")
    print(f"requests={total_completed}")
    print(f"concurrency={concurrency}")
    print(f"duration_seconds={total_duration:.2f}")
    print(f"requests_per_second={rps:.2f}")
    print(f"status_counts={dict(statuses)}")
    print(f"latency_avg_ms={avg_latency:.2f}")
    print(f"latency_p50_ms={p50:.2f}")
    print(f"latency_p95_ms={p95:.2f}")
    print(f"latency_max_ms={max_latency:.2f}")
    print(f"error_rate={error_rate:.4f}")

    if error_rate > args.max_error_rate:
        print(
            f"FAIL: error_rate {error_rate:.4f} exceeded threshold {args.max_error_rate:.4f}"
        )
        return 1
    if p95 > args.max_p95_ms:
        print(f"FAIL: p95 {p95:.2f}ms exceeded threshold {args.max_p95_ms:.2f}ms")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
