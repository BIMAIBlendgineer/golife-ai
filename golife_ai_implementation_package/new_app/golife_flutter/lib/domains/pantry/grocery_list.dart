// Rewritten for GoLife after auditing Wanna (MIT).
// No source file copied verbatim.

class GroceryList {
  const GroceryList({
    required this.id,
    required this.name,
    required this.isShared,
    this.sharedMemberCount = 0,
    this.items = const <PantryListItem>[],
  });

  final String id;
  final String name;
  final bool isShared;
  final int sharedMemberCount;
  final List<PantryListItem> items;
}

class PantryListItem {
  const PantryListItem({
    required this.id,
    required this.title,
    required this.isChecked,
  });

  final String id;
  final String title;
  final bool isChecked;
}
