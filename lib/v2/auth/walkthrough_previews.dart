import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Food image URLs from Unsplash (free for commercial use)
const _kFoodImages = [
  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&h=200&fit=crop&auto=format&q=80',
  'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200&h=200&fit=crop&auto=format&q=80',
  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&h=200&fit=crop&auto=format&q=80',
];

// ─── Helper: Food thumbnail with fallback ───────────────────────────────────

Widget _foodThumbnail(String url, {double size = 52.0, double radius = 10.0}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(Icons.restaurant, color: Colors.orange.shade300, size: size * 0.5),
      ),
    ),
  );
}

// ─── 1. Meal Plan Day-by-Day Preview ────────────────────────────────────────
// Matches the actual app: vertical day list with Breakfast/Lunch/Dinner slots

class MealPlanPreview extends StatelessWidget {
  const MealPlanPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header - matches actual app format
        Text(
          'Wednesday, Feb 12',
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        // Meal slots matching the actual app layout
        _mealSlot('Breakfast', 'Banana Pancakes', _kFoodImages[1], true),
        const SizedBox(height: 6),
        _mealSlot('Lunch', 'Chicken Caesar Wrap', _kFoodImages[0], true),
        const SizedBox(height: 6),
        _mealSlot('Dinner', null, null, false),
        const SizedBox(height: 12),
        // Next day peek
        Text(
          'Thursday, Feb 13',
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        _mealSlot('Breakfast', 'Overnight Oats', _kFoodImages[2], true),
        const SizedBox(height: 6),
        _mealSlot('Lunch', null, null, false),
      ],
    );
  }

  Widget _mealSlot(String mealType, String? name, String? imageUrl, bool filled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? Colors.grey.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: filled ? Colors.grey.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Meal type label
          SizedBox(
            width: 62,
            child: Text(
              mealType,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          if (filled && imageUrl != null) ...[
            _foodThumbnail(imageUrl, size: 36.0, radius: 8.0),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              filled ? (name ?? '') : 'Tap to add',
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                fontSize: 13,
                color: filled ? Colors.grey.shade800 : Colors.grey.shade400,
                fontStyle: filled ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          if (!filled)
            Icon(Icons.add_circle_outline, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

// ─── 2. Grocery List Preview ────────────────────────────────────────────────
// Matches actual app: grouped by aisle, purple accent (0xFF9B8AA0)

class GroceryListPreview extends StatelessWidget {
  const GroceryListPreview({super.key});

  static const _purple = Color(0xFF9B8AA0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header showing it auto-generates
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: _purple),
              const SizedBox(width: 6),
              Text(
                'Auto-generated & sorted by aisle',
                style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _purple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Produce section
        _aisleHeader('🥬', 'Produce', '3 items'),
        _groceryItem(true, 'Broccoli (2 crowns)'),
        _groceryItem(false, 'Tomatoes (4)'),
        _groceryItem(false, 'Onion (1 large)'),
        const SizedBox(height: 10),
        // Dairy section
        _aisleHeader('🥛', 'Dairy & Eggs', '2 items'),
        _groceryItem(true, 'Shredded mozzarella'),
        _groceryItem(false, 'Butter (1 stick)'),
        const SizedBox(height: 10),
        // Pantry section
        _aisleHeader('🥫', 'Pantry', '2 items'),
        _groceryItem(false, 'Penne pasta (1 lb)'),
        _groceryItem(false, 'Olive oil'),
      ],
    );
  }

  Widget _aisleHeader(String emoji, String title, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groceryItem(bool checked, String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 3),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: checked ? _purple : Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 13,
              color: checked ? Colors.grey.shade400 : Colors.grey.shade800,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3. Learning Path Preview ───────────────────────────────────────────────
// Enhanced to show AI-generated details (parent tip, success signs, if resistant)

class LearningPathPreview extends StatelessWidget {
  const LearningPathPreview({super.key});

  // status: 2=done, 1=current, 0=pending
  static const _steps = [
    (2, 'Getting familiar', 'Let them explore the potty chair'),
    (2, 'Practice sitting', 'Sit with clothes on after meals'),
    (1, 'First tries', 'Try without a diaper for short periods'),
    (0, 'Building routine', 'Regular potty breaks throughout the day'),
    (0, 'Nighttime training', 'Limit fluids before bed, try overnight'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with AI badge
        Row(
          children: [
            const Text(
              'Potty Training',
              style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 10, color: Color(0xFFEC407A)),
                  SizedBox(width: 3),
                  Text(
                    'AI Plan',
                    style: TextStyle(
                      fontFamily: 'Andika New Basic',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEC407A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Steps timeline
        ...List.generate(_steps.length, (i) {
          final (status, title, desc) = _steps[i];
          final isLast = i == _steps.length - 1;
          final color = status >= 1
              ? const Color(0xFFEC407A)
              : Colors.grey.shade300;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: status == 1 ? 16 : 12,
                        height: status == 1 ? 16 : 12,
                        decoration: BoxDecoration(
                          color: status == 2
                              ? color
                              : (status == 1
                                  ? color.withValues(alpha: 0.3)
                                  : Colors.transparent),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: status == 2
                            ? const Icon(Icons.check,
                                size: 8, color: Colors.white)
                            : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: i < 2
                                ? const Color(0xFFEC407A).withValues(alpha: 0.5)
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${i + 1}: $title',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            fontSize: 13,
                            fontWeight: status == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: status == 0
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                        if (status >= 1) ...[
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (status == 2)
                  Icon(Icons.check_circle,
                      size: 16,
                      color: const Color(0xFFEC407A).withValues(alpha: 0.7)),
                if (status == 1)
                  const Icon(Icons.arrow_forward_ios,
                      size: 12, color: Color(0xFFEC407A)),
              ],
            ),
          );
        }),
        // Expandable detail hint for current step
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEC407A).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEC407A).withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 14, color: const Color(0xFFEC407A)),
                  const SizedBox(width: 6),
                  const Text(
                    'Parent tip',
                    style: TextStyle(
                      fontFamily: 'Andika New Basic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC407A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Your calm energy matters more than perfection. If they resist, try again in 30 minutes with a playful approach.',
                style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 4. Calendar Preview ────────────────────────────────────────────────────
// Matches actual app: person filter circles + calendar grid + event items below

class CalendarPreview extends StatelessWidget {
  const CalendarPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Column(
      children: [
        // Person filter circles (matches actual app)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _filterCircle('All', const Color(0xFF52A097), true),
            const SizedBox(width: 8),
            _filterCircle('Me', const Color(0xFF7E57C2), false),
            const SizedBox(width: 8),
            _filterCircle('E', const Color(0xFFFF8C00), false),
            const SizedBox(width: 8),
            _filterCircle('L', const Color(0xFF4CAF50), false),
          ],
        ),
        const SizedBox(height: 12),
        // Month header
        Text(
          'February 2026',
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayHeaders
              .map((d) => SizedBox(
                    width: 28,
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        _calendarRow([9, 10, 11, 12, 13, 14, 15],
            todayIndex: 3,
            dotDays: {0, 2, 4}),
        const SizedBox(height: 4),
        _calendarRow([16, 17, 18, 19, 20, 21, 22],
            dotDays: {1, 3, 5}),
        const SizedBox(height: 10),
        // Event items below calendar (matches actual app)
        _eventItem('Swim class', 'Emma', const Color(0xFFFF8C00), Icons.pool),
        const SizedBox(height: 6),
        _eventItem('Dentist appointment', 'Mom', const Color(0xFF7E57C2), Icons.medical_services),
      ],
    );
  }

  Widget _filterCircle(String label, Color color, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: active ? null : Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            fontSize: label.length > 2 ? 9 : 11,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _eventItem(String title, String person, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Andika New Basic',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              person,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarRow(List<int> days,
      {int? todayIndex, Set<int> dotDays = const {}}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final isToday = i == todayIndex;
        final hasDot = dotDays.contains(i);
        return SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF52A097) : null,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${days[i]}',
                    style: TextStyle(
                      fontFamily: 'Andika New Basic',
                      fontSize: 12,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              if (hasDot)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF52A097),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 5),
            ],
          ),
        );
      }),
    );
  }
}

// ─── 5. Activities Preview ──────────────────────────────────────────────────

class ActivitiesPreview extends StatelessWidget {
  const ActivitiesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _activityCard('🎨', 'Finger Painting', const Color(0xFFE91E63)),
        const SizedBox(height: 8),
        _activityCard('🏃', 'Backyard Obstacle Course', const Color(0xFF4CAF50)),
        const SizedBox(height: 8),
        _activityCard('🧩', 'Shape Sorting Game', const Color(0xFFFF8C00)),
        const SizedBox(height: 8),
        _activityCard('🎵', 'Musical Freeze Dance', const Color(0xFF7E57C2)),
      ],
    );
  }

  Widget _activityCard(String emoji, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

// ─── 6. Milestones Preview ──────────────────────────────────────────────────

class MilestonesPreview extends StatelessWidget {
  const MilestonesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const milestones = [
      (true, 'Rolls over both ways'),
      (true, 'Sits without support'),
      (true, 'Crawls forward'),
      (false, 'Pulls to stand'),
      (false, 'Takes first steps'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_run,
                size: 16, color: Color(0xFF4CAF50)),
            const SizedBox(width: 6),
            const Text(
              'Physical Milestones',
              style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '3 of 5',
              style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 12,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 3 / 5,
            backgroundColor: Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation(Color(0xFF4CAF50)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        ...milestones.map((m) {
          final (done, text) = m;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 18,
                  color: done
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Andika New Basic',
                    fontSize: 13,
                    color: done
                        ? Colors.grey.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
