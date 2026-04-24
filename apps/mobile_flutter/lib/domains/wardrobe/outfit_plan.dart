// Rewritten for GoLife after auditing OpenWardrobe app (MIT, provenance pending verification).
// No source file copied verbatim.

class OutfitPlan {
  const OutfitPlan({
    required this.id,
    required this.name,
    required this.itemIds,
  });

  final String id;
  final String name;
  final List<String> itemIds;
}
