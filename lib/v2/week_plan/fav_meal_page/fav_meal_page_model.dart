import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'fav_meal_page_widget.dart' show FavMealPageWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

  // Track which cookbook mode: 'personal' or 'shared' (creator only)
  String cookbookMode = 'personal';

  // Track which recipe source tab is selected: 'my' or 'templates'
  String recipeSourceTab = 'my';

  // Meal templates (user-created combos)
  List<MealComboRecord> mealTemplates = [];

  // Track if meal templates have been loaded
  bool loadedMealTemplates = false;

  /// userMeal
  List<MealRecord> userMeal = [];

  // Creator's shared recipes (loaded when follower has active creator code)
  List<MealRecord> creatorSharedRecipes = [];
  // Creator's shared templates
  List<MealComboRecord> creatorSharedTemplates = [];
  String? activeCreatorName;
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
