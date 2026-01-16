import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/app_state.dart';
import 'activity_results_model.dart';
export 'activity_results_model.dart';

/// Activity Results - Shows top 3 activities for selected feeling
class ActivityResultsWidget extends StatefulWidget {
  const ActivityResultsWidget({
    super.key,
    required this.bubbleType,
  });

  final String bubbleType;

  static String routeName = 'ActivityResults';
  static String routePath = '/activity-results';

  @override
  State<ActivityResultsWidget> createState() => _ActivityResultsWidgetState();
}

class _ActivityResultsWidgetState extends State<ActivityResultsWidget> {
  late ActivityResultsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showMore = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActivityResultsModel());
    // Seed function already ran - commented out to prevent duplicates
    // _seedTestActivities();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _getBubbleFieldName(String bubbleType) {
    switch (bubbleType) {
      case 'calm':
        return 'bubble_calm';
      case 'move':
        return 'bubble_need_to_move';
      case 'channel':
        return 'bubble_need_to_move'; // Primary field for query, combined scoring in _getBubbleScore
      case 'learning':
        return 'bubble_learning';
      case 'creative':
        return 'bubble_creative';
      case 'independent':
        return 'bubble_independent';
      case 'connection':
        return 'bubble_connection';
      case 'outdoor':
        return 'bubble_outdoor';
      case 'minimal':
        return 'bubble_minimal_setup';
      case 'sensory':
        return 'bubble_sensory';
      case 'brain':
        return 'bubble_brain_busy';
      default:
        return 'bubble_calm';
    }
  }

  int _getBubbleScore(ActivityRecord activity, String bubbleType) {
    switch (bubbleType) {
      case 'calm':
        return activity.bubbleCalm;
      case 'move':
        return activity.bubbleNeedToMove;
      case 'channel':
        // Combined score: movement + brain engagement for directed energy activities
        // This prioritizes activities that burn energy AND keep the mind busy
        return ((activity.bubbleNeedToMove * 0.6) + (activity.bubbleBrainBusy * 0.4)).round();
      case 'learning':
        return activity.bubbleLearning;
      case 'creative':
        return activity.bubbleCreative;
      case 'independent':
        return activity.bubbleIndependent;
      case 'connection':
        return activity.bubbleConnection;
      case 'outdoor':
        return activity.bubbleOutdoor;
      case 'minimal':
        return activity.bubbleMinimalSetup;
      case 'sensory':
        return activity.bubbleSensory;
      case 'brain':
        return activity.bubbleBrainBusy;
      default:
        return 0;
    }
  }

  String _getBubbleTitle(String bubbleType) {
    switch (bubbleType) {
      case 'calm':
        return 'Peaceful activities';
      case 'move':
        return 'High energy activities';
      case 'channel':
        return 'Channel that energy';
      case 'learning':
        return 'Learning activities';
      case 'creative':
        return 'Creative activities';
      case 'independent':
        return 'Independent activities';
      case 'connection':
        return 'Connection activities';
      case 'outdoor':
        return 'Outdoor activities';
      case 'minimal':
        return 'Quick setup activities';
      case 'sensory':
        return 'Sensory activities';
      case 'brain':
        return 'Brain-engaging activities';
      default:
        return 'Activities';
    }
  }

  String _getBubbleSubtitle(String bubbleType) {
    switch (bubbleType) {
      case 'calm':
        return 'Perfect for peaceful moments';
      case 'move':
        return 'Great for burning energy';
      case 'channel':
        return 'Active AND engaging activities';
      case 'learning':
        return 'Fun ways to learn';
      case 'creative':
        return 'Time to create something special';
      case 'independent':
        return 'Activities for solo play';
      case 'connection':
        return 'Quality time together';
      case 'outdoor':
        return 'Fresh air adventures';
      case 'minimal':
        return 'Easy to set up';
      case 'sensory':
        return 'Engage the senses';
      case 'brain':
        return 'Keep those minds busy';
      default:
        return 'Top picks for right now';
    }
  }

  /// Seed test activities into Firestore (call once for testing)
  /// Uses the clean schema: 23 fields total
  Future<void> _seedTestActivities() async {
    final testActivities = [
      {
        // Core fields
        'title': 'Spoon & Bowl Transfer',
        'description': 'The child transfers objects from one bowl to another using a spoon, focusing on control and coordination.',
        'location': 'indoor',
        'energy': 'low',
        'things_needed': 'Two bowls, spoon, dry beans',
        'activity_safety_concerns': 'Choking hazard; supervise closely.',
        'time_duration': '10 minutes',
        // Child/parent context
        'readiness_level': 'exploring',
        'age_floor': 18,
        'parent_proximity': 'nearby',
        'setup_time': '0-2 min',
        'cleanup_difficulty': 'easy',
        'supervision_needed': true,
        // Bubble scores (1-10)
        'bubble_calm': 9,
        'bubble_need_to_move': 2,
        'bubble_learning': 7,
        'bubble_creative': 3,
        'bubble_independent': 8,
        'bubble_connection': 2,
        'bubble_outdoor': 0,
        'bubble_minimal_setup': 8,
        'bubble_sensory': 6,
        'bubble_brain_busy': 7,
      },
      {
        'title': "Painter's Tape Road",
        'description': 'Tape lines on the floor to create paths for walking, cars, or animals.',
        'location': 'indoor',
        'energy': 'medium',
        'things_needed': "Painter's tape",
        'activity_safety_concerns': 'Remove tape slowly to avoid residue.',
        'time_duration': '15 minutes',
        'readiness_level': 'moving',
        'age_floor': 20,
        'parent_proximity': 'free',
        'setup_time': '3-5 min',
        'cleanup_difficulty': 'easy',
        'supervision_needed': false,
        'bubble_calm': 4,
        'bubble_need_to_move': 7,
        'bubble_learning': 4,
        'bubble_creative': 7,
        'bubble_independent': 6,
        'bubble_connection': 3,
        'bubble_outdoor': 0,
        'bubble_minimal_setup': 7,
        'bubble_sensory': 4,
        'bubble_brain_busy': 5,
      },
      {
        'title': 'Nature Sorting Tray',
        'description': 'The child sorts natural objects by size, texture, or color.',
        'location': 'outdoor',
        'energy': 'low',
        'things_needed': 'Tray and nature items',
        'activity_safety_concerns': 'Check items for sharp edges.',
        'time_duration': '20 minutes',
        'readiness_level': 'observing',
        'age_floor': 18,
        'parent_proximity': 'nearby',
        'setup_time': '3-5 min',
        'cleanup_difficulty': 'easy',
        'supervision_needed': true,
        'bubble_calm': 8,
        'bubble_need_to_move': 3,
        'bubble_learning': 8,
        'bubble_creative': 5,
        'bubble_independent': 7,
        'bubble_connection': 3,
        'bubble_outdoor': 9,
        'bubble_minimal_setup': 6,
        'bubble_sensory': 9,
        'bubble_brain_busy': 7,
      },
      {
        'title': 'Cloth Pull Box',
        'description': 'The child pulls scarves or cloths through a hole in a box.',
        'location': 'indoor',
        'energy': 'low',
        'things_needed': 'Box and cloths',
        'activity_safety_concerns': 'Ensure hole edges are smooth.',
        'time_duration': '10 minutes',
        'readiness_level': 'grasping',
        'age_floor': 14,
        'parent_proximity': 'free',
        'setup_time': '0-2 min',
        'cleanup_difficulty': 'easy',
        'supervision_needed': false,
        'bubble_calm': 8,
        'bubble_need_to_move': 2,
        'bubble_learning': 6,
        'bubble_creative': 4,
        'bubble_independent': 9,
        'bubble_connection': 2,
        'bubble_outdoor': 0,
        'bubble_minimal_setup': 7,
        'bubble_sensory': 7,
        'bubble_brain_busy': 6,
      },
      {
        'title': 'Water Pour Practice',
        'description': 'The child pours water between containers to practice coordination.',
        'location': 'indoor',
        'energy': 'low',
        'things_needed': 'Pitcher, cups, water',
        'activity_safety_concerns': 'Slipping hazard from spills.',
        'time_duration': '15 minutes',
        'readiness_level': 'practicing',
        'age_floor': 20,
        'parent_proximity': 'nearby',
        'setup_time': '3-5 min',
        'cleanup_difficulty': 'messy',
        'supervision_needed': true,
        'bubble_calm': 9,
        'bubble_need_to_move': 2,
        'bubble_learning': 8,
        'bubble_creative': 3,
        'bubble_independent': 8,
        'bubble_connection': 2,
        'bubble_outdoor': 0,
        'bubble_minimal_setup': 6,
        'bubble_sensory': 8,
        'bubble_brain_busy': 7,
      },
    ];

    for (final activity in testActivities) {
      await ActivityRecord.collection.add(activity);
    }
    debugPrint('Seeded ${testActivities.length} test activities');
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isComfortMode = FFAppState().isComfortMode;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isComfortMode ? Color(0xFF2C3E50) : Color(0xFFFFE9E1),
        body: Container(
          decoration: BoxDecoration(
            gradient: isComfortMode
              ? LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                )
              : LinearGradient(
                  colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
          ),
          child: SafeArea(
            child: StreamBuilder<List<ActivityRecord>>(
              stream: queryActivityRecord(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  );
                }

                List<ActivityRecord> allActivities = snapshot.data!;

                // Sort by bubble score descending
                allActivities.sort((a, b) {
                  int scoreA = _getBubbleScore(a, widget.bubbleType);
                  int scoreB = _getBubbleScore(b, widget.bubbleType);
                  return scoreB.compareTo(scoreA);
                });

                // Get top 3 and next batch
                List<ActivityRecord> topActivities =
                    allActivities.take(3).toList();
                List<ActivityRecord> moreActivities = allActivities.length > 3
                    ? allActivities.skip(3).take(5).toList()
                    : [];

                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        InkWell(
                          onTap: () {
                            context.pop();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: isComfortMode
                                  ? Color(0xFF95A5A6)
                                  : FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Back',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: isComfortMode
                                        ? Color(0xFF95A5A6)
                                        : FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.0),

                        // Page title
                        Text(
                          _getBubbleTitle(widget.bubbleType),
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: isComfortMode ? Colors.white : null,
                                fontSize: 28.0,
                                letterSpacing: isComfortMode ? 0.5 : 0.0,
                                fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.bold,
                              ),
                        ),

                        SizedBox(height: 8.0),

                        Text(
                          _getBubbleSubtitle(widget.bubbleType),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: isComfortMode
                                  ? Colors.white.withOpacity(0.7)
                                  : FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16.0,
                                letterSpacing: isComfortMode ? 0.5 : 0.0,
                                fontWeight: isComfortMode ? FontWeight.w300 : null,
                              ),
                        ),

                        SizedBox(height: 32.0),

                        // Top 3 activities
                        ...topActivities.map((activity) {
                          return Column(
                            children: [
                              _buildActivityCard(activity),
                              SizedBox(height: 16.0),
                            ],
                          );
                        }).toList(),

                        // Show more button
                        if (moreActivities.isNotEmpty && !_showMore)
                          Center(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showMore = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isComfortMode
                                      ? Colors.white.withOpacity(0.5)
                                      : FlutterFlowTheme.of(context).primary,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Text(
                                  'Show more',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: isComfortMode
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context).primary,
                                        fontSize: 16.0,
                                        letterSpacing: isComfortMode ? 0.5 : 0.0,
                                        fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                                      ),
                                ),
                              ),
                            ),
                          ),

                        // Additional activities
                        if (_showMore)
                          ...moreActivities.map((activity) {
                            return Column(
                              children: [
                                _buildActivityCard(activity),
                                SizedBox(height: 16.0),
                              ],
                            );
                          }).toList(),

                        SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getActivityEmoji(String title) {
    if (title.toLowerCase().contains('sock')) return '🧦';
    if (title.toLowerCase().contains('pour')) return '💧';
    if (title.toLowerCase().contains('tape') || title.toLowerCase().contains('road')) return '🚗';
    if (title.toLowerCase().contains('nature') || title.toLowerCase().contains('sound')) return '👂';
    if (title.toLowerCase().contains('box') || title.toLowerCase().contains('cardboard')) return '📦';
    if (title.toLowerCase().contains('color')) return '🌈';
    if (title.toLowerCase().contains('dance')) return '💃';
    if (title.toLowerCase().contains('shadow')) return '🔦';
    if (title.toLowerCase().contains('bubble wrap')) return '🫧';
    if (title.toLowerCase().contains('sensory') || title.toLowerCase().contains('calm')) return '✨';
    return '🎯';
  }

  Widget _buildTag(String text, Color backgroundColor) {
    final isComfortMode = FFAppState().isComfortMode;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isComfortMode ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: isComfortMode
          ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
          : null,
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Andika New Basic',
              color: isComfortMode ? Colors.white : null,
              fontSize: 12.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityRecord activity) {
    final isComfortMode = FFAppState().isComfortMode;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: isComfortMode
          ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
          : null,
        boxShadow: isComfortMode ? null : [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with emoji and favorite button
          Row(
            children: [
              if (!isComfortMode)
                Text(
                  _getActivityEmoji(activity.title),
                  style: TextStyle(fontSize: 32.0),
                ),
              if (!isComfortMode) SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  activity.title,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        color: isComfortMode ? Colors.white : null,
                        fontSize: 20.0,
                        letterSpacing: isComfortMode ? 0.5 : 0.0,
                        fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.bold,
                      ),
                ),
              ),
              // Favorite button
              InkWell(
                onTap: () {
                  setState(() {
                    FFAppState().toggleFavoriteActivity(activity.reference);
                  });
                },
                child: Icon(
                  FFAppState().isFavoriteActivity(activity.reference)
                    ? Icons.favorite
                    : Icons.favorite_border,
                  color: isComfortMode
                    ? (FFAppState().isFavoriteActivity(activity.reference)
                      ? Colors.red.shade300
                      : Colors.white.withOpacity(0.5))
                    : (FFAppState().isFavoriteActivity(activity.reference)
                      ? Colors.red
                      : FlutterFlowTheme.of(context).secondaryText),
                  size: 24.0,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.0),

          // Description
          Text(
            activity.description,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: isComfortMode ? Colors.white.withOpacity(0.9) : null,
                  fontSize: 15.0,
                  letterSpacing: 0.0,
                ),
          ),

          SizedBox(height: 16.0),

          // Metadata - colored tags
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              if (activity.hasTimeDuration())
                _buildTag('Time: ${activity.timeDuration}', Color(0xFFE3F2FD)),
              if (activity.hasParentProximity())
                _buildTag(
                  activity.parentProximity == 'free'
                    ? 'Parent: Free'
                    : activity.parentProximity == 'nearby'
                      ? 'Parent: Nearby'
                      : 'Parent: Together',
                  Color(0xFFFFF3E0),
                ),
              if (activity.hasSetupTime())
                _buildTag('Setup: ${activity.setupTime}', Color(0xFFF3E5F5)),
              if (activity.hasCleanupDifficulty())
                _buildTag('Cleanup: ${activity.cleanupDifficulty}', Color(0xFFE8F5E9)),
            ],
          ),

          if (activity.hasThingsNeeded())
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 12.0, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    color: isComfortMode ? Colors.white.withOpacity(0.7) : FlutterFlowTheme.of(context).secondaryText,
                    size: 18.0,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      activity.thingsNeeded,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: isComfortMode ? Colors.white.withOpacity(0.8) : FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

}
