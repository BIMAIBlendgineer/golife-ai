import '../../domains/analytics/analytics_event.dart';
import '../../domains/monetization/entitlement.dart';
import '../storage/local_store.dart';

enum EntitlementFeature {
  dailyMissionRefreshes,
  aiAssistedCaptures,
  exportBundles,
}

extension EntitlementFeatureX on EntitlementFeature {
  String get storageKey {
    switch (this) {
      case EntitlementFeature.dailyMissionRefreshes:
        return 'daily_mission_refreshes';
      case EntitlementFeature.aiAssistedCaptures:
        return 'ai_assisted_captures';
      case EntitlementFeature.exportBundles:
        return 'export_bundles';
    }
  }
}

class EntitlementGateResult {
  const EntitlementGateResult({
    required this.feature,
    required this.allowed,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.reasonCode,
    required this.enforced,
  });

  final EntitlementFeature feature;
  final bool allowed;
  final int limit;
  final int used;
  final int remaining;
  final String reasonCode;
  final bool enforced;

  Map<String, Object?> toAnalyticsMetadata() {
    return <String, Object?>{
      'feature': feature.storageKey,
      'allowed': allowed,
      'limit': limit,
      'used': used,
      'remaining': remaining,
      'reason_code': reasonCode,
      'enforced': enforced,
    };
  }
}

class EntitlementService {
  EntitlementService({
    required LocalStore localStore,
    DateTime Function()? clock,
  })  : _localStore = localStore,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final LocalStore _localStore;
  final DateTime Function() _clock;

  Future<Entitlement> loadEntitlement() async {
    final stored = await _localStore.loadEntitlement();
    return _normalize(stored);
  }

  Future<void> saveEntitlement(Entitlement entitlement) {
    return _localStore.saveEntitlement(_normalize(entitlement));
  }

  EntitlementGateResult gateForFeature(
    EntitlementFeature feature, {
    required Entitlement entitlement,
    required Iterable<AnalyticsEvent> analyticsEvents,
  }) {
    final limit = _limitForFeature(feature, entitlement);
    if (feature == EntitlementFeature.exportBundles) {
      final used = _usedCountForFeature(feature, analyticsEvents);
      return EntitlementGateResult(
        feature: feature,
        allowed: true,
        limit: limit,
        used: used,
        remaining: limit,
        reasonCode: 'export_delete_always_available',
        enforced: false,
      );
    }

    final used = _usedCountForFeature(feature, analyticsEvents);
    final remaining = (limit - used).clamp(0, limit);
    return EntitlementGateResult(
      feature: feature,
      allowed: used < limit,
      limit: limit,
      used: used,
      remaining: remaining,
      reasonCode: used < limit ? 'within_quota' : 'quota_exhausted',
      enforced: true,
    );
  }

  Entitlement _normalize(Entitlement entitlement) {
    final mergedTrace =
        Map<String, Object?>.from(entitlement.trace)
          ..putIfAbsent('source_state', () => 'local_cache')
          ..['billing_status'] = entitlementBillingProviderDisabled
          ..['verified'] = false;
    return entitlement.copyWith(
      billingProvider: entitlementBillingProviderDisabled,
      renewalState: entitlementRenewalStateDisabled,
      trace: mergedTrace,
    );
  }

  int _limitForFeature(EntitlementFeature feature, Entitlement entitlement) {
    switch (feature) {
      case EntitlementFeature.dailyMissionRefreshes:
        return entitlement.quota.dailyMissionRefreshes;
      case EntitlementFeature.aiAssistedCaptures:
        return entitlement.quota.aiAssistedCaptures;
      case EntitlementFeature.exportBundles:
        return entitlement.quota.exportBundles;
    }
  }

  int _usedCountForFeature(
    EntitlementFeature feature,
    Iterable<AnalyticsEvent> analyticsEvents,
  ) {
    final todayStart = DateTime.utc(
      _clock().toUtc().year,
      _clock().toUtc().month,
      _clock().toUtc().day,
    );
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    return analyticsEvents.where((event) {
      final timestamp = DateTime.tryParse(event.timestampIso)?.toUtc();
      if (timestamp == null ||
          timestamp.isBefore(todayStart) ||
          !timestamp.isBefore(tomorrowStart)) {
        return false;
      }
      switch (feature) {
        case EntitlementFeature.dailyMissionRefreshes:
          return event.eventName == 'mission_set_generated';
        case EntitlementFeature.aiAssistedCaptures:
          return event.eventName == 'capture_parsed' &&
              event.metadata['remote'] == true;
        case EntitlementFeature.exportBundles:
          return event.eventName == 'export_requested' &&
              event.metadata['export_format'] == 'bundle';
      }
    }).length;
  }
}
