class MaintenanceReminderStatus {
  static const scheduled = 'scheduled';
  static const done = 'done';
  static const skipped = 'skipped';

  static const values = <String>[scheduled, done, skipped];

  static String normalize(String? rawValue) {
    if (values.contains(rawValue)) {
      return rawValue!;
    }
    return scheduled;
  }
}

class MaintenanceReminder {
  const MaintenanceReminder({
    required this.id,
    required this.userId,
    required this.ownedItemId,
    required this.title,
    required this.dueDate,
    this.recurrence = 'none',
    this.status = MaintenanceReminderStatus.scheduled,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String ownedItemId;
  final String title;
  final String dueDate;
  final String recurrence;
  final String status;
  final String createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'owned_item_id': ownedItemId,
      'title': title,
      'due_date': dueDate,
      'recurrence': recurrence,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory MaintenanceReminder.fromJson(Map<String, dynamic> json) {
    return MaintenanceReminder(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 'local-user').toString(),
      ownedItemId:
          (json['owned_item_id'] ?? json['ownedItemId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      dueDate: (json['due_date'] ?? json['dueDate'] ?? '').toString(),
      recurrence: (json['recurrence'] ?? 'none').toString(),
      status: MaintenanceReminderStatus.normalize(
        (json['status'] ?? '').toString(),
      ),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
