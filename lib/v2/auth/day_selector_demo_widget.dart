import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'day_selector_demo_model.dart';
export 'day_selector_demo_model.dart';

/// Interactive calendar for selecting up to 7 days to plan meals
/// Shows actual calendar with dates and day columns
class DaySelectorDemoWidget extends StatefulWidget {
  const DaySelectorDemoWidget({super.key});

  static String routeName = 'DaySelectorDemo';
  static String routePath = '/day-selector-demo';

  @override
  State<DaySelectorDemoWidget> createState() => _DaySelectorDemoWidgetState();
}

class _DaySelectorDemoWidgetState extends State<DaySelectorDemoWidget> with TickerProviderStateMixin {
  late DaySelectorDemoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Track selected days (using day index 0-6)
  Set<int> selectedDays = {0, 1, 2, 3, 4, 5, 6}; // Default: all 7 days selected

  // Start from today
  final DateTime startDate = DateTime.now();

  // Staggered entrance animation controllers
  late AnimationController _headerController;
  late AnimationController _subtitleController;
  late AnimationController _calendarController;
  late AnimationController _buttonController;

  // Breathing element animation
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DaySelectorDemoModel());

    // Initialize staggered entrance controllers
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize breathing controller
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Staggered entrance timing
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _subtitleController.forward();
      });
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) _calendarController.forward();
      });
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _subtitleController.dispose();
    _calendarController.dispose();
    _buttonController.dispose();
    _breathController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                stops: [0.0, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    _staggeredEntry(
                      controller: _headerController,
                      child: InkWell(
                        onTap: () => context.safePop(),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Title
                    _staggeredEntry(
                      controller: _headerController,
                      child: Text(
                        'Select Days to Plan',
                        style: FlutterFlowTheme.of(context).displaySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _staggeredEntry(
                      controller: _subtitleController,
                      child: Text(
                        'Pick any days from the next 30 days',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    // Calendar
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _staggeredEntry(
                          controller: _calendarController,
                          slideOffset: 30.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Day headers (Sun, Mon, Tue, etc.)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                                      return Expanded(
                                        child: Text(
                                          day,
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // Calendar dates
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _buildCalendarGrid(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Selected count and continue button
                    _staggeredEntry(
                      controller: _buttonController,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ScaleTransition(
                                scale: _breathAnimation,
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedDays.length} ${selectedDays.length == 1 ? 'day' : 'days'} selected',
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                          FFButtonWidget(
                            onPressed: selectedDays.isEmpty
                                ? null
                                : () async {
                                    HapticFeedback.mediumImpact();
                                    // Navigate to meal plan demo with selected days
                                    context.pushNamed(
                                      'MealPlanDemo',
                                      extra: <String, dynamic>{
                                        'selectedDays': selectedDays.toList(),
                                        kTransitionInfoKey: const TransitionInfo(
                                          hasTransition: true,
                                          transitionType: PageTransitionType.fade,
                                          duration: Duration(milliseconds: 300),
                                        ),
                                      },
                                    );
                                  },
                            text: 'Continue',
                            options: FFButtonOptions(
                              height: 56.0,
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              iconPadding: const EdgeInsets.all(0.0),
                              color: selectedDays.isEmpty
                                  ? FlutterFlowTheme.of(context).secondaryText
                                  : FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                              elevation: 3.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(28.0),
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
        ),
      ),
    );
  }

  Widget _staggeredEntry({
    required AnimationController controller,
    required Widget child,
    double slideOffset = 20.0,
  }) {
    final fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slideAnim = Tween<Offset>(
      begin: Offset(0, slideOffset / 400),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }

  Widget _buildCalendarGrid() {
    // Get the first day of current month for alignment
    final firstDayOfMonth = DateTime(startDate.year, startDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    // Generate 30 days starting from today
    final days = List.generate(30, (index) => startDate.add(Duration(days: index)));

    // Build calendar grid
    List<Widget> calendarCells = [];

    // Add empty cells for days before the first day (if today isn't the start of a week)
    final todayWeekday = startDate.weekday % 7;
    for (int i = 0; i < todayWeekday; i++) {
      calendarCells.add(const SizedBox());
    }

    // Add day cells (up to 30 days)
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final isSelected = selectedDays.contains(i);
      final isToday = i == 0;

      calendarCells.add(
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              if (isSelected) {
                selectedDays.remove(i);
              } else {
                selectedDays.add(i);
              }
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : isToday
                      ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: isToday && !isSelected
                  ? Border.all(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                      width: 2.0,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FFAppState().currentFontFamily,
                  fontSize: 18.0,
                  fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0.0,
                  color: isSelected
                      ? Colors.white
                      : FlutterFlowTheme.of(context).primaryText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: calendarCells,
    );
  }
}
