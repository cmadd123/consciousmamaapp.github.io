import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'skill_preview_data.dart';
import 'skill_detail_preview_widget.dart';

class SkillsHomePreviewWidget extends StatefulWidget {
  const SkillsHomePreviewWidget({super.key});

  @override
  State<SkillsHomePreviewWidget> createState() =>
      _SkillsHomePreviewWidgetState();
}

class _SkillsHomePreviewWidgetState extends State<SkillsHomePreviewWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final skills = SkillPreviewData.allSkills;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAF7F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            shadowColor: Colors.transparent,
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🎨',
                          style: TextStyle(fontSize: 48.0),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Skills & Hobbies',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF5D4E60),
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        // Preview badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: const Color(0xFF6EC6CA),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            '✨ Preview Feature',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xFF6EC6CA),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Skills Grid
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 14.0,
                mainAxisSpacing: 14.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final skill = skills[index];
                  final isActive = (skill['progress_percentage'] as double) > 0;

                  final isWoodworking = skill['skill_name'] == 'Woodworking';

                  return InkWell(
                    onTap: () {
                      if (isWoodworking) {
                        // Navigate to Woodworking detail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SkillDetailPreviewWidget(),
                          ),
                        );
                      } else {
                        // Show coming soon dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Text(skill['skill_icon'] as String, style: TextStyle(fontSize: 24.0)),
                                SizedBox(width: 12.0),
                                Text(
                                  skill['skill_name'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              'This skill is coming soon! We\'re currently finalizing the milestone content.',
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                fontSize: 15.0,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Got it',
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xFF6EC6CA),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFF6EC6CA),
                                width: 2.0,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Skill icon with optional progress ring
                          if (isActive)
                            SizedBox(
                              width: 80.0,
                              height: 80.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Progress ring
                                  CircularPercentIndicator(
                                    percent: (skill['progress_percentage'] as double) / 100,
                                    radius: 40.0,
                                    lineWidth: 6.0,
                                    animation: false,
                                    progressColor: const Color(0xFF6EC6CA),
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    center: Container(
                                      width: 64.0,
                                      height: 64.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          skill['skill_icon'] as String,
                                          style: const TextStyle(fontSize: 32.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF7F5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  skill['skill_icon'] as String,
                                  style: const TextStyle(fontSize: 36.0),
                                ),
                              ),
                            ),
                          const SizedBox(height: 14.0),
                          // Skill name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              skill['skill_name'] as String,
                              style: const TextStyle(
                                fontFamily: 'Andika New Basic',
                                color: Color(0xFF5D4E60),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          // Progress text or "Start" button
                          if (isActive)
                            Text(
                              '${skill['completed_milestones']} / ${skill['total_milestones']} milestones',
                              style: const TextStyle(
                                fontFamily: 'Andika New Basic',
                                color: Color(0xFF9B8A9E),
                                fontSize: 12.0,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFB4B4),
                                    Color(0xFFFFD4D4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: const Text(
                                'Start',
                                style: TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: skills.length,
              ),
            ),
          ),
          // Bottom info card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5F3),
                      Color(0xFFFFF0EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '💡',
                          style: TextStyle(fontSize: 24.0),
                        ),
                        const SizedBox(width: 10.0),
                        const Text(
                          'About Skills & Hobbies',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF5D4E60),
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Guide your kids through meaningful hobbies that build real, transferable skills. Each skill has 15 progressive milestones—from beginner basics all the way to advanced techniques and even turning skills into income.\n\n🔨 Woodworking is fully available to preview. Other skills coming soon!',
                      style: TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Color(0xFF5D4E60),
                        fontSize: 14.0,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF6EC6CA),
                            size: 20.0,
                          ),
                          const SizedBox(width: 10.0),
                          const Expanded(
                            child: Text(
                              'No age restrictions—you decide when they\'re ready',
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                color: Color(0xFF5D4E60),
                                fontSize: 13.0,
                              ),
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
        ],
      ),
    );
  }
}
