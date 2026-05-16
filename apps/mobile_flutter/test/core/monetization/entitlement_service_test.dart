import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/monetization/entitlement_service.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/analytics/analytics_event.dart';
import 'package:golife_flutter/domains/monetization/entitlement.dart';

void main() {
  test('loads a disabled-safe free entitlement by default', () async {
    final store = MemoryLocalStore();
    final service = EntitlementService(
      localStore: store,
      clock: () => DateTime.utc(2026, 5, 16, 12),
    );

    final entitlement = await service.loadEntitlement();

    expect(entitlement.plan, EntitlementPlan.free);
    expect(entitlement.billingProvider, entitlementBillingProviderDisabled);
    expect(entitlement.renewalState, entitlementRenewalStateDisabled);
  });

  test('export gate stays available even with zero quota', () {
    final service = EntitlementService(
      localStore: MemoryLocalStore(),
      clock: () => DateTime.utc(2026, 5, 16, 12),
    );
    final entitlement = Entitlement(
      plan: EntitlementPlan.free,
      quota: const EntitlementQuota(
        dailyMissionRefreshes: 0,
        aiAssistedCaptures: 0,
        exportBundles: 0,
      ),
      trialStatus: entitlementTrialStatusNotStarted,
      billingProvider: entitlementBillingProviderDisabled,
      renewalState: entitlementRenewalStateDisabled,
      trace: const <String, Object?>{'source_state': 'local_cache'},
    );

    final gate = service.gateForFeature(
      EntitlementFeature.exportBundles,
      entitlement: entitlement,
      analyticsEvents: const <AnalyticsEvent>[],
    );

    expect(gate.allowed, isTrue);
    expect(gate.enforced, isFalse);
    expect(gate.reasonCode, 'export_delete_always_available');
  });

  test('ai-assisted capture gate blocks when the daily quota is exhausted', () {
    final service = EntitlementService(
      localStore: MemoryLocalStore(),
      clock: () => DateTime.utc(2026, 5, 16, 12),
    );
    final entitlement = Entitlement(
      plan: EntitlementPlan.free,
      quota: const EntitlementQuota(
        dailyMissionRefreshes: 4,
        aiAssistedCaptures: 1,
        exportBundles: 1,
      ),
      trialStatus: entitlementTrialStatusNotStarted,
      billingProvider: entitlementBillingProviderDisabled,
      renewalState: entitlementRenewalStateDisabled,
      trace: const <String, Object?>{'source_state': 'local_cache'},
    );

    final gate = service.gateForFeature(
      EntitlementFeature.aiAssistedCaptures,
      entitlement: entitlement,
      analyticsEvents: const <AnalyticsEvent>[
        AnalyticsEvent(
          eventId: 'analytics-1',
          eventName: 'capture_parsed',
          timestampIso: '2026-05-16T09:00:00Z',
          locale: 'en',
          source: 'capture_gateway',
          metadata: <String, Object?>{
            'remote': true,
          },
        ),
      ],
    );

    expect(gate.allowed, isFalse);
    expect(gate.used, 1);
    expect(gate.remaining, 0);
    expect(gate.reasonCode, 'quota_exhausted');
  });
}
