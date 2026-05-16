import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/missions/mission_set.dart';

void main() {
  test('parses mission set contract fields and source state', () {
    final missionSet = MissionSet.fromJson({
      'missionSetId': 'ms_2026-05-16',
      'date': '2026-05-16',
      'sourceState': 'live',
      'missions': [
        {
          'id': 'm-1',
          'title': 'Close one visible task',
          'body': 'Finish one short admin task.',
          'evidence': ['A pending task is visible.'],
          'uncertainty': 'Energy can still change.',
          'requires_confirmation': true,
          'domain_targets': ['task'],
          'recommendation_type': 'mission',
          'confidence': 0.8,
          'trace': {'remote': true},
        },
      ],
      'rankingTrace': {
        'rankingVersion': 'mission_ranker_v1',
        'policyVersion': 'policy_v1',
      },
      'createdAt': '2026-05-16T08:00:00Z',
    });

    expect(missionSet.missionSetId, 'ms_2026-05-16');
    expect(missionSet.sourceState, MissionSourceState.live);
    expect(missionSet.missions, hasLength(1));
    expect(missionSet.rankingTrace['policyVersion'], 'policy_v1');
  });
}
