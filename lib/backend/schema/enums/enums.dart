import 'package:collection/collection.dart';

enum Role {
  assistant,
  user,
}

enum ActGoalMilestones {
  Communication,
  Cognitive,
  Selfcare,
  Physical,
  SocialEmotional,
}

enum CurrentPage {
  Home,
  Calendar,
  Add,
  Milestones,
  Settings,
  Activities,
  Meals,
  Tasks,
  More,
}

enum MealTyp {
  Breakfast,
  Lunch,
  Dinner,
  Snacks,
}

enum DrinkType {
  Water,
  Milk,
  Juice,
  Lemonade,
  Smoothie,
  Tea,
  Coffee,
  Soda,
  Other,
}

enum RecipeType {
  Entree,
  Side,
  Dessert,
}

/// Types of shareable content
enum SharedContentType {
  mealPlan,
  learningPath,
  activity,
  activityPlan,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (Role):
      return Role.values.deserialize(value) as T?;
    case (ActGoalMilestones):
      return ActGoalMilestones.values.deserialize(value) as T?;
    case (CurrentPage):
      return CurrentPage.values.deserialize(value) as T?;
    case (MealTyp):
      return MealTyp.values.deserialize(value) as T?;
    case (DrinkType):
      return DrinkType.values.deserialize(value) as T?;
    case (RecipeType):
      return RecipeType.values.deserialize(value) as T?;
    case (SharedContentType):
      return SharedContentType.values.deserialize(value) as T?;
    default:
      return null;
  }
}
