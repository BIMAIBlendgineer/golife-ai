const Set<String> blockedAnalyticsMetadataKeys = <String>{
  'summary',
  'body',
  'text',
  'notes',
  'rawtext',
  'payload',
  'fileref',
  'generatedmessage',
  'issuedescription',
  'merchantname',
  'price',
  'receipt',
  'purchasetoken',
  'serialnumber',
  'purchaseproof',
  'journal',
};

Map<String, Object?> sanitizeAnalyticsMetadata(Map<String, Object?> raw) {
  return _sanitizeMap(raw, depth: 0);
}

Map<String, Object?> _sanitizeMap(
  Map<String, Object?> raw, {
  required int depth,
}) {
  if (depth > 3) {
    return const <String, Object?>{};
  }

  final sanitized = <String, Object?>{};
  bool hasText = false;
  String? longestBucket;

  for (final entry in raw.entries) {
    final normalizedKey = entry.key.trim();
    if (normalizedKey.isEmpty) {
      continue;
    }

    if (_isBlockedAnalyticsKey(normalizedKey)) {
      final bucket = _textLengthBucket(entry.value);
      if (bucket != null) {
        hasText = true;
        longestBucket = _maxTextBucket(longestBucket, bucket);
      }
      continue;
    }

    final nextValue = _sanitizeValue(
      entry.value,
      depth: depth + 1,
    );
    if (nextValue == null) {
      continue;
    }
    sanitized[normalizedKey] = nextValue;
  }

  if (hasText) {
    sanitized['has_text'] = true;
  }
  if (longestBucket != null) {
    sanitized['text_length_bucket'] = longestBucket;
  }
  return sanitized;
}

Object? _sanitizeValue(
  Object? value, {
  required int depth,
}) {
  if (value == null || value is num || value is bool) {
    return value;
  }
  if (value is String) {
    return _sanitizeString(value);
  }
  if (value is List) {
    final items = value
        .take(20)
        .map((item) => _sanitizeValue(item, depth: depth + 1))
        .where((item) => item != null)
        .cast<Object?>()
        .toList(growable: false);
    return items.isEmpty ? null : items;
  }
  if (value is Map) {
    final nested = _sanitizeMap(
      value.map<String, Object?>(
        (key, item) => MapEntry(key.toString(), item),
      ),
      depth: depth + 1,
    );
    return nested.isEmpty ? null : nested;
  }
  return _sanitizeString(value.toString());
}

String? _sanitizeString(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final looksFreeText =
      trimmed.contains('\n') || trimmed.contains('\r') || trimmed.length > 80;
  if (looksFreeText) {
    return null;
  }
  return trimmed;
}

String? _textLengthBucket(Object? value) {
  if (value is String) {
    return _bucketForLength(value.trim().length);
  }
  if (value is List) {
    final joined = value.map((item) => item.toString()).join(' ');
    return _bucketForLength(joined.trim().length);
  }
  if (value is Map) {
    final joined = value.values.map((item) => item.toString()).join(' ');
    return _bucketForLength(joined.trim().length);
  }
  if (value == null) {
    return null;
  }
  return _bucketForLength(value.toString().trim().length);
}

String? _bucketForLength(int length) {
  if (length <= 0) {
    return null;
  }
  if (length <= 50) {
    return '1_50';
  }
  if (length <= 200) {
    return '51_200';
  }
  return '200_plus';
}

String _maxTextBucket(String? current, String next) {
  const order = <String, int>{
    '1_50': 1,
    '51_200': 2,
    '200_plus': 3,
  };
  if (current == null) {
    return next;
  }
  return (order[next] ?? 0) >= (order[current] ?? 0) ? next : current;
}

bool _isBlockedAnalyticsKey(String rawKey) {
  final normalized = rawKey.trim().toLowerCase().replaceAll('_', '');
  if (blockedAnalyticsMetadataKeys.contains(normalized)) {
    return true;
  }
  return blockedAnalyticsMetadataKeys.any(
    (key) => normalized.endsWith(key) || normalized.contains(key),
  );
}
