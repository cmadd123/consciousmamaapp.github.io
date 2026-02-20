import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/share_content_bottom_sheet.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/momrise_confirmation.dart';
import '/v2/todo/addcalender/addcalender_widget.dart';
import 'package:flutter/material.dart';
import 'my_activities_model.dart';
export 'my_activities_model.dart';

class MyActivitiesWidget extends StatefulWidget {
  const MyActivitiesWidget({super.key});

  static String routeName = 'MyActivities';
  static String routePath = '/myActivities';

  @override
  State<MyActivitiesWidget> createState() => _MyActivitiesWidgetState();
}

class _MyActivitiesWidgetState extends State<MyActivitiesWidget> {
  late MyActivitiesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyActivitiesModel());
    _loadParentInfo();
  }

  Future<void> _loadParentInfo() async {
    if (currentUserReference == null) return;
    final user = await UsersRecord.getDocumentOnce(currentUserReference!);
    if (mounted) {
      setState(() {
        _model.parentInfo = ParentDisplayInfo.fromUser(user);
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FFAppState().isComfortMode
            ? const Color(0xFF2C3E50)
            : const Color(0xFFFFE9E1),
        floatingActionButton: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 80.0),
          child: FloatingActionButton(
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CreateActivityBottomSheet(
                  onSave: () {
                    safeSetState(() {});
                  },
                ),
              );
            },
            backgroundColor: FFAppState().isComfortMode
                ? const Color(0xFF7F8C8D)
                : FlutterFlowTheme.of(context).primary,
            elevation: 8.0,
            child: Icon(
              Icons.add_rounded,
              color: FFAppState().isComfortMode
                  ? const Color(0xFFECF0F1)
                  : FlutterFlowTheme.of(context).info,
              size: 28.0,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: FFAppState().isComfortMode
                ? const LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: SafeArea(
            top: true,
            child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                    child: Row(
                      children: [
                        // Back button
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: FFAppState().isComfortMode
                                ? const Color(0xFFECF0F1)
                                : FlutterFlowTheme.of(context).primaryText,
                            size: 20.0,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Custom Activities',
                          style: FlutterFlowTheme.of(context).headlineMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: FFAppState().isComfortMode
                                ? const Color(0xFFECF0F1)
                                : FlutterFlowTheme.of(context).primaryText,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Description
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                    child: Text(
                      'Activities you created. Tap to edit, or add to your calendar!',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: FFAppState().isComfortMode
                            ? const Color(0xFF95A5A6)
                            : FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Activities list
                  Expanded(
                    child: _buildActivitiesList(),
                  ),
                  const SizedBox(height: 100.0), // Space for navbar
                ],
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.home,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    return StreamBuilder<List<UserActivityRecord>>(
      stream: queryUserActivityRecord(
        queryBuilder: (query) {
          // Only filter by user_ref - no orderBy to avoid needing composite index
          return query.where('user_ref', isEqualTo: currentUserReference);
        },
      ),
      builder: (context, snapshot) {
        // Handle errors - show empty state instead of infinite loading
        if (snapshot.hasError) {
          debugPrint('Error loading activities: ${snapshot.error}');
          // Show empty state on error
          return _buildEmptyState();
        }

        // Show loading only briefly, then show empty state
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: FlutterFlowTheme.of(context).primary,
            ),
          );
        }

        // If no data yet (but not waiting), show empty state
        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        final activities = snapshot.data!;

        if (activities.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 100.0),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityCard(activity);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 64.0,
              color: FFAppState().isComfortMode
                  ? const Color(0xFF7F8C8D)
                  : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No activities yet',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Andika New Basic',
                color: FFAppState().isComfortMode
                    ? const Color(0xFFECF0F1)
                    : FlutterFlowTheme.of(context).primaryText,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tap the + button to create your first activity!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: FFAppState().isComfortMode
                    ? const Color(0xFF95A5A6)
                    : FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(UserActivityRecord activity) {
    final emoji = activity.iconEmoji.isNotEmpty ? activity.iconEmoji : '🎨';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () async {
          // Tap to edit
          await _editActivity(activity);
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FFAppState().isComfortMode
                ? const Color(0xFF2C3E50)
                : Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: FFAppState().isComfortMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
            border: Border.all(
              color: FFAppState().isComfortMode
                  ? const Color(0xFF7F8C8D)
                  : Colors.grey.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row - emoji, title, and favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity emoji in styled container
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: FFAppState().isComfortMode
                          ? const Color(0xFF34495E)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: FFAppState().isComfortMode
                            ? const Color(0xFFECF0F1)
                            : FlutterFlowTheme.of(context).primaryText,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Share button
                  GestureDetector(
                    onTap: () {
                      showShareActivityBottomSheet(
                        context: context,
                        activity: activity,
                      );
                    },
                    child: Icon(
                      Icons.share_outlined,
                      color: FFAppState().isComfortMode
                          ? const Color(0xFF95A5A6)
                          : FlutterFlowTheme.of(context).secondaryText,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Favorite button
                  GestureDetector(
                    onTap: () async {
                      await activity.reference.update({
                        'is_favorite': !activity.isFavorite,
                      });
                    },
                    child: Icon(
                      activity.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: activity.isFavorite
                          ? Colors.red
                          : (FFAppState().isComfortMode
                              ? const Color(0xFF95A5A6)
                              : FlutterFlowTheme.of(context).secondaryText),
                      size: 24.0,
                    ),
                  ),
                ],
              ),
              // Description - directly under title
              if (activity.description.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: FFAppState().isComfortMode
                        ? const Color(0xFF95A5A6)
                        : FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 15.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
              const SizedBox(height: 12.0),
              // Tags row - styled to match curated activities
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  if (activity.timeDuration.isNotEmpty)
                    _buildColoredTag(
                      text: activity.timeDuration,
                      chipColor: const Color(0xFF9C27B0), // Purple - matches curated
                      icon: Icons.schedule,
                    ),
                  if (activity.parentProximity.isNotEmpty)
                    _buildColoredTag(
                      text: activity.parentProximity == 'free'
                          ? 'Independent'
                          : activity.parentProximity == 'nearby'
                              ? 'Nearby'
                              : 'Together',
                      chipColor: activity.parentProximity == 'free'
                          ? const Color(0xFF4CAF50) // Green
                          : activity.parentProximity == 'nearby'
                              ? const Color(0xFFFF9800) // Orange
                              : const Color(0xFFE91E63), // Pink
                      icon: activity.parentProximity == 'free'
                          ? Icons.self_improvement
                          : activity.parentProximity == 'nearby'
                              ? Icons.visibility
                              : Icons.people,
                    ),
                  if (activity.setupTime.isNotEmpty)
                    _buildColoredTag(
                      text: activity.setupTime,
                      chipColor: const Color(0xFF2196F3), // Blue - matches curated
                      icon: Icons.build_outlined,
                    ),
                  if (activity.cleanupDifficulty.isNotEmpty)
                    _buildColoredTag(
                      text: activity.cleanupDifficulty,
                      chipColor: activity.cleanupDifficulty == 'easy'
                          ? const Color(0xFF52A097) // Teal (matches app primary)
                          : activity.cleanupDifficulty == 'medium'
                              ? const Color(0xFFFF9800) // Orange
                              : const Color(0xFFF44336), // Red
                      icon: Icons.cleaning_services_outlined,
                    ),
                ],
              ),
              // Things Needed - styled with border like curated activities
              if (activity.thingsNeeded.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: FFAppState().isComfortMode
                        ? const Color(0xFF2C3E50)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: FFAppState().isComfortMode
                          ? const Color(0xFF7F8C8D)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.list_alt,
                          color: Color(0xFF95A5A6),
                          size: 16.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          activity.thingsNeeded,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FFAppState().isComfortMode
                                ? const Color(0xFFECF0F1)
                                : FlutterFlowTheme.of(context).primaryText,
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Safety Note
              // Safety Note - styled to match curated activities
              if (activity.safetyNote.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 16.0,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          activity.safetyNote,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FFAppState().isComfortMode
                                ? const Color(0xFFECF0F1)
                                : FlutterFlowTheme.of(context).primaryText,
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Action buttons row at the bottom right
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Quick add to today button
                  InkWell(
                    onTap: () async {
                      await _quickAddToToday(activity);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: FFAppState().isComfortMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.0),
                        border: FFAppState().isComfortMode
                            ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 16.0,
                            color: FFAppState().isComfortMode
                                ? Colors.white
                                : const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Quick Add',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              fontSize: 12.0,
                              color: FFAppState().isComfortMode
                                  ? Colors.white
                                  : const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Add to calendar button (schedule for different day)
                  InkWell(
                    onTap: () async {
                      await _addToCalendar(activity);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: FFAppState().isComfortMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.0),
                        border: FFAppState().isComfortMode
                            ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16.0,
                            color: FFAppState().isComfortMode
                                ? Colors.white
                                : FlutterFlowTheme.of(context).primary,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Schedule',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              fontSize: 13.0,
                              color: FFAppState().isComfortMode
                                  ? Colors.white
                                  : FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a styled chip matching curated activities style
  Widget _buildColoredTag({
    required String text,
    required Color chipColor,
    IconData? icon,
  }) {
    final isComfortMode = FFAppState().isComfortMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isComfortMode
            ? chipColor.withValues(alpha: 0.2)
            : chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14.0,
              color: isComfortMode ? chipColor.withValues(alpha: 0.9) : chipColor,
            ),
            const SizedBox(width: 4.0),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 12.0,
              color: isComfortMode ? chipColor.withValues(alpha: 0.9) : chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCalendar(UserActivityRecord activity) async {
    // Navigate to calendar add page with activity pre-filled
    // Import and navigate directly to pass parameters
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddcalenderWidget(
          fromPage: 'activities',
          prefillName: activity.title,
          prefillDescription: activity.description,
        ),
      ),
    );

    // Increment times_used counter
    await activity.reference.update({
      'times_used': (activity.timesUsed) + 1,
    });
  }

  Future<void> _quickAddToToday(UserActivityRecord activity) async {
    // Show assignment bottom sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddAssignmentSheet(
        activity: activity,
        onConfirm: (selectedChildren, assignToMom, assignToDad, targetDate) async {
          try {
            // Create the event for the selected date with all activity details
            await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
              name: activity.title,
              description: activity.description,
              isrecurring: false,
              selectedChildren: selectedChildren,
              userRef: currentUserReference,
              date: targetDate,
              typ: 'Activity',
              isCompleted: false,
              assignedToMom: assignToMom,
              assignedToDad: assignToDad,
              sourceActivityRef: activity.reference,
              thingsNeeded: activity.thingsNeeded,
              timeDuration: activity.timeDuration,
              parentProximity: activity.parentProximity,
              setupTime: activity.setupTime,
              cleanupDifficulty: activity.cleanupDifficulty,
              iconEmoji: activity.iconEmoji,
              safetyNote: activity.safetyNote,
            ));

            // Increment times_used counter
            await activity.reference.update({
              'times_used': (activity.timesUsed) + 1,
            });

            if (mounted) {
              await MomRiseConfirmation.show(context, message: 'Added to Calendar');
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding activity: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _editActivity(UserActivityRecord activity) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateActivityBottomSheet(
        editActivity: activity,
        onSave: () {
          safeSetState(() {});
        },
      ),
    );
  }
}

/// Bottom sheet for creating/editing activities
class CreateActivityBottomSheet extends StatefulWidget {
  final VoidCallback? onSave;
  final UserActivityRecord? editActivity; // If provided, we're editing

  const CreateActivityBottomSheet({
    super.key,
    this.onSave,
    this.editActivity,
  });

  @override
  State<CreateActivityBottomSheet> createState() => _CreateActivityBottomSheetState();
}

class _CreateActivityBottomSheetState extends State<CreateActivityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thingsNeededController = TextEditingController();
  final _safetyNoteController = TextEditingController();

  String _selectedParentProximity = 'nearby';
  String _selectedSetupTime = '0-2 min';
  String _selectedCleanupDifficulty = 'easy';
  String _selectedEmoji = '🎨'; // Default emoji
  int _durationMinutes = 15;
  bool _isSaving = false;

  // Child and parent assignment
  List<ChildernRecord>? _userChildren;
  Set<DocumentReference> _selectedChildren = {};
  bool _assignToMom = false;
  bool _assignToDad = false;

  // Parent display info
  ParentDisplayInfo _parentInfo = ParentDisplayInfo.defaults();

  final List<String> _parentProximityOptions = ['involved', 'nearby', 'free'];
  final List<String> _setupTimeOptions = ['0-2 min', '3-5 min', '5+ min'];
  final List<String> _cleanupOptions = ['easy', 'medium', 'messy'];

  // Emoji options for activities - organized by category
  final List<String> _emojiOptions = [
    // Art & Creative
    '🎨', '🖌️', '✏️', '🖍️',
    // Active & Sports
    '⚽', '🏃', '💃', '🤸',
    // Music
    '🎵', '🎸', '🥁', '🎤',
    // Learning
    '📚', '🔤', '🧮', '🧠',
    // Science & Nature
    '🔬', '🌿', '🌻', '🦋',
    // Sensory & Play
    '💧', '🫧', '✨', '🌈',
    // Building & Crafts
    '🧱', '🔨', '✂️', '🧶',
    // Food & Cooking
    '🍪', '🧁', '🥣', '👩‍🍳',
    // Pretend & Games
    '🎭', '🎪', '🧩', '🎲',
    // Animals
    '🐶', '🐱', '🐻', '🦁',
    // Outdoors
    '🌳', '🏕️', '🚲', '⛱️',
    // Misc fun
    '🎯', '🎈', '🎁', '⭐',
  ];

  bool get _isEditing => widget.editActivity != null;

  @override
  void initState() {
    super.initState();
    _loadUserChildren();
    _loadParentInfo();

    // Pre-fill form if editing
    if (widget.editActivity != null) {
      final activity = widget.editActivity!;
      _titleController.text = activity.title;
      _descriptionController.text = activity.description;
      _thingsNeededController.text = activity.thingsNeeded;
      _safetyNoteController.text = activity.safetyNote;
      _selectedParentProximity = activity.parentProximity.isNotEmpty ? activity.parentProximity : 'nearby';
      _selectedSetupTime = activity.setupTime.isNotEmpty ? activity.setupTime : '0-2 min';
      _selectedCleanupDifficulty = activity.cleanupDifficulty.isNotEmpty ? activity.cleanupDifficulty : 'easy';
      // Load emoji - stored in iconEmoji field, fallback to default
      _selectedEmoji = activity.iconEmoji.isNotEmpty ? activity.iconEmoji : '🎨';
      // Parse duration from string like "15 minutes"
      final durationMatch = RegExp(r'(\d+)').firstMatch(activity.timeDuration);
      _durationMinutes = durationMatch != null ? int.parse(durationMatch.group(1)!) : 15;
      _selectedChildren = activity.assignedChildren.toSet();
      _assignToMom = activity.assignedToMom;
      _assignToDad = activity.assignedToDad;
    }
  }

  Future<void> _loadUserChildren() async {
    final children = await queryChildernRecordOnce(
      queryBuilder: (childernRecord) => childernRecord.where(
        'userRef',
        isEqualTo: currentUserReference,
      ),
    );
    if (mounted) {
      setState(() {
        _userChildren = children;
      });
    }
  }

  Future<void> _loadParentInfo() async {
    if (currentUserReference == null) return;
    final user = await UsersRecord.getDocumentOnce(currentUserReference!);
    if (mounted) {
      setState(() {
        _parentInfo = ParentDisplayInfo.fromUser(user);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thingsNeededController.dispose();
    _safetyNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: FFAppState().isComfortMode
              ? const Color(0xFF34495E)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: FFAppState().isComfortMode
                    ? const Color(0xFF7F8C8D)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Activity' : 'Create Activity',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Andika New Basic',
                      color: FFAppState().isComfortMode
                          ? const Color(0xFFECF0F1)
                          : FlutterFlowTheme.of(context).primaryText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: FFAppState().isComfortMode
                          ? const Color(0xFF95A5A6)
                          : FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, MediaQuery.of(context).viewInsets.bottom + 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildLabel('Activity Name *'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration('e.g., Finger painting'),
                      style: _inputTextStyle(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an activity name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Description
                    _buildLabel('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration('What is this activity about?'),
                      style: _inputTextStyle(),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16.0),

                    // Emoji picker
                    _buildLabel('Activity Emoji'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _emojiOptions.map((emoji) {
                        final bool isSelected = _selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedEmoji = emoji;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2)
                                  : (FFAppState().isComfortMode
                                      ? const Color(0xFF2C3E50)
                                      : const Color(0xFFF5F5F5)),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary
                                    : (FFAppState().isComfortMode
                                        ? Colors.transparent
                                        : const Color(0xFFE0E0E0)),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                        blurRadius: 8.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24.0),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Duration slider
                    _buildLabel('Duration: $_durationMinutes minutes'),
                    Container(
                      decoration: BoxDecoration(
                        color: FFAppState().isComfortMode
                            ? const Color(0xFF2C3E50)
                            : FlutterFlowTheme.of(context).prim30,
                        borderRadius: BorderRadius.circular(14.0),
                        border: FFAppState().isComfortMode
                            ? null
                            : Border.all(color: const Color(0xFFCBE3E0), width: 1.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Slider(
                        value: _durationMinutes.toDouble(),
                        min: 5,
                        max: 45,
                        divisions: 8,
                        activeColor: FFAppState().isComfortMode
                            ? const Color(0xFF64B5F6)
                            : const Color(0xFF1976D2),
                        inactiveColor: FFAppState().isComfortMode
                            ? const Color(0xFF455A64)
                            : const Color(0xFFBBDEFB),
                        onChanged: (value) {
                          setState(() => _durationMinutes = value.round());
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Parent proximity chips (orange)
                    _buildLabel('Parent Involvement'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _parentProximityOptions.map((prox) {
                        final isSelected = _selectedParentProximity == prox;
                        final chipColor = const Color(0xFFFF9800); // Orange
                        return _buildAnimatedChip(
                          label: prox,
                          isSelected: isSelected,
                          chipColor: chipColor,
                          onTap: () => setState(() => _selectedParentProximity = prox),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Setup time chips (purple)
                    _buildLabel('Setup Time'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _setupTimeOptions.map((setup) {
                        final isSelected = _selectedSetupTime == setup;
                        final chipColor = const Color(0xFF9C27B0); // Purple
                        return _buildAnimatedChip(
                          label: setup,
                          isSelected: isSelected,
                          chipColor: chipColor,
                          onTap: () => setState(() => _selectedSetupTime = setup),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Cleanup difficulty chips (traffic light colors)
                    _buildLabel('Cleanup'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _cleanupOptions.map((cleanup) {
                        final isSelected = _selectedCleanupDifficulty == cleanup;
                        // Color scheme: teal=easy, orange=medium, red=hard
                        final chipColor = cleanup == 'easy'
                            ? const Color(0xFF52A097) // Teal (matches app primary)
                            : cleanup == 'medium'
                                ? const Color(0xFFFF9800) // Orange
                                : const Color(0xFFF44336); // Red
                        return _buildAnimatedChip(
                          label: cleanup,
                          isSelected: isSelected,
                          chipColor: chipColor,
                          onTap: () => setState(() => _selectedCleanupDifficulty = cleanup),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Assign To Parents
                    _buildLabel('Assign to Parents'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        // "Me" chip
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _assignToMom = !_assignToMom;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: _assignToMom
                                  ? (FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : _parentInfo.myColor.withValues(alpha: 0.15))
                                  : (FFAppState().isComfortMode
                                      ? const Color(0xFF2C3E50)
                                      : const Color(0xFFF5F5F5)),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: _assignToMom
                                    ? (FFAppState().isComfortMode
                                        ? const Color(0xFF95A5A6)
                                        : _parentInfo.myColor)
                                    : Colors.transparent,
                                width: _assignToMom ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: _parentInfo.myColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _parentInfo.myInitial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  _parentInfo.myName,
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFFECF0F1)
                                        : const Color(0xFF5D4E60),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_assignToMom) ...[
                                  const SizedBox(width: 4.0),
                                  Icon(
                                    Icons.check_circle,
                                    size: 16.0,
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFFECF0F1)
                                        : _parentInfo.myColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        // Partner chip
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _assignToDad = !_assignToDad;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: _assignToDad
                                  ? (FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : _parentInfo.partnerColor.withValues(alpha: 0.15))
                                  : (FFAppState().isComfortMode
                                      ? const Color(0xFF2C3E50)
                                      : const Color(0xFFF5F5F5)),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: _assignToDad
                                    ? (FFAppState().isComfortMode
                                        ? const Color(0xFF95A5A6)
                                        : _parentInfo.partnerColor)
                                    : Colors.transparent,
                                width: _assignToDad ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: _parentInfo.partnerColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _parentInfo.partnerInitial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  _parentInfo.partnerName,
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFFECF0F1)
                                        : const Color(0xFF5D4E60),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_assignToDad) ...[
                                  const SizedBox(width: 4.0),
                                  Icon(
                                    Icons.check_circle,
                                    size: 16.0,
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFFECF0F1)
                                        : _parentInfo.partnerColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Child Selection
                    if (_userChildren != null && _userChildren!.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      _buildLabel('Assign to Children'),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _userChildren!.map((child) {
                          final isSelected = _selectedChildren.contains(child.reference);
                          final color = child.selectedColor ?? const Color(0xFF52A097);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedChildren.remove(child.reference);
                                } else {
                                  _selectedChildren.add(child.reference);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (FFAppState().isComfortMode
                                        ? const Color(0xFF7F8C8D)
                                        : color.withValues(alpha: 0.15))
                                    : (FFAppState().isComfortMode
                                        ? const Color(0xFF2C3E50)
                                        : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: isSelected
                                      ? (FFAppState().isComfortMode
                                          ? const Color(0xFF95A5A6)
                                          : color)
                                      : Colors.transparent,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        child.name.isNotEmpty ? child.name[0].toLowerCase() : 'C',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    child.name,
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      color: FFAppState().isComfortMode
                                          ? const Color(0xFFECF0F1)
                                          : const Color(0xFF5D4E60),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4.0),
                                    Icon(
                                      Icons.check_circle,
                                      size: 16.0,
                                      color: FFAppState().isComfortMode
                                          ? const Color(0xFFECF0F1)
                                          : color,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Things needed (at the bottom)
                    const SizedBox(height: 16.0),
                    _buildLabelWithIcon('Things Needed', Icons.list),
                    TextFormField(
                      controller: _thingsNeededController,
                      decoration: _buildInputDecoration('e.g., Paper, paint, brushes'),
                      style: _inputTextStyle(),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16.0),

                    // Safety note
                    _buildLabelWithIcon('Safety Note', Icons.warning_amber_rounded),
                    TextFormField(
                      controller: _safetyNoteController,
                      decoration: _buildInputDecoration('Any safety concerns or precautions'),
                      style: _inputTextStyle(),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24.0),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: _isSaving ? null : _saveActivity,
                        text: _isSaving ? 'Saving...' : 'Save Activity',
                        options: FFButtonOptions(
                          height: 50.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                    // Delete button (only when editing)
                    if (_isEditing) ...[
                      const SizedBox(height: 12.0),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _isSaving ? null : _confirmDelete,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: Text(
                            'Delete Activity',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              fontSize: 16.0,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Andika New Basic',
          color: FFAppState().isComfortMode
              ? const Color(0xFFECF0F1)
              : FlutterFlowTheme.of(context).primaryText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
        ),
      ),
    );
  }

  Widget _buildLabelWithIcon(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.0,
            color: FFAppState().isComfortMode
                ? const Color(0xFFECF0F1)
                : FlutterFlowTheme.of(context).primaryText,
          ),
          const SizedBox(width: 6.0),
          Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: FFAppState().isComfortMode
                  ? const Color(0xFFECF0F1)
                  : FlutterFlowTheme.of(context).primaryText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Andika New Basic',
        color: FFAppState().isComfortMode
            ? const Color(0xFF7F8C8D)
            : FlutterFlowTheme.of(context).secondaryText.withValues(alpha:0.6),
      ),
      filled: true,
      fillColor: FFAppState().isComfortMode
          ? const Color(0xFF2C3E50)
          : FlutterFlowTheme.of(context).prim30, // Teal background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: FFAppState().isComfortMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFCBE3E0), width: 1.0), // Teal border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: FFAppState().isComfortMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFCBE3E0), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  TextStyle _inputTextStyle() {
    return TextStyle(
      fontFamily: 'Andika New Basic',
      color: FFAppState().isComfortMode
          ? const Color(0xFFECF0F1)
          : FlutterFlowTheme.of(context).primaryText,
    );
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = createUserActivityRecordData(
        userRef: currentUserReference,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        timeDuration: '$_durationMinutes minutes',
        parentProximity: _selectedParentProximity,
        setupTime: _selectedSetupTime,
        cleanupDifficulty: _selectedCleanupDifficulty,
        iconEmoji: _selectedEmoji,
        thingsNeeded: _thingsNeededController.text.trim(),
        safetyNote: _safetyNoteController.text.trim(),
        isFavorite: _isEditing ? widget.editActivity!.isFavorite : false,
        timesUsed: _isEditing ? widget.editActivity!.timesUsed : 0,
        createdTime: _isEditing ? widget.editActivity!.createdTime : getCurrentTimestamp,
        updatedTime: getCurrentTimestamp,
        assignedChildren: _selectedChildren.toList(),
        assignedToMom: _assignToMom,
        assignedToDad: _assignToDad,
      );

      if (_isEditing) {
        // Update existing activity
        // Explicitly update assigned_children to ensure empty arrays are handled
        await widget.editActivity!.reference.update({
          ...data,
          'assigned_children': _selectedChildren.toList(), // Explicitly set even if empty
        });
      } else {
        // Create new activity
        await UserActivityRecord.collection.add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSave?.call();
        await MomRiseConfirmation.show(context, message: _isEditing ? 'Activity Updated' : 'Activity Saved');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FFAppState().isComfortMode
            ? const Color(0xFF34495E)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Delete Activity?',
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            color: FFAppState().isComfortMode
                ? const Color(0xFFECF0F1)
                : const Color(0xFF5D4E60),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_titleController.text}"? This cannot be undone.',
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            color: FFAppState().isComfortMode
                ? const Color(0xFF95A5A6)
                : const Color(0xFF5D4E60),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: FFAppState().isComfortMode
                    ? const Color(0xFF95A5A6)
                    : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      try {
        await widget.editActivity!.reference.delete();
        if (mounted) {
          Navigator.pop(context);
          widget.onSave?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting activity: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  /// Builds an animated selection chip with shadow effect on selection
  Widget _buildAnimatedChip({
    required String label,
    required bool isSelected,
    required Color chipColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (FFAppState().isComfortMode ? chipColor : chipColor)
              : (FFAppState().isComfortMode
                  ? const Color(0xFF2C3E50)
                  : chipColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (FFAppState().isComfortMode
                    ? chipColor.withValues(alpha: 0.3)
                    : chipColor.withValues(alpha: 0.3)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            color: isSelected
                ? Colors.white
                : (FFAppState().isComfortMode
                    ? chipColor.withValues(alpha: 0.8)
                    : chipColor),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}

/// Quick assignment bottom sheet for adding activity to calendar
class QuickAddAssignmentSheet extends StatefulWidget {
  final UserActivityRecord activity;
  final Function(List<DocumentReference>, bool, bool, DateTime) onConfirm;

  const QuickAddAssignmentSheet({
    super.key,
    required this.activity,
    required this.onConfirm,
  });

  @override
  State<QuickAddAssignmentSheet> createState() => _QuickAddAssignmentSheetState();
}

class _QuickAddAssignmentSheetState extends State<QuickAddAssignmentSheet> {
  List<ChildernRecord>? _userChildren;
  Set<DocumentReference> _selectedChildren = {};
  bool _assignToMom = false;
  bool _assignToDad = false;
  bool _isLoading = false;
  DateTime? _selectedDate; // null means Today

  // Parent display info
  ParentDisplayInfo _parentInfo = ParentDisplayInfo.defaults();

  @override
  void initState() {
    super.initState();
    // Pre-fill from activity defaults
    _selectedChildren = widget.activity.assignedChildren.toSet();
    _assignToMom = widget.activity.assignedToMom;
    _assignToDad = widget.activity.assignedToDad;
    _loadUserChildren();
    _loadParentInfo();
  }

  Future<void> _loadUserChildren() async {
    final children = await queryChildernRecordOnce(
      queryBuilder: (childernRecord) => childernRecord.where(
        'userRef',
        isEqualTo: currentUserReference,
      ),
    );
    if (mounted) {
      setState(() {
        _userChildren = children;
      });
    }
  }

  Future<void> _loadParentInfo() async {
    if (currentUserReference == null) return;
    final user = await UsersRecord.getDocumentOnce(currentUserReference!);
    if (mounted) {
      setState(() {
        _parentInfo = ParentDisplayInfo.fromUser(user);
      });
    }
  }

  /// Get the list of day options: Today, Tomorrow, and the next 5 days of the week
  List<Map<String, dynamic>> _getDayOptions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<Map<String, dynamic>> options = [
      {'label': 'Today', 'date': today},
      {'label': 'Tomorrow', 'date': today.add(const Duration(days: 1))},
    ];

    // Add next 5 days (skipping today and tomorrow)
    for (int i = 2; i <= 6; i++) {
      final date = today.add(Duration(days: i));
      final weekdayIndex = date.weekday - 1; // weekday is 1-7 (Mon-Sun)
      options.add({
        'label': weekdayNames[weekdayIndex],
        'date': date,
      });
    }

    return options;
  }

  Widget _buildDayChip(Map<String, dynamic> option, bool isComfortMode) {
    final isSelected = _selectedDate == option['date'] ||
        (_selectedDate == null && option['label'] == 'Today');
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = option['date'] as DateTime;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
              : (isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? FlutterFlowTheme.of(context).primary : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Text(
          option['label'] as String,
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : (isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60)),
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayOptions = _getDayOptions();
    final isComfortMode = FFAppState().isComfortMode;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20.0),
        decoration: BoxDecoration(
          color: isComfortMode ? const Color(0xFF34495E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: isComfortMode ? const Color(0xFF7F8C8D) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Title
              Text(
                'Add Activity',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Andika New Basic',
                  color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.activity.title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: isComfortMode ? const Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 20.0),

              // Day selection - stacked in rows
              Text(
                'When',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10.0),
              // First row: Today, Tomorrow
              Row(
                children: [
                  _buildDayChip(dayOptions[0], isComfortMode),
                  const SizedBox(width: 8.0),
                  _buildDayChip(dayOptions[1], isComfortMode),
                ],
              ),
              const SizedBox(height: 8.0),
              // Second row: Mon, Tue, Wed, Thu, Fri (or whatever 5 days come next)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: dayOptions.skip(2).map((option) => _buildDayChip(option, isComfortMode)).toList(),
              ),

              const SizedBox(height: 20.0),

              // Assign to Parents
              Text(
                'Assign to',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  // "Me" chip
                  GestureDetector(
                    onTap: () => setState(() => _assignToMom = !_assignToMom),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _assignToMom
                            ? _parentInfo.myColor.withValues(alpha: 0.15)
                            : (isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: _assignToMom ? _parentInfo.myColor : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _parentInfo.myColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(_parentInfo.myInitial, style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            _parentInfo.myName,
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_assignToMom) ...[
                            const SizedBox(width: 6.0),
                            Icon(Icons.check_circle, size: 18.0, color: _parentInfo.myColor),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Partner chip
                  GestureDetector(
                    onTap: () => setState(() => _assignToDad = !_assignToDad),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _assignToDad
                            ? _parentInfo.partnerColor.withValues(alpha: 0.15)
                            : (isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: _assignToDad ? _parentInfo.partnerColor : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _parentInfo.partnerColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(_parentInfo.partnerInitial, style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            _parentInfo.partnerName,
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_assignToDad) ...[
                            const SizedBox(width: 6.0),
                            Icon(Icons.check_circle, size: 18.0, color: _parentInfo.partnerColor),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Children selection
              if (_userChildren != null && _userChildren!.isNotEmpty) ...[
                const SizedBox(height: 20.0),
                Text(
                  'For children',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: _userChildren!.map((child) {
                    final isSelected = _selectedChildren.contains(child.reference);
                    final color = child.selectedColor ?? const Color(0xFF52A097);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedChildren.remove(child.reference);
                          } else {
                            _selectedChildren.add(child.reference);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : (isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  child.name.isNotEmpty ? child.name[0].toLowerCase() : 'C',
                                  style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              child.name,
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                color: isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6.0),
                              Icon(Icons.check_circle, size: 18.0, color: color),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24.0),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FFButtonWidget(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    final selectedDate = _selectedDate ?? DateTime.now();
                    final targetDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                    Navigator.pop(context);
                    await widget.onConfirm(
                      _selectedChildren.toList(),
                      _assignToMom,
                      _assignToDad,
                      targetDate,
                    );
                  },
                  text: _isLoading ? 'Adding...' : 'Add Activity',
                  options: FFButtonOptions(
                    height: 50.0,
                    color: const Color(0xFF4CAF50),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Andika New Basic',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
