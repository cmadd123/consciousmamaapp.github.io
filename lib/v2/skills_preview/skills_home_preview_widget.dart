import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'skill_preview_data.dart';
import 'skill_detail_preview_widget.dart';
import 'create_skill_path_preview_widget.dart';

class SkillsHomePreviewWidget extends StatefulWidget {
  const SkillsHomePreviewWidget({super.key});

  @override
  State<SkillsHomePreviewWidget> createState() =>
      _SkillsHomePreviewWidgetState();
}

class _SkillsHomePreviewWidgetState extends State<SkillsHomePreviewWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // PREVIEW MODE: Set to false to use real Firestore data
  final bool _usePreviewData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAF7F5),
      body: _usePreviewData
          ? _buildPreviewContent(context)
          : StreamBuilder<List<SkillPathRecord>>(
              stream: querySkillPathRecord(
                queryBuilder: (skillPathRecord) => skillPathRecord
                    .where('user_ref', isEqualTo: currentUserReference)
                    .orderBy('last_updated', descending: true),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B8A9E)),
                      ),
                    ),
                  );
                }

                final skillPaths = snapshot.data!;
                return _buildContent(context, skillPaths);
              },
            ),
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    // Preview data - Woodworking skill
    final previewSkillPaths = [
      _PreviewSkillPath(
        skillName: 'Woodworking',
        skillIcon: '🔨',
        progressPercentage: 13.33,
        completedMilestones: 2,
        totalMilestones: 15,
      ),
    ];

    return _buildContentFromPreview(context, previewSkillPaths);
  }

  Widget _buildContentFromPreview(BuildContext context, List<_PreviewSkillPath> previewPaths) {
    return CustomScrollView(
        slivers: [
          _buildHeader(context),
          _buildCreateButton(context),
          if (previewPaths.isEmpty)
            _buildEmptyState()
          else
            _buildSkillGrid(context, previewPaths: previewPaths),
        ],
      );
  }

  Widget _buildContent(BuildContext context, List<SkillPathRecord> skillPaths) {
    return CustomScrollView(
        slivers: [
          _buildHeader(context),
          _buildCreateButton(context),
          if (skillPaths.isEmpty)
            _buildEmptyState()
          else
            _buildSkillGrid(context, skillPaths: skillPaths),
        ],
      );
  }


  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
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
                    style: TextStyle(fontSize: 32.0),
                  ),
                  const SizedBox(height: 2.0),
                  const Text(
                    'Skills & Hobbies',
                    style: TextStyle(
                      fontFamily: 'Andika New Basic',
                      color: Color(0xFF5D4E60),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFF6EC6CA),
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      '✨ Preview',
                      style: TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Color(0xFF6EC6CA),
                        fontSize: 10.0,
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
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateSkillPathPreviewWidget(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6EC6CA),
                  Color(0xFF81D4D9),
                ],
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6EC6CA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 32.0,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Skill Path',
                        style: TextStyle(
                          fontFamily: 'Andika New Basic',
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'AI-generated curriculum from expert sources',
                        style: TextStyle(
                          fontFamily: 'Andika New Basic',
                          color: Colors.white,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '🚀',
              style: TextStyle(fontSize: 64.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'No Skill Paths Yet',
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: Color(0xFF5D4E60),
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            Text(
              'Tap the button above to create your first AI-generated skill path!',
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: Color(0xFF9B8A9E),
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillGrid(BuildContext context, {List<SkillPathRecord>? skillPaths, List<_PreviewSkillPath>? previewPaths}) {
    final count = skillPaths?.length ?? previewPaths?.length ?? 0;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final String skillName;
            final String skillIcon;
            final double progressPercent;
            final int completedMilestones;
            final int totalMilestones;

            if (skillPaths != null) {
              final skillPath = skillPaths[index];
              skillName = skillPath.skillName;
              skillIcon = skillPath.skillIcon;
              progressPercent = skillPath.progressPercentage / 100;
              completedMilestones = skillPath.completedMilestones;
              totalMilestones = skillPath.totalMilestones;
            } else {
              final previewPath = previewPaths![index];
              skillName = previewPath.skillName;
              skillIcon = previewPath.skillIcon;
              progressPercent = previewPath.progressPercentage / 100;
              completedMilestones = previewPath.completedMilestones;
              totalMilestones = previewPath.totalMilestones;
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SkillDetailPreviewWidget(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color(0xFF9B8A9E),
                    width: 2.0,
                  ),
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
                    SizedBox(
                      width: 64.0,
                      height: 64.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularPercentIndicator(
                            percent: progressPercent,
                            radius: 32.0,
                            lineWidth: 5.0,
                            animation: false,
                            progressColor: const Color(0xFF9B8A9E),
                            backgroundColor: const Color(0xFFF5F5F5),
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Container(
                              width: 52.0,
                              height: 52.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  skillIcon,
                                  style: const TextStyle(fontSize: 26.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        skillName,
                        style: const TextStyle(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF5D4E60),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      '$completedMilestones / $totalMilestones milestones',
                      style: const TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Color(0xFF9B8A9E),
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: count,
        ),
      ),
    );
  }
}

// Preview helper class
class _PreviewSkillPath {
  final String skillName;
  final String skillIcon;
  final double progressPercentage;
  final int completedMilestones;
  final int totalMilestones;

  _PreviewSkillPath({
    required this.skillName,
    required this.skillIcon,
    required this.progressPercentage,
    required this.completedMilestones,
    required this.totalMilestones,
  });
}
