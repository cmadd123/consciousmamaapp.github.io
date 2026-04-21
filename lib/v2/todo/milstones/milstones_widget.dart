import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/v2/learning_path/create_learning_path_bottom_sheet/create_learning_path_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '/components/page_animations.dart';
import '/components/animated_press_widget.dart';
import 'milstones_model.dart';
export 'milstones_model.dart';

class MilstonesWidget extends StatefulWidget {
  const MilstonesWidget({super.key});

  static String routeName = 'milstones';
  static String routePath = '/milstones';

  @override
  State<MilstonesWidget> createState() => _MilstonesWidgetState();
}

class _MilstonesWidgetState extends State<MilstonesWidget> {
  late MilstonesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Data
  ChildernRecord? _selectedChild;
  List<ChildernRecord> _allChildren = [];
  List<SaticMilestonesRecord> _milestones = [];
  List<ChildrenAccomlishedMilestonesRecord> _accomplished = [];
  bool _isLoading = true;
  String? _error;
  double _childAge = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MilstonesModel());
    _loadData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var selectedChildRef = FFAppState().selectedChildForMilestone;

      // Auto-select first child if none selected
      if (selectedChildRef == null) {
        final childrenQuery = await FirebaseFirestore.instance
            .collection('childern')
            .where('userRef', isEqualTo: currentUserReference)
            .limit(1)
            .get();
        if (childrenQuery.docs.isEmpty) {
          setState(() {
            _isLoading = false;
            _error = 'No children added yet';
          });
          return;
        }
        selectedChildRef = childrenQuery.docs.first.reference;
        FFAppState().selectedChildForMilestone = selectedChildRef;
      }

      // Load the selected child
      final childDoc = await selectedChildRef.get();
      if (!childDoc.exists) {
        setState(() {
          _isLoading = false;
          _error = 'Child not found';
        });
        return;
      }

      _selectedChild = ChildernRecord.fromSnapshot(childDoc);

      if (_selectedChild?.birthDay == null) {
        setState(() {
          _isLoading = false;
          _error = 'Child birthday not set';
        });
        return;
      }

      _childAge = functions.newCobverBirthdayToAGe(_selectedChild!.birthDay!);

      // Load all children for the user
      final childrenQuery = await FirebaseFirestore.instance
          .collection('childern')
          .where('userRef', isEqualTo: currentUserReference)
          .get();
      _allChildren = childrenQuery.docs
          .map((doc) => ChildernRecord.fromSnapshot(doc))
          .toList()
        ..sort((a, b) {
          if (a.birthDay == null && b.birthDay == null) return 0;
          if (a.birthDay == null) return 1;
          if (b.birthDay == null) return -1;
          return a.birthDay!.compareTo(b.birthDay!);
        });

      // Load milestones for this age from Static_Milestones
      final milestonesQuery = await FirebaseFirestore.instance
          .collection('Static_Milestones')
          .where('age', isEqualTo: _childAge)
          .get();
      _milestones = milestonesQuery.docs
          .map((doc) => SaticMilestonesRecord.fromSnapshot(doc))
          .toList();

      // Load accomplished milestones
      final accomplishedQuery = await FirebaseFirestore.instance
          .collection('children_accomlished_milestones')
          .where('child', isEqualTo: _selectedChild!.reference)
          .where('age', isEqualTo: _childAge)
          .get();
      _accomplished = accomplishedQuery.docs
          .map((doc) => ChildrenAccomlishedMilestonesRecord.fromSnapshot(doc))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading data: $e';
      });
    }
  }

  Future<void> _toggleMilestoneCompletion({
    required DocumentReference milestoneRef,
    required String category,
    required bool currentlyCompleted,
  }) async {
    if (_selectedChild == null) return;

    try {
      if (currentlyCompleted) {
        // Find and delete the accomplishment record
        final querySnapshot = await FirebaseFirestore.instance
            .collection('children_accomlished_milestones')
            .where('child', isEqualTo: _selectedChild!.reference)
            .where('milestone', isEqualTo: milestoneRef)
            .get();

        for (final doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        // Create new accomplishment record
        await FirebaseFirestore.instance
            .collection('children_accomlished_milestones')
            .add({
          'child': _selectedChild!.reference,
          'milestone': milestoneRef,
          'category': category,
          'age': _childAge,
        });
      }

      // Reload accomplished milestones
      final accomplishedQuery = await FirebaseFirestore.instance
          .collection('children_accomlished_milestones')
          .where('child', isEqualTo: _selectedChild!.reference)
          .where('age', isEqualTo: _childAge)
          .get();

      setState(() {
        _accomplished = accomplishedQuery.docs
            .map((doc) => ChildrenAccomlishedMilestonesRecord.fromSnapshot(doc))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _selectChild(ChildernRecord child) {
    FFAppState().selectedChildForMilestone = child.reference;
    _loadData();
  }

  bool _isMilestoneCompleted(DocumentReference milestoneRef) {
    return _accomplished.any((a) => a.milestone?.id == milestoneRef.id);
  }

  void _openLearningPathCreation(String milestoneTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateLearningPathBottomSheet(
        initialChallenge: milestoneTitle,
      ),
    );
  }

  List<SaticMilestonesRecord> _getMilestonesForCategory(ActGoalMilestones category) {
    return _milestones.where((m) => m.actGoal == category).toList();
  }

  int _getAccomplishedCountForCategory(ActGoalMilestones category) {
    final categoryMilestones = _getMilestonesForCategory(category);
    return categoryMilestones.where((m) => _isMilestoneCompleted(m.reference)).length;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          child: Stack(
            children: [
              if (_isLoading)
                Center(child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: BouncingDots(color: FlutterFlowTheme.of(context).primary, size: 10.0),
                ))
              else if (_error != null)
                _buildErrorState()
              else
                _buildContent(),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(currentPage: HomeNavPage.home),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: FlutterFlowTheme.of(context).secondaryText),
          const SizedBox(height: 16),
          Text(_error!, style: FlutterFlowTheme.of(context).bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.goNamed('HomeHybrid'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
            ),
            child: const Text('Go to Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            CascadeItem(
              index: 0,
              baseDelayMs: 200,
              staggerMs: 150,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Milestones',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Child selector
            CascadeItem(
              index: 1,
              baseDelayMs: 200,
              staggerMs: 150,
              child: _buildChildSelector(),
            ),
            const SizedBox(height: 24),

            // Progress summary
            CascadeItem(
              index: 2,
              baseDelayMs: 200,
              staggerMs: 150,
              child: _buildProgressSummary(),
            ),
            const SizedBox(height: 32),

            // Category sections
            _buildCategorySection(
              title: 'Physical Milestones',
              icon: Icons.directions_run,
              color: const Color(0xFF4CAF50),
              category: ActGoalMilestones.Physical,
              cascadeBaseDelay: 650,
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              title: 'Cognitive Milestones',
              icon: Icons.psychology,
              color: const Color(0xFF64B5F6),
              category: ActGoalMilestones.Cognitive,
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              title: 'Self-care Milestones',
              icon: Icons.self_improvement,
              color: const Color(0xFFEE8B60),
              category: ActGoalMilestones.Selfcare,
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              title: 'Communication Milestones',
              icon: Icons.record_voice_over,
              color: const Color(0xFF52A097),
              category: ActGoalMilestones.Communication,
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              title: 'Social/Emotional Milestones',
              icon: Icons.favorite,
              color: const Color(0xFFE57373),
              category: ActGoalMilestones.SocialEmotional,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _allChildren.map((child) {
          final isSelected = child.reference.id == _selectedChild?.reference.id;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _selectChild(child),
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0x1D52A097) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).alternate,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          child.name.isNotEmpty ? child.name[0].toLowerCase() : 'c',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      child.name,
                      style: FlutterFlowTheme.of(context).bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final totalMilestones = _milestones.length;
    final completedMilestones = _accomplished.length;
    final progress = totalMilestones > 0 ? completedMilestones / totalMilestones : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Track ${_selectedChild?.name ?? 'your child'}'s developmental milestones.",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: const Color(0xC2000000),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap a milestone to turn it into a learning path.',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: 40,
              lineWidth: 10,
              percent: progress.clamp(0.0, 1.0),
              animation: true,
              progressColor: FlutterFlowTheme.of(context).primary,
              backgroundColor: const Color(0x6552A097),
              center: Text(
                '${(progress * 100).toInt()}%',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection({
    required String title,
    required IconData icon,
    required Color color,
    required ActGoalMilestones category,
    int? cascadeBaseDelay,
  }) {
    final categoryMilestones = _getMilestonesForCategory(category);
    final accomplishedCount = _getAccomplishedCountForCategory(category);
    final total = categoryMilestones.length;
    final progress = total > 0 ? accomplishedCount / total : 0.0;
    final animate = cascadeBaseDelay != null;

    Widget maybeAnimate(int index, Widget child) {
      if (!animate) return child;
      return CascadeItem(index: index, baseDelayMs: cascadeBaseDelay, staggerMs: 100, child: child);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Header
          maybeAnimate(0, Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
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
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$accomplishedCount of $total completed',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),

          // Progress bar
          maybeAnimate(1, Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearPercentIndicator(
              percent: progress.clamp(0.0, 1.0),
              lineHeight: 8,
              animation: true,
              progressColor: color,
              backgroundColor: color.withOpacity(0.2),
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
            ),
          )),
          const SizedBox(height: 12),

          // Milestones list
          if (categoryMilestones.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No milestones for this category at age ${_childAge.toInt()}',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: categoryMilestones.length,
              itemBuilder: (context, index) {
                final milestone = categoryMilestones[index];
                final isCompleted = _isMilestoneCompleted(milestone.reference);

                return maybeAnimate(2 + index, Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _openLearningPathCreation(milestone.title),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleMilestoneCompletion(
                              milestoneRef: milestone.reference,
                              category: milestone.category,
                              currentlyCompleted: isCompleted,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              milestone.title,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted
                                    ? FlutterFlowTheme.of(context).secondaryText
                                    : FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: color.withOpacity(0.6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
              },
            ),
        ],
      ),
    );
  }
}
