import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/custom_code/actions/sharing_service.dart';
import '/index.dart';

class ImportSharedContentWidget extends StatefulWidget {
  const ImportSharedContentWidget({
    super.key,
    required this.shareCode,
  });

  final String shareCode;

  static String routeName = 'ImportSharedContent';
  static String routePath = '/shared/:shareCode';

  @override
  State<ImportSharedContentWidget> createState() => _ImportSharedContentWidgetState();
}

/// Represents a selectable recipe item from shared content
class _SelectableRecipe {
  final String id;
  final String name;
  final String? imageUrl;
  final String mealType;
  final int dayOffset;
  final bool isCombo;
  final Map<String, dynamic> recipeData;
  final Map<String, dynamic>? comboData;
  bool isSelected;

  _SelectableRecipe({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.mealType,
    required this.dayOffset,
    required this.isCombo,
    required this.recipeData,
    this.comboData,
    this.isSelected = true,
  });

  // Get combo sides for display
  List<String> get comboSides {
    if (!isCombo || comboData == null) return [];
    final sides = comboData!['sides'] as List<dynamic>? ?? [];
    return sides
        .map((s) => (s as Map<String, dynamic>)['recipe_name'] as String? ?? 'Side')
        .toList();
  }

  // Get drink info for combos
  String? get comboDrink {
    if (!isCombo || comboData == null) return null;
    final drinkType = comboData!['drink_type'] as String?;
    final drinkCustom = comboData!['drink_custom'] as String?;
    if (drinkCustom != null && drinkCustom.isNotEmpty) return drinkCustom;
    if (drinkType != null && drinkType.isNotEmpty) return drinkType;
    return null;
  }

  // Get ingredients list
  List<String> get ingredients {
    final ing = recipeData['ingredients'];
    if (ing is List) {
      return ing.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Get cooking instructions
  List<String> get cookingInstructions {
    final inst = recipeData['cooking_instructions'];
    if (inst is List) {
      return inst.map((e) => e.toString()).toList();
    }
    return [];
  }
}

class _ImportSharedContentWidgetState extends State<ImportSharedContentWidget> {
  SharedContentRecord? _sharedContent;
  bool _isLoading = true;
  bool _isImporting = false;
  String? _error;

  // Parsed recipes from shared content
  List<_SelectableRecipe> _recipes = [];

  // Import mode: 'cookbook' or 'mealplan'
  String _importMode = 'cookbook';

  // For meal plan mode - selected day and meal type
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Dinner';

  // Meal type order for grouping
  static const _mealTypeOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  // Track expanded days for collapsible UI
  Set<int> _expandedDays = {};

  @override
  void initState() {
    super.initState();
    _loadSharedContent();
  }

  Future<void> _loadSharedContent() async {
    print('ImportSharedContent: Loading content for shareCode: ${widget.shareCode}');
    try {
      final content = await SharedContentRecord.getByShareCode(widget.shareCode);
      print('ImportSharedContent: Content loaded: ${content != null ? 'found' : 'not found'}');
      if (content != null) {
        print('ImportSharedContent: Content type: ${content.contentType}');
        print('ImportSharedContent: Content data keys: ${content.contentData.keys}');
        print('ImportSharedContent: Full content data: ${content.contentData}');
        // Debug specific fields for activity type
        if (content.contentType == SharedContentType.activity) {
          print('ImportSharedContent: title = ${content.contentData['title']}');
          print('ImportSharedContent: description = ${content.contentData['description']}');
          print('ImportSharedContent: things_needed = ${content.contentData['things_needed']}');
          print('ImportSharedContent: time_duration = ${content.contentData['time_duration']}');
          print('ImportSharedContent: parent_proximity = ${content.contentData['parent_proximity']}');
          print('ImportSharedContent: setup_time = ${content.contentData['setup_time']}');
          print('ImportSharedContent: cleanup_difficulty = ${content.contentData['cleanup_difficulty']}');
        }
        await SharingService.incrementViewCount(content);
        // Parse recipes for meal-related content types
        if (content.contentType == SharedContentType.mealPlan ||
            content.contentType == SharedContentType.dayTemplate ||
            content.contentType == null) {
          _parseRecipes(content);
        }
        // Also try parsing if no content type but has recipe data
        if (_recipes.isEmpty && content.contentData.containsKey('recipes')) {
          _parseRecipes(content);
        }
      }
      setState(() {
        _sharedContent = content;
        _isLoading = false;
        if (content == null) {
          _error = 'This share link is no longer valid or has expired.';
        }
      });
    } catch (e) {
      print('ImportSharedContent: Error loading content: $e');
      setState(() {
        _isLoading = false;
        _error = 'Failed to load shared content. Please try again.';
      });
    }
  }

  /// Parse the shared content to extract individual recipes
  void _parseRecipes(SharedContentRecord content) {
    final recipes = <_SelectableRecipe>[];
    final contentData = content.contentData;
    final meals = contentData['meals'] as List<dynamic>? ?? [];

    int index = 0;
    final dayOffsets = <int>{};
    for (final mealData in meals) {
      final recipe = mealData['recipe'] as Map<String, dynamic>?;
      final combo = mealData['combo'] as Map<String, dynamic>?;
      final dateOffset = mealData['date_offset'] as int? ?? 0;
      final mealTypeStr = mealData['meal_type'] as String? ?? 'Dinner';

      dayOffsets.add(dateOffset);

      if (combo != null) {
        // It's a meal template - get name from combo name or entree name
        final comboName = combo['name'] as String?;
        final entree = combo['entree'] as Map<String, dynamic>?;
        String name = comboName ?? entree?['recipe_name'] ?? 'Meal Template';
        String? imageUrl = entree?['image_url'] as String?;

        recipes.add(_SelectableRecipe(
          id: 'combo_$index',
          name: name,
          imageUrl: imageUrl,
          mealType: mealTypeStr,
          dayOffset: dateOffset,
          isCombo: true,
          recipeData: entree ?? {},
          comboData: combo,
        ));
      } else if (recipe != null) {
        // Single recipe
        recipes.add(_SelectableRecipe(
          id: 'recipe_$index',
          name: recipe['recipe_name'] ?? 'Unknown Recipe',
          imageUrl: recipe['image_url'] as String?,
          mealType: mealTypeStr,
          dayOffset: dateOffset,
          isCombo: false,
          recipeData: recipe,
        ));
      }
      index++;
    }

    _recipes = recipes;
    // Expand all days by default
    _expandedDays = dayOffsets;
  }

  int get _selectedCount => _recipes.where((r) => r.isSelected).length;

  // Group recipes by day offset
  Map<int, List<_SelectableRecipe>> get _groupedByDay {
    final grouped = <int, List<_SelectableRecipe>>{};
    for (final recipe in _recipes) {
      grouped.putIfAbsent(recipe.dayOffset, () => []).add(recipe);
    }
    // Sort by day offset
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedGrouped = <int, List<_SelectableRecipe>>{};
    for (final key in sortedKeys) {
      // Sort recipes within each day by meal type order
      final dayRecipes = grouped[key]!;
      dayRecipes.sort((a, b) {
        final aIndex = _mealTypeOrder.indexOf(a.mealType);
        final bIndex = _mealTypeOrder.indexOf(b.mealType);
        return (aIndex == -1 ? 999 : aIndex).compareTo(bIndex == -1 ? 999 : bIndex);
      });
      sortedGrouped[key] = dayRecipes;
    }
    return sortedGrouped;
  }

  // Get day name from offset
  String _getDayName(int dayOffset) {
    final date = DateTime.now().add(Duration(days: dayOffset));
    return dateTimeFormat("EEEE", date, locale: 'en');
  }

  // Check if day is expanded
  bool _isDayExpanded(int dayOffset) => _expandedDays.contains(dayOffset);

  // Toggle day expansion
  void _toggleDay(int dayOffset) {
    setState(() {
      if (_expandedDays.contains(dayOffset)) {
        _expandedDays.remove(dayOffset);
      } else {
        _expandedDays.add(dayOffset);
      }
    });
  }

  // Count planned meals for a day
  int _countMealsForDay(int dayOffset) {
    return _recipes.where((r) => r.dayOffset == dayOffset).length;
  }

  // Check if this is a single template import (vs meal plan)
  bool _isSingleTemplate() {
    if (_sharedContent == null) return false;
    // Single template has exactly 1 recipe and it's a combo
    return _recipes.length == 1 && _recipes.first.isCombo;
  }

  // Get appropriate title for import screen
  String _getImportTitle() {
    if (_isSingleTemplate()) {
      return 'Shared Meal Template';
    }
    return 'Shared Recipes';
  }

  // Build simplified view for single template
  Widget _buildSingleTemplateView(_SelectableRecipe template) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template name with badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Template',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple[700],
                          fontFamily: 'Andika New Basic',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Template contents (entrée, sides, drink)
          if (template.comboData != null) ...[
            // Entrée
            if (template.recipeData['recipe_name'] != null) ...[
              _buildTemplateItem(
                label: 'Entrée',
                value: template.recipeData['recipe_name'] as String,
                icon: Icons.restaurant,
              ),
              const SizedBox(height: 8),
            ],
            // Sides
            if (template.comboSides.isNotEmpty) ...[
              _buildTemplateItem(
                label: 'Sides',
                value: template.comboSides.join(', '),
                icon: Icons.restaurant_outlined,
              ),
              const SizedBox(height: 8),
            ],
            // Drink
            if (template.comboDrink != null) ...[
              _buildTemplateItem(
                label: 'Drink',
                value: template.comboDrink!,
                icon: Icons.local_drink,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTemplateItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF666666)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF999999),
                  fontFamily: 'Andika New Basic',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Andika New Basic',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Check if a specific meal type is present for a day
  bool _hasMealType(int dayOffset, String mealType) {
    return _recipes.any((r) => r.dayOffset == dayOffset && r.mealType == mealType);
  }

  // Check if a meal is a combo for a specific day/meal type
  bool _isComboMeal(int dayOffset, String mealType) {
    return _recipes.any((r) => r.dayOffset == dayOffset && r.mealType == mealType && r.isCombo);
  }

  // Build a collapsible day group (matching meal planner style)
  Widget _buildDayGroup(int dayOffset, List<_SelectableRecipe> recipes) {
    final isExpanded = _isDayExpanded(dayOffset);
    final mealCount = recipes.length;
    final dayName = _getDayName(dayOffset);

    return Column(
      children: [
        // Day header (always visible) - matching meal planner style
        InkWell(
          onTap: () => _toggleDay(dayOffset),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: dayOffset == 0
                  ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                  : Colors.transparent,
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                // Expand/collapse chevron
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
                // Day name
                Expanded(
                  child: Text(
                    dayOffset == 0 ? 'Today ($dayName)' : dayName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: dayOffset == 0 ? 15.0 : 14.0,
                          fontWeight: dayOffset == 0 ? FontWeight.w600 : FontWeight.normal,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                // Meal indicators (dots) when collapsed
                if (!isExpanded) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Breakfast, Lunch, Dinner dots
                      ...['Breakfast', 'Lunch', 'Dinner'].map((mealType) {
                        final hasMeal = _hasMealType(dayOffset, mealType);
                        final isCombo = _isComboMeal(dayOffset, mealType);
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: hasMeal
                                  ? (isCombo ? const Color(0xFFFF9800) : FlutterFlowTheme.of(context).primary)
                                  : const Color(0xFFE0E0E0),
                              shape: BoxShape.circle,
                              border: isCombo && hasMeal
                                  ? Border.all(color: Colors.white, width: 1.5)
                                  : null,
                            ),
                          ),
                        );
                      }),
                      // Gap before snack
                      const SizedBox(width: 8.0),
                      // Snack dot
                      Builder(builder: (context) {
                        final hasSnack = _hasMealType(dayOffset, 'Snacks');
                        final isSnackCombo = _isComboMeal(dayOffset, 'Snacks');
                        return Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            color: hasSnack
                                ? (isSnackCombo
                                    ? const Color(0xFFFF9800).withOpacity(0.7)
                                    : FlutterFlowTheme.of(context).primary.withOpacity(0.7))
                                : const Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '$mealCount meal${mealCount == 1 ? '' : 's'}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF888888),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Expanded content - show meals grouped by meal type
        if (isExpanded)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
            ),
            child: Column(
              children: [
                // Group by meal type within each day
                ..._mealTypeOrder.map((mealType) {
                  // Show each recipe under its FIRST matching meal type only (avoid duplicates)
                  final alreadyShown = <String>{};
                  for (final prevType in _mealTypeOrder) {
                    if (prevType == mealType) break;
                    for (final r in recipes) {
                      final types = r.mealType.split(',').map((t) => t.trim()).toList();
                      if (types.contains(prevType)) alreadyShown.add(r.id);
                    }
                  }
                  final mealsOfType = recipes.where((r) {
                    if (alreadyShown.contains(r.id)) return false;
                    final types = r.mealType.split(',').map((t) => t.trim()).toList();
                    return types.contains(mealType) || r.mealType == mealType;
                  }).toList();
                  if (mealsOfType.isEmpty) return const SizedBox.shrink();
                  return _buildMealSlot(mealType, mealsOfType);
                }),
              ],
            ),
          ),
      ],
    );
  }

  // Build a meal slot within an expanded day (matching meal planner style)
  Widget _buildMealSlot(String mealType, List<_SelectableRecipe> recipes) {
    final icon = _getMealTypeIcon(mealType);
    final color = _getMealTypeColor(mealType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  mealType,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
          // Recipes in this slot
          ...recipes.map((recipe) => _buildRecipeCard(recipe)),
        ],
      ),
    );
  }

  // Build a recipe card within a meal slot (matching meal planner style)
  Widget _buildRecipeCard(_SelectableRecipe recipe) {
    return InkWell(
      onTap: () {
        setState(() => recipe.isSelected = !recipe.isSelected);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: recipe.isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Selection checkbox
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: recipe.isSelected
                        ? FlutterFlowTheme.of(context).primary
                        : Colors.transparent,
                    border: Border.all(
                      color: recipe.isSelected
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: recipe.isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? Image.network(
                          recipe.imageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(size: 48),
                        )
                      : _buildPlaceholderImage(size: 48),
                ),
                const SizedBox(width: 12),

                // Recipe name and combo badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.isCombo)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Template',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple[700],
                              fontFamily: 'Andika New Basic',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // View details button
                InkWell(
                  onTap: () => _showRecipeDetails(recipe),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.visibility,
                      color: FlutterFlowTheme.of(context).secondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            // Template contents (sides and drink) - without plus icon
            if (recipe.isCombo && (recipe.comboSides.isNotEmpty || recipe.comboDrink != null))
              Container(
                margin: const EdgeInsets.only(top: 8, left: 32),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sides
                    if (recipe.comboSides.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: recipe.comboSides.map((side) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              side,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontFamily: 'Andika New Basic',
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    // Drink
                    if (recipe.comboDrink != null) ...[
                      if (recipe.comboSides.isNotEmpty) const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_drink, size: 14, color: Colors.blue[400]),
                          const SizedBox(width: 6),
                          Text(
                            recipe.comboDrink!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontFamily: 'Andika New Basic',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading shared content...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Andika New Basic',
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () => context.go('/'),
              text: 'Go Home',
              options: FFButtonOptions(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Andika New Basic',
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the activity import UI
  Widget _buildActivityContent(SharedContentRecord content) {
    final contentData = content.contentData;
    final emoji = contentData['icon_emoji'] as String? ?? '🎨';
    final title = contentData['title'] as String? ?? 'Activity';
    final description = contentData['description'] as String? ?? '';
    final timeDuration = contentData['time_duration'] as String? ?? '';
    final parentProximity = contentData['parent_proximity'] as String? ?? '';
    final setupTime = contentData['setup_time'] as String? ?? '';
    final cleanupDifficulty = contentData['cleanup_difficulty'] as String? ?? '';
    final thingsNeeded = contentData['things_needed'] as String? ?? '';
    final safetyNote = contentData['safety_note'] as String? ?? '';
    final personalNote = contentData['personal_note'] as String?;

    return Column(
      children: [
        // Fixed header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF5F5F5),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Shared Activity',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared by info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Shared by ${content.sharedByName}',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        // Personal note if present
                        if (personalNote != null && personalNote.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 16,
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    personalNote,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity preview card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with emoji
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  if (timeDuration.isNotEmpty)
                                    Text(
                                      timeDuration,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: 'Andika New Basic',
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Description
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            description,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],

                        // Tags
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (timeDuration.isNotEmpty)
                              _buildActivityTag(
                                text: timeDuration,
                                color: const Color(0xFF1976D2),
                                bgColor: const Color(0xFFE3F2FD),
                              ),
                            if (parentProximity.isNotEmpty)
                              _buildActivityTag(
                                text: parentProximity == 'free'
                                    ? 'Parent: Free'
                                    : parentProximity == 'nearby'
                                        ? 'Parent: Nearby'
                                        : 'Parent: Together',
                                color: const Color(0xFFE65100),
                                bgColor: const Color(0xFFFFF3E0),
                              ),
                            if (setupTime.isNotEmpty)
                              _buildActivityTag(
                                text: 'Setup: $setupTime',
                                color: const Color(0xFF7B1FA2),
                                bgColor: const Color(0xFFF3E5F5),
                              ),
                            if (cleanupDifficulty.isNotEmpty)
                              _buildActivityTag(
                                text: 'Cleanup: $cleanupDifficulty',
                                color: const Color(0xFF2E7D32),
                                bgColor: const Color(0xFFE8F5E9),
                              ),
                          ],
                        ),

                        // Things needed
                        if (thingsNeeded.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.list_alt,
                                    size: 18,
                                    color: Color(0xFF95A5A6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    thingsNeeded,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Safety note
                        if (safetyNote.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    size: 18,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    safetyNote,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Import button
                  FFButtonWidget(
                    onPressed: _isImporting ? null : () => _handleActivityImport(content),
                    text: _isImporting ? 'Saving...' : 'Save to My Activities',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(28),
                      disabledColor: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel button
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(
                        'Not now',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTag({
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Andika New Basic',
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleActivityImport(SharedContentRecord content) async {
    setState(() => _isImporting = true);

    try {
      final activityRef = await SharingService.importActivity(
        sharedContent: content,
      );

      if (!mounted) return;

      if (activityRef != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity saved to your collection!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to My Activities page
        context.goNamed('MyActivities');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save activity. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isImporting = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isImporting = false);
    }
  }

  /// Build the activity plan import UI
  Widget _buildActivityPlanContent(SharedContentRecord content) {
    final contentData = content.contentData;
    final planTitle = contentData['plan_title'] as String? ?? 'Activity Plan';
    final activities = contentData['activities'] as List<dynamic>? ?? [];
    final activityCount = activities.length;
    final personalNote = contentData['personal_note'] as String?;

    // Group activities by day offset (0 = today, 1 = tomorrow, etc.)
    final today = DateTime.now();
    String getDayLabel(int offset) {
      if (offset == 0) return 'Today';
      if (offset == 1) return 'Tomorrow';
      final date = today.add(Duration(days: offset));
      return DateFormat('EEEE').format(date);  // Day name
    }
    final activitiesByDay = <int, List<Map<String, dynamic>>>{};
    for (final activity in activities) {
      final dayOffset = (activity as Map<String, dynamic>)['day_offset'] as int? ?? 0;
      if (dayOffset >= 0 && dayOffset < 7) {
        activitiesByDay.putIfAbsent(dayOffset, () => []).add(activity);
      }
    }

    return Column(
      children: [
        // Fixed header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF5F5F5),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Shared Activity Plan',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared by info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Shared by ${content.sharedByName}',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        // Personal note if present
                        if (personalNote != null && personalNote.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 16,
                                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    personalNote,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Plan overview card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.calendar_month,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    planTitle,
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Text(
                                    '$activityCount activities for the week',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activities by day (sorted by day offset: 0=Today, 1=Tomorrow, etc.)
                  ...(activitiesByDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key))).map((entry) {
                    final dayIndex = entry.key;
                    final dayActivities = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getDayLabel(dayIndex),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ...dayActivities.map((activity) {
                            final name = activity['name'] as String? ?? 'Activity';
                            final assignedToMom = activity['assigned_to_mom'] as bool? ?? false;
                            final assignedToDad = activity['assigned_to_dad'] as bool? ?? false;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Andika New Basic',
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                  if (assignedToMom)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(left: 4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEC407A),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text('M', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  if (assignedToDad)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(left: 4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1976D2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text('D', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Import button
                  FFButtonWidget(
                    onPressed: _isImporting ? null : () => _handleActivityPlanImport(content),
                    text: _isImporting ? 'Importing...' : 'Import to This Week',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(28),
                      disabledColor: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel button
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(
                        'Not now',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build the day template import UI
  Widget _buildDayTemplateContent(SharedContentRecord content) {
    final contentData = content.contentData;
    final dayTemplateName = contentData['day_template_name'] as String? ?? 'Day Template';
    final templates = contentData['templates'] as List<dynamic>? ?? [];
    final personalNote = contentData['personal_note'] as String?;

    // Sort templates by meal type order
    const mealOrder = {'Breakfast': 0, 'Lunch': 1, 'Dinner': 2, 'Snacks': 3};
    final sortedTemplates = List<Map<String, dynamic>>.from(
      templates.map((t) => t as Map<String, dynamic>),
    )..sort((a, b) {
      final aOrder = mealOrder[a['meal_type']] ?? 4;
      final bOrder = mealOrder[b['meal_type']] ?? 4;
      return aOrder.compareTo(bOrder);
    });

    return Column(
      children: [
        // Fixed header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF5F5F5),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Shared Day Template',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared by info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.calendar_view_day,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayTemplateName,
                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Text(
                                'Shared by ${content.sharedByName}',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Text(
                                '${sortedTemplates.length} meal${sortedTemplates.length == 1 ? '' : 's'}',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personal note
                  if (personalNote != null && personalNote.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 18, color: Colors.amber[700]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              personalNote,
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                fontSize: 14,
                                color: Colors.amber[900],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Meal template list
                  Text(
                    'Meals in this template:',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 12),

                  ...sortedTemplates.map((template) {
                    final mealType = template['meal_type'] as String? ?? 'Meal';
                    final name = template['name'] as String? ?? '';
                    final entree = template['entree'] as Map<String, dynamic>?;
                    final sides = template['sides'] as List<dynamic>? ?? [];
                    final desserts = template['desserts'] as List<dynamic>? ?? [];
                    final snacks = template['snacks'] as List<dynamic>? ?? [];
                    final imageUrl = entree?['image_url'] as String?
                        ?? (snacks.isNotEmpty ? (snacks.first as Map<String, dynamic>)['image_url'] as String? : null);

                    final displayName = name.isNotEmpty
                        ? name
                        : entree?['recipe_name'] as String?
                          ?? (snacks.isNotEmpty ? (snacks.first as Map<String, dynamic>)['recipe_name'] as String? : null)
                          ?? mealType;

                    // Count items
                    int itemCount = 0;
                    if (entree != null) itemCount++;
                    itemCount += sides.length;
                    itemCount += desserts.length;
                    itemCount += snacks.length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, fit: BoxFit.cover)
                                  : Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 20,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$mealType${itemCount > 1 ? ' ($itemCount items)' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: 'Andika New Basic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Import button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isImporting ? null : () => _handleDayTemplateImport(content),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 2,
                      ),
                      child: _isImporting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Save to My Cookbook',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDayTemplateImport(SharedContentRecord content) async {
    setState(() => _isImporting = true);

    try {
      final importedCount = await SharingService.importDayTemplate(
        sharedContent: content,
      );

      if (!mounted) return;

      if (importedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day template saved to your cookbook! ($importedCount meals)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to Cookbook page (FavMealPage)
        context.goNamed('FavMealPage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import day template. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isImporting = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isImporting = false);
    }
  }

  Future<void> _handleActivityPlanImport(SharedContentRecord content) async {
    setState(() => _isImporting = true);

    try {
      // Import starting from today (day_offset 0 = today, 1 = tomorrow, etc.)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final importedCount = await SharingService.importActivityPlan(
        sharedContent: content,
        targetWeekStart: today,
      );

      if (!mounted) return;

      if (importedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$importedCount activities imported to your calendar!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to Calendar page
        context.goNamed('Calendarpage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import activities. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isImporting = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isImporting = false);
    }
  }

  Widget _buildContent() {
    final content = _sharedContent!;

    // Route to activity import for activity content type
    if (content.contentType == SharedContentType.activity) {
      return _buildActivityContent(content);
    }

    // Route to activity plan import for activity plan content type
    if (content.contentType == SharedContentType.activityPlan) {
      return _buildActivityPlanContent(content);
    }

    // Route to day template import
    if (content.contentType == SharedContentType.dayTemplate) {
      return _buildDayTemplateContent(content);
    }

    return Column(
      children: [
        // Fixed header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF5F5F5),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _getImportTitle(),
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared by info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: 'Andika New Basic',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Shared by ${content.sharedByName}',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        // Personal note if present
                        if (content.contentData['personal_note'] != null &&
                            (content.contentData['personal_note'] as String).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 16,
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    content.contentData['personal_note'] as String,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select all / none
                  Row(
                    children: [
                      Text(
                        'Select recipes to import',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final allSelected = _recipes.every((r) => r.isSelected);
                            for (var r in _recipes) {
                              r.isSelected = !allSelected;
                            }
                          });
                        },
                        child: Text(
                          _recipes.every((r) => r.isSelected) ? 'Deselect All' : 'Select All',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).primary,
                            fontFamily: 'Andika New Basic',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Simplified view for single template or grouped list for meal plans
                  if (_isSingleTemplate())
                    _buildSingleTemplateView(_recipes.first)
                  else
                    ..._groupedByDay.entries.map((entry) => _buildDayGroup(entry.key, entry.value)),

                  const SizedBox(height: 24),

                  // Info message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book, size: 20, color: FlutterFlowTheme.of(context).primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selected items will be saved to your cookbook.',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Import button
                  FFButtonWidget(
                    onPressed: _selectedCount == 0 || _isImporting ? null : _handleImport,
                    text: _isImporting
                        ? 'Importing...'
                        : 'Save $_selectedCount Item${_selectedCount == 1 ? '' : 's'} to Cookbook',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(28),
                      disabledColor: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel button
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(
                        'Not now',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build a horizontal scrollable day selector for the next 7 days
  Widget _buildDaySelector() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          final isSelected = _selectedDate.year == day.year &&
              _selectedDate.month == day.month &&
              _selectedDate.day == day.day;
          final isToday = day.day == today.day && day.month == today.month;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedDate = day),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? FlutterFlowTheme.of(context).primary
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      dateTimeFormat("E", day, locale: 'en').substring(0, 3),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontFamily: 'Andika New Basic',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontFamily: 'Andika New Basic',
                      ),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.indigo;
      case 'snacks':
      case 'snack':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPlaceholderImage({double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: Colors.grey[400], size: size * 0.48),
    );
  }

  // Show recipe details in a bottom sheet
  void _showRecipeDetails(_SelectableRecipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Image
                    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          recipe.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Icon(Icons.restaurant, size: 48, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      recipe.name,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Meal type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getMealTypeColor(recipe.mealType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getMealTypeIcon(recipe.mealType),
                                  size: 14, color: _getMealTypeColor(recipe.mealType)),
                              const SizedBox(width: 4),
                              Text(
                                recipe.mealType.split(',').map((t) => t.trim()).join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getMealTypeColor(recipe.mealType),
                                  fontFamily: 'Andika New Basic',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (recipe.isCombo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Combo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purple[700],
                                fontFamily: 'Andika New Basic',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Combo contents
                    if (recipe.isCombo) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Includes:',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Entree
                      _buildComboItem(Icons.restaurant, 'Entree', recipe.name),
                      // Sides
                      ...recipe.comboSides.map((side) => _buildComboItem(Icons.add_circle_outline, 'Side', side)),
                      // Drink
                      if (recipe.comboDrink != null)
                        _buildComboItem(Icons.local_drink, 'Drink', recipe.comboDrink!),
                    ],

                    // Ingredients
                    if (recipe.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Ingredients:',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map((ing) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ing,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],

                    // Instructions
                    if (recipe.cookingInstructions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Instructions:',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...recipe.cookingInstructions.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComboItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Andika New Basic',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Andika New Basic',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _importMode == value;
    return InkWell(
      onTap: () => setState(() => _importMode = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: isSelected ? FlutterFlowTheme.of(context).primary : Colors.grey[600], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          color: isSelected ? FlutterFlowTheme.of(context).primary : null,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: Colors.grey[600],
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImport() async {
    final selectedRecipes = _recipes.where((r) => r.isSelected).toList();
    if (selectedRecipes.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      int successCount = 0;

      if (_importMode == 'cookbook') {
        // Save selected recipes to cookbook (meal collection)
        for (final recipe in selectedRecipes) {
          try {
            if (recipe.isCombo && recipe.comboData != null) {
              // Create combo with entree and sides
              await _createComboInCookbook(recipe);
            } else {
              // Create single meal
              await _createMealInCookbook(recipe.recipeData);
            }
            successCount++;
          } catch (e) {
            if (kDebugMode) print('Error saving recipe: $e');
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $successCount item${successCount == 1 ? '' : 's'} to your cookbook!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to meal plan page
        context.goNamed(CreateMealPlanWidget.routeName);
      } else {
        // Add to meal plan for specific day
        for (final recipe in selectedRecipes) {
          try {
            if (recipe.isCombo && recipe.comboData != null) {
              await _addComboToMealPlan(recipe);
            } else {
              await _addRecipeToMealPlan(recipe.recipeData);
            }
            successCount++;
          } catch (e) {
            if (kDebugMode) print('Error adding to meal plan: $e');
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $successCount recipe${successCount == 1 ? '' : 's'} to your meal plan!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Increment import count
        if (_sharedContent != null) {
          await _sharedContent!.reference.update({
            'import_count': FieldValue.increment(1),
          });
        }

        // Navigate to meal plan page
        context.goNamed(CreateMealPlanWidget.routeName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isImporting = false);
    }
  }

  Future<DocumentReference> _createMealInCookbook(Map<String, dynamic> data) async {
    final recipeName = data['recipe_name'] as String?;

    // Check if a meal with the same name already exists for this user
    if (recipeName != null && recipeName.isNotEmpty) {
      final existing = await MealRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .where('recipe_name', isEqualTo: recipeName)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Return existing meal reference instead of creating duplicate
        return existing.docs.first.reference;
      }
    }

    final mealRef = await MealRecord.collection.add(createMealRecordData(
      recipeName: recipeName,
      imageUrl: data['image_url'] as String?,
      prepareTime: (data['prepare_time'] as num?)?.toDouble(),
      cookingTime: (data['cooking_time'] as num?)?.toDouble(),
      mealTyp: data['meal_typ'] as String?,
      userRef: currentUserReference,
    ));

    // Update ingredients and cooking instructions (arrays)
    await mealRef.update({
      'ingredients': data['ingredients'] ?? [],
      'CookingInstructions': data['cooking_instructions'] ?? [],
    });

    return mealRef;
  }

  Future<void> _createComboInCookbook(_SelectableRecipe recipe) async {
    final combo = recipe.comboData!;
    DocumentReference? entreeRef;
    List<DocumentReference> sideRefs = [];
    List<DocumentReference> dessertRefs = [];

    // Create entree
    final entreeData = combo['entree'] as Map<String, dynamic>?;
    if (entreeData != null) {
      entreeRef = await _createMealInCookbook(entreeData);
    }

    // Create sides
    final sidesData = combo['sides'] as List<dynamic>? ?? [];
    for (final sideData in sidesData) {
      if (sideData is Map<String, dynamic>) {
        final sideRef = await _createMealInCookbook(sideData);
        sideRefs.add(sideRef);
      }
    }

    // Create desserts
    final dessertsData = combo['desserts'] as List<dynamic>? ?? [];
    for (final dessertData in dessertsData) {
      if (dessertData is Map<String, dynamic>) {
        final dessertRef = await _createMealInCookbook(dessertData);
        dessertRefs.add(dessertRef);
      }
    }

    // Create the combo
    final comboRef = await MealComboRecord.collection.add(createMealComboRecordData(
      name: combo['name'] as String?,
      entreeRef: entreeRef,
      drinkType: _parseDrinkType(combo['drink_type'] as String?),
      drinkCustom: combo['drink_custom'] as String?,
      mealTyp: _parseMealType(combo['meal_typ'] as String?),
      userRef: currentUserReference,
      createdTime: DateTime.now(),
    ));

    // Add side refs and dessert refs to the combo
    final updateData = <String, dynamic>{};
    if (sideRefs.isNotEmpty) {
      updateData['side_refs'] = sideRefs;
    }
    if (dessertRefs.isNotEmpty) {
      updateData['dessert_refs'] = dessertRefs;
    }
    if (updateData.isNotEmpty) {
      await comboRef.update(updateData);
    }
  }

  Future<void> _addRecipeToMealPlan(Map<String, dynamic> data) async {
    final mealRef = await _createMealInCookbook(data);
    final mealType = _parseMealType(_selectedMealType);

    // Check if a meal plan entry already exists for this date/meal type
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await MealPlanRecord.collection
        .where('user_ref', isEqualTo: currentUserReference)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .get();

    // Check if any existing entry has the same meal type
    final hasExisting = existing.docs.any((doc) {
      final record = MealPlanRecord.fromSnapshot(doc);
      return record.typ == mealType;
    });

    if (hasExisting) {
      // Skip creating duplicate meal plan entry
      if (kDebugMode) print('Meal plan entry already exists for ${_selectedDate.toString()} $mealType');
      return;
    }

    await MealPlanRecord.collection.add(createMealPlanRecordData(
      date: _selectedDate,
      typ: mealType,
      userRef: currentUserReference,
      userFirebasemeal: mealRef,
    ));
  }

  Future<void> _addComboToMealPlan(_SelectableRecipe recipe) async {
    final mealType = _parseMealType(_selectedMealType);

    // Check if a meal plan entry already exists for this date/meal type
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await MealPlanRecord.collection
        .where('user_ref', isEqualTo: currentUserReference)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .get();

    // Check if any existing entry has the same meal type
    final hasExisting = existing.docs.any((doc) {
      final record = MealPlanRecord.fromSnapshot(doc);
      return record.typ == mealType;
    });

    if (hasExisting) {
      // Skip creating duplicate meal plan entry
      if (kDebugMode) print('Meal plan entry already exists for ${_selectedDate.toString()} $mealType');
      return;
    }

    final combo = recipe.comboData!;
    DocumentReference? entreeRef;
    List<DocumentReference> sideRefs = [];
    List<DocumentReference> dessertRefs = [];

    // Create entree
    final entreeData = combo['entree'] as Map<String, dynamic>?;
    if (entreeData != null) {
      entreeRef = await _createMealInCookbook(entreeData);
    }

    // Create sides
    final sidesData = combo['sides'] as List<dynamic>? ?? [];
    for (final sideData in sidesData) {
      if (sideData is Map<String, dynamic>) {
        final sideRef = await _createMealInCookbook(sideData);
        sideRefs.add(sideRef);
      }
    }

    // Create desserts
    final dessertsData = combo['desserts'] as List<dynamic>? ?? [];
    for (final dessertData in dessertsData) {
      if (dessertData is Map<String, dynamic>) {
        final dessertRef = await _createMealInCookbook(dessertData);
        dessertRefs.add(dessertRef);
      }
    }

    // Create the combo
    final comboRef = await MealComboRecord.collection.add(createMealComboRecordData(
      name: combo['name'] as String?,
      entreeRef: entreeRef,
      drinkType: _parseDrinkType(combo['drink_type'] as String?),
      drinkCustom: combo['drink_custom'] as String?,
      mealTyp: mealType,
      userRef: currentUserReference,
      createdTime: DateTime.now(),
    ));

    // Add side refs and dessert refs to the combo
    final updateData = <String, dynamic>{};
    if (sideRefs.isNotEmpty) {
      updateData['side_refs'] = sideRefs;
    }
    if (dessertRefs.isNotEmpty) {
      updateData['dessert_refs'] = dessertRefs;
    }
    if (updateData.isNotEmpty) {
      await comboRef.update(updateData);
    }

    // Create the meal plan entry with combo reference
    await MealPlanRecord.collection.add(createMealPlanRecordData(
      date: _selectedDate,
      typ: mealType,
      userRef: currentUserReference,
      mealComboRef: comboRef,
    ));
  }

  MealTyp? _parseMealType(String? type) {
    if (type == null) return null;
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealTyp.Breakfast;
      case 'lunch':
        return MealTyp.Lunch;
      case 'dinner':
        return MealTyp.Dinner;
      case 'snacks':
      case 'snack':
        return MealTyp.Snacks;
      default:
        return MealTyp.Dinner;
    }
  }

  DrinkType? _parseDrinkType(String? type) {
    if (type == null) return null;
    switch (type.toLowerCase()) {
      case 'water':
        return DrinkType.Water;
      case 'milk':
        return DrinkType.Milk;
      case 'juice':
        return DrinkType.Juice;
      case 'smoothie':
        return DrinkType.Smoothie;
      case 'other':
        return DrinkType.Other;
      default:
        return DrinkType.Water;
    }
  }
}
