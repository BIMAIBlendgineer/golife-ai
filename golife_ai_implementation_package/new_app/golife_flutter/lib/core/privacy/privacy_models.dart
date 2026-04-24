enum DomainKey {
  habits,
  tasks,
  week,
  finance,
  pantry,
  wardrobe,
  copilot,
}

enum DataPermission {
  localOnly,
  syncAllowed,
  aiAllowed,
}

extension DomainKeyX on DomainKey {
  String get storageKey {
    switch (this) {
      case DomainKey.habits:
        return 'habits';
      case DomainKey.tasks:
        return 'tasks';
      case DomainKey.week:
        return 'week';
      case DomainKey.finance:
        return 'finance';
      case DomainKey.pantry:
        return 'pantry';
      case DomainKey.wardrobe:
        return 'wardrobe';
      case DomainKey.copilot:
        return 'copilot';
    }
  }

  String get label {
    switch (this) {
      case DomainKey.habits:
        return 'Habits';
      case DomainKey.tasks:
        return 'Tasks';
      case DomainKey.week:
        return 'Week';
      case DomainKey.finance:
        return 'Money';
      case DomainKey.pantry:
        return 'Pantry';
      case DomainKey.wardrobe:
        return 'Closet';
      case DomainKey.copilot:
        return 'Copilot';
    }
  }

  String get wireName {
    switch (this) {
      case DomainKey.habits:
        return 'habit';
      case DomainKey.tasks:
        return 'task';
      case DomainKey.week:
        return 'week';
      case DomainKey.finance:
        return 'finance';
      case DomainKey.pantry:
        return 'pantry';
      case DomainKey.wardrobe:
        return 'wardrobe';
      case DomainKey.copilot:
        return 'mission';
    }
  }
}

extension DataPermissionX on DataPermission {
  String get storageKey {
    switch (this) {
      case DataPermission.localOnly:
        return 'local_only';
      case DataPermission.syncAllowed:
        return 'sync_allowed';
      case DataPermission.aiAllowed:
        return 'ai_allowed';
    }
  }

  String get label {
    switch (this) {
      case DataPermission.localOnly:
        return 'Local';
      case DataPermission.syncAllowed:
        return 'Sync';
      case DataPermission.aiAllowed:
        return 'AI';
    }
  }
}

class PrivacySettings {
  const PrivacySettings({required this.permissions});

  final Map<DomainKey, DataPermission> permissions;

  factory PrivacySettings.defaults() {
    return PrivacySettings(
      permissions: {
        for (final domain in DomainKey.values)
          domain: domain == DomainKey.copilot
              ? DataPermission.aiAllowed
              : DataPermission.localOnly,
      },
    );
  }

  DataPermission permissionFor(DomainKey domain) {
    return permissions[domain] ?? DataPermission.localOnly;
  }

  List<DomainKey> get aiAllowedDomains {
    return permissions.entries
        .where((entry) => entry.value == DataPermission.aiAllowed)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  PrivacySettings copyWithPermission(
    DomainKey domain,
    DataPermission permission,
  ) {
    final next = Map<DomainKey, DataPermission>.from(permissions);
    next[domain] = permission;
    return PrivacySettings(permissions: next);
  }

  Map<String, dynamic> toJson() {
    return {
      'permissions': {
        for (final entry in permissions.entries)
          entry.key.storageKey: entry.value.storageKey,
      },
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    final defaults = PrivacySettings.defaults();
    final rawPermissions =
        (json['permissions'] as Map<String, dynamic>?) ?? const {};
    final permissions = <DomainKey, DataPermission>{};

    for (final domain in DomainKey.values) {
      final rawValue = rawPermissions[domain.storageKey] as String?;
      permissions[domain] = _permissionFromKey(rawValue) ?? defaults.permissionFor(domain);
    }

    return PrivacySettings(permissions: permissions);
  }
}

DataPermission? _permissionFromKey(String? rawValue) {
  for (final permission in DataPermission.values) {
    if (permission.storageKey == rawValue) {
      return permission;
    }
  }
  return null;
}
