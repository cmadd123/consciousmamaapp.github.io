import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/todo/addcalender/addcalender_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Filter state for Browse All mode
  String? _filterDuration; // null = any, or "10 minutes", "15 minutes", etc.
  String? _filterSetup; // null = any, "0-2 min", "3-5 min", "5+ min"
  String? _filterCleanup; // null = any, "easy", "medium", "messy"
  String? _filterParentProximity; // null = any, "free", "nearby", "involved"

  // Search state
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  String _getBubbleFieldName(String bubbleType) {
    // Check if it's a category type (situation bubbles)
    if (_isCategoryType(bubbleType)) {
      return 'category'; // Filter by category field for situation bubbles
    }

    // Otherwise use bubble fields for feeling bubbles
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

  bool _isCategoryType(String bubbleType) {
    return const ['sibling', 'transition', 'energy', 'quick', 'independent',
                  'calm', 'cooking', 'bath', 'messy', 'weather'].contains(bubbleType);
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
      // Situation categories (practical, parent-centered)
      case 'sibling':
        return 'Sibling Peacekeepers';
      case 'transition':
        return 'Transition & Waiting';
      case 'energy':
        return 'Energy Burners';
      case 'quick':
        return 'Quick Wins';
      case 'cooking':
        return 'Cooking Together';
      case 'bath':
        return 'Bath Time Fun';
      case 'messy':
        return 'Messy Play';
      case 'weather':
        return 'Weather Days';
      // Feeling bubbles (emotional states)
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
        return 'Independent Play';
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
      case 'all':
        return 'All Activities';
      default:
        return 'Activities';
    }
  }

  String _getBubbleSubtitle(String bubbleType) {
    switch (bubbleType) {
      // Situation categories - practical, problem-solving language
      case 'sibling':
        return 'Reduce fighting and promote cooperation between siblings';
      case 'transition':
        return 'Keep them busy during car rides, appointments, and waiting rooms';
      case 'energy':
        return 'Burn off excess energy when they need to move their bodies NOW';
      case 'quick':
        return 'Under 10 minutes with minimal setup - easy wins for busy moments';
      case 'cooking':
        return 'Kitchen tasks they can actually help with while you cook';
      case 'bath':
        return 'Make bath time easier and more enjoyable for everyone';
      case 'messy':
        return 'Sensory-rich activities for when you\'re ready for cleanup';
      case 'weather':
        return 'Outdoor fun for sunny days or creative indoor alternatives for rain/snow';
      // Feeling bubbles
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
        return 'So you can get something done while they play solo';
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
      case 'all':
        return 'Browse and plan ahead';
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

                // Filter by category if it's a category type (situation bubble)
                if (_isCategoryType(widget.bubbleType)) {
                  allActivities = allActivities.where((activity) {
                    return activity.category == widget.bubbleType;
                  }).toList();
                }

                // Apply filters for 'all' mode
                if (widget.bubbleType == 'all') {
                  allActivities = allActivities.where((activity) {
                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final titleMatch = activity.title.toLowerCase().contains(_searchQuery);
                      final descMatch = activity.description.toLowerCase().contains(_searchQuery);
                      final thingsMatch = activity.thingsNeeded.toLowerCase().contains(_searchQuery);
                      if (!titleMatch && !descMatch && !thingsMatch) {
                        return false;
                      }
                    }
                    // Duration filter
                    if (_filterDuration != null && activity.timeDuration != _filterDuration) {
                      return false;
                    }
                    // Setup time filter
                    if (_filterSetup != null && activity.setupTime != _filterSetup) {
                      return false;
                    }
                    // Cleanup filter
                    if (_filterCleanup != null && activity.cleanupDifficulty != _filterCleanup) {
                      return false;
                    }
                    // Parent proximity filter
                    if (_filterParentProximity != null && activity.parentProximity != _filterParentProximity) {
                      return false;
                    }
                    return true;
                  }).toList();
                }

                // Sort by bubble score descending, or alphabetically for 'all'
                if (widget.bubbleType == 'all') {
                  allActivities.sort((a, b) => a.title.compareTo(b.title));
                } else {
                  allActivities.sort((a, b) {
                    int scoreA = _getBubbleScore(a, widget.bubbleType);
                    int scoreB = _getBubbleScore(b, widget.bubbleType);
                    return scoreB.compareTo(scoreA);
                  });
                }

                // Get top 3 and next batch (or all for browse mode)
                List<ActivityRecord> topActivities;
                List<ActivityRecord> moreActivities;
                if (widget.bubbleType == 'all') {
                  // Show more items initially in browse mode
                  topActivities = allActivities.take(6).toList();
                  moreActivities = allActivities.length > 6
                      ? allActivities.skip(6).toList()
                      : [];
                } else {
                  topActivities = allActivities.take(3).toList();
                  moreActivities = allActivities.length > 3
                      ? allActivities.skip(3).take(5).toList()
                      : [];
                }

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

                        // Search and Filter chips for Browse All mode
                        if (widget.bubbleType == 'all') ...[
                          SizedBox(height: 16.0),
                          // Search field
                          Container(
                            decoration: BoxDecoration(
                              color: isComfortMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(14.0),
                              border: isComfortMode
                                  ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                                  : null,
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                fontSize: 15.0,
                                color: isComfortMode ? Colors.white : const Color(0xFF5D4E60),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search activities...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 15.0,
                                  color: isComfortMode
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.grey,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: isComfortMode
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.grey,
                                  size: 20.0,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: isComfortMode
                                              ? Colors.white.withValues(alpha: 0.7)
                                              : Colors.grey,
                                          size: 20.0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 14.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  label: _filterDuration ?? 'Time',
                                  isActive: _filterDuration != null,
                                  onTap: () => _showFilterSheet(
                                    context,
                                    'Duration',
                                    ['10 minutes', '15 minutes', '20 minutes', '30 minutes'],
                                    _filterDuration,
                                    (value) => setState(() => _filterDuration = value),
                                    filterType: 'duration',
                                  ),
                                  isComfortMode: isComfortMode,
                                  filterType: 'duration',
                                ),
                                SizedBox(width: 8.0),
                                _buildFilterChip(
                                  label: _filterSetup != null ? 'Setup: $_filterSetup' : 'Setup',
                                  isActive: _filterSetup != null,
                                  onTap: () => _showFilterSheet(
                                    context,
                                    'Setup Time',
                                    ['0-2 min', '3-5 min', '5+ min'],
                                    _filterSetup,
                                    (value) => setState(() => _filterSetup = value),
                                    filterType: 'setup',
                                  ),
                                  isComfortMode: isComfortMode,
                                  filterType: 'setup',
                                ),
                                SizedBox(width: 8.0),
                                _buildFilterChip(
                                  label: _filterCleanup != null ? 'Cleanup: $_filterCleanup' : 'Cleanup',
                                  isActive: _filterCleanup != null,
                                  onTap: () => _showFilterSheet(
                                    context,
                                    'Cleanup Difficulty',
                                    ['easy', 'medium', 'messy'],
                                    _filterCleanup,
                                    (value) => setState(() => _filterCleanup = value),
                                    filterType: 'cleanup',
                                  ),
                                  isComfortMode: isComfortMode,
                                  filterType: 'cleanup',
                                ),
                                SizedBox(width: 8.0),
                                _buildFilterChip(
                                  label: _filterParentProximity != null
                                      ? (_filterParentProximity == 'free' ? 'Independent'
                                          : _filterParentProximity == 'nearby' ? 'Nearby' : 'Together')
                                      : 'Parent',
                                  isActive: _filterParentProximity != null,
                                  onTap: () => _showFilterSheet(
                                    context,
                                    'Parent Involvement',
                                    ['free', 'nearby', 'involved'],
                                    _filterParentProximity,
                                    (value) => setState(() => _filterParentProximity = value),
                                    displayLabels: {'free': 'Independent', 'nearby': 'Nearby', 'involved': 'Together'},
                                    filterType: 'parent',
                                  ),
                                  isComfortMode: isComfortMode,
                                  filterType: 'parent',
                                ),
                                // Clear all filters button
                                if (_filterDuration != null || _filterSetup != null ||
                                    _filterCleanup != null || _filterParentProximity != null) ...[
                                  SizedBox(width: 8.0),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _filterDuration = null;
                                        _filterSetup = null;
                                        _filterCleanup = null;
                                        _filterParentProximity = null;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.clear, size: 16.0, color: Colors.red),
                                          SizedBox(width: 4.0),
                                          Text(
                                            'Clear',
                                            style: TextStyle(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 13.0,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          // Results count
                          Text(
                            '${allActivities.length} activities',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode
                                  ? Colors.white.withOpacity(0.5)
                                  : FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 13.0,
                            ),
                          ),
                        ],

                        SizedBox(height: 24.0),

                        // Empty state when no activities match
                        if (allActivities.isEmpty && widget.bubbleType == 'all')
                          _buildEmptyFilterState(isComfortMode)
                        else
                          // Activities list
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

  /// Empty state shown when no activities match the current filters/search
  Widget _buildEmptyFilterState(bool isComfortMode) {
    final hasFilters = _filterDuration != null ||
        _filterSetup != null ||
        _filterCleanup != null ||
        _filterParentProximity != null;
    final hasSearch = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.filter_list_off,
              size: 56.0,
              color: isComfortMode
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              hasSearch
                  ? 'No activities match "$_searchQuery"'
                  : 'No activities match these filters',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : const Color(0xFF5D4E60),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              hasSearch || hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'No activities available',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.grey,
                    fontSize: 14.0,
                  ),
            ),
            if (hasSearch || hasFilters) ...[
              const SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _filterDuration = null;
                    _filterSetup = null;
                    _filterCleanup = null;
                    _filterParentProximity = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isComfortMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.0),
                    border: isComfortMode
                        ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontFamily: 'Andika New Basic',
                      fontSize: 14.0,
                      color: isComfortMode
                          ? Colors.white
                          : FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getActivityEmoji(String title) {
    final titleLower = title.toLowerCase();

    // Sibling activities
    if (titleLower.contains('cardboard') || titleLower.contains('city')) return '📦';
    if (titleLower.contains('pass') && titleLower.contains('ball')) return '⚽';
    if (titleLower.contains('puzzle') && titleLower.contains('race')) return '🧩';

    // Transition activities
    if (titleLower.contains('i spy') || titleLower.contains('car')) return '🚗';
    if (titleLower.contains('counting') || titleLower.contains('waiting')) return '🔢';
    if (titleLower.contains('sticker')) return '⭐';

    // Energy activities
    if (titleLower.contains('pillowcase') || titleLower.contains('race')) return '🏃';
    if (titleLower.contains('freeze') && titleLower.contains('dance')) return '💃';
    if (titleLower.contains('balloon')) return '🎈';

    // Quick activities
    if (titleLower.contains('napkin') || titleLower.contains('folding')) return '🍽️';
    if (titleLower.contains('sock')) return '🧦';
    if (titleLower.contains('magnet')) return '🧲';

    // Independent activities
    if (titleLower.contains('button')) return '🔘';
    if (titleLower.contains('coloring') || titleLower.contains('color')) return '🖍️';
    if (titleLower.contains('duplo') || titleLower.contains('building')) return '🧱';

    // Calm activities
    if (titleLower.contains('breathing') || titleLower.contains('stuffed')) return '🧸';
    if (titleLower.contains('quiet') && titleLower.contains('book')) return '📖';
    if (titleLower.contains('rocking')) return '🪑';

    // Cooking activities
    if (titleLower.contains('banana') || titleLower.contains('slicing')) return '🍌';
    if (titleLower.contains('vegetable') || titleLower.contains('washing')) return '🥕';
    if (titleLower.contains('strawberry')) return '🍓';

    // Bath activities
    if (titleLower.contains('bubble') && titleLower.contains('bath')) return '🫧';
    if (titleLower.contains('pour') && titleLower.contains('bath')) return '💧';
    if (titleLower.contains('bath') && titleLower.contains('crayon')) return '🖍️';

    // Messy activities
    if (titleLower.contains('shaving') && titleLower.contains('cream')) return '🫧';
    if (titleLower.contains('mud')) return '🪴';
    if (titleLower.contains('paint') && titleLower.contains('ice')) return '🧊';

    // Weather activities
    if (titleLower.contains('puddle')) return '🌧️';
    if (titleLower.contains('snow')) return '❄️';
    if (titleLower.contains('shadow')) return '☀️';

    // Legacy/fallback patterns
    if (titleLower.contains('pour')) return '💧';
    if (titleLower.contains('tape') || titleLower.contains('road')) return '🚗';
    if (titleLower.contains('nature') || titleLower.contains('sound')) return '👂';
    if (titleLower.contains('box')) return '📦';
    if (titleLower.contains('dance')) return '💃';
    if (titleLower.contains('bubble wrap')) return '🫧';
    if (titleLower.contains('sensory') || titleLower.contains('calm')) return '✨';

    return '🎯';
  }

  /// Build a colored chip for activity cards (smaller version of bottom sheet chips)
  Widget _buildCardChip(IconData icon, String label, bool isComfortMode, {Color? chipColor}) {
    final color = chipColor ?? FlutterFlowTheme.of(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isComfortMode
            ? color.withOpacity(0.2)
            : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.0,
            color: isComfortMode ? color.withOpacity(0.9) : color,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 12.0,
              color: isComfortMode ? color.withOpacity(0.9) : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityRecord activity) {
    final isComfortMode = FFAppState().isComfortMode;

    return GestureDetector(
      onTap: () => _showActivityDetailsSheet(context, activity),
      child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji in styled container (matches custom activity icon style)
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: isComfortMode
                      ? const Color(0xFF34495E)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Center(
                  child: Text(
                    _getActivityEmoji(activity.title),
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
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        color: isComfortMode ? Colors.white : null,
                        fontSize: 18.0,
                        letterSpacing: isComfortMode ? 0.5 : 0.0,
                        fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8.0),
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

          // Metadata - colored chips matching bottom sheet style
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              if (activity.hasTimeDuration())
                _buildCardChip(Icons.schedule, activity.timeDuration, isComfortMode, chipColor: const Color(0xFF9C27B0)),
              if (activity.hasParentProximity())
                _buildCardChip(
                  activity.parentProximity == 'free'
                      ? Icons.self_improvement
                      : activity.parentProximity == 'nearby'
                          ? Icons.visibility
                          : Icons.people,
                  activity.parentProximity == 'free'
                      ? 'Independent'
                      : activity.parentProximity == 'nearby'
                          ? 'Nearby'
                          : 'Together',
                  isComfortMode,
                  chipColor: activity.parentProximity == 'free'
                      ? const Color(0xFF4CAF50)
                      : activity.parentProximity == 'nearby'
                          ? const Color(0xFFFF9800)
                          : const Color(0xFFE91E63),
                ),
              if (activity.hasSetupTime())
                _buildCardChip(Icons.build_outlined, activity.setupTime, isComfortMode, chipColor: const Color(0xFF2196F3)),
              if (activity.hasCleanupDifficulty())
                _buildCardChip(
                  Icons.cleaning_services_outlined,
                  activity.cleanupDifficulty,
                  isComfortMode,
                  chipColor: activity.cleanupDifficulty == 'easy'
                      ? const Color(0xFF4CAF50)
                      : activity.cleanupDifficulty == 'medium'
                          ? const Color(0xFFFF9800)
                          : const Color(0xFFF44336),
                ),
            ],
          ),

          if (activity.hasThingsNeeded())
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 12.0, 0, 0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isComfortMode
                      ? const Color(0xFF2C3E50)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isComfortMode ? const Color(0xFF7F8C8D) : Colors.grey.withValues(alpha: 0.2),
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
                              color: isComfortMode ? const Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Safety notes on card
          if (activity.hasActivitySafetyConcerns())
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 12.0, 0, 0),
              child: Container(
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
                        color: Color(0xFFFF9800),
                        size: 16.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        activity.activitySafetyConcerns,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode ? const Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Quick Add buttons
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16.0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Quick add to today button
                InkWell(
                  onTap: () async {
                    await _showQuickAddSheet(context, activity);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isComfortMode
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.0),
                      border: isComfortMode
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 16.0,
                          color: isComfortMode ? Colors.white : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          'Quick Add',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            fontSize: 14.0,
                            color: isComfortMode ? Colors.white : const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                // Schedule button
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddcalenderWidget(
                          fromPage: 'activities',
                          prefillName: activity.title,
                          prefillDescription: activity.description,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isComfortMode
                        ? Colors.white.withOpacity(0.1)
                        : FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.0),
                      border: isComfortMode
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.0,
                          color: isComfortMode ? Colors.white : FlutterFlowTheme.of(context).primary,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          'Schedule',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            fontSize: 14.0,
                            color: isComfortMode ? Colors.white : FlutterFlowTheme.of(context).primary,
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
        ],
      ),
    ),
    );
  }

  /// Shows a bottom sheet with full activity details
  void _showActivityDetailsSheet(BuildContext context, ActivityRecord activity) {
    final isComfortMode = FFAppState().isComfortMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: isComfortMode ? const Color(0xFF34495E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar at top (outside scroll)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: isComfortMode ? const Color(0xFF7F8C8D) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, MediaQuery.of(sheetContext).padding.bottom + 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Header with emoji and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: isComfortMode
                            ? const Color(0xFF2C3E50)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Center(
                        child: Text(
                          _getActivityEmoji(activity.title),
                          style: const TextStyle(fontSize: 32.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode ? Colors.white : const Color(0xFF5D4E60),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (activity.hasLocation()) ...[
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                Icon(
                                  activity.location == 'outdoor' ? Icons.park : Icons.home,
                                  size: 16.0,
                                  color: isComfortMode ? const Color(0xFF95A5A6) : Colors.grey,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  activity.location == 'outdoor' ? 'Outdoor' : 'Indoor',
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 14.0,
                                    color: isComfortMode ? const Color(0xFF95A5A6) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Description
                Text(
                  activity.description,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode ? Colors.white.withOpacity(0.9) : const Color(0xFF5D4E60),
                    fontSize: 15.0,
                  ),
                ),

                const SizedBox(height: 20.0),

                // Detail chips with colors
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    if (activity.hasTimeDuration())
                      _buildDetailChip(Icons.schedule, activity.timeDuration, isComfortMode, chipColor: const Color(0xFF9C27B0)),
                    if (activity.hasSetupTime())
                      _buildDetailChip(Icons.build_outlined, 'Setup: ${activity.setupTime}', isComfortMode, chipColor: const Color(0xFF2196F3)),
                    if (activity.hasCleanupDifficulty())
                      _buildDetailChip(
                        Icons.cleaning_services_outlined,
                        'Cleanup: ${activity.cleanupDifficulty}',
                        isComfortMode,
                        chipColor: activity.cleanupDifficulty == 'easy'
                            ? const Color(0xFF4CAF50)
                            : activity.cleanupDifficulty == 'medium'
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFF44336),
                      ),
                    if (activity.hasParentProximity())
                      _buildDetailChip(
                        activity.parentProximity == 'free'
                            ? Icons.self_improvement
                            : activity.parentProximity == 'nearby'
                                ? Icons.visibility
                                : Icons.people,
                        activity.parentProximity == 'free'
                            ? 'Independent play'
                            : activity.parentProximity == 'nearby'
                                ? 'Parent nearby'
                                : 'Together time',
                        isComfortMode,
                        chipColor: activity.parentProximity == 'free'
                            ? const Color(0xFF4CAF50)
                            : activity.parentProximity == 'nearby'
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFE91E63),
                      ),
                  ],
                ),

                // Things needed section
                if (activity.hasThingsNeeded()) ...[
                  const SizedBox(height: 12.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isComfortMode
                          ? const Color(0xFF2C3E50)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: isComfortMode ? const Color(0xFF7F8C8D) : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.list_alt,
                            size: 18.0,
                            color: Color(0xFF95A5A6),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            activity.thingsNeeded,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode ? const Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Safety concerns section
                if (activity.hasActivitySafetyConcerns()) ...[
                  const SizedBox(height: 12.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
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
                            size: 18.0,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            activity.activitySafetyConcerns,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: isComfortMode ? const Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28.0),

                // Action buttons
                Row(
                  children: [
                    // Quick Add button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showQuickAddSheet(context, activity);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 20.0,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Quick Add',
                                style: TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Schedule button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddcalenderWidget(
                                fromPage: 'activities',
                                prefillName: activity.title,
                                prefillDescription: activity.description,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: BoxDecoration(
                            color: isComfortMode
                                ? Colors.white.withOpacity(0.1)
                                : FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: isComfortMode
                                  ? Colors.white.withOpacity(0.3)
                                  : FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20.0,
                                color: isComfortMode ? Colors.white : FlutterFlowTheme.of(context).primary,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Schedule',
                                style: TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 16.0,
                                  color: isComfortMode ? Colors.white : FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a detail chip with optional color
  Widget _buildDetailChip(IconData icon, String label, bool isComfortMode, {Color? chipColor}) {
    final color = chipColor ?? FlutterFlowTheme.of(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isComfortMode
            ? color.withOpacity(0.2)
            : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: isComfortMode ? color.withOpacity(0.9) : color,
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 13.0,
              color: isComfortMode ? color.withOpacity(0.9) : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuickAddSheet(BuildContext context, ActivityRecord activity) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityQuickAddSheet(activity: activity),
    );
  }

  /// Filter color mapping - matches the tag colors on activity cards
  static const Map<String, Color> _filterColors = {
    'duration': Color(0xFFE3F2FD), // blue background
    'setup': Color(0xFFF3E5F5), // purple background
    'cleanup': Color(0xFFE8F5E9), // green background
    'parent': Color(0xFFFFF3E0), // orange background
  };

  static const Map<String, Color> _filterTextColors = {
    'duration': Color(0xFF1565C0), // blue text
    'setup': Color(0xFF7B1FA2), // purple text
    'cleanup': Color(0xFF2E7D32), // green text
    'parent': Color(0xFFE65100), // orange text
  };

  /// Builds a filter chip for the browse all mode
  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isComfortMode,
    String? filterType, // 'duration', 'setup', 'cleanup', 'parent'
  }) {
    // Get colors based on filter type when active
    final Color activeBackgroundColor = isActive && filterType != null
        ? _filterColors[filterType] ?? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
        : (isComfortMode
            ? Colors.white.withValues(alpha: 0.1)
            : FlutterFlowTheme.of(context).secondaryBackground);

    final Color activeTextColor = isActive && filterType != null
        ? _filterTextColors[filterType] ?? FlutterFlowTheme.of(context).primary
        : (isComfortMode ? Colors.white : const Color(0xFF5D4E60));

    final Color borderColor = isActive && filterType != null
        ? _filterTextColors[filterType] ?? FlutterFlowTheme.of(context).primary
        : (isComfortMode
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.3));

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: activeBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: borderColor,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                fontSize: 13.0,
                color: activeTextColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4.0),
            Icon(
              Icons.arrow_drop_down,
              size: 18.0,
              color: isActive
                  ? activeTextColor
                  : (isComfortMode ? Colors.white.withValues(alpha: 0.7) : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet for filter selection
  void _showFilterSheet(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    Function(String?) onSelect, {
    Map<String, String>? displayLabels,
    String? filterType,
  }) {
    final isComfortMode = FFAppState().isComfortMode;

    // Get header color based on filter type
    final Color headerBackgroundColor = filterType != null
        ? _filterColors[filterType] ?? Colors.transparent
        : Colors.transparent;
    final Color headerTextColor = filterType != null
        ? _filterTextColors[filterType] ?? (isComfortMode ? Colors.white : const Color(0xFF5D4E60))
        : (isComfortMode ? Colors.white : const Color(0xFF5D4E60));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isComfortMode ? const Color(0xFF2C3E50) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with colored background
              Container(
                decoration: BoxDecoration(
                  color: isComfortMode ? Colors.transparent : headerBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: headerTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentValue != null)
                      InkWell(
                        onTap: () {
                          onSelect(null);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: headerTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Options
              ...options.map((option) {
                final isSelected = option == currentValue;
                final displayLabel = displayLabels?[option] ?? option;

                return InkWell(
                  onTap: () {
                    onSelect(option);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    color: isSelected
                        ? (isComfortMode
                            ? (filterType != null
                                ? _filterTextColors[filterType]!.withValues(alpha: 0.2)
                                : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2))
                            : (filterType != null
                                ? _filterColors[filterType]
                                : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)))
                        : Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayLabel,
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            fontSize: 16.0,
                            color: isSelected
                                ? (filterType != null
                                    ? _filterTextColors[filterType]
                                    : FlutterFlowTheme.of(context).primary)
                                : (isComfortMode ? Colors.white : const Color(0xFF5D4E60)),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: filterType != null
                                ? _filterTextColors[filterType]
                                : FlutterFlowTheme.of(context).primary,
                            size: 20.0,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick add bottom sheet for system activities
class _ActivityQuickAddSheet extends StatefulWidget {
  final ActivityRecord activity;

  const _ActivityQuickAddSheet({required this.activity});

  @override
  State<_ActivityQuickAddSheet> createState() => _ActivityQuickAddSheetState();
}

class _ActivityQuickAddSheetState extends State<_ActivityQuickAddSheet> {
  List<ChildernRecord>? _userChildren;
  Set<DocumentReference> _selectedChildren = {};
  bool _assignToMom = false;
  bool _assignToDad = false;
  bool _isLoading = false;
  DateTime? _selectedDate; // null means Today
  late ParentDisplayInfo _parentInfo;

  @override
  void initState() {
    super.initState();
    _parentInfo = ParentDisplayInfo.fromUser(currentUserDocument);
    _loadUserChildren();
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
                  // Mom chip
                  GestureDetector(
                    onTap: () => setState(() => _assignToMom = !_assignToMom),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _assignToMom
                            ? _parentInfo.myColor.withOpacity(0.15)
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
                  // Dad chip
                  GestureDetector(
                    onTap: () => setState(() => _assignToDad = !_assignToDad),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _assignToDad
                            ? _parentInfo.partnerColor.withOpacity(0.15)
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
                              ? color.withOpacity(0.15)
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
                                  child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
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
                    try {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final targetDate = _selectedDate ?? today;

                      await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                        name: widget.activity.title,
                        description: widget.activity.description,
                        isrecurring: false,
                        selectedChildren: _selectedChildren.toList(),
                        userRef: currentUserReference,
                        date: targetDate,
                        typ: 'Activity',
                        isCompleted: false,
                        assignedToMom: _assignToMom,
                        assignedToDad: _assignToDad,
                        thingsNeeded: widget.activity.thingsNeeded,
                        timeDuration: widget.activity.timeDuration,
                        parentProximity: widget.activity.parentProximity,
                        setupTime: widget.activity.setupTime,
                        cleanupDifficulty: widget.activity.cleanupDifficulty,
                        safetyNote: widget.activity.activitySafetyConcerns,
                      ));

                      if (mounted) {
                        Navigator.pop(context);
                        final dayLabel = _selectedDate == null ? 'today' : _getDayLabel(targetDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.activity.title} added to $dayLabel!'),
                            backgroundColor: const Color(0xFF4CAF50),
                            duration: const Duration(seconds: 2),
                          ),
                        );
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
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  text: _isLoading ? 'Adding...' : 'Add to ${_getButtonDayLabel()}',
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

  Widget _buildDayChip(Map<String, dynamic> option, bool isComfortMode) {
    final label = option['label'] as String;
    final date = option['date'] as DateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if this date is selected (null means today is selected by default)
    final isSelected = (_selectedDate == null && date == today) ||
                       (_selectedDate != null && _selectedDate!.year == date.year &&
                        _selectedDate!.month == date.month && _selectedDate!.day == date.day);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date == today ? null : date;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withOpacity(0.15)
              : (isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            color: isSelected
                ? const Color(0xFF4CAF50)
                : (isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60)),
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) return 'today';
    if (date == tomorrow) return 'tomorrow';

    final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdayNames[date.weekday - 1];
  }

  /// Get the day label for the button (capitalized)
  String _getButtonDayLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = _selectedDate ?? today;

    if (targetDate == today) return 'Today';
    if (targetDate == tomorrow) return 'Tomorrow';

    final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdayNames[targetDate.weekday - 1];
  }
}
