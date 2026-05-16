import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/monetization/entitlement.dart';

void main() {
  test('parses entitlement contract fields', () {
    final entitlement = Entitlement.fromJson({
      'plan': 'premium',
      'quota': {
        'dailyMissionRefreshes': 6,
        'aiAssistedCaptures': 20,
        'exportBundles': 3,
      },
      'trialStatus': 'active',
      'billingProvider': 'disabled',
      'renewalState': 'trial',
      'trace': {
        'source_state': 'local_cache',
      },
    });

    expect(entitlement.plan, EntitlementPlan.premium);
    expect(entitlement.quota.dailyMissionRefreshes, 6);
    expect(entitlement.quota.exportBundles, 3);
    expect(entitlement.trialStatus, 'active');
    expect(entitlement.billingProvider, 'disabled');
    expect(entitlement.renewalState, 'trial');
  });
}
