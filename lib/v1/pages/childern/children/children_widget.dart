import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/v1/pages/childern/childen_edit_pop_up_c/childen_edit_pop_up_c_widget.dart';
import '/v1/pages/childern/childend_delet_pop_up/childend_delet_pop_up_widget.dart';
// Puzzle widget removed - using simple progress bar instead
import '/components/milestone_category_progress_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'children_model.dart';
export 'children_model.dart';

class ChildrenWidget extends StatefulWidget {
  const ChildrenWidget({
    super.key,
    this.childRef,
  });

  final DocumentReference? childRef;

  static String routeName = 'Children';
  static String routePath = '/children';

  @override
  State<ChildrenWidget> createState() => _ChildrenWidgetState();
}

class _ChildrenWidgetState extends State<ChildrenWidget> {
  late ChildrenModel _model;
  int _selectedChildIndex = 0;
  bool _hasInitializedChildRef = false; // Track if we've already set index from widget.childRef

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChildrenModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEDFFFD),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 75.0),
            child: FloatingActionButton(
              onPressed: () async {
                // Navigate to full-page Add Child flow (settings mode)
                context.pushNamed(
                  AddChildEnhancedWidget.routeName,
                  queryParameters: {
                    'isOnboarding': serializeParam(false, ParamType.bool),
                  },
                );
              },
              backgroundColor: theme.primary,
              elevation: 8.0,
              child: Icon(
                Icons.add_rounded,
                color: theme.info,
                size: 24.0,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              StreamBuilder<List<ChildernRecord>>(
                stream: queryChildernRecord(
                  queryBuilder: (childernRecord) => childernRecord.where(
                    'userRef',
                    isEqualTo: currentUserReference,
                  ),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                      ),
                    );
                  }

                  final children = snapshot.data!;

                  if (children.isEmpty) {
                    return const Center(
                      child: EmptyListViewComponentWidget(
                        icon: Icon(FFIcons.kcilChild),
                        message: 'No children Yet',
                      ),
                    );
                  }

                  // Ensure selected index is valid
                  if (_selectedChildIndex >= children.length) {
                    _selectedChildIndex = 0;
                  }

                  // If a specific child was requested, find and select them ONLY ONCE
                  if (widget.childRef != null && !_hasInitializedChildRef) {
                    final requestedIndex = children.indexWhere(
                      (c) => c.reference.path == widget.childRef!.path,
                    );
                    if (requestedIndex >= 0) {
                      _selectedChildIndex = requestedIndex;
                      _hasInitializedChildRef = true; // Mark as initialized so we don't reset on every rebuild
                    }
                  }

                  final selectedChild = children[_selectedChildIndex];

                  return Column(
                    children: [
                      // Header with title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Text(
                              'My Children',
                              style: theme.titleLarge.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Child avatar tabs
                      Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            final child = children[index];
                            final isSelected = index == _selectedChildIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChildIndex = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    // Avatar circle
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: isSelected ? 70 : 60,
                                      height: isSelected ? 70 : 60,
                                      decoration: BoxDecoration(
                                        color: child.selectedColor ?? theme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? theme.primary : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: theme.primary.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: child.avatar.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                child.avatar,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => _buildInitial(child.name),
                                              ),
                                            )
                                          : _buildInitial(child.name),
                                    ),
                                    const SizedBox(height: 4),
                                    // Name
                                    Text(
                                      child.name,
                                      style: theme.bodySmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? theme.primary : theme.secondaryText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Child summary content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              // Child info card
                              _buildChildInfoCard(context, theme, selectedChild),

                              const SizedBox(height: 16),

                              // Today's task
                              _buildTodaysTask(context, theme, selectedChild),

                              const SizedBox(height: 16),

                              // Learning paths
                              _buildLearningPaths(context, theme, selectedChild),

                              const SizedBox(height: 16),

                              // Upcoming events
                              _buildUpcomingEvents(context, theme, selectedChild),

                              const SizedBox(height: 16),

                              // Milestone progress (at the bottom)
                              if (selectedChild.birthDay != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: MilestoneCategoryProgressWidget(
                                    childRef: selectedChild.reference,
                                    childBirthday: selectedChild.birthDay!,
                                    onTap: () {
                                      // Set the selected child for milestones page
                                      FFAppState().selectedChildForMilestone = selectedChild.reference;
                                      context.pushNamed(MilstonesWidget.routeName);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Bottom navbar
              const Align(
                alignment: Alignment.bottomCenter,
                child: HomeNavBarWidget(currentPage: HomeNavPage.home),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChildInfoCard(BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    final age = _calculateAge(child.birthDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: child.selectedColor ?? theme.primary,
                shape: BoxShape.circle,
              ),
              child: child.avatar.isNotEmpty
                  ? ClipOval(
                      child: Image.network(child.avatar, fit: BoxFit.cover),
                    )
                  : _buildInitial(child.name),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: theme.titleMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.cake_outlined, size: 16, color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        age,
                        style: theme.bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit & Delete buttons
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          elevation: 0,
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => FocusScope.of(dialogContext).unfocus(),
                            child: ChildenEditPopUpCWidget(childRow: child),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.edit_outlined, color: theme.primary),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          elevation: 0,
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => FocusScope.of(dialogContext).unfocus(),
                            child: ChildendDeletPopUpWidget(child: child.reference),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.delete_outline, color: theme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return '';
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;
    final adjustedMonths = months < 0 ? months + 12 : months;
    final adjustedYears = months < 0 ? years - 1 : years;

    if (adjustedYears == 0) {
      return '$adjustedMonths months old';
    } else if (adjustedMonths == 0) {
      return '$adjustedYears years old';
    } else {
      return '$adjustedYears yr $adjustedMonths mo';
    }
  }

  Widget _buildTodaysTask(BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<List<LearningPathTasksRecord>>(
        stream: queryLearningPathTasksRecord(
          queryBuilder: (q) => q
              .where('child_ref', isEqualTo: child.reference)
              .where('is_completed', isEqualTo: false)
              .orderBy('task_time')
              .limit(1),
        ),
        builder: (context, taskSnapshot) {
          if (!taskSnapshot.hasData || taskSnapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final task = taskSnapshot.data!.first;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Today's Lesson",
                            style: theme.bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.title,
                  style: theme.titleMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description.length > 100
                      ? '${task.description.substring(0, 100)}...'
                      : task.description,
                  style: theme.bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLearningPaths(BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Paths',
                style: theme.titleMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(LearnPathWidget.routeName),
                child: Text(
                  'See All',
                  style: theme.bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<LearningPathRecord>>(
            stream: queryLearningPathRecord(
              queryBuilder: (q) => q
                  .where('child_ref', isEqualTo: child.reference)
                  .where('is_completed', isEqualTo: false)
                  .limit(3),
            ),
            builder: (context, pathSnapshot) {
              if (!pathSnapshot.hasData || pathSnapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.school_outlined, size: 48, color: theme.secondaryText),
                        const SizedBox(height: 8),
                        Text(
                          'No active learning paths',
                          style: theme.bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: pathSnapshot.data!.map((path) {
                  return _buildLearningPathCard(context, theme, path);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPathCard(BuildContext context, FlutterFlowTheme theme, LearningPathRecord path) {
    return StreamBuilder<List<LearningPathTasksRecord>>(
      stream: queryLearningPathTasksRecord(
        queryBuilder: (q) => q
            .where('program_ref', isEqualTo: path.reference)
            .where('is_completed', isEqualTo: true),
      ),
      builder: (context, completedSnapshot) {
        final completedCount = completedSnapshot.data?.length ?? 0;

        return InkWell(
          onTap: () {
            context.pushNamed(
              LearnPathDetialsWidget.routeName,
              queryParameters: {
                'leRef': serializeParam(path.reference, ParamType.DocumentReference),
              }.withoutNulls,
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                // Progress circle instead of puzzle
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: path.tasksCount > 0 ? completedCount / path.tasksCount : 0,
                          strokeWidth: 5,
                          backgroundColor: theme.primary.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${((path.tasksCount > 0 ? completedCount / path.tasksCount : 0) * 100).round()}%',
                            style: theme.bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.title,
                        style: theme.bodyLarge.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${path.tasksCount} lessons',
                        style: theme.bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.secondaryText),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
            style: theme.titleMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<EventAndTaskRecord>>(
            stream: queryEventAndTaskRecord(
              queryBuilder: (q) => q
                  .where('user_ref', isEqualTo: currentUserReference)
                  .where('is_completed', isEqualTo: false),
            ),
            builder: (context, eventSnapshot) {
              // Filter events for this child and upcoming dates in code
              final now = DateTime.now();
              final todayStart = DateTime(now.year, now.month, now.day);
              final filteredEvents = (eventSnapshot.data ?? [])
                  .where((e) => e.selectedChild == child.reference)
                  .where((e) => e.date != null && e.date!.isAfter(todayStart.subtract(const Duration(seconds: 1))))
                  .toList()
                ..sort((a, b) => (a.date ?? DateTime(2099)).compareTo(b.date ?? DateTime(2099)));
              final upcomingEvents = filteredEvents.take(3).toList();

              if (!eventSnapshot.hasData || upcomingEvents.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'No upcoming events',
                      style: theme.bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: upcomingEvents.map((event) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              event.date != null ? '${event.date!.day}' : '-',
                              style: theme.bodyLarge.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: theme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: theme.bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (event.date != null)
                                Text(
                                  DateFormat('EEEE, MMM d').format(event.date!),
                                  style: theme.bodySmall.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: theme.secondaryText,
                                  ),
                                ),
                              // Show assigned family members
                              if (event.assignedToMom || event.assignedToDad)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      if (event.assignedToMom)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE91E63).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE91E63),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'M',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Mom',
                                                style: theme.bodySmall.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: const Color(0xFFE91E63),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (event.assignedToDad)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2196F3).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF2196F3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'D',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Dad',
                                                style: theme.bodySmall.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: const Color(0xFF2196F3),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
