import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/home_nav_bar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/app_state.dart';
import 'feeling_bubbles_model.dart';
export 'feeling_bubbles_model.dart';

/// Feeling Bubbles - Mom picks ONE feeling
/// Shows 10 feeling options, routes to filtered activity results
class FeelingBubblesWidget extends StatefulWidget {
  const FeelingBubblesWidget({super.key});

  static String routeName = 'FeelingBubbles';
  static String routePath = '/feeling-bubbles';

  @override
  State<FeelingBubblesWidget> createState() => _FeelingBubblesWidgetState();
}

class _FeelingBubblesWidgetState extends State<FeelingBubblesWidget> {
  late FeelingBubblesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeelingBubblesModel());
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigate to home instead of exiting
        context.goNamed(HomeHybridWidget.routeName);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isComfortMode ? Color(0xFF2C3E50) : Color(0xFFFFE9E1),
        body: Stack(
          children: [
            Container(
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page title
                    Text(
                      'What mood are we in?',
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
                      'I need...',
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            fontFamily: 'Andika New Basic',
                            color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 16.0,
                            letterSpacing: isComfortMode ? 0.5 : 0.0,
                            fontWeight: isComfortMode ? FontWeight.w300 : null,
                          ),
                    ),

                    SizedBox(height: 24.0),

                    // Favorites button
                    InkWell(
                      onTap: () {
                        context.pushNamed('FavoriteActivities');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: isComfortMode ? Colors.red.shade300 : Colors.red,
                              size: 22.0,
                            ),
                            SizedBox(width: 12.0),
                            Text(
                              'My Favorite Activities',
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: isComfortMode ? Colors.white : null,
                                    fontSize: 18.0,
                                    letterSpacing: isComfortMode ? 0.5 : 0.0,
                                    fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32.0),

                    // Feeling bubbles - 2 per row
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeelingBubble(context, '😌', 'Something calming, please.', 'calm'),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: _buildFeelingBubble(context, '⚡', 'They\'ve got allll the wiggles.', 'move'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeelingBubble(context, '🧩', 'Their brain wants a job.', 'brain'),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: _buildFeelingBubble(context, '🎨', 'Let\'s spark some creativity.', 'creative'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeelingBubble(context, '🎯', 'I need them to play on their own for a bit.', 'independent'),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: _buildFeelingBubble(context, '💕', 'We could use a little connection.', 'connection'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeelingBubble(context, '🌿', 'We should probably get outside.', 'outdoor'),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: _buildFeelingBubble(context, '⏱️', 'No energy left for setup.', 'minimal'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeelingBubble(context, '✨', 'They\'re craving sensory stuff today.', 'sensory'),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: _buildFeelingBubble(context, '🏃', 'Help me channel this energy somewhere.', 'channel'),
                        ),
                      ],
                    ),

                        SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: HomeNavBarWidget(
                currentPage: HomeNavPage.activities,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildFeelingBubble(
    BuildContext context,
    String emoji,
    String text,
    String bubbleType,
  ) {
    final isComfortMode = FFAppState().isComfortMode;

    return InkWell(
      onTap: () {
        // Navigate to activity results with selected bubble
        context.pushNamed(
          'ActivityResults',
          queryParameters: {
            'bubbleType': serializeParam(bubbleType, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: isComfortMode
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
            : null,
          boxShadow: isComfortMode ? null : [
            BoxShadow(
              blurRadius: 2.0,
              color: Color(0x1A000000),
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isComfortMode)
              Text(
                emoji,
                style: TextStyle(fontSize: 28.0),
              ),
            if (!isComfortMode) SizedBox(height: 6.0),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode ? Colors.white : null,
                    fontSize: 13.0,
                    letterSpacing: isComfortMode ? 0.5 : 0.0,
                    fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
