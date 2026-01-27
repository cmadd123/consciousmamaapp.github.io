import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/compele_taskpopup/compele_taskpopup_widget.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'learn_path_detials_model.dart';
export 'learn_path_detials_model.dart';

class LearnPathDetialsWidget extends StatefulWidget {
  const LearnPathDetialsWidget({
    super.key,
    required this.leRef,
  });

  final DocumentReference? leRef;

  static String routeName = 'learnPathDetials';
  static String routePath = '/learnPathDetials';

  @override
  State<LearnPathDetialsWidget> createState() => _LearnPathDetialsWidgetState();
}

class _LearnPathDetialsWidgetState extends State<LearnPathDetialsWidget>
    with TickerProviderStateMixin {
  late LearnPathDetialsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Completion celebration state
  bool _showCelebration = false;
  bool _hasShownCelebration = false;
  int? _previousCompletedCount; // Track previous count to detect transition to complete
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LearnPathDetialsModel());

    // Setup celebration animations
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _confettiController.dispose();
    _model.dispose();

    super.dispose();
  }

  void _triggerCelebration() {
    if (!_hasShownCelebration) {
      _hasShownCelebration = true;
      setState(() => _showCelebration = true);
      _celebrationController.forward();
      _confettiController.repeat();

      // Auto-dismiss after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _dismissCelebration();
        }
      });
    }
  }

  void _dismissCelebration() {
    _celebrationController.reverse().then((_) {
      if (mounted) {
        setState(() => _showCelebration = false);
        _confettiController.stop();
      }
    });
  }

  // Show edit learning path dialog
  void _showEditLearningPathDialog(BuildContext context, LearningPathRecord learningPath) {
    final titleController = TextEditingController(text: learningPath.title);
    final descriptionController = TextEditingController(text: learningPath.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Edit Learning Path',
          style: FlutterFlowTheme.of(context).titleMedium.override(
            fontFamily: 'Andika New Basic',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Update the learning path
              await learningPath.reference.update({
                'title': titleController.text,
                'description': descriptionController.text,
              });
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Learning path updated'),
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                  ),
                );
              }
            },
            child: Text(
              'Save',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: FlutterFlowTheme.of(context).primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the celebration overlay
  Widget _buildCelebrationOverlay(BuildContext context) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Semi-transparent backdrop
            GestureDetector(
              onTap: _dismissCelebration,
              child: Container(
                color: Colors.black.withOpacity(_fadeAnimation.value * 0.6),
              ),
            ),
            // Animated confetti particles
            ...List.generate(20, (index) {
              final random = index * 0.05;
              return AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  final progress = (_confettiController.value + random) % 1.0;
                  final xOffset = (index % 5 - 2) * 80.0 + (progress * 50 * (index % 2 == 0 ? 1 : -1));
                  return Positioned(
                    top: progress * MediaQuery.of(context).size.height,
                    left: MediaQuery.of(context).size.width / 2 + xOffset,
                    child: Transform.rotate(
                      angle: progress * 6.28 * (index % 2 == 0 ? 1 : -1),
                      child: Opacity(
                        opacity: (1 - progress) * _fadeAnimation.value,
                        child: Text(
                          ['🎉', '⭐', '🌟', '✨', '🎊', '💫'][index % 6],
                          style: TextStyle(fontSize: 24 + (index % 3) * 8.0),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            // Main celebration card
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy/star icon with pulse
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 1.2),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Text(
                              '🏆',
                              style: TextStyle(fontSize: 72),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Congratulations!',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You completed all lessons\nin this learning path!',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amazing job! 🎉',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _dismissCelebration,
                        text: 'Continue',
                        options: FFButtonOptions(
                          width: 160,
                          height: 48,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFEDFFFD),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              StreamBuilder<LearningPathRecord>(
            stream: LearningPathRecord.getDocument(widget.leRef!),
            builder: (context, pathSnapshot) {
              if (!pathSnapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              final learningPath = pathSnapshot.data!;

              return StreamBuilder<List<LearningPathTasksRecord>>(
                stream: queryLearningPathTasksRecord(
                  queryBuilder: (learningPathTasksRecord) =>
                      learningPathTasksRecord
                          .where(
                            'program_ref',
                            isEqualTo: widget.leRef,
                          )
                          .orderBy('task_time'),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    );
                  }
                  List<LearningPathTasksRecord> tasksList = snapshot.data!;
                  final completedCount = tasksList.where((e) => e.isCompleted).length;

                  // Check if the path just became fully complete (not on initial load if already complete)
                  // Only trigger celebration if: tasks exist, all complete, not shown before,
                  // and we've seen a previous count that was less than total
                  if (tasksList.isNotEmpty &&
                      completedCount == tasksList.length &&
                      !_hasShownCelebration &&
                      _previousCompletedCount != null &&
                      _previousCompletedCount! < tasksList.length) {
                    // Use addPostFrameCallback to avoid calling setState during build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _triggerCelebration();
                    });
                  }
                  // Update previous count for next comparison
                  _previousCompletedCount = completedCount;

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 0.0),
                        child: Row(
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () => context.safePop(),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Header card with puzzle
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Back button and title
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(9.0, 8.0, 9.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(LearnPathWidget.routeName);
                                        },
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 37.0, 0.0),
                                        child: Text(
                                          'Learning Path',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 24.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          // Edit button
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              _showEditLearningPathDialog(context, learningPath);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 12.0),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                color: FlutterFlowTheme.of(context).primary,
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          // Delete button
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Delete Learning Path?'),
                                                  content: Text(
                                                    'Are you sure you want to delete "${learningPath.title}"? This will also delete all lessons. This cannot be undone.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(ctx, false),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(ctx, true),
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(color: FlutterFlowTheme.of(context).error),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                // Navigate away FIRST to avoid stream errors
                                                if (context.mounted) {
                                                  context.goNamed(LearnPathWidget.routeName);
                                                  // Brief delay to let navigation happen
                                                  await Future.delayed(const Duration(milliseconds: 100));
                                                }
                                                // Then delete all lessons for this path
                                                for (final task in tasksList) {
                                                  await task.reference.delete();
                                                }
                                                // Delete the learning path
                                                await widget.leRef!.delete();
                                                // Show snackbar (will show on the new page)
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Learning path deleted')),
                                                  );
                                                }
                                              }
                                            },
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: FlutterFlowTheme.of(context).error,
                                              size: 24.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Title
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                    child: Text(
                                      learningPath.title.isNotEmpty
                                          ? learningPath.title
                                          : 'Learning Path',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                                // Description
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 12.0),
                                  child: Text(
                                    learningPath.description.isNotEmpty
                                        ? learningPath.description
                                        : 'A personalized program designed to help your child develop new skills.',
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          color: Color(0xBD000000),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                // Progress indicator
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$completedCount of ${tasksList.length} lessons complete',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          if (completedCount == tasksList.length)
                                            Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF4CAF50),
                                              size: 20.0,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: LinearProgressIndicator(
                                          value: tasksList.length > 0 ? completedCount / tasksList.length : 0,
                                          minHeight: 8.0,
                                          backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context).primary,
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
                      // Task list - scrollable
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              child: ListView.builder(
                                key: ValueKey('tasks_${tasksList.map((t) => '${t.reference.id}_${t.isCompleted}').join('_')}'),
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                itemCount: tasksList.length,
                                itemBuilder: (context, index) {
                                  final task = tasksList[index];
                                  return Padding(
                                    key: ValueKey('task_${task.reference.id}_${task.isCompleted}'),
                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 20.0, 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 7.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                dateTimeFormat(
                                                  "MMMEd",
                                                  task.taskTime!,
                                                  locale: FFLocalizations.of(context).languageCode,
                                                ),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              Text(
                                                dateTimeFormat(
                                                  "jm",
                                                  task.taskTime!,
                                                  locale: FFLocalizations.of(context).languageCode,
                                                ),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                          child: Container(
                                            width: 1.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Builder(
                                            builder: (context) => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  enableDrag: true,
                                                  builder: (bottomSheetContext) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(bottomSheetContext).unfocus();
                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                                                        child: LearnPathDetailsComponentWidget(
                                                          learningTask: task,
                                                          filterlist: tasksList.length,
                                                          notfilteredlist: completedCount + 1,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: task.isCompleted
                                                      ? Color(0xFF4CAF50).withOpacity(0.1)
                                                      : Color(0x5AFFD8E4),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                  border: Border.all(
                                                    color: task.isCompleted
                                                        ? Color(0xFF4CAF50)
                                                        : FlutterFlowTheme.of(context).primary,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsetsDirectional.fromSTEB(15.0, 12.0, 8.0, 12.0),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.max,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              task.title ?? 'Lesson',
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    fontFamily: 'Andika New Basic',
                                                                    color: Colors.black,
                                                                    letterSpacing: 0.0,
                                                                  ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Text(
                                                              task.isCompleted ? 'View Notes' : 'View Details',
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    fontFamily: 'Andika New Basic',
                                                                    color: task.isCompleted
                                                                        ? Color(0xFF4CAF50)
                                                                        : Colors.black,
                                                                    letterSpacing: 0.0,
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // Checkbox / Completed icon
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 9.0, 0.0),
                                                      child: task.isCompleted
                                                          ? Icon(
                                                              FFIcons.kcheckicon,
                                                              color: Color(0xFF32DD8D),
                                                              size: 24.0,
                                                            )
                                                          : Builder(
                                                              builder: (context) => InkWell(
                                                                splashColor: Colors.transparent,
                                                                focusColor: Colors.transparent,
                                                                hoverColor: Colors.transparent,
                                                                highlightColor: Colors.transparent,
                                                                onTap: () async {
                                                                  await showDialog(
                                                                    context: context,
                                                                    builder: (dialogContext) {
                                                                      return Dialog(
                                                                        elevation: 0,
                                                                        insetPadding: EdgeInsets.zero,
                                                                        backgroundColor: Colors.transparent,
                                                                        alignment: AlignmentDirectional(0.0, 0.0)
                                                                            .resolve(Directionality.of(context)),
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            FocusScope.of(dialogContext).unfocus();
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                          },
                                                                          child: CompeleTaskpopupWidget(),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ).then((value) {
                                                                    if (value is TaskCompletionResult) {
                                                                      safeSetState(() => _model.isconfarim = value.confirmed);
                                                                    } else {
                                                                      safeSetState(() => _model.isconfarim = value == true);
                                                                    }
                                                                  });

                                                                  if (_model.isconfarim == true) {
                                                                    await task.reference.update(
                                                                      createLearningPathTasksRecordData(isCompleted: true),
                                                                    );
                                                                    // Check if all tasks complete
                                                                    final newCompletedCount = completedCount + 1;
                                                                    if (newCompletedCount == tasksList.length) {
                                                                      await widget.leRef!.update(
                                                                        createLearningPathRecordData(isCompleted: true),
                                                                      );
                                                                      // Trigger celebration!
                                                                      _triggerCelebration();
                                                                    }
                                                                  }
                                                                  safeSetState(() {});
                                                                },
                                                                child: Container(
                                                                  width: 19.0,
                                                                  height: 19.0,
                                                                  decoration: BoxDecoration(
                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                    border: Border.all(
                                                                      color: Color(0xFF999999),
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom padding
                      SizedBox(height: 12.0),
                    ],
                  );
                },
              );
            },
          ),
              // Celebration overlay
              if (_showCelebration)
                _buildCelebrationOverlay(context),
            ],
          ),
        ),
      ),
    );
  }
}
