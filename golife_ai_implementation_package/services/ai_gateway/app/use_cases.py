from app.graphs.golife_graph import run_suggestion_graph
from app.guardrails import enforce_task_rewrite_privacy
from app.providers.base import LLMProvider
from app.schemas import (
    SuggestionRequest,
    SuggestionResponse,
    TaskRewriteRequest,
    TaskRewriteResponse,
    TaskRewriteStep,
)
from app.settings import Settings

TASK_REWRITE_SYSTEM_PROMPT = """
Return JSON only.
Rewrite the task into small, safe, actionable steps.
No external actions without confirmation.
"""


async def run_suggestions(
    request: SuggestionRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
    intent: str,
) -> SuggestionResponse:
    return await run_suggestion_graph(
        request,
        settings=settings,
        provider=provider,
        intent=intent,
    )


async def run_domain_suggestions(
    request: SuggestionRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
    required_domain: str,
    intent: str,
) -> SuggestionResponse:
    merged_domains = list(
        dict.fromkeys(
            [
                *request.allowed_domains,
                *request.privacy_settings.allowed_domains,
                required_domain,
            ]
        )
    )
    domain_request = request.model_copy(
        update={
            "scope": "domain",
            "allowed_domains": merged_domains,
            "privacy_settings": request.privacy_settings.model_copy(
                update={"allowed_domains": merged_domains}
            ),
        }
    )
    return await run_suggestions(
        domain_request,
        settings=settings,
        provider=provider,
        intent=intent,
    )


async def run_task_rewrite(
    request: TaskRewriteRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> TaskRewriteResponse:
    enforce_task_rewrite_privacy(request)
    provider_result = await provider.complete_json(
        system_prompt=TASK_REWRITE_SYSTEM_PROMPT,
        user_payload={
            "intent": "task_rewrite",
            "user_id": request.user_id,
            "task_title": request.task_title,
            "task_description": request.task_description,
            "constraints": request.constraints,
        },
    )
    rewrites = [
        TaskRewriteStep.model_validate(item)
        for item in provider_result.get("rewrites", [])
    ]
    return TaskRewriteResponse(
        rewrites=rewrites,
        trace={
            "provider": provider.provider_name,
            "configured_provider": settings.llm_provider,
            "mock_mode": settings.resolved_mock_mode,
            "rewrite_count": len(rewrites),
            "mock": provider_result.get("mock", False),
        },
    )
