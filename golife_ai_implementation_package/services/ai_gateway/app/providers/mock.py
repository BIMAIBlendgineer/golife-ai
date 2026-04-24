from typing import Any

from app.providers.base import LLMProvider
from app.schemas import Domain


class MockLLMProvider(LLMProvider):
    provider_name = "mock"

    def __init__(self, *, reason: str = "explicit_mock") -> None:
        self.reason = reason

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None = None,
        model: str | None = None,
        temperature: float = 0.2,
    ) -> dict[str, Any]:
        intent = str(user_payload.get("intent", "daily_mission"))
        if intent == "task_rewrite":
            return self._task_rewrite(user_payload)
        if intent == "finance_reflect":
            return self._finance_reflect(user_payload)
        if intent == "pantry_rescue":
            return self._pantry_rescue(user_payload)
        if intent == "closet_decision":
            return self._closet_decision(user_payload)
        return self._daily_mission(user_payload)

    def _daily_mission(self, payload: dict[str, Any]) -> dict[str, Any]:
        domains = self._extract_domains(payload)
        if {"task", "habit"}.issubset(domains):
            suggestions = [
                self._suggestion(
                    suggestion_id="mock-daily-task-habit",
                    title="Cerrar una tarea corta y registrar un habito base",
                    domain_targets=["task", "habit"],
                    recommendation_type="mission",
                    body="Haz una tarea de menos de 10 minutos y registra un habito de recuperacion para recuperar traccion.",
                    evidence=[
                        self._evidence("task", "Hay actividad reciente de tareas."),
                        self._evidence("habit", "Tambien hay actividad reciente de habitos."),
                    ],
                    confidence=0.78,
                    uncertainty="Respuesta mock basada en patrones locales, no en un modelo remoto.",
                )
            ]
        elif {"finance", "pantry"}.issubset(domains):
            suggestions = [
                self._suggestion(
                    suggestion_id="mock-daily-finance-pantry",
                    title="Usar despensa antes de una compra nueva",
                    domain_targets=["finance", "pantry"],
                    recommendation_type="mission",
                    body="Antes de comprar algo hoy, revisa un item ya disponible en despensa que pueda cubrir una comida simple.",
                    evidence=[
                        self._evidence("finance", "Hay eventos financieros permitidos."),
                        self._evidence("pantry", "Tambien hay senales de pantry o grocery list."),
                    ],
                    confidence=0.76,
                    uncertainty="Respuesta mock; conviene revisar disponibilidad real antes de actuar.",
                )
            ]
        elif "wardrobe" in domains:
            suggestions = [
                self._suggestion(
                    suggestion_id="mock-daily-wardrobe",
                    title="Revisar el armario antes de una compra",
                    domain_targets=["wardrobe"],
                    recommendation_type="reflection",
                    body="Compara la intencion de compra con una prenda que ya tengas y decide despues de revisar una alternativa interna.",
                    evidence=[
                        self._evidence("wardrobe", "El dominio wardrobe contiene actividad relevante."),
                    ],
                    confidence=0.74,
                    uncertainty="Respuesta mock; requiere confirmacion humana y revision visual.",
                )
            ]
        else:
            suggestions = [
                self._suggestion(
                    suggestion_id="mock-daily-generic",
                    title="Elegir una accion pequena y verificable",
                    domain_targets=["mission"],
                    recommendation_type="mission",
                    body="Elige una sola accion de bajo esfuerzo que puedas completar hoy y revisa despues si realmente redujo friccion.",
                    evidence=[
                        self._evidence("mission", "Hay suficiente contexto para sugerir una accion pequena."),
                    ],
                    confidence=0.63,
                    uncertainty="Respuesta mock con contexto limitado.",
                )
            ]

        return self._result(suggestions=suggestions)

    def _finance_reflect(self, payload: dict[str, Any]) -> dict[str, Any]:
        suggestions = [
            self._suggestion(
                suggestion_id="mock-finance-reflect",
                title="Mirar el gasto reciente con contexto",
                domain_targets=["finance"],
                recommendation_type="reflection",
                body="Resume un gasto reciente y revisa si estuvo conectado a una necesidad concreta o a una compra impulsiva.",
                evidence=[
                    self._evidence("finance", "Se recibio contexto financiero permitido."),
                ],
                confidence=0.8,
                uncertainty="Respuesta mock de reflexion; no es consejo financiero.",
            )
        ]
        return self._result(suggestions=suggestions)

    def _pantry_rescue(self, payload: dict[str, Any]) -> dict[str, Any]:
        suggestions = [
            self._suggestion(
                suggestion_id="mock-pantry-rescue",
                title="Rescatar un ingrediente ya disponible",
                domain_targets=["pantry"],
                recommendation_type="mission",
                body="Usa primero un ingrediente ya registrado antes de agregar uno nuevo a la lista de compra.",
                evidence=[
                    self._evidence("pantry", "Se detecto contexto de pantry permitido."),
                ],
                confidence=0.79,
                uncertainty="Respuesta mock; confirma existencias reales antes de actuar.",
            )
        ]
        return self._result(suggestions=suggestions)

    def _closet_decision(self, payload: dict[str, Any]) -> dict[str, Any]:
        suggestions = [
            self._suggestion(
                suggestion_id="mock-closet-decision",
                title="Comparar una compra con lo que ya existe",
                domain_targets=["wardrobe"],
                recommendation_type="reflection",
                body="Antes de comprar, revisa si ya tienes una prenda funcionalmente similar y decide despues de esa comparacion.",
                evidence=[
                    self._evidence("wardrobe", "Se detecto actividad de armario o purchase intention."),
                ],
                confidence=0.77,
                uncertainty="Respuesta mock; la comparacion final la debe hacer la persona usuaria.",
            )
        ]
        return self._result(suggestions=suggestions)

    def _task_rewrite(self, payload: dict[str, Any]) -> dict[str, Any]:
        task_title = str(payload.get("task_title", "Tarea"))
        rewrites = [
            {
                "title": f"Definir resultado de: {task_title}",
                "reason": "Aclara que significa terminar la tarea.",
                "estimated_minutes": 5,
                "evidence": [
                    self._evidence("task", f"La tarea original fue '{task_title}'."),
                ],
                "confidence": 0.82,
            },
            {
                "title": "Preparar el primer insumo o documento",
                "reason": "Reduce friccion antes de empezar.",
                "estimated_minutes": 10,
                "evidence": [
                    self._evidence("task", "Preparar insumos suele desbloquear la ejecucion."),
                ],
                "confidence": 0.76,
            },
            {
                "title": "Hacer el primer bloque de 15 minutos",
                "reason": "Convierte una tarea difusa en una accion concreta.",
                "estimated_minutes": 15,
                "evidence": [
                    self._evidence("task", "Un primer bloque pequeno reduce la procrastinacion."),
                ],
                "confidence": 0.8,
            },
        ]
        return {
            "mock": True,
            "reason": self.reason,
            "rewrites": rewrites,
            "_provider_meta": {"provider": self.provider_name},
        }

    def _extract_domains(self, payload: dict[str, Any]) -> set[Domain]:
        domains: set[Domain] = set()
        for domain in payload.get("allowed_domains", []):
            domains.add(domain)
        for event in payload.get("events", []):
            domain = event.get("domain")
            if domain:
                domains.add(domain)
        for summary in payload.get("domain_summaries", []):
            domain = summary.get("domain")
            if domain:
                domains.add(domain)
        return domains

    def _result(self, *, suggestions: list[dict[str, Any]]) -> dict[str, Any]:
        return {
            "mock": True,
            "reason": self.reason,
            "suggestions": suggestions,
            "_provider_meta": {"provider": self.provider_name},
        }

    @staticmethod
    def _suggestion(
        *,
        suggestion_id: str,
        title: str,
        domain_targets: list[Domain],
        recommendation_type: str,
        body: str,
        evidence: list[dict[str, Any]],
        confidence: float,
        uncertainty: str,
    ) -> dict[str, Any]:
        return {
            "suggestion_id": suggestion_id,
            "title": title,
            "domain_targets": domain_targets,
            "recommendation_type": recommendation_type,
            "body": body,
            "evidence": evidence,
            "confidence": confidence,
            "uncertainty": uncertainty,
            "requires_confirmation": True,
            "forbidden_actions": [
                "external_action_without_confirmation",
                "regulated_advice",
            ],
            "status": "draft",
        }

    @staticmethod
    def _evidence(source_domain: Domain, claim: str) -> dict[str, Any]:
        return {
            "source_domain": source_domain,
            "entity_id": None,
            "claim": claim,
            "confidence": 0.7,
        }
