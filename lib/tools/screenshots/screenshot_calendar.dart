import 'package:flutter/material.dart';
import 'demo_data.dart';

/// Screenshot shell for the Calendar screen.
/// White background with monthly calendar and event list.
class ScreenshotCalendar extends StatelessWidget {
  const ScreenshotCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Filter circles
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _FilterCircle(label: 'All', color: kPrimary, selected: true),
                          const SizedBox(width: 10),
                          const _FilterCircle(label: 'S', color: Color(0xFF9C27B0), selected: false),
                          const SizedBox(width: 10),
                          const _FilterCircle(label: 'D', color: Color(0xFF1976D2), selected: false),
                          const SizedBox(width: 10),
                          _FilterCircle(
                            label: demoChildren[0].initial,
                            color: demoChildren[0].color,
                            selected: false,
                          ),
                          const SizedBox(width: 10),
                          _FilterCircle(
                            label: demoChildren[1].initial,
                            color: demoChildren[1].color,
                            selected: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Calendar grid
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Month header
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.chevron_left, color: kPrimary),
                              Text(
                                'February 2026',
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right, color: kPrimary),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Day headers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                                .map((d) => SizedBox(
                                      width: 36,
                                      child: Text(
                                        d,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),

                          const SizedBox(height: 8),

                          // Calendar weeks (Feb 2026 starts on Sunday)
                          const _CalendarWeek(days: [1, 2, 3, 4, 5, 6, 7], today: 17, eventDays: {3, 5, 7, 10, 12, 14, 17, 19, 21, 24}),
                          const _CalendarWeek(days: [8, 9, 10, 11, 12, 13, 14], today: 17, eventDays: {3, 5, 7, 10, 12, 14, 17, 19, 21, 24}),
                          const _CalendarWeek(days: [15, 16, 17, 18, 19, 20, 21], today: 17, eventDays: {3, 5, 7, 10, 12, 14, 17, 19, 21, 24}),
                          const _CalendarWeek(days: [22, 23, 24, 25, 26, 27, 28], today: 17, eventDays: {3, 5, 7, 10, 12, 14, 17, 19, 21, 24}),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Today's events header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Monday, February 17',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Event cards
                    _EventCard(
                      title: 'Potty Training - Day 3',
                      time: '9:00 AM',
                      type: 'Learning Path',
                      assignees: [demoChildren[0]],
                      color: const Color(0xFFEC407A),
                      completed: false,
                    ),

                    const _EventCard(
                      title: 'Playdate at the park',
                      time: '2:00 PM',
                      type: 'Activity',
                      assignees: demoChildren,
                      color: kPrimary,
                      completed: false,
                    ),

                    const _EventCard(
                      title: 'Chicken Stir Fry',
                      time: '5:30 PM',
                      type: 'Dinner',
                      assignees: [],
                      color: kTertiary,
                      completed: false,
                    ),

                    _EventCard(
                      title: 'Bath time routine',
                      time: '7:00 PM',
                      type: 'Task',
                      assignees: [demoChildren[0], demoChildren[1]],
                      color: const Color(0xFF64B5F6),
                      completed: false,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            const ScreenshotNavBar(selectedIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _FilterCircle extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;

  const _FilterCircle({
    required this.label,
    required this.color,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: label.length > 1 ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _CalendarWeek extends StatelessWidget {
  final List<int> days;
  final int today;
  final Set<int> eventDays;

  const _CalendarWeek({
    required this.days,
    required this.today,
    required this.eventDays,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          final isToday = d == today;
          final hasEvent = eventDays.contains(d);

          return SizedBox(
            width: 36,
            height: 42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isToday ? kPrimary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday ? null : (d > 0 ? null : null),
                  ),
                  child: Center(
                    child: Text(
                      d > 0 ? '$d' : '',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
                if (hasEvent && !isToday)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String type;
  final List<DemoChild> assignees;
  final Color color;
  final bool completed;

  const _EventCard({
    required this.title,
    required this.time,
    required this.type,
    required this.assignees,
    required this.color,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color bar
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Assignee circles
          if (assignees.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: assignees.length * 20.0 + 10,
                height: 26,
                child: Stack(
                  children: [
                    for (int i = 0; i < assignees.length; i++)
                      Positioned(
                        left: i * 18.0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: assignees[i].color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              assignees[i].initial,
                              style: const TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Checkbox
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
