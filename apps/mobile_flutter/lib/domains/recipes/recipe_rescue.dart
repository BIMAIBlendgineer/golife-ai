import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class RecipeRescue {
  const RecipeRescue({
    required this.id,
    required this.title,
    required this.summary,
    required this.ingredientNames,
    required this.estimatedMinutes,
    this.status = 'draft',
  });

  final String id;
  final String title;
  final String summary;
  final List<String> ingredientNames;
  final int estimatedMinutes;
  final String status;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'ingredient_names': ingredientNames,
      'estimated_minutes': estimatedMinutes,
      'status': status,
    };
  }

  factory RecipeRescue.fromJson(Map<String, dynamic> json) {
    return RecipeRescue(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      ingredientNames:
          ((json['ingredient_names'] ?? json['ingredientNames']) as List?)
                  ?.map((item) => item.toString())
                  .toList(growable: false) ??
              const <String>[],
      estimatedMinutes:
          ((json['estimated_minutes'] ?? json['estimatedMinutes']) as num?)
                  ?.toInt() ??
              15,
      status: (json['status'] ?? 'draft').toString(),
    );
  }

  LifeEvent toLifeEvent(String type, {String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'pantry',
      type: type,
      summary: title,
      privacyLevel: privacyLevel,
      payload: {
        'recipeRescueId': id,
        'ingredients': ingredientNames,
        'estimatedMinutes': estimatedMinutes,
        'status': status,
      },
    );
  }
}
