import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import 'dto/ai_gateway_dto.dart';

abstract class AiGatewayClient {
  Future<MissionSuggestionDto> fetchDailyMission({
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  });
}

class MockAiGatewayClient implements AiGatewayClient {
  const MockAiGatewayClient();

  @override
  Future<MissionSuggestionDto> fetchDailyMission({
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    final allowedDomains = privacySettings.aiAllowedDomains
        .map((domain) => domain.wireName)
        .toSet();

    if (allowedDomains.isEmpty) {
      return MissionSuggestionDto(
        id: 'mission-paused',
        title: 'Copilot paused',
        body: 'Enable AI on at least one domain to generate a daily mission.',
        evidence: const ['No domain is currently marked as AI-allowed.'],
        uncertainty: 'No cross-domain inference was attempted.',
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': const <String>[],
        },
      );
    }

    if (allowedDomains.contains('task') && allowedDomains.contains('habit')) {
      return MissionSuggestionDto(
        id: 'mission-task-habit',
        title: 'Close one task, protect one ritual',
        body:
            'Finish the shortest critical task first, then log one low-friction habit so the day ends with traction instead of spillover.',
        evidence: const [
          'Tasks and habits are both AI-allowed.',
          'The life graph already has events in both domains.',
        ],
        uncertainty: 'Mock mission based on consented domains, not a real remote call.',
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': allowedDomains.toList()..sort(),
          'eventCount': lifeEvents.length,
        },
      );
    }

    if (allowedDomains.contains('finance') && allowedDomains.contains('pantry')) {
      return MissionSuggestionDto(
        id: 'mission-finance-pantry',
        title: 'Use what is already paid for',
        body:
            'Before adding anything to a shopping list, build one meal around an ingredient you already have at home.',
        evidence: const [
          'Finance and pantry are both AI-allowed.',
          'The mission avoids purchase advice and focuses on using existing items.',
        ],
        uncertainty: 'Mock mission; pantry availability still needs human confirmation.',
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': allowedDomains.toList()..sort(),
          'eventCount': lifeEvents.length,
        },
      );
    }

    if (allowedDomains.contains('wardrobe')) {
      return MissionSuggestionDto(
        id: 'mission-wardrobe',
        title: 'Compare before buying',
        body:
            'Review one outfit you already own before acting on any clothing purchase intention today.',
        evidence: const [
          'Wardrobe is AI-allowed.',
          'The mission keeps the final decision with the user.',
        ],
        uncertainty: 'Mock mission; visual comparison still needs the person.',
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': allowedDomains.toList()..sort(),
          'eventCount': lifeEvents.length,
        },
      );
    }

    return MissionSuggestionDto(
      id: 'mission-generic',
      title: 'Pick one visible win',
      body:
          'Choose the smallest action that clearly reduces friction in one AI-allowed area and review it once it is done.',
      evidence: const [
        'At least one domain allows AI.',
      ],
      uncertainty: 'Mock mission with limited cross-domain context.',
      requiresConfirmation: true,
      trace: {
        'mock': true,
        'allowedDomains': allowedDomains.toList()..sort(),
        'eventCount': lifeEvents.length,
      },
    );
  }
}
