import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'meal_demo_intro_model.dart';
export 'meal_demo_intro_model.dart';

/// Day selection page - First step of meal planning demo
/// Shows which days to plan for (mimics real meal planner)
class MealDemoIntroWidget extends StatefulWidget {
  const MealDemoIntroWidget({super.key});

  static String routeName = 'MealDemoIntro';
  static String routePath = '/meal-demo-intro';

  @override
  State<MealDemoIntroWidget> createState() => _MealDemoIntroWidgetState();
}

class _MealDemoIntroWidgetState extends State<MealDemoIntroWidget>
    with TickerProviderStateMixin {
  late MealDemoIntroModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Selected days (for demo, just select first 3 days)
  Set<int> selectedDays = {0, 1, 2};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealDemoIntroModel());

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start fade in after frame renders
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return {
        'date': date,
        'dayName': dateTimeFormat("EEEE", date, locale: 'en'),
        'dateStr': dateTimeFormat("MMM d", date, locale: 'en'),
      };
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
              stops: [0.0, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Which days do you\nwant to plan?',
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                              ).copyWith(height: 1.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to select days',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Day selection list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isSelected = selectedDays.contains(index);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedDays.remove(index);
                                } else {
                                  selectedDays.add(index);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : Colors.transparent,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Checkbox
                                  Container(
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? FlutterFlowTheme.of(context).primary
                                            : const Color(0xFFCCCCCC),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16.0,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),

                                  const SizedBox(width: 16.0),

                                  // Day info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          day['dayName'] as String,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineSmall
                                              .override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Text(
                                          day['dateStr'] as String,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: FFButtonWidget(
                      onPressed: selectedDays.isEmpty
                          ? null
                          : () async {
                              await _fadeController.reverse();
                              if (mounted) {
                                context.pushNamed('MealPlanDemo');
                              }
                            },
                      text: 'Continue (${selectedDays.length} days)',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56.0,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        iconPadding: const EdgeInsets.all(0.0),
                        color: selectedDays.isEmpty
                            ? const Color(0xFFCCCCCC)
                            : FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        elevation: selectedDays.isEmpty ? 0 : 3.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
