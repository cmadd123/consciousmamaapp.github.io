import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'recipe_from_link_widget.dart' show RecipeFromLinkWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecipeFromLinkModel extends FlutterFlowModel<RecipeFromLinkWidget> {
  ///  Local state fields for this page.

  String? mealImage;
  String? recipeName;
  String? recipeDescription;
  int prepTime = 0;
  int cookTime = 0;
  String servings = '';
  String? sourceUrl;

  List<String> ingredientsList = [];
  void addToIngredientsList(String item) => ingredientsList.add(item);
  void removeFromIngredientsList(String item) => ingredientsList.remove(item);
  void removeAtIndexFromIngredientsList(int index) =>
      ingredientsList.removeAt(index);
  void insertAtIndexInIngredientsList(int index, String item) =>
      ingredientsList.insert(index, item);
  void updateIngredientsListAtIndex(int index, Function(String) updateFn) =>
      ingredientsList[index] = updateFn(ingredientsList[index]);

  List<String> cookingInsturction = [];
  void addToCookingInsturction(String item) => cookingInsturction.add(item);
  void removeFromCookingInsturction(String item) =>
      cookingInsturction.remove(item);
  void removeAtIndexFromCookingInsturction(int index) =>
      cookingInsturction.removeAt(index);
  void insertAtIndexInCookingInsturction(int index, String item) =>
      cookingInsturction.insert(index, item);
  void updateCookingInsturctionAtIndex(int index, Function(String) updateFn) =>
      cookingInsturction[index] = updateFn(cookingInsturction[index]);

  bool isLoading = false;
  bool hasExtracted = false;
  String? errorMessage;
  bool addToMealPlan = true; // Default to true, user can uncheck
  bool isPasteMode = false; // Toggle between URL import and paste text mode

  // User-selected meal plan date and type (when not pre-selected)
  DateTime? selectedDate;
  MealTyp? selectedMealType;

  // Multi-select categories for the recipe (Breakfast, Lunch, Dinner, Snacks)
  Set<String> selectedCategories = {};

  // Selected recipe type (Entree, Side, or Dessert) - defaults to Entree
  String selectedRecipeType = 'Entree';

  // Created meal reference
  MealRecord? createdMeal;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for urlTextField widget.
  FocusNode? urlTextFieldFocusNode;
  TextEditingController? urlTextFieldTextController;
  String? Function(BuildContext, String?)? urlTextFieldTextControllerValidator;

  // State field(s) for ingredientTextField widget.
  FocusNode? ingredientTextFieldFocusNode;
  TextEditingController? ingredientTextFieldTextController;
  String? Function(BuildContext, String?)?
      ingredientTextFieldTextControllerValidator;

  // State field(s) for instructionTextField widget.
  FocusNode? instructionTextFieldFocusNode;
  TextEditingController? instructionTextFieldTextController;
  String? Function(BuildContext, String?)?
      instructionTextFieldTextControllerValidator;

  // State field(s) for pasteTextField widget.
  FocusNode? pasteTextFieldFocusNode;
  TextEditingController? pasteTextFieldTextController;

  // State field(s) for recipeNameTextField widget.
  FocusNode? recipeNameTextFieldFocusNode;
  TextEditingController? recipeNameTextFieldTextController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    urlTextFieldFocusNode?.dispose();
    urlTextFieldTextController?.dispose();
    ingredientTextFieldFocusNode?.dispose();
    ingredientTextFieldTextController?.dispose();
    instructionTextFieldFocusNode?.dispose();
    instructionTextFieldTextController?.dispose();
    pasteTextFieldFocusNode?.dispose();
    pasteTextFieldTextController?.dispose();
    recipeNameTextFieldFocusNode?.dispose();
    recipeNameTextFieldTextController?.dispose();
  }

  /// Clear extracted recipe data
  void clearRecipe() {
    mealImage = null;
    recipeName = null;
    recipeDescription = null;
    prepTime = 0;
    cookTime = 0;
    servings = '';
    sourceUrl = null;
    ingredientsList.clear();
    cookingInsturction.clear();
    hasExtracted = false;
    errorMessage = null;
  }

  /// Strip HTML tags and clean up text
  String _cleanText(String text) {
    // Remove HTML tags like <p id="...">, </p>, <div>, etc.
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Remove common HTML artifacts like &nbsp;, &amp;, etc.
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    // Remove leftover tag fragments like "p id=..." that might appear at start of text
    // Matches patterns like: p id="abc123" or div class="foo" at the beginning or after whitespace
    cleaned = cleaned.replaceAll(RegExp(r'^[a-z]+\s+id=[^>\s]*\s*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[a-z]+\s+id=[^>\s]*\s*', caseSensitive: false), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'^[a-z]+\s+class=[^>\s]*\s*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[a-z]+\s+class=[^>\s]*\s*', caseSensitive: false), ' ');
    // Also remove standalone attribute fragments like id="..." or class="..."
    cleaned = cleaned.replaceAll(RegExp(r'\bid=[^>\s]*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\bclass=[^>\s]*', caseSensitive: false), '');
    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.trim();
  }

  /// Upgrade Pinterest image URLs to full resolution
  String? _upgradePinterestUrl(String? url) {
    if (url == null || url.isEmpty) return url;
    if (url.contains('i.pinimg.com')) {
      return url
          .replaceFirst('/236x/', '/originals/')
          .replaceFirst('/474x/', '/originals/')
          .replaceFirst('/564x/', '/originals/');
    }
    return url;
  }

  /// Populate from extracted recipe data
  void populateFromRecipe(Map<String, dynamic> recipe) {
    recipeName = _cleanText(recipe['name'] as String? ?? '');
    if (recipeName!.isEmpty) recipeName = null;
    recipeNameTextFieldTextController?.text = recipeName ?? '';
    recipeDescription = _cleanText(recipe['description'] as String? ?? '');
    if (recipeDescription!.isEmpty) recipeDescription = null;
    mealImage = _upgradePinterestUrl(recipe['imageUrl'] as String?);
    prepTime = (recipe['prepTime'] as num?)?.toInt() ?? 0;
    cookTime = (recipe['cookTime'] as num?)?.toInt() ?? 0;
    servings = recipe['servings']?.toString() ?? '';
    sourceUrl = recipe['sourceUrl'] as String?;

    // Populate ingredients
    ingredientsList.clear();
    if (recipe['ingredients'] != null) {
      for (final ingredient in (recipe['ingredients'] as List)) {
        if (ingredient != null) {
          final cleaned = _cleanText(ingredient.toString());
          if (cleaned.isNotEmpty) {
            ingredientsList.add(cleaned);
          }
        }
      }
    }

    // Populate instructions
    cookingInsturction.clear();
    if (recipe['instructions'] != null) {
      for (final instruction in (recipe['instructions'] as List)) {
        if (instruction != null) {
          final cleaned = _cleanText(instruction.toString());
          if (cleaned.isNotEmpty) {
            cookingInsturction.add(cleaned);
          }
        }
      }
    }

    hasExtracted = true;
  }
}
