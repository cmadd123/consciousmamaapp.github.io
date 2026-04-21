import 'package:flutter/material.dart';
import 'demo_data.dart';

/// Screenshot shell for the Learning Path detail view.
/// Shows an AI-generated day-by-day learning path with tasks.
class ScreenshotLearningPath extends StatelessWidget {
  const ScreenshotLearningPath({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBrandGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 20, color: kPrimary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Learning Path',
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 16, color: kPrimary),
                                  SizedBox(width: 4),
                                  Text(
                                    'AI Generated',
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Path info card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEC407A).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.route, color: Color(0xFFEC407A), size: 24),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Potty Training',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'For Emma, age 2',
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: 0.28,
                                      minHeight: 8,
                                      backgroundColor: kPrimary.withValues(alpha: 0.15),
                                      valueColor: const AlwaysStoppedAnimation(kPrimary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '2 of 7 days',
                                  style: TextStyle(
                                    fontFamily: kFontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Day tasks
                      const _DayCard(
                        dayNumber: 1,
                        title: 'Introduction Day',
                        completed: true,
                        tasks: [
                          _Task('Read a potty training book together', true),
                          _Task('Let them sit on the potty (clothed) during book time', true),
                          _Task('Use positive language: "This is where big kids go!"', true),
                        ],
                        parentTip: 'Keep it pressure-free today. The goal is just familiarity.',
                      ),

                      const _DayCard(
                        dayNumber: 2,
                        title: 'Getting Comfortable',
                        completed: true,
                        tasks: [
                          _Task('Try sitting on potty without diaper before bath', true),
                          _Task('Celebrate any attempt, even just sitting', true),
                          _Task('Let them flush and wash hands (make it fun)', true),
                        ],
                        parentTip: 'If they resist, back off and try again tomorrow. No forcing.',
                      ),

                      const _DayCard(
                        dayNumber: 3,
                        title: 'Building the Routine',
                        completed: false,
                        tasks: [
                          _Task('Offer potty after waking up and after meals', false),
                          _Task('Switch to pull-ups during the day', false),
                          _Task('Create a simple reward system (sticker chart)', false),
                        ],
                        parentTip: 'Accidents are normal and expected. Stay calm and encouraging.',
                      ),

                      const _DayCard(
                        dayNumber: 4,
                        title: 'Practice Makes Progress',
                        completed: false,
                        tasks: [
                          _Task('Set a timer for every 60-90 minutes', false),
                          _Task('Practice pulling pants up and down', false),
                          _Task('Talk about body signals: "Do you feel anything?"', false),
                        ],
                        parentTip: null,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              const ScreenshotNavBar(selectedIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final int dayNumber;
  final String title;
  final bool completed;
  final List<_Task> tasks;
  final String? parentTip;

  const _DayCard({
    required this.dayNumber,
    required this.title,
    required this.completed,
    required this.tasks,
    this.parentTip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: completed
            ? Border.all(color: kPrimary.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: completed ? kPrimary : const Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: completed
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          '$dayNumber',
                          style: const TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF666666),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $dayNumber',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12,
                      color: completed ? kPrimary : const Color(0xFF999999),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tasks
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: t.done ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: t.done ? kPrimary : const Color(0xFFCCCCCC),
                          width: 1.5,
                        ),
                      ),
                      child: t.done
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.text,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14,
                          color: t.done ? const Color(0xFF999999) : null,
                          decoration: t.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          // Parent tip
          if (parentTip != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFFFFA726)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      parentTip!,
                      style: const TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Task {
  final String text;
  final bool done;

  const _Task(this.text, this.done);
}
