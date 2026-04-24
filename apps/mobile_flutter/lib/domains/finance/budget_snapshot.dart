// Rewritten for GoLife while Flow source is unavailable locally.
// This is a placeholder domain model, not a migration from a verified local repo.

class BudgetSnapshot {
  const BudgetSnapshot({
    required this.periodLabel,
    required this.spent,
    required this.cap,
  });

  final String periodLabel;
  final double spent;
  final double cap;
}
