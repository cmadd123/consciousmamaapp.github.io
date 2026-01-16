import 'dart:math' as math;
import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/custom_functions.dart' as functions;

/// Data class for milestone category info
class MilestoneCategory {
  final ActGoalMilestones category;
  final String label;
  final IconData icon;
  final Color color;

  const MilestoneCategory({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });

  static List<MilestoneCategory> get all => const [
        MilestoneCategory(
          category: ActGoalMilestones.Physical,
          label: 'Physical',
          icon: Icons.directions_run,
          color: Color(0xFFFF7043),
        ),
        MilestoneCategory(
          category: ActGoalMilestones.Communication,
          label: 'Speech',
          icon: Icons.record_voice_over,
          color: Color(0xFF42A5F5),
        ),
        MilestoneCategory(
          category: ActGoalMilestones.Cognitive,
          label: 'Cognitive',
          icon: Icons.psychology,
          color: Color(0xFFAB47BC),
        ),
        MilestoneCategory(
          category: ActGoalMilestones.SocialEmotional,
          label: 'Social',
          icon: Icons.favorite,
          color: Color(0xFFEC407A),
        ),
        MilestoneCategory(
          category: ActGoalMilestones.Selfcare,
          label: 'Self-care',
          icon: Icons.self_improvement,
          color: Color(0xFF66BB6A),
        ),
      ];
}

/// A widget that displays milestone progress for all categories in a horizontal row.
/// Each category shows a circular icon with a progress ring around it.
class MilestoneCategoryProgressWidget extends StatelessWidget {
  final DocumentReference childRef;
  final DateTime childBirthday;
  final VoidCallback? onTap;

  const MilestoneCategoryProgressWidget({
    super.key,
    required this.childRef,
    required this.childBirthday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final childAge = functions.newCobverBirthdayToAGe(childBirthday);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Milestones',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    Text(
                      'View All',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Category progress row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MilestoneCategory.all.map((cat) {
                return _CategoryProgressItem(
                  category: cat,
                  childRef: childRef,
                  childAge: childAge,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProgressItem extends StatelessWidget {
  final MilestoneCategory category;
  final DocumentReference childRef;
  final double childAge;

  const _CategoryProgressItem({
    required this.category,
    required this.childRef,
    required this.childAge,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SaticMilestonesRecord>>(
      stream: querySaticMilestonesRecord(
        queryBuilder: (q) => q
            .where('age', isEqualTo: childAge)
            .where('act_goal', isEqualTo: category.category.serialize()),
      ),
      builder: (context, totalSnapshot) {
        if (!totalSnapshot.hasData) {
          return _buildPlaceholder(context);
        }

        final totalMilestones = totalSnapshot.data!;
        if (totalMilestones.isEmpty) {
          return _buildPlaceholder(context);
        }

        return StreamBuilder<List<ChildrenAccomlishedMilestonesRecord>>(
          stream: queryChildrenAccomlishedMilestonesRecord(
            queryBuilder: (q) => q
                .where('child', isEqualTo: childRef)
                .where('age', isEqualTo: childAge)
                .where('category', isEqualTo: category.category.serialize()),
          ),
          builder: (context, completedSnapshot) {
            final completed = completedSnapshot.data?.length ?? 0;
            final total = totalMilestones.length;
            final progress = total > 0 ? completed / total : 0.0;

            return _buildCategoryWidget(context, completed, total, progress);
          },
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return _buildCategoryWidget(context, 0, 0, 0.0);
  }

  Widget _buildCategoryWidget(
    BuildContext context,
    int completed,
    int total,
    double progress,
  ) {
    const double size = 50.0;
    const double strokeWidth = 3.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: size - strokeWidth,
                height: size - strokeWidth,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 22,
                  color: category.color,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: const Size(50.0, 50.0),
                painter: _CircularProgressPainter(
                  progress: progress,
                  color: category.color,
                  backgroundColor: category.color.withValues(alpha: 0.2),
                  strokeWidth: strokeWidth,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          total > 0 ? '$completed/$total' : '-',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 11,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      ],
    );
  }
}

/// Custom painter for the circular progress ring
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
