import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/analytics/analytics_sanitizer.dart';

void main() {
  test('removes blocked sensitive keys and keeps safe metadata', () {
    final sanitized = sanitizeAnalyticsMetadata(
      <String, Object?>{
        'summary': 'Raw mission summary',
        'body': 'Mission body',
        'rawText': 'Captured free text',
        'fileRef': 'files/receipt.jpg',
        'price': 9.99,
        'receipt': 'receipt blob',
        'purchaseToken': 'token-123',
        'domain': 'finance',
        'trace': <String, Object?>{
          'merchantName': 'Amazon',
          'result_count': 3,
        },
      },
    );

    expect(sanitized.containsKey('summary'), isFalse);
    expect(sanitized.containsKey('body'), isFalse);
    expect(sanitized.containsKey('rawText'), isFalse);
    expect(sanitized.containsKey('fileRef'), isFalse);
    expect(sanitized.containsKey('price'), isFalse);
    expect(sanitized.containsKey('receipt'), isFalse);
    expect(sanitized.containsKey('purchaseToken'), isFalse);
    expect(sanitized['domain'], 'finance');
    expect(sanitized['has_text'], true);
    expect(sanitized['text_length_bucket'], '1_50');
    final trace = Map<String, Object?>.from(sanitized['trace'] as Map);
    expect(trace.containsKey('merchantName'), isFalse);
    expect(trace['result_count'], 3);
  });
}
