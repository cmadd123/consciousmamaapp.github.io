import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'fav_meal_page_widget.dart' show FavMealPageWidget;
import 'package:flutter/material.dart';

class FavMealPageModel extends FlutterFlowModel<FavMealPageWidget> {
  ///  Local state fields for this page.

  String selectedTab = 'All';

  // Filter for cookbook - can be: All, Breakfast, Lunch, Dinner, Snacks, Side
  String categoryFilter = 'All';

  // Search query for filtering recipes by name
  String searchQuery = '';

  // Text controller for search field
  TextEditingController? searchController;

  // Track if we're in selection mode (came from meal planner)
  bool isSelectionMode = false;

  // Track if we've loaded all recipes (vs just favorites)
  bool loadedAllRecipes = false;

  // Track which recipe source tab is selected: 'my' or 'templates'
  String recipeSourceTab = 'my';

  // Meal templates (user-created combos)
  List<MealComboRecord> mealTemplates = [];

  // Track if meal templates have been loaded
  bool loadedMealTemplates = false;

  /// userMeal
  List<MealRecord> userMeal = [];
  void addToUserMeal(MealRecord item) => userMeal.add(item);
  void removeFromUserMeal(MealRecord item) => userMeal.remove(item);
  void removeAtIndexFromUserMeal(int index) => userMeal.removeAt(index);
  void insertAtIndexInUserMeal(int index, MealRecord item) =>
      userMeal.insert(index, item);
  void updateUserMealAtIndex(int index, Function(MealRecord) updateFn) =>
      userMeal[index] = updateFn(userMeal[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in FavMealPage widget.
  List<FavouritMealRecord>? userMeals;
  // Stores action output result for [Backend Call - Read Document] action in FavMealPage widget.
  MealRecord? mealrefuser;

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController?.dispose();
  }
}
