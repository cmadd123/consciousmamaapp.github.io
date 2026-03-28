import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'skill_preview_data.dart';
import 'dart:math' as math;

class SkillDetailPreviewWidget extends StatefulWidget {
  const SkillDetailPreviewWidget({super.key});

  @override
  State<SkillDetailPreviewWidget> createState() =>
      _SkillDetailPreviewWidgetState();
}

class _SkillDetailPreviewWidgetState extends State<SkillDetailPreviewWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int? expandedMilestoneIndex;

  @override
  Widget build(BuildContext context) {
    final skillData = SkillPreviewData.woodworkingSkill;
    final milestones = skillData['milestones'] as List;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAF7F5), // Warm background like rest of app
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFD7F2EB), // Teal
                      const Color(0xFFFFE9E1), // Pink
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            skillData['skill_icon'] as String,
                            style: const TextStyle(fontSize: 40.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        skillData['skill_name'] as String,
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular progress
                    CircularPercentIndicator(
                      percent: (skillData['progress_percentage'] as double) / 100,
                      radius: 50.0,
                      lineWidth: 8.0,
                      animation: true,
                      animateFromLastPercent: true,
                      progressColor: const Color(0xFF6EC6CA), // Teal
                      backgroundColor: const Color(0xFFF5F5F5),
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Text(
                        '${(skillData['progress_percentage'] as double).toInt()}%',
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
                            '${skillData['completed_milestones']} of ${skillData['total_milestones']} Milestones',
                            style: const TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xFF5D4E60),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${skillData['completed_sub_milestones']} of ${skillData['total_sub_milestones']} steps complete',
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
                  final milestone = milestones[index] as Map;
                  final subMilestones = milestone['sub_milestones'] as List<Map>;
                  final isCompleted = milestone['completed'] as bool;
                  final isExpanded = expandedMilestoneIndex == index;
                  final completedCount = subMilestones.where((s) => s['completed'] == true).length;

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
                            color: Colors.black.withOpacity(0.04),
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
                                              '${milestone['number']}',
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
                                          milestone['title'] as String,
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
                                children: subMilestones.map((subMilestone) {
                                  final subCompleted = subMilestone['completed'] as bool;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(14.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF7F5),
                                        borderRadius: BorderRadius.circular(14.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
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
                                                  subMilestone['title'] as String,
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
                                          const SizedBox(height: 10.0),
                                          // Watch video button
                                          InkWell(
                                            onTap: () async {
                                              final searchQuery = subMilestone['video_search'] as String;
                                              final url = 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(searchQuery)}';
                                              if (await canLaunchUrl(Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFFF9E9E), Color(0xFFFFD4D4)],
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.play_circle_outline_rounded,
                                                    color: Colors.white,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  const Text(
                                                    'Watch Video',
                                                    style: TextStyle(
                                                      fontFamily: 'Andika New Basic',
                                                      color: Colors.white,
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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
    );
  }
}
