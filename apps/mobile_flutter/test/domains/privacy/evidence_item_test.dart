import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/privacy/evidence_item.dart';

void main() {
  test('parses evidence item contract fields', () {
    final item = EvidenceItem.fromJson({
      'evidence_id': 'evidence-1',
      'source_type': 'capture',
      'local_payload_ref': 'vault://capture/1',
      'privacy_class': 'ai_allowed',
      'allowed_for_ai': true,
      'created_at': '2026-05-16T08:00:00Z',
      'hash': 'abc123',
    });

    expect(item.evidenceId, 'evidence-1');
    expect(item.sourceType, 'capture');
    expect(item.privacyClass, EvidencePrivacyClass.aiAllowed);
    expect(item.allowedForAi, isTrue);
    expect(item.hash, 'abc123');
  });
}
