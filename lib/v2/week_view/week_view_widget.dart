import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'week_view_model.dart';
export 'week_view_model.dart';

/// Week View - Peace-First Design
/// Shows the rhythm of the week without overwhelming
class WeekViewWidget extends StatefulWidget {
  const WeekViewWidget({super.key});

  static String routeName = 'WeekView';
  static String routePath = '/week-view';

  @override
  State<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends State<WeekViewWidget> {
  late WeekViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeekViewModel());
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF2C3E50),
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.homeSubpage),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: SingleChildScrollView(
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
                          const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF95A5A6),
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Back',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: const Color(0xFF95A5A6),
                                  fontSize: 14.0,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // Page title
                    Center(
                      child: Text(
                        'This week\'s rhythm',
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 28.0,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFFECF0F1),
                            ),
                      ),
                    ),

                    const SizedBox(height: 48.0),

                    // Week days
                    _buildDayCard(
                      context,
                      'Monday',
                      'Presence over perfection',
                      'Start with presence, not productivity',
                      DateTime.now().weekday == DateTime.monday,
                    ),

                    const SizedBox(height: 16.0),

                    _buildDayCard(
                      context,
                      'Tuesday',
                      'Language development',
                      'Talk, read, sing together',
                      DateTime.now().weekday == DateTime.tuesday,
                    ),

                    const SizedBox(height: 16.0),

                    _buildDayCard(
                      context,
                      'Wednesday',
                      'Simple meals, less stress',
                      'Batch cooking or easy favorites',
                      DateTime.now().weekday == DateTime.wednesday,
                    ),

                    const SizedBox(height: 16.0),

                    _buildDayCard(
                      context,
                      'Thursday',
                      'Rest when you can',
                      'Nap when they nap, screen time is okay',
                      DateTime.now().weekday == DateTime.thursday,
                    ),

                    const SizedBox(height: 16.0),

                    _buildDayCard(
                      context,
                      'Friday',
                      'Connection through play',
                      'Follow their lead, be present',
                      DateTime.now().weekday == DateTime.friday,
                    ),

                    const SizedBox(height: 16.0),

                    _buildDayCard(
                      context,
                      'Saturday',
                      'Slow mornings',
                      'No agenda, just be',
                      DateTime.now().weekday == DateTime.saturday,
                    ),

                    const SizedBox(height: 16.0),

                    _buildDayCard(
                      context,
                      'Sunday',
                      'Preparation for the week',
                      'Gentle prep: groceries, meal ideas',
                      DateTime.now().weekday == DateTime.sunday,
                    ),

                    const SizedBox(height: 48.0),

                    // Footer message
                    Center(
                      child: Text(
                        'This is a guide, not a rule.\nAdjust as life demands.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: const Color(0xFF7F8C8D),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),

                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String day,
    String focus,
    String description,
    bool isToday,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF3E5568) : const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: isToday ? const Color(0xFF7F8C8D) : const Color(0x33FFFFFF),
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: const Color(0xFF95A5A6),
                      fontSize: 12.0,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              if (isToday)
                Text(
                  'TODAY',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: const Color(0xFFBDC3C7),
                        fontSize: 11.0,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            focus,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFFFFFFFF),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            description,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFFBDC3C7),
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}
