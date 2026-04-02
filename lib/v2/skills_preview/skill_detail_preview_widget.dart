import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/home_nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillDetailPreviewWidget extends StatefulWidget {
  const SkillDetailPreviewWidget({
    super.key,
    required this.skillPathRef,
  });

  final DocumentReference skillPathRef;

  @override
  State<SkillDetailPreviewWidget> createState() =>
      _SkillDetailPreviewWidgetState();
}

class _SkillDetailPreviewWidgetState extends State<SkillDetailPreviewWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int? expandedMilestoneIndex;

  Future<void> _toggleSubMilestone(
    SkillPathRecord skillPath,
    int milestoneIndex,
    int subMilestoneIndex,
  ) async {
    try {
      // Get current milestone
      final milestones = List<SkillMilestoneStruct>.from(skillPath.milestones);
      final milestone = milestones[milestoneIndex];

      // Get current sub-milestone
      final subMilestones = List<SkillSubMilestoneStruct>.from(milestone.subMilestones);
      final subMilestone = subMilestones[subMilestoneIndex];

      // Toggle completion
      final newCompleted = !subMilestone.completed;
      subMilestones[subMilestoneIndex] = SkillSubMilestoneStruct(
        title: subMilestone.title,
        videoSearch: subMilestone.videoSearch,
        completed: newCompleted,
        completedDate: newCompleted ? DateTime.now() : null,
      );

      // Check if all sub-milestones are now complete
      final allSubsComplete = subMilestones.every((s) => s.completed);

      // Update milestone
      milestones[milestoneIndex] = SkillMilestoneStruct(
        number: milestone.number,
        title: milestone.title,
        completed: allSubsComplete,
        completedDate: allSubsComplete ? DateTime.now() : null,
        subMilestones: subMilestones,
      );

      // Calculate new progress
      final completedMilestones = milestones.where((m) => m.completed).length;
      final totalSubMilestones = milestones.fold<int>(
        0,
        (sum, m) => sum + m.subMilestones.length,
      );
      final completedSubMilestones = milestones.fold<int>(
        0,
        (sum, m) => sum + m.subMilestones.where((s) => s.completed).length,
      );
      final progressPercentage = totalSubMilestones > 0
          ? (completedSubMilestones / totalSubMilestones) * 100
          : 0.0;

      // Update Firestore
      await widget.skillPathRef.update({
        'milestones': milestones.map((m) => m.toMap()).toList(),
        'completed_milestones': completedMilestones,
        'completed_sub_milestones': completedSubMilestones,
        'progress_percentage': progressPercentage,
        'last_updated': FieldValue.serverTimestamp(),
      });

      // Show celebration if milestone just completed
      if (allSubsComplete && !milestone.completed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Milestone ${milestone.number} complete!'),
            backgroundColor: const Color(0xFF6EC6CA),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error toggling sub-milestone: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating progress. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SkillPathRecord>(
      stream: SkillPathRecord.getDocument(widget.skillPathRef),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAF7F5),
            body: const Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B8A9E)),
                ),
              ),
            ),
          );
        }

        final skillPath = snapshot.data!;
        final milestones = skillPath.milestones;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFFAF7F5),
          body: CustomScrollView(
            slivers: [
              // App Bar with gradient
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD7F2EB), // Teal
                          Color(0xFFFFE9E1), // Pink
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40.0),
                          // Skill icon in circle
                          Container(
                            width: 80.0,
                            height: 80.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                skillPath.skillIcon,
                                style: const TextStyle(fontSize: 40.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            skillPath.skillName,
                            style: const TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xFF5D4E60),
                              fontSize: 28.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Progress card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Circular progress
                        CircularPercentIndicator(
                          percent: skillPath.progressPercentage / 100,
                          radius: 50.0,
                          lineWidth: 8.0,
                          animation: true,
                          animateFromLastPercent: true,
                          progressColor: const Color(0xFF6EC6CA), // Teal
                          backgroundColor: const Color(0xFFF5F5F5),
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Text(
                            '${skillPath.progressPercentage.toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xFF5D4E60),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24.0),
                        // Progress text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${skillPath.completedMilestones} of ${skillPath.totalMilestones} Milestones',
                                style: const TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  color: Color(0xFF5D4E60),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${skillPath.completedSubMilestones} of ${skillPath.totalSubMilestones} steps complete',
                                style: const TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  color: Color(0xFF9B8A9E),
                                  fontSize: 13.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Milestones list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final milestone = milestones[index];
                      final subMilestones = milestone.subMilestones;
                      final isCompleted = milestone.completed;
                      final isExpanded = expandedMilestoneIndex == index;
                      final completedCount = subMilestones.where((s) => s.completed).length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: isCompleted
                                ? Border.all(color: const Color(0xFF6EC6CA), width: 2.0)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    expandedMilestoneIndex = isExpanded ? null : index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Number circle
                                      Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          gradient: isCompleted
                                              ? const LinearGradient(
                                                  colors: [Color(0xFF6EC6CA), Color(0xFF4FA8AC)],
                                                )
                                              : null,
                                          color: isCompleted ? null : const Color(0xFFF5F5F5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: isCompleted
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                )
                                              : Text(
                                                  '${milestone.number}',
                                                  style: const TextStyle(
                                                    fontFamily: 'Andika New Basic',
                                                    color: Color(0xFF9B8A9E),
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      // Title and progress
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              milestone.title,
                                              style: TextStyle(
                                                fontFamily: 'Andika New Basic',
                                                color: const Color(0xFF5D4E60),
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w600,
                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                decorationColor: const Color(0xFF9B8A9E),
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              '$completedCount of ${subMilestones.length} steps',
                                              style: const TextStyle(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xFF9B8A9E),
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Expand icon
                                      Icon(
                                        isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                        color: const Color(0xFF9B8A9E),
                                        size: 24.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Expanded content
                              if (isExpanded)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                                  child: Column(
                                    children: subMilestones.asMap().entries.map((entry) {
                                      final subIndex = entry.key;
                                      final subMilestone = entry.value;
                                      final subCompleted = subMilestone.completed;

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: InkWell(
                                          onTap: () => _toggleSubMilestone(skillPath, index, subIndex),
                                          borderRadius: BorderRadius.circular(14.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(14.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFAF7F5),
                                              borderRadius: BorderRadius.circular(14.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Custom checkbox
                                                Container(
                                                  width: 22.0,
                                                  height: 22.0,
                                                  margin: const EdgeInsets.only(top: 2.0),
                                                  decoration: BoxDecoration(
                                                    color: subCompleted ? const Color(0xFF6EC6CA) : Colors.white,
                                                    borderRadius: BorderRadius.circular(6.0),
                                                    border: Border.all(
                                                      color: subCompleted ? const Color(0xFF6EC6CA) : const Color(0xFFD0D0D0),
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: subCompleted
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 14.0,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Text(
                                                    subMilestone.title,
                                                    style: TextStyle(
                                                      fontFamily: 'Andika New Basic',
                                                      color: const Color(0xFF5D4E60),
                                                      fontSize: 14.0,
                                                      height: 1.4,
                                                      decoration: subCompleted ? TextDecoration.lineThrough : null,
                                                      decorationColor: const Color(0xFF9B8A9E),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: milestones.length,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.home),
        );
      },
    );
  }
}
