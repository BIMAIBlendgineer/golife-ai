from fastapi.testclient import TestClient

from app.main import create_app
from app.providers.base import LLMProvider
from app.settings import Settings


def _event(event_id: str, domain: str, event_type: str = 'logged') -> dict:
    return {
        'event_id': event_id,
        'user_id': 'user-1',
        'domain': domain,
        'event_type': event_type,
        'timestamp': '2026-04-24T10:00:00Z',
        'payload': {'value': 1},
        'source': 'manual',
        'privacy_level': 'ai_allowed',
    }


def test_daily_mission_graph_tasks_and_habits(client):
    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['task', 'habit'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['task', 'habit'],
            },
            'domain_summaries': [
                {'domain': 'task', 'summary': 'Several open tasks', 'evidence_count': 2},
                {'domain': 'habit', 'summary': 'A recovery habit is active', 'evidence_count': 1},
            ],
            'constraints': {'tone': 'gentle'},
            'life_events': [
                _event('evt-task-1', 'task'),
                _event('evt-habit-1', 'habit', 'habit_checked'),
            ],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data['suggestions']) == 3
    assert data['suggestions'][0]['domain_targets'] == ['task', 'habit']
    assert data['suggestions'][0]['requires_confirmation'] is True
    assert 'validate_consent' in data['trace']['nodes']
    assert 'assess_risks' in data['trace']['nodes']
    assert 'feedback_learning' in data['trace']['nodes']
    assert 'build_response' in data['trace']['nodes']
    assert data['trace']['assess_risks']['risk_count'] >= 1


def test_daily_mission_graph_finance_and_pantry(client):
    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['finance', 'pantry'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['finance', 'pantry'],
            },
            'domain_summaries': [
                {'domain': 'finance', 'summary': 'Food spending increased', 'evidence_count': 1},
                {'domain': 'pantry', 'summary': 'There are ingredients to use', 'evidence_count': 2},
            ],
            'constraints': {'avoid': ['shopping_recommendations']},
            'life_events': [
                _event('evt-finance-1', 'finance', 'expense_logged'),
                _event('evt-pantry-1', 'pantry', 'ingredient_flagged'),
            ],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data['suggestions']) == 3
    body = data['suggestions'][0]['body'].lower()
    assert 'buy' not in body
    assert 'revisa' in body or 'despensa' in body or 'comida' in body
    assert data['trace']['classify_day_state']['day_state'] == 'recovery'
    assert data['trace']['assess_risks']['risks'][0]['risk_id'] == 'food_spend_overlap'
    assert data['trace']['rank']['score_breakdown']


def test_daily_mission_graph_wardrobe_purchase_intention(client):
    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['wardrobe'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['wardrobe'],
            },
            'domain_summaries': [
                {
                    'domain': 'wardrobe',
                    'summary': 'A purchase intention needs review',
                    'evidence_count': 1,
                },
            ],
            'constraints': {'require_visual_check': True},
            'life_events': [
                _event('evt-closet-1', 'wardrobe', 'purchase_intention'),
            ],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data['suggestions']) == 3
    suggestion = data['suggestions'][0]
    assert suggestion['domain_targets'] == ['wardrobe']
    assert 'compara' in suggestion['body'].lower() or 'revis' in suggestion['body'].lower()
    assert suggestion['evidence']
    assert suggestion['uncertainty']
    assert data['trace']['assess_risks']['risks'][0]['risk_id'] == 'purchase_intention_active'


class TwoSuggestionProvider(LLMProvider):
    provider_name = 'two-suggestion-provider'

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict,
        response_schema: dict | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> dict:
        return {
            'suggestions': [
                {
                    'suggestion_id': 's-1',
                    'title': 'Complete the task',
                    'domain_targets': ['task'],
                    'recommendation_type': 'mission',
                    'body': 'Finish the task block.',
                    'evidence': [
                        {
                            'source_domain': 'task',
                            'claim': 'Task evidence exists.',
                            'confidence': 0.9,
                        }
                    ],
                    'confidence': 0.8,
                    'uncertainty': 'low',
                    'requires_confirmation': True,
                },
                {
                    'suggestion_id': 's-2',
                    'title': 'Protect the habit',
                    'domain_targets': ['habit'],
                    'recommendation_type': 'mission',
                    'body': 'Keep the habit alive.',
                    'evidence': [
                        {
                            'source_domain': 'habit',
                            'claim': 'Habit evidence exists.',
                            'confidence': 0.8,
                        }
                    ],
                    'confidence': 0.78,
                    'uncertainty': 'medium',
                    'requires_confirmation': True,
                },
            ]
        }


class StaticSuggestionProvider(LLMProvider):
    provider_name = 'static-suggestion-provider'

    def __init__(self, suggestions: list[dict]) -> None:
        self._suggestions = suggestions
        self.seen_payloads: list[dict] = []

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict,
        response_schema: dict | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> dict:
        self.seen_payloads.append(user_payload)
        return {'suggestions': self._suggestions}


def test_daily_mission_graph_synthesizes_missing_third_suggestion():
    app = create_app(
        settings=Settings(ai_gateway_enable_mock=False, llm_provider='openrouter'),
        provider=TwoSuggestionProvider(),
    )
    client = TestClient(app)

    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['task', 'habit', 'pantry'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['task', 'habit', 'pantry'],
            },
            'life_events': [
                _event('evt-task-1', 'task'),
                _event('evt-habit-1', 'habit', 'habit_checked'),
                _event('evt-pantry-1', 'pantry', 'ingredient_flagged'),
            ],
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data['suggestions']) == 3
    assert data['trace']['build_response']['synthesized_count'] == 1


def test_daily_mission_graph_adds_structured_ranking(client):
    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['task', 'habit'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['task', 'habit'],
            },
            'domain_summaries': [
                {'domain': 'task', 'summary': 'Urgent task pressure exists', 'evidence_count': 2},
                {'domain': 'habit', 'summary': 'A fragile habit needs continuity', 'evidence_count': 1},
            ],
            'life_events': [
                _event('evt-task-1', 'task'),
                _event('evt-habit-1', 'habit', 'habit_checked'),
            ],
        },
    )

    assert response.status_code == 200
    data = response.json()
    ranking = data['suggestions'][0]['ranking']
    assert ranking['impact_score'] >= 0.6
    assert ranking['urgency_score'] >= 0.5
    assert ranking['final_score'] >= 0.5
    assert ranking['ranking_reason']
    assert ranking['evidence_refs']
    assert 'privacy_score' in ranking
    assert 'feedback_score' in ranking
    assert 'novelty_score' in ranking
    assert data['trace']['rank']['score_breakdown'][0]['ranking_reason']


def test_daily_mission_graph_low_effort_mission_beats_higher_effort_peer():
    provider = StaticSuggestionProvider(
        suggestions=[
            {
                'suggestion_id': 'mission-low-effort',
                'title': 'Close one visible task block',
                'domain_targets': ['task'],
                'recommendation_type': 'mission',
                'body': 'Finish one visible task block before switching.',
                'evidence': [
                    {
                        'source_domain': 'task',
                        'claim': 'Task evidence exists.',
                        'confidence': 0.8,
                    }
                ],
                'confidence': 0.76,
                'uncertainty': 'low',
                'requires_confirmation': True,
            },
            {
                'suggestion_id': 'mission-higher-effort',
                'title': 'Reshape the task and the whole week',
                'domain_targets': ['task', 'week'],
                'recommendation_type': 'mission',
                'body': 'Rework the task plan and also adjust the wider week.',
                'evidence': [
                    {
                        'source_domain': 'task',
                        'claim': 'Task evidence exists.',
                        'confidence': 0.76,
                    }
                ],
                'confidence': 0.72,
                'uncertainty': 'medium',
                'requires_confirmation': True,
            },
        ]
    )
    app = create_app(
        settings=Settings(ai_gateway_enable_mock=False, llm_provider='openrouter'),
        provider=provider,
    )
    client = TestClient(app)

    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['task', 'week'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['task', 'week'],
            },
            'life_events': [
                _event('evt-task-1', 'task'),
                _event('evt-week-1', 'week'),
            ],
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data['suggestions'][0]['suggestion_id'] == 'mission-low-effort'
    assert data['suggestions'][0]['ranking']['effort_score'] > data['suggestions'][1]['ranking']['effort_score']


def test_daily_mission_graph_penalizes_repeated_rejected_pattern(tmp_path):
    provider = StaticSuggestionProvider(
        suggestions=[
            {
                'suggestion_id': 'mission-repeat-task',
                'title': 'Push the same task mission again',
                'domain_targets': ['task'],
                'recommendation_type': 'mission',
                'body': 'Repeat the same task push.',
                'evidence': [
                    {
                        'source_domain': 'task',
                        'claim': 'Task evidence exists.',
                        'confidence': 0.82,
                    }
                ],
                'confidence': 0.78,
                'uncertainty': 'medium',
                'requires_confirmation': True,
            },
            {
                'suggestion_id': 'reflection-task',
                'title': 'Review the task shape first',
                'domain_targets': ['task'],
                'recommendation_type': 'reflection',
                'body': 'Review why this task matters before pushing again.',
                'evidence': [
                    {
                        'source_domain': 'task',
                        'claim': 'Task evidence exists.',
                        'confidence': 0.8,
                    }
                ],
                'confidence': 0.72,
                'uncertainty': 'medium',
                'requires_confirmation': True,
            },
        ]
    )
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=False,
            llm_provider='openrouter',
            feedback_store_path=str(tmp_path / 'mission_feedback.json'),
        ),
        provider=provider,
    )
    client = TestClient(app)

    for index in range(2):
        feedback_response = client.post(
            '/v1/feedback',
            json={
                'user_id': 'user-1',
                'suggestion_id': f'old-task-mission-{index}',
                'status': 'rejected',
                'domain_targets': ['task'],
                'recommendation_type': 'mission',
                'rejection_reason_category': 'too_hard',
                'effort_feedback': 'high',
                'repeated_flag': True,
                'notes': 'This feels too hard and too repetitive.',
                'trace': {'learning_keys_by_suggestion_id': {f'old-task-mission-{index}': 'mission|task'}},
            },
        )
        assert feedback_response.status_code == 200

    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['task'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['task'],
            },
            'life_events': [_event('evt-task-1', 'task')],
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data['suggestions'][0]['suggestion_id'] == 'reflection-task'
    mission_candidate = next(
        item for item in data['suggestions'] if item['suggestion_id'] == 'mission-repeat-task'
    )
    assert mission_candidate['ranking']['feedback_score'] < 0.5
    assert mission_candidate['ranking']['novelty_score'] < 0.3


def test_daily_mission_graph_excludes_privacy_blocked_events_from_provider_payload():
    provider = StaticSuggestionProvider(
        suggestions=[
            {
                'suggestion_id': 'task-safe',
                'title': 'Close one safe task block',
                'domain_targets': ['task'],
                'recommendation_type': 'mission',
                'body': 'Finish one task block with AI-allowed evidence only.',
                'evidence': [
                    {
                        'source_domain': 'task',
                        'claim': 'Only AI-allowed task evidence was used.',
                        'confidence': 0.81,
                    }
                ],
                'confidence': 0.79,
                'uncertainty': 'medium',
                'requires_confirmation': True,
            }
        ]
    )
    app = create_app(
        settings=Settings(ai_gateway_enable_mock=False, llm_provider='openrouter'),
        provider=provider,
    )
    client = TestClient(app)

    response = client.post(
        '/v1/missions/daily',
        json={
            'user_id': 'user-1',
            'allowed_domains': ['task'],
            'privacy_settings': {
                'ai_enabled': True,
                'allowed_domains': ['task'],
                'allow_cross_domain_patterns': False,
            },
            'life_events': [
                _event('evt-task-1', 'task', 'ai_allowed'),
                _event('evt-habit-1', 'habit', 'local_only'),
            ],
        },
    )

    assert response.status_code == 200
    provider_payload = provider.seen_payloads[-1]
    assert [item['domain'] for item in provider_payload['events']] == ['task']
    data = response.json()
    assert data['trace']['validate_consent']['filtered_events_count'] == 1
    assert data['suggestions'][0]['ranking']['privacy_score'] >= 0.9
