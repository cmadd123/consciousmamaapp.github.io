import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/puzzle_progress_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import '/v1/pages/childern/childen_edit_pop_up_c/childen_edit_pop_up_c_widget.dart';
import '/index.dart';

class ChildSummaryWidget extends StatefulWidget {
  const ChildSummaryWidget({
    super.key,
    required this.childRef,
  });

  final DocumentReference childRef;

  static String routeName = 'childSummary';
  static String routePath = '/childSummary';

  @override
  State<ChildSummaryWidget> createState() => _ChildSummaryWidgetState();
}

class _ChildSummaryWidgetState extends State<ChildSummaryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return StreamBuilder<ChildernRecord>(
      stream: ChildernRecord.getDocument(widget.childRef),
      builder: (context, childSnapshot) {
        if (!childSnapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFEDFFFD),
            body: Center(
              child: CircularProgressIndicator(color: theme.primary),
            ),
          );
        }

        final child = childSnapshot.data!;
        final age = _calculateAge(child.birthDay);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xFFEDFFFD),
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        // Header with child info
                        _buildHeader(context, theme, child, age),

                        const SizedBox(height: 16),

                        // Today's Learning Task
                        _buildTodaysTask(context, theme, child),

                        const SizedBox(height: 16),

                        // Active Learning Paths with Puzzles
                        _buildLearningPaths(context, theme, child),

                        const SizedBox(height: 16),

                        // Upcoming Events
                        _buildUpcomingEvents(context, theme, child),

                        const SizedBox(height: 16),

                        // Quick Stats
                        _buildQuickStats(context, theme, child),
                      ],
                    ),
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
      },
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
      return '$adjustedMonths mo';
    } else if (adjustedMonths == 0) {
      return '$adjustedYears yr';
    } else {
      return '$adjustedYears yr $adjustedMonths mo';
    }
  }

  Widget _buildHeader(
      BuildContext context, FlutterFlowTheme theme, ChildernRecord child, String age) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Back button and title row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios, color: theme.primaryText),
              ),
              Expanded(
                child: Text(
                  "${child.name}'s Summary",
                  style: theme.titleLarge.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Edit button
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
                          onTap: () {
                            FocusScope.of(dialogContext).unfocus();
                          },
                          child: ChildenEditPopUpCWidget(
                            childRow: child,
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: Icon(Icons.edit_outlined, color: theme.primary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Child avatar and info
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: child.selectedColor ?? theme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (child.selectedColor ?? theme.primary).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child.avatar.isNotEmpty
                    ? ClipOval(
                        child: Image.network(child.avatar, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          child.name.isNotEmpty ? child.name[0].toLowerCase() : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 16),

              // Child details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: theme.headlineSmall.override(
                        fontFamily: 'Andika New Basic',
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
                          style: theme.bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysTask(
      BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<List<LearningPathTasksRecord>>(
        stream: queryLearningPathTasksRecord(
          queryBuilder: (q) => q
              .where('user_ref', isEqualTo: currentUserReference)
              .where('child_ref', isEqualTo: widget.childRef)
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
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Today's Lesson",
                            style: theme.bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${task.duration} min',
                      style: theme.bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.title,
                  style: theme.titleMedium.override(
                    fontFamily: 'Andika New Basic',
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
                    fontFamily: 'Andika New Basic',
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                          child: LearnPathDetailsComponentWidget(
                            learningTask: task,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Start Activity'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLearningPaths(
      BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
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
                  fontFamily: 'Andika New Basic',
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(LearnPathWidget.routeName),
                child: Text(
                  'See All',
                  style: theme.bodySmall.override(
                    fontFamily: 'Andika New Basic',
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
                  .where('user_ref', isEqualTo: currentUserReference)
                  .where('child_ref', isEqualTo: widget.childRef)
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
                        Icon(Icons.school_outlined,
                            size: 48, color: theme.secondaryText),
                        const SizedBox(height: 8),
                        Text(
                          'No active learning paths',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Andika New Basic',
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

  Widget _buildLearningPathCard(
      BuildContext context, FlutterFlowTheme theme, LearningPathRecord path) {
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
                'leRef': serializeParam(
                  path.reference,
                  ParamType.DocumentReference,
                ),
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
              // Full 3x3 puzzle grid
              PuzzleProgressWidget(
                themeId: path.puzzleTheme,
                completedTasks: completedCount,
                totalTasks: path.tasksCount,
                size: 70,
                showLabel: false,
              ),

              const SizedBox(width: 16),

              // Path info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.title,
                      style: theme.bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount of ${path.tasksCount} tasks',
                      style: theme.bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: path.tasksCount > 0
                          ? completedCount / path.tasksCount
                          : 0,
                      backgroundColor: theme.primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(theme.primary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: theme.secondaryText),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildUpcomingEvents(
      BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
            style: theme.titleMedium.override(
              fontFamily: 'Andika New Basic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<EventAndTaskRecord>>(
            stream: queryEventAndTaskRecord(
              queryBuilder: (q) => q
                  .where('user_ref', isEqualTo: currentUserReference)
                  .where('date', isGreaterThanOrEqualTo: DateTime.now())
                  .orderBy('date'),
            ),
            builder: (context, eventSnapshot) {
              // Filter client-side for events assigned to this child
              // (supports both old selected_child and new selected_children fields)
              final filteredEvents = (eventSnapshot.data ?? []).where((event) {
                return event.selectedChild == widget.childRef ||
                    event.selectedChildren.contains(widget.childRef);
              }).take(3).toList();

              if (!eventSnapshot.hasData || filteredEvents.isEmpty) {
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
                        fontFamily: 'Andika New Basic',
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: filteredEvents.map((event) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(14),
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
                              event.date != null
                                  ? '${event.date!.day}'
                                  : '-',
                              style: theme.bodyLarge.override(
                                fontFamily: 'Andika New Basic',
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
                                  fontFamily: 'Andika New Basic',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (event.date != null)
                                Text(
                                  DateFormat('EEEE, MMM d').format(event.date!),
                                  style: theme.bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: theme.secondaryText,
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

  Widget _buildQuickStats(
      BuildContext context, FlutterFlowTheme theme, ChildernRecord child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: theme.titleMedium.override(
              fontFamily: 'Andika New Basic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<LearningPathTasksRecord>>(
            stream: queryLearningPathTasksRecord(
              queryBuilder: (q) {
                final weekAgo = DateTime.now().subtract(const Duration(days: 7));
                return q
                    .where('child_ref', isEqualTo: widget.childRef)
                    .where('is_completed', isEqualTo: true)
                    .where('completed_at', isGreaterThanOrEqualTo: weekAgo);
              },
            ),
            builder: (context, statsSnapshot) {
              final completedThisWeek = statsSnapshot.data?.length ?? 0;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      theme,
                      Icons.check_circle_outline,
                      '$completedThisWeek',
                      'Tasks Done',
                      const Color(0xFF4CAF50),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.primaryText.withOpacity(0.1),
                    ),
                    _buildStatItem(
                      theme,
                      Icons.emoji_events_outlined,
                      completedThisWeek >= 7 ? '1' : '0',
                      'Puzzles',
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(FlutterFlowTheme theme, IconData icon, String value,
      String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.headlineSmall.override(
            fontFamily: 'Andika New Basic',
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.bodySmall.override(
            fontFamily: 'Andika New Basic',
            color: theme.secondaryText,
          ),
        ),
      ],
    );
  }
}
