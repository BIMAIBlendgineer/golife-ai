// Clean-room rewrite for GoLife after auditing Habo (GPL-3.0).
// No GPL source copied into this file.

class HabitLog {
  const HabitLog({
    required this.habitId,
    required this.loggedAtIso,
    required this.outcome,
    this.note = '',
  });

  final String habitId;
  final String loggedAtIso;
  final String outcome;
  final String note;
}
