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
    assert data['suggestions'][0]['domain_targets'] == ['task', 'habit']
    assert data['suggestions'][0]['requires_confirmation'] is True
    assert 'validate_consent' in data['trace']['nodes']
    assert 'build_response' in data['trace']['nodes']


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
    body = data['suggestions'][0]['body'].lower()
    assert 'buy' not in body
    assert 'revisa' in body or 'despensa' in body or 'comida' in body
    assert data['trace']['classify_day_state']['day_state'] == 'recovery'


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
    suggestion = data['suggestions'][0]
    assert suggestion['domain_targets'] == ['wardrobe']
    assert 'compara' in suggestion['body'].lower() or 'revis' in suggestion['body'].lower()
    assert suggestion['evidence']
    assert suggestion['uncertainty']
