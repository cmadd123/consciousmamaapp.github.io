import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'day_selector_demo_enhanced_model.dart';
export 'day_selector_demo_enhanced_model.dart';

/// Scene 3-4: Enhanced Calendar Selector with Premium Animations
class DaySelectorDemoEnhancedWidget extends StatefulWidget {
  const DaySelectorDemoEnhancedWidget({super.key});

  static String routeName = 'DaySelectorDemoEnhanced';
  static String routePath = '/day-selector-demo-enhanced';

  @override
  State<DaySelectorDemoEnhancedWidget> createState() =>
      _DaySelectorDemoEnhancedWidgetState();
}

class _DaySelectorDemoEnhancedWidgetState
    extends State<DaySelectorDemoEnhancedWidget>
    with TickerProviderStateMixin {
  late DaySelectorDemoEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Track selected days (using day index 0-29)
  Set<int> selectedDays = {};

  // Start from today
  final DateTime startDate = DateTime.now();

  // Animation controllers
  late AnimationController _slideUpController;
  late AnimationController _confettiController;
  late Animation<Offset> _slideUpAnimation;

  // Grid animation controllers
  final List<AnimationController> _dayControllers = [];
  final List<Animation<double>> _dayFadeAnimations = [];
  final List<Animation<Offset>> _daySlideAnimations = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DaySelectorDemoEnhancedModel());

    // Slide up animation for calendar entrance
    _slideUpController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideUpController,
      curve: Curves.elasticOut,
    ));

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );

    // Create staggered animations for each day cell
    for (int i = 0; i < 30; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );

      _dayControllers.add(controller);

      _dayFadeAnimations.add(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );

      _daySlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      );
    }

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start calendar slide up
    await _slideUpController.forward();

    // Stagger day cell animations
    for (int i = 0; i < _dayControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted) {
          _dayControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideUpController.dispose();
    _confettiController.dispose();
    for (var controller in _dayControllers) {
      controller.dispose();
    }
    _model.dispose();
    super.dispose();
  }

  void _onDayTap(int dayIndex) {
    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      if (selectedDays.contains(dayIndex)) {
        selectedDays.remove(dayIndex);
      } else {
        selectedDays.add(dayIndex);
      }
    });
  }

  Future<void> _onContinue() async {
    if (selectedDays.isEmpty) return;

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Trigger confetti
    _confettiController.play();

    // Wait for confetti to show
    await Future.delayed(const Duration(milliseconds: 400));

    // Navigate to enhanced meal plan demo with selected days
    if (mounted) {
      context.pushNamed(
        'MealPlanDemoEnhanced',
        extra: <String, dynamic>{
          'selectedDays': selectedDays.toList(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
            child: Stack(
              children: [
                SafeArea(
                  top: true,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with fade-in
                        FadeTransition(
                          opacity: _slideUpController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Days to Plan',
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                'Pick any days from the next 30 days',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        // Calendar with slide-up animation
                        Expanded(
                          child: SlideTransition(
                            position: _slideUpAnimation,
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
                                children: [
                                  // Day headers (Sun, Mon, Tue, etc.)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.05),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                                          .map((day) {
                                        return Expanded(
                                          child: Text(
                                            day,
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  fontFamily: 'Andika New Basic',
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // Calendar dates with staggered animation
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildAnimatedCalendarGrid(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // Selected count and continue button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Animated counter
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                '${selectedDays.length} ${selectedDays.length == 1 ? 'day' : 'days'} selected',
                                key: ValueKey<int>(selectedDays.length),
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            // Continue button with animation
                            AnimatedScale(
                              scale: selectedDays.isEmpty ? 0.95 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: FFButtonWidget(
                                onPressed:
                                    selectedDays.isEmpty ? null : _onContinue,
                                text: 'Continue',
                                options: FFButtonOptions(
                                  height: 56.0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  iconPadding: const EdgeInsets.all(0.0),
                                  color: selectedDays.isEmpty
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryText
                                      : FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Confetti overlay
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: 3.14 / 2, // Down
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.02,
                    numberOfParticles: 30,
                    gravity: 0.3,
                    colors: [
                      FlutterFlowTheme.of(context).primary,
                      FlutterFlowTheme.of(context).secondary,
                      FlutterFlowTheme.of(context).tertiary,
                      const Color(0xFFFFA726),
                      const Color(0xFF9C27B0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCalendarGrid() {
    // Get the weekday of the start date (0 = Sunday, 6 = Saturday)
    final todayWeekday = startDate.weekday % 7;

    // Generate 30 days starting from today
    final days = List.generate(30, (index) => startDate.add(Duration(days: index)));

    // Build calendar cells
    List<Widget> calendarCells = [];

    // Add empty cells for days before the first day
    for (int i = 0; i < todayWeekday; i++) {
      calendarCells.add(const SizedBox());
    }

    // Add day cells with animations
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final isSelected = selectedDays.contains(i);
      final isToday = i == 0;

      calendarCells.add(
        FadeTransition(
          opacity: _dayFadeAnimations[i],
          child: SlideTransition(
            position: _daySlideAnimations[i],
            child: _buildDayCell(day, i, isSelected, isToday),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      children: calendarCells,
    );
  }

  Widget _buildDayCell(DateTime day, int index, bool isSelected, bool isToday) {
    return InkWell(
      onTap: () => _onDayTap(index),
      borderRadius: BorderRadius.circular(12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 18.0,
                      fontWeight:
                          isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                      letterSpacing: 0.0,
                      color: isSelected
                          ? Colors.white
                          : FlutterFlowTheme.of(context).primaryText,
                    ),
                child: Text('${day.day}'),
              ),
            ),
            // Checkmark for selected days
            if (isSelected)
              Positioned(
                top: 2,
                right: 2,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
