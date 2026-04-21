import 'package:flutter/material.dart';
import 'demo_data.dart';

/// Screenshot shell for the Milestones screen.
/// White background with child selector and categorized milestone checklist.
class ScreenshotMilestones extends StatelessWidget {
  const ScreenshotMilestones({super.key});

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
                    // Header
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Text(
                        'Milestones',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Child selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _ChildChip(child: demoChildren[0], selected: true),
                          const SizedBox(width: 16),
                          _ChildChip(child: demoChildren[1], selected: false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Track Emma's developmental milestones.",
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          // Progress circle
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: kPrimary.withValues(alpha: 0.3), width: 4),
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      value: 0.42,
                                      strokeWidth: 5,
                                      backgroundColor: kPrimary.withValues(alpha: 0.15),
                                      valueColor: const AlwaysStoppedAnimation(kPrimary),
                                    ),
                                  ),
                                  const Text(
                                    '42%',
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    const _CategorySection(
                      title: 'Physical',
                      icon: Icons.directions_run,
                      color: Color(0xFF4CAF50),
                      progress: 0.6,
                      completed: 3,
                      total: 5,
                      milestones: [
                        DemoMilestone(title: 'Walks without support', completed: true),
                        DemoMilestone(title: 'Kicks a ball forward', completed: true),
                        DemoMilestone(title: 'Runs with coordination', completed: true),
                        DemoMilestone(title: 'Climbs stairs with alternating feet'),
                        DemoMilestone(title: 'Pedals a tricycle'),
                      ],
                    ),

                    const _CategorySection(
                      title: 'Cognitive',
                      icon: Icons.psychology,
                      color: Color(0xFF64B5F6),
                      progress: 0.4,
                      completed: 2,
                      total: 5,
                      milestones: [
                        DemoMilestone(title: 'Sorts shapes and colors', completed: true),
                        DemoMilestone(title: 'Follows two-step instructions', completed: true),
                        DemoMilestone(title: 'Names familiar objects'),
                        DemoMilestone(title: 'Completes simple puzzles'),
                        DemoMilestone(title: 'Understands "same" and "different"'),
                      ],
                    ),

                    const _CategorySection(
                      title: 'Communication',
                      icon: Icons.chat_bubble_outline,
                      color: kPrimary,
                      progress: 0.4,
                      completed: 2,
                      total: 5,
                      milestones: [
                        DemoMilestone(title: 'Says 50+ words', completed: true),
                        DemoMilestone(title: 'Uses 2-word phrases', completed: true),
                        DemoMilestone(title: 'Asks "what" and "where" questions'),
                        DemoMilestone(title: 'Strangers understand most speech'),
                        DemoMilestone(title: 'Uses pronouns (I, me, you)'),
                      ],
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
    );
  }
}

class _ChildChip extends StatelessWidget {
  final DemoChild child;
  final bool selected;

  const _ChildChip({required this.child, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? kPrimary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? kPrimary : const Color(0xFFCCCCCC),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: child.color,
            child: Text(
              child.initial,
              style: const TextStyle(
                fontFamily: kFontFamily,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            child.name,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? kPrimary : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double progress;
  final int completed;
  final int total;
  final List<DemoMilestone> milestones;

  const _CategorySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.progress,
    required this.completed,
    required this.total,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$completed of $total completed',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),

          const SizedBox(height: 12),

          // Milestone items
          ...milestones.map((m) => _MilestoneItem(milestone: m, color: color)),
        ],
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final DemoMilestone milestone;
  final Color color;

  const _MilestoneItem({required this.milestone, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: milestone.completed ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: milestone.completed ? color : const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            child: milestone.completed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              milestone.title,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14,
                decoration: milestone.completed ? TextDecoration.lineThrough : null,
                color: milestone.completed ? const Color(0xFF999999) : null,
              ),
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: color.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
