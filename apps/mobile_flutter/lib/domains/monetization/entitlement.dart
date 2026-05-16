enum EntitlementPlan {
  free,
  premium,
  pro,
}

const String entitlementBillingProviderDisabled = 'disabled';
const String entitlementRenewalStateDisabled = 'disabled';
const String entitlementTrialStatusNotStarted = 'not_started';

extension EntitlementPlanX on EntitlementPlan {
  String get storageKey {
    switch (this) {
      case EntitlementPlan.free:
        return 'free';
      case EntitlementPlan.premium:
        return 'premium';
      case EntitlementPlan.pro:
        return 'pro';
    }
  }
}

EntitlementPlan entitlementPlanFromStorage(String? rawValue) {
  for (final value in EntitlementPlan.values) {
    if (value.storageKey == rawValue) {
      return value;
    }
  }
  return EntitlementPlan.free;
}

class EntitlementQuota {
  const EntitlementQuota({
    required this.dailyMissionRefreshes,
    required this.aiAssistedCaptures,
    required this.exportBundles,
  });

  static const EntitlementQuota disabledSafeDefault = EntitlementQuota(
    dailyMissionRefreshes: 24,
    aiAssistedCaptures: 24,
    exportBundles: 1,
  );

  final int dailyMissionRefreshes;
  final int aiAssistedCaptures;
  final int exportBundles;

  EntitlementQuota copyWith({
    int? dailyMissionRefreshes,
    int? aiAssistedCaptures,
    int? exportBundles,
  }) {
    return EntitlementQuota(
      dailyMissionRefreshes:
          dailyMissionRefreshes ?? this.dailyMissionRefreshes,
      aiAssistedCaptures: aiAssistedCaptures ?? this.aiAssistedCaptures,
      exportBundles: exportBundles ?? this.exportBundles,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'daily_mission_refreshes': dailyMissionRefreshes,
      'ai_assisted_captures': aiAssistedCaptures,
      'export_bundles': exportBundles,
    };
  }

  factory EntitlementQuota.fromJson(Map<String, dynamic> json) {
    return EntitlementQuota(
      dailyMissionRefreshes: ((json['daily_mission_refreshes'] ??
                  json['dailyMissionRefreshes']) as num?)
              ?.toInt() ??
          0,
      aiAssistedCaptures:
          ((json['ai_assisted_captures'] ?? json['aiAssistedCaptures']) as num?)
                  ?.toInt() ??
              0,
      exportBundles: ((json['export_bundles'] ?? json['exportBundles']) as num?)
              ?.toInt() ??
          0,
    );
  }
}

class Entitlement {
  const Entitlement({
    required this.plan,
    required this.quota,
    required this.trialStatus,
    required this.billingProvider,
    required this.renewalState,
    required this.trace,
  });

  final EntitlementPlan plan;
  final EntitlementQuota quota;
  final String trialStatus;
  final String billingProvider;
  final String renewalState;
  final Map<String, Object?> trace;

  factory Entitlement.disabledSafeDefault({
    Map<String, Object?> trace = const <String, Object?>{},
  }) {
    return Entitlement(
      plan: EntitlementPlan.free,
      quota: EntitlementQuota.disabledSafeDefault,
      trialStatus: entitlementTrialStatusNotStarted,
      billingProvider: entitlementBillingProviderDisabled,
      renewalState: entitlementRenewalStateDisabled,
      trace: <String, Object?>{
        'source_state': 'local_default',
        'billing_status': entitlementBillingProviderDisabled,
        'verified': false,
        ...trace,
      },
    );
  }

  bool get billingDisabled =>
      billingProvider == entitlementBillingProviderDisabled;

  Entitlement copyWith({
    EntitlementPlan? plan,
    EntitlementQuota? quota,
    String? trialStatus,
    String? billingProvider,
    String? renewalState,
    Map<String, Object?>? trace,
  }) {
    return Entitlement(
      plan: plan ?? this.plan,
      quota: quota ?? this.quota,
      trialStatus: trialStatus ?? this.trialStatus,
      billingProvider: billingProvider ?? this.billingProvider,
      renewalState: renewalState ?? this.renewalState,
      trace: trace ?? this.trace,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'plan': plan.storageKey,
      'quota': quota.toJson(),
      'trial_status': trialStatus,
      'billing_provider': billingProvider,
      'renewal_state': renewalState,
      'trace': trace,
    };
  }

  factory Entitlement.fromJson(Map<String, dynamic> json) {
    return Entitlement(
      plan: entitlementPlanFromStorage(json['plan']?.toString()),
      quota: EntitlementQuota.fromJson(
        Map<String, dynamic>.from(
          (json['quota'] as Map?)?.cast<String, Object?>() ?? const {},
        ),
      ),
      trialStatus:
          (json['trial_status'] ??
                  json['trialStatus'] ??
                  entitlementTrialStatusNotStarted)
              .toString(),
      billingProvider:
          (json['billing_provider'] ??
                  json['billingProvider'] ??
                  entitlementBillingProviderDisabled)
              .toString(),
      renewalState:
          (json['renewal_state'] ??
                  json['renewalState'] ??
                  entitlementRenewalStateDisabled)
              .toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
    );
  }
}
