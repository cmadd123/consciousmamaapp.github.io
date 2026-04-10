import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'feature_walkthrough_model.dart';
import 'walkthrough_previews.dart';

export 'feature_walkthrough_model.dart';

class FeatureWalkthroughWidget extends StatefulWidget {
  const FeatureWalkthroughWidget({super.key});

  static String routeName = 'FeatureWalkthrough';
  static String routePath = '/feature-walkthrough';

  @override
  State<FeatureWalkthroughWidget> createState() =>
      _FeatureWalkthroughWidgetState();
}

class _FeatureWalkthroughWidgetState extends State<FeatureWalkthroughWidget>
    with TickerProviderStateMixin {
  late FeatureWalkthroughModel _model;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Breathing animation for preview card
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;

  // Page data
  late final List<_PageData> _pages;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeatureWalkthroughModel());

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    // 8 pages, momentum-optimized order, honest copy
    _pages = [
      // 1. Meal Planning - the core hook, biggest daily pain point
      _PageData(
        title: 'Plan your meals in minutes',
        subtitle: 'Pick your days, fill in breakfast, lunch, and dinner — done for the week',
        preview: const MealPlanPreview(),
        accentColor: const Color(0xFFFF6B6B),
        icon: Icons.restaurant_menu,
      ),
      // 2. Grocery List - immediate payoff from meal planning
      _PageData(
        title: 'Your grocery list writes itself',
        subtitle: 'Every ingredient from your meal plan, sorted by aisle and ready to shop',
        preview: const GroceryListPreview(),
        accentColor: const Color(0xFF9B8AA0),
        icon: Icons.shopping_cart,
      ),
      // 3. Cookbook - complete the meal ecosystem
      _PageData(
        title: 'All your recipes in one place',
        subtitle: 'Save favorites, import from any website, or create your own — ready when you need them',
        preview: const CookbookPreview(),
        accentColor: const Color(0xFFE67E22),
        icon: Icons.menu_book,
      ),
      // 4. Learning Paths - the differentiator, emotional hook
      _PageData(
        title: 'Potty training? Sleep struggles? We\'ll walk you through it',
        subtitle: 'Tell us the challenge and we create a day-by-day plan with tips for every step',
        preview: const LearningPathPreview(),
        accentColor: const Color(0xFFEC407A),
        icon: Icons.route,
      ),
      // 5. Calendar - ties it all together
      _PageData(
        title: 'Your whole family in one calendar',
        subtitle: 'Meals, appointments, and learning tasks — all at a glance',
        preview: const CalendarPreview(),
        accentColor: const Color(0xFF52A097),
        icon: Icons.calendar_month,
      ),
      // 6. Todo List - planning companion
      _PageData(
        title: 'Never forget the little things',
        subtitle: 'Keep track of everything on your plate — from appointments to party planning',
        preview: const TodoListPreview(),
        accentColor: const Color(0xFF5C6BC0),
        icon: Icons.checklist_rounded,
      ),
      // 7. Milestones - emotional close
      _PageData(
        title: 'Track every milestone as it happens',
        subtitle: 'From rolling over to first words — see how far they\'ve come',
        preview: const MilestonesPreview(),
        accentColor: const Color(0xFF4CAF50),
        icon: Icons.star,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _entranceController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _entranceController.dispose();
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _goToNext() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSetup();
    }
  }

  void _navigateToSetup() {
    HapticFeedback.mediumImpact();
    context.pushNamed(
      'SetupTransition',
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 400),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    final page = _pages[_currentPage];

    return Scaffold(
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
            opacity: _entranceFade,
            child: Column(
              children: [
                // Top bar: page counter + skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentPage + 1} of ${_pages.length}',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      if (!isLastPage)
                        TextButton(
                          onPressed: _navigateToSetup,
                          child: Text(
                            'Skip',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        )
                      else
                        const SizedBox(width: 60),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final p = _pages[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Icon badge
                            Container(
                              width: 56.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: p.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Icon(
                                p.icon,
                                color: p.accentColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              p.title,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.0,
                                  )
                                  .copyWith(height: 1.3),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Text(
                                p.subtitle,
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    )
                                    .copyWith(height: 1.4),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Preview card with breathing animation
                            ScaleTransition(
                              scale: _breathAnimation,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: p.accentColor
                                          .withValues(alpha: 0.1),
                                      blurRadius: 20.0,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: p.preview,
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dot indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3.0),
                        width: isActive ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: isActive
                              ? page.accentColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      );
                    }),
                  ),
                ),

                // Bottom button
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      _goToNext();
                    },
                    text: isLastPage ? 'Let\'s Get Started' : 'Next',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0),
                      iconPadding: const EdgeInsets.all(0.0),
                      color: page.accentColor,
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
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final String title;
  final String subtitle;
  final Widget preview;
  final Color accentColor;
  final IconData icon;

  const _PageData({
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.accentColor,
    required this.icon,
  });
}
