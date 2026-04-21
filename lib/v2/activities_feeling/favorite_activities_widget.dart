import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorite_activities_model.dart';
export 'favorite_activities_model.dart';

/// Favorite Activities - Shows all favorited activities
class FavoriteActivitiesWidget extends StatefulWidget {
  const FavoriteActivitiesWidget({super.key});

  static String routeName = 'FavoriteActivities';
  static String routePath = '/favorite-activities';

  @override
  State<FavoriteActivitiesWidget> createState() => _FavoriteActivitiesWidgetState();
}

class _FavoriteActivitiesWidgetState extends State<FavoriteActivitiesWidget> {
  late FavoriteActivitiesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FavoriteActivitiesModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isComfortMode = FFAppState().isComfortMode;
    final favoriteRefs = FFAppState().favoriteActivities;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFFFE9E1),
        body: Container(
          decoration: BoxDecoration(
            gradient: isComfortMode
              ? const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                )
              : const LinearGradient(
                  colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
          ),
          child: SafeArea(
            child: favoriteRefs.isEmpty
              ? _buildEmptyState(context, isComfortMode)
              : StreamBuilder<List<ActivityRecord>>(
                  stream: queryActivityRecord(
                    queryBuilder: (activityRecord) => activityRecord.where(
                      FieldPath.documentId,
                      whereIn: favoriteRefs.map((ref) => ref.id).toList(),
                    ),
                  ),
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

                    List<ActivityRecord> favoriteActivities = snapshot.data!;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 24.0),
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
                                      ? const Color(0xFF95A5A6)
                                      : FlutterFlowTheme.of(context).secondaryText,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Back',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: isComfortMode
                                            ? const Color(0xFF95A5A6)
                                            : FlutterFlowTheme.of(context).secondaryText,
                                          fontSize: 14.0,
                                          letterSpacing: isComfortMode ? 0.5 : 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32.0),

                            // Page title
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: isComfortMode ? Colors.red.shade300 : Colors.red,
                                  size: 32.0,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    'My Favorites',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineLarge
                                        .override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: isComfortMode ? Colors.white : null,
                                          fontSize: 28.0,
                                          letterSpacing: isComfortMode ? 0.5 : 0.0,
                                          fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8.0),

                            Text(
                              '${favoriteActivities.length} saved ${favoriteActivities.length == 1 ? 'activity' : 'activities'}',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: isComfortMode
                                      ? Colors.white70
                                      : FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 16.0,
                                    letterSpacing: isComfortMode ? 0.5 : 0.0,
                                    fontWeight: isComfortMode ? FontWeight.w300 : null,
                                  ),
                            ),

                            const SizedBox(height: 32.0),

                            // Favorite activities
                            ...favoriteActivities.map((activity) {
                              return Column(
                                children: [
                                  _buildActivityCard(activity, isComfortMode),
                                  const SizedBox(height: 16.0),
                                ],
                              );
                            }),
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

  Widget _buildEmptyState(BuildContext context, bool isComfortMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80.0,
              color: isComfortMode
                ? Colors.white.withOpacity(0.3)
                : FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 24.0),
            Text(
              'No favorites yet',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: isComfortMode ? Colors.white : null,
                    fontSize: 24.0,
                    letterSpacing: isComfortMode ? 0.5 : 0.0,
                    fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Tap the heart icon on any activity to save it here for quick access later.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: isComfortMode
                      ? Colors.white70
                      : FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                    letterSpacing: isComfortMode ? 0.5 : 0.0,
                    fontWeight: isComfortMode ? FontWeight.w300 : null,
                  ),
            ),
            const SizedBox(height: 32.0),
            InkWell(
              onTap: () {
                context.pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(24.0),
                  border: isComfortMode
                    ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
                    : null,
                ),
                child: Text(
                  'Browse Activities',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: Colors.white,
                        fontSize: 16.0,
                        letterSpacing: isComfortMode ? 0.5 : 0.0,
                        fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
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

  Widget _buildTag(String text, Color backgroundColor, bool isComfortMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isComfortMode ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(14.0),
        border: isComfortMode
          ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
          : null,
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily,
              color: isComfortMode ? Colors.white : null,
              fontSize: 12.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityRecord activity, bool isComfortMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: isComfortMode
          ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
          : null,
        boxShadow: isComfortMode ? null : [
          const BoxShadow(
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
                  style: const TextStyle(fontSize: 32.0),
                ),
              if (!isComfortMode) const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  activity.title,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: isComfortMode ? Colors.white : null,
                        fontSize: 20.0,
                        letterSpacing: isComfortMode ? 0.5 : 0.0,
                        fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.bold,
                      ),
                ),
              ),
              // Favorite button (to unfavorite)
              InkWell(
                onTap: () {
                  setState(() {
                    FFAppState().removeFromFavoriteActivities(activity.reference);
                  });
                },
                child: Icon(
                  Icons.favorite,
                  color: isComfortMode ? Colors.red.shade300 : Colors.red,
                  size: 24.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Description
          Text(
            activity.description,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: isComfortMode ? Colors.white.withOpacity(0.9) : null,
                  fontSize: 15.0,
                  letterSpacing: 0.0,
                ),
          ),

          const SizedBox(height: 16.0),

          // Metadata - colored tags
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              if (activity.hasTimeDuration())
                _buildTag('Time: ${activity.timeDuration}', const Color(0xFFE3F2FD), isComfortMode),
              if (activity.hasParentProximity())
                _buildTag(
                  activity.parentProximity == 'free'
                    ? 'Parent: Free'
                    : activity.parentProximity == 'nearby'
                      ? 'Parent: Nearby'
                      : 'Parent: Together',
                  const Color(0xFFFFF3E0),
                  isComfortMode,
                ),
              if (activity.hasSetupTime())
                _buildTag('Setup: ${activity.setupTime}', const Color(0xFFF3E5F5), isComfortMode),
              if (activity.hasCleanupDifficulty())
                _buildTag('Cleanup: ${activity.cleanupDifficulty}', const Color(0xFFE8F5E9), isComfortMode),
            ],
          ),

          if (activity.hasThingsNeeded())
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 12.0, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                    size: 18.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      activity.thingsNeeded,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
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
