import 'package:flutter/material.dart';
import 'demo_data.dart';

/// Screenshot shell for the Meal Plan screen.
/// Warm beige background with weekly meal plan view.
class ScreenshotMealPlan extends StatelessWidget {
  const ScreenshotMealPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF8F5), Color(0xFFF5EDE6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF999999)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Title row
                            Row(
                              children: [
                                const Icon(Icons.arrow_back_ios, size: 20, color: kPrimary),
                                const SizedBox(width: 12),
                                const Text(
                                  'Meal Plan',
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Action icons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ActionIcon(Icons.notifications_active, const Color(0xFFFFA726)),
                                _ActionIcon(Icons.share, kSecondary),
                                _ActionIcon(Icons.auto_awesome, const Color(0xFF9C27B0)),
                                _ActionIcon(Icons.menu_book, kPrimary),
                                _ActionIcon(Icons.shopping_cart, const Color(0xFF9B8AA0)),
                                _ActionIcon(Icons.calendar_month, const Color(0xFF4CAF50)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Days list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _DaySection(
                              day: 'Monday, Feb 17',
                              isToday: true,
                              expanded: true,
                              meals: const [
                                _DemoMeal('\u{1F305}', 'Breakfast', 'Scrambled Eggs & Toast'),
                                _DemoMeal('\u{1F31E}', 'Lunch', 'Turkey & Cheese Wraps'),
                                _DemoMeal('\u{1F319}', 'Dinner', 'Chicken Stir Fry'),
                                _DemoMeal('\u{1F36A}', 'Snacks', 'Apple slices & PB'),
                              ],
                            ),
                            _DaySection(
                              day: 'Tuesday, Feb 18',
                              isToday: false,
                              expanded: false,
                              meals: const [
                                _DemoMeal('\u{1F305}', 'Breakfast', 'Pancakes'),
                                _DemoMeal('\u{1F31E}', 'Lunch', ''),
                                _DemoMeal('\u{1F319}', 'Dinner', 'Pasta Bolognese'),
                                _DemoMeal('\u{1F36A}', 'Snacks', ''),
                              ],
                            ),
                            _DaySection(
                              day: 'Wednesday, Feb 19',
                              isToday: false,
                              expanded: false,
                              meals: const [
                                _DemoMeal('\u{1F305}', 'Breakfast', 'Oatmeal'),
                                _DemoMeal('\u{1F31E}', 'Lunch', 'Grilled Cheese'),
                                _DemoMeal('\u{1F319}', 'Dinner', ''),
                                _DemoMeal('\u{1F36A}', 'Snacks', 'Yogurt cups'),
                              ],
                            ),
                            _DaySection(
                              day: 'Thursday, Feb 20',
                              isToday: false,
                              expanded: false,
                              meals: const [
                                _DemoMeal('\u{1F305}', 'Breakfast', ''),
                                _DemoMeal('\u{1F31E}', 'Lunch', ''),
                                _DemoMeal('\u{1F319}', 'Dinner', 'Taco Night'),
                                _DemoMeal('\u{1F36A}', 'Snacks', ''),
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const ScreenshotNavBar(selectedIndex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ActionIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String day;
  final bool isToday;
  final bool expanded;
  final List<_DemoMeal> meals;

  const _DaySection({
    required this.day,
    required this.isToday,
    required this.expanded,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    final planned = meals.where((m) => m.name.isNotEmpty).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isToday ? kPrimary.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Day header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: isToday ? 15 : 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (!expanded) ...[
                  // Meal indicator dots
                  ...meals.map((m) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.name.isNotEmpty ? kPrimary : Colors.grey.shade300,
                        ),
                      )),
                  const SizedBox(width: 4),
                  Text(
                    '$planned/4',
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Expanded meal slots
          if (expanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: meals.map((meal) => _MealSlot(meal: meal)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealSlot extends StatelessWidget {
  final _DemoMeal meal;

  const _MealSlot({required this.meal});

  @override
  Widget build(BuildContext context) {
    final hasData = meal.name.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(meal.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.type,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
                if (hasData)
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    'Tap to add a meal',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 13,
                      color: kPrimary.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (!hasData) Icon(Icons.add_circle_outline, size: 20, color: kPrimary),
        ],
      ),
    );
  }
}

class _DemoMeal {
  final String emoji;
  final String type;
  final String name;

  const _DemoMeal(this.emoji, this.type, this.name);
}
