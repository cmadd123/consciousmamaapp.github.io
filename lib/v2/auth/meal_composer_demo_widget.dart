import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/celebration_animation.dart';
import 'package:flutter/material.dart';
import 'meal_composer_demo_model.dart';
export 'meal_composer_demo_model.dart';

/// Exact replica of real meal composer - Demo with fake data
class MealComposerDemoWidget extends StatefulWidget {
  const MealComposerDemoWidget({
    super.key,
    required this.mealName,
    required this.dayIndex,
  });

  final String mealName; // "Breakfast", "Lunch", "Dinner", "Snacks"
  final int dayIndex;

  static String routeName = 'MealComposerDemo';
  static String routePath = '/meal-composer-demo';

  @override
  State<MealComposerDemoWidget> createState() => _MealComposerDemoWidgetState();
}

// Fake recipe data class
class FakeRecipe {
  final String name;
  final int prepTime;
  final int cookTime;
  final String imageUrl;

  FakeRecipe(this.name, this.prepTime, this.cookTime, this.imageUrl);
}

class _MealComposerDemoWidgetState extends State<MealComposerDemoWidget> {
  late MealComposerDemoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Selected items
  FakeRecipe? selectedEntree;
  List<FakeRecipe> selectedSides = [];
  List<FakeRecipe> selectedDesserts = [];
  String? selectedDrink;

  // Leftover toggles
  bool isLeftoverEntree = false;
  bool isLeftoverSide = false;
  bool isLeftoverDessert = false;

  // Custom meal and notes
  final TextEditingController customMealController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Fake recipe database
  final List<FakeRecipe> fakeEntrees = [
    FakeRecipe('Spaghetti & Meatballs', 10, 25, '🍝'),
    FakeRecipe('Grilled Chicken', 5, 20, '🍗'),
    FakeRecipe('Salmon with Herbs', 10, 15, '🐟'),
    FakeRecipe('Veggie Stir Fry', 15, 10, '🥗'),
    FakeRecipe('Beef Tacos', 10, 15, '🌮'),
  ];

  final List<FakeRecipe> fakeSides = [
    FakeRecipe('Caesar Salad', 5, 0, '🥗'),
    FakeRecipe('Garlic Bread', 2, 8, '🍞'),
    FakeRecipe('Steamed Broccoli', 2, 5, '🥦'),
    FakeRecipe('Rice Pilaf', 5, 20, '🍚'),
    FakeRecipe('Roasted Vegetables', 10, 25, '🥕'),
    FakeRecipe('Mashed Potatoes', 5, 15, '🥔'),
  ];

  final List<FakeRecipe> fakeDesserts = [
    FakeRecipe('Chocolate Chip Cookies', 10, 12, '🍪'),
    FakeRecipe('Apple Pie', 20, 45, '🥧'),
    FakeRecipe('Ice Cream', 0, 0, '🍨'),
    FakeRecipe('Fruit Salad', 10, 0, '🍇'),
    FakeRecipe('Brownies', 10, 25, '🍫'),
  ];

  final List<String> drinks = ['Water', 'Milk', 'Juice', 'Lemonade', 'Iced Tea', 'Custom...'];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealComposerDemoModel());
  }

  @override
  void dispose() {
    customMealController.dispose();
    notesController.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get hasAnyItems {
    if (customMealController.text.trim().isNotEmpty) return true;
    return selectedEntree != null || selectedSides.isNotEmpty || selectedDesserts.isNotEmpty || selectedDrink != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFAF8F5), Color(0xFFF5EDE6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(context, theme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: widget.mealName == 'Snacks'
                        ? _buildSnacksLayout(context)
                        : _buildMealLayout(context),
                  ),
                ),
                _buildBottomActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mealName.toUpperCase(),
                  style: theme.titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  dateTimeFormat('EEEE, MMMM d', DateTime.now().add(Duration(days: widget.dayIndex))),
                  style: theme.bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          title: 'ENTREE',
          icon: Icons.restaurant,
          isLeftover: isLeftoverEntree,
          onLeftoverChanged: (value) => setState(() => isLeftoverEntree = value),
          child: _buildSlot(
            context,
            item: selectedEntree,
            placeholder: 'Tap to add entree',
            onAdd: () => _showRecipePicker('entree'),
            onRemove: () => setState(() => selectedEntree = null),
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSection(
          context,
          title: 'SIDES',
          icon: Icons.grain,
          isLeftover: isLeftoverSide,
          onLeftoverChanged: (value) => setState(() => isLeftoverSide = value),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ...selectedSides.asMap().entries.map((entry) => _buildCompactSlot(
                context,
                item: entry.value,
                onRemove: () => setState(() => selectedSides.removeAt(entry.key)),
              )),
              if (selectedSides.length < 3)
                _buildAddButton(context, 'Add side', () => _showRecipePicker('side')),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSection(
          context,
          title: 'DESSERTS',
          icon: Icons.cake,
          isLeftover: isLeftoverDessert,
          onLeftoverChanged: (value) => setState(() => isLeftoverDessert = value),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ...selectedDesserts.asMap().entries.map((entry) => _buildCompactSlot(
                context,
                item: entry.value,
                onRemove: () => setState(() => selectedDesserts.removeAt(entry.key)),
              )),
              if (selectedDesserts.length < 2)
                _buildAddButton(context, 'Add dessert', () => _showRecipePicker('dessert')),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSection(
          context,
          title: 'DRINKS',
          icon: Icons.local_drink,
          child: _buildDrinkSlot(context),
        ),
        const SizedBox(height: 20.0),
        _buildNotesSection(context),
        const SizedBox(height: 20.0),
        _buildCustomMealField(context),
        const SizedBox(height: 100.0),
      ],
    );
  }

  Widget _buildSnacksLayout(BuildContext context) {
    // For demo simplicity, snacks use the sides list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          title: 'SNACKS',
          icon: Icons.cookie,
          isLeftover: isLeftoverSide,
          onLeftoverChanged: (value) => setState(() => isLeftoverSide = value),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ...selectedSides.asMap().entries.map((entry) => _buildCompactSlot(
                context,
                item: entry.value,
                onRemove: () => setState(() => selectedSides.removeAt(entry.key)),
              )),
              if (selectedSides.length < 6)
                _buildAddButton(context, 'Add', () => _showRecipePicker('side')),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSection(
          context,
          title: 'DRINKS',
          icon: Icons.local_drink,
          child: _buildDrinkSlot(context),
        ),
        const SizedBox(height: 20.0),
        _buildNotesSection(context),
        const SizedBox(height: 100.0),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    bool? isLeftover,
    ValueChanged<bool>? onLeftoverChanged,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final friendlyTitle = title.length > 1
        ? title[0].toUpperCase() + title.substring(1).toLowerCase()
        : title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 18.0, color: theme.primary),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                friendlyTitle,
                style: theme.bodyLarge.override(
                  fontFamily: 'Andika New Basic',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D4E60),
                  letterSpacing: 0.0,
                ),
              ),
            ),
            if (isLeftover != null && onLeftoverChanged != null)
              InkWell(
                onTap: () => onLeftoverChanged(!isLeftover),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isLeftover ? const Color(0xFFFF9800).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLeftover ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 18.0,
                        color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFF999999),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Leftover',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14.0),
        child,
      ],
    );
  }

  Widget _buildSlot(BuildContext context, {
    required FakeRecipe? item,
    required String placeholder,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    final theme = FlutterFlowTheme.of(context);

    if (item == null) {
      return InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: theme.primary.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, size: 28.0, color: theme.primary),
              ),
              const SizedBox(height: 10.0),
              Text(
                placeholder,
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: const Color(0xFF5D4E60),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: theme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Emoji image
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(13.0)),
              ),
              child: Center(
                child: Text(item.imageUrl, style: const TextStyle(fontSize: 40.0)),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.prepTime > 0 || item.cookTime > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 14.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Text(
                              '${item.prepTime + item.cookTime} min',
                              style: theme.bodySmall.override(
                                fontFamily: 'Andika New Basic',
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Tap to change',
                        style: theme.bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: theme.primary.withOpacity(0.7),
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: theme.secondaryText),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSlot(BuildContext context, {
    required FakeRecipe? item,
    required VoidCallback onRemove,
  }) {
    final theme = FlutterFlowTheme.of(context);
    if (item == null) return const SizedBox.shrink();

    return Container(
      width: 100.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13.0)),
                ),
                child: Center(
                  child: Text(item.imageUrl, style: const TextStyle(fontSize: 36.0)),
                ),
              ),
              Positioned(
                top: 4.0,
                right: 4.0,
                child: InkWell(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14.0, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.name,
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, String label, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: 100.0,
        height: 110.0,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: theme.primary.withOpacity(0.25),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, size: 20.0, color: theme.primary),
            ),
            const SizedBox(height: 6.0),
            Text(
              label,
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF5D4E60),
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkSlot(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: drinks.map((drink) {
        final isSelected = selectedDrink == drink;
        return InkWell(
          onTap: () => setState(() => selectedDrink = drink),
          borderRadius: BorderRadius.circular(20.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected ? theme.primary : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isSelected ? theme.primary : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            child: Text(
              drink,
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF5D4E60),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.lightbulb_outline_rounded, size: 18.0, color: theme.primary),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Notes',
              style: theme.bodyLarge.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D4E60),
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '(optional)',
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF9B8A9E),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFE8DDD5)),
          ),
          child: TextField(
            controller: notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Any thoughts? e.g., Make extra for tomorrow...',
              hintStyle: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF9B8A9E).withOpacity(0.7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14.0),
            ),
            style: theme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: const Color(0xFF5D4E60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomMealField(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.edit_note, size: 18.0, color: Color(0xFFFF9800)),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Or, add custom meal',
              style: theme.bodyLarge.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D4E60),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        TextField(
          controller: customMealController,
          decoration: InputDecoration(
            hintText: 'E.g., "Eating Out", "Pizza Delivery", "Takeout"',
            hintStyle: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF999999),
              fontFamily: 'Andika New Basic',
            ),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.primary, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          style: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Andika New Basic',
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Leave blank if using recipes above',
          style: TextStyle(
            fontSize: 12.0,
            color: Color(0xFF999999),
            fontFamily: 'Andika New Basic',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FFButtonWidget(
          onPressed: !hasAnyItems
              ? null
              : () async {
                  // If this is Dinner (the missing meal), show congratulations!
                  if (widget.mealName == 'Dinner' && mounted) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return Stack(
                          children: [
                            // Confetti animation in background
                            const Positioned.fill(
                              child: CelebrationAnimation(),
                            ),
                            // Dialog in foreground
                            Dialog(
                              backgroundColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(32.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20.0,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated party emoji
                                    const PartyEmojiAnimation(
                                      emoji: '🎉',
                                      size: 64.0,
                                    ),
                                const SizedBox(height: 24.0),
                                // Congratulations text
                                Text(
                                  'You did it!',
                                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Your week is planned. No more "what\'s for dinner?" stress.',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 32.0),
                                // Close button
                                FFButtonWidget(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  text: 'Awesome!',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 48.0,
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    iconPadding: const EdgeInsets.all(0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  // Return meal data with emoji and timing (matching real meal planner card format)
                  if (mounted) {
                    Navigator.pop(context, {
                      'entree': selectedEntree?.name,
                      'entreePic': selectedEntree?.imageUrl, // emoji for display
                      'sides': selectedSides.map((s) => s.name).toList(),
                      'dessert': selectedDesserts.isNotEmpty ? selectedDesserts.first.name : null,
                      'drink': selectedDrink,
                      'prepTime': selectedEntree?.prepTime ?? 0,
                      'cookTime': selectedEntree?.cookTime ?? 0,
                    });
                  }
                },
          text: hasAnyItems ? 'Save Meal' : 'Add at least one item',
          options: FFButtonOptions(
            width: double.infinity,
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            iconPadding: const EdgeInsets.all(0.0),
            color: hasAnyItems ? theme.primary : theme.secondaryText,
            textStyle: theme.titleMedium.override(
              fontFamily: 'Andika New Basic',
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
            elevation: 0.0,
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(28.0),
          ),
        ),
      ),
    );
  }

  void _showRecipePicker(String type) {
    final theme = FlutterFlowTheme.of(context);
    List<FakeRecipe> recipes = [];
    if (type == 'entree') recipes = fakeEntrees;
    else if (type == 'side') recipes = fakeSides;
    else if (type == 'dessert') recipes = fakeDesserts;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select ${type[0].toUpperCase()}${type.substring(1)}',
                style: theme.titleMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16.0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      leading: Text(recipe.imageUrl, style: const TextStyle(fontSize: 32.0)),
                      title: Text(recipe.name),
                      subtitle: Text('${recipe.prepTime + recipe.cookTime} min'),
                      onTap: () {
                        setState(() {
                          if (type == 'entree') selectedEntree = recipe;
                          else if (type == 'side') selectedSides.add(recipe);
                          else if (type == 'dessert') selectedDesserts.add(recipe);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
