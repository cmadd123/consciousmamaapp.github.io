import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'meal_demo_guided_model.dart';
export 'meal_demo_guided_model.dart';

/// Simplified meal demo guided widget
/// TODO: Add full tutorial overlay system with step-by-step guidance
/// For now, this is a placeholder that simulates meal selection
class MealDemoGuidedWidget extends StatefulWidget {
  const MealDemoGuidedWidget({super.key});

  static String routeName = 'MealDemoGuided';
  static String routePath = '/meal-demo-guided';

  @override
  State<MealDemoGuidedWidget> createState() => _MealDemoGuidedWidgetState();
}

class _MealDemoGuidedWidgetState extends State<MealDemoGuidedWidget>
    with TickerProviderStateMixin {
  late MealDemoGuidedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Demo recipes
  final List<Map<String, String>> _demoRecipes = [
    {'name': 'Spaghetti & Meatballs', 'emoji': '🍝', 'time': '30 min'},
    {'name': 'Chicken Tacos', 'emoji': '🌮', 'time': '25 min'},
    {'name': 'Grilled Chicken & Rice', 'emoji': '🍗', 'time': '35 min'},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealDemoGuidedModel());

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start fade in
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

  void _selectRecipe(String recipeName) async {
    // Fade out
    await _fadeController.reverse();

    // Navigate to celebration with recipe name
    if (mounted) {
      context.pushNamed(
        'Celebration',
        queryParameters: {
          'recipeName': recipeName,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    Column(
                      children: [
                        Text(
                          'Pick a recipe for\ntomorrow\'s dinner',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                              ).copyWith(height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap any recipe to add it to your plan',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Recipe cards
                    Expanded(
                      child: ListView.builder(
                        itemCount: _demoRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _demoRecipes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () => _selectRecipe(recipe['name']!),
                              child: Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12.0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Emoji icon
                                    Container(
                                      width: 64.0,
                                      height: 64.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          recipe['emoji']!,
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16.0),

                                    // Recipe info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe['name']!,
                                            style: FlutterFlowTheme.of(context)
                                                .headlineSmall
                                                .override(
                                                  fontFamily: 'Andika New Basic',
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 16.0,
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                              ),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                recipe['time']!,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .override(
                                                      fontFamily: 'Andika New Basic',
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      color: FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Arrow
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 20.0,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Skip option
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                        onPressed: () async {
                          await _fadeController.reverse();
                          if (mounted) {
                            context.pushNamed('FeaturesEnhanced');
                          }
                        },
                        child: Text(
                          'Skip Tutorial',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                decoration: TextDecoration.underline,
                              ),
                        ),
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
}
