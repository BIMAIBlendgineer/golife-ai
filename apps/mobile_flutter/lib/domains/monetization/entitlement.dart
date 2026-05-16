enum EntitlementPlan {
  free,
  premium,
  pro,
}

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

  final int dailyMissionRefreshes;
  final int aiAssistedCaptures;
  final int exportBundles;

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
          (json['trial_status'] ?? json['trialStatus'] ?? 'not_started')
              .toString(),
      billingProvider:
          (json['billing_provider'] ?? json['billingProvider'] ?? 'disabled')
              .toString(),
      renewalState:
          (json['renewal_state'] ?? json['renewalState'] ?? 'disabled')
              .toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
    );
  }
}
