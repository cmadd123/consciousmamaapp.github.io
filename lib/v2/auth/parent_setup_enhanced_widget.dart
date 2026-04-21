import '/v2/auth/account_transition_widget.dart';
import '/v2/auth/onboarding_progress_tracker.dart';
import '/v2/auth/demo_data_notifier.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'parent_setup_enhanced_model.dart';
export 'parent_setup_enhanced_model.dart';

class ParentSetupEnhancedWidget extends StatefulWidget {
  const ParentSetupEnhancedWidget({super.key});

  static String routeName = 'ParentSetupEnhanced';
  static String routePath = '/parent-setup-enhanced';

  @override
  State<ParentSetupEnhancedWidget> createState() => _ParentSetupEnhancedWidgetState();
}

class _ParentSetupEnhancedWidgetState extends State<ParentSetupEnhancedWidget>
    with TickerProviderStateMixin {
  late ParentSetupEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Staggered entrance controllers
  late AnimationController _headerController;
  late AnimationController _titleController;
  late AnimationController _yourCardController;
  late AnimationController _partnerCardController;
  late AnimationController _buttonController;

  // Breathing element — preview circles pulse gently
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // Button glow pulse when form is valid
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Color picker ring burst
  late AnimationController _colorRingController;
  late Animation<double> _colorRingAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParentSetupEnhancedModel());

    _model.myNameController ??= TextEditingController();
    _model.myNameFocusNode ??= FocusNode();

    _model.partnerNameController ??= TextEditingController();
    _model.partnerNameFocusNode ??= FocusNode();

    // Set default colors
    _model.myColor = const Color(0xFFEC407A); // Pink default
    _model.partnerColor = const Color(0xFF1976D2); // Blue default

    // Staggered entrance animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _yourCardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _partnerCardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Breathing element
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Button glow
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Color ring burst
    _colorRingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _colorRingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _colorRingController, curve: Curves.easeOut),
    );

    // Stagger the entrances
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _titleController.forward();
      });
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _yourCardController.forward();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _partnerCardController.forward();
      });
      Future.delayed(const Duration(milliseconds: 550), () {
        if (mounted) _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _titleController.dispose();
    _yourCardController.dispose();
    _partnerCardController.dispose();
    _buttonController.dispose();
    _breathController.dispose();
    _glowController.dispose();
    _colorRingController.dispose();
    _model.dispose();
    super.dispose();
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
      child: SlideTransition(
        position: slideAnim,
        child: child,
      ),
    );
  }

  bool get _isFormValid =>
      (_model.myNameController?.text ?? '').trim().isNotEmpty;

  void _checkGlow() {
    if (_isFormValid && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!_isFormValid && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
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
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back arrow + progress tracker
                        _staggeredEntry(
                          controller: _headerController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-1.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () => context.safePop(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              OnboardingProgressTracker(
                                currentStep: 3,
                                fadeAnimation: CurvedAnimation(
                                  parent: _headerController,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Title + subtitle
                        _staggeredEntry(
                          controller: _titleController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About you',
                                style: FlutterFlowTheme.of(context).headlineMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Choose names and colors for you and your husband. These will appear throughout the app.',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // === YOUR SECTION ===
                        _staggeredEntry(
                          controller: _yourCardController,
                          slideOffset: 30.0,
                          child: _buildSectionCard(
                            context,
                            title: 'You',
                            subtitle: 'What should we call you?',
                            nameController: _model.myNameController!,
                            nameFocusNode: _model.myNameFocusNode!,
                            nameHint: 'Your name or nickname',
                            nameValidator: _model.myNameControllerValidator!,
                            selectedColor: _model.myColor,
                            onColorSelected: (color) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _model.myColor = color;
                              });
                              _colorRingController.forward(from: 0.0);
                            },
                            initial: _model.myNameController!.text.isNotEmpty
                                ? _model.myNameController!.text[0].toUpperCase()
                                : 'M',
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // === HUSBAND SECTION ===
                        _staggeredEntry(
                          controller: _partnerCardController,
                          slideOffset: 30.0,
                          child: _buildSectionCard(
                            context,
                            title: 'Your Husband (Optional)',
                            subtitle: 'What should we call him?',
                            nameController: _model.partnerNameController!,
                            nameFocusNode: _model.partnerNameFocusNode!,
                            nameHint: 'Husband\'s name or nickname (optional)',
                            nameValidator: _model.partnerNameControllerValidator!,
                            selectedColor: _model.partnerColor,
                            onColorSelected: (color) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _model.partnerColor = color;
                              });
                              _colorRingController.forward(from: 0.0);
                            },
                            initial: _model.partnerNameController!.text.isNotEmpty
                                ? _model.partnerNameController!.text[0].toUpperCase()
                                : 'P',
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Continue button with glow
                        _staggeredEntry(
                          controller: _buttonController,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: _isFormValid
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(14.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: FlutterFlowTheme.of(context).primary.withOpacity(
                                                  _glowAnimation.value * 0.4,
                                                ),
                                            blurRadius: 16.0,
                                            spreadRadius: 2.0,
                                          ),
                                        ],
                                      )
                                    : null,
                                child: child,
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 56.0,
                              child: FFButtonWidget(
                                onPressed: () async {
                                  HapticFeedback.mediumImpact();
                                  if (_model.formKey.currentState?.validate() ?? false) {
                                    // Save to local state (will be written to Firestore after signup)
                                    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
                                    demoData.setParentInfo(
                                      myNameValue: _model.myNameController.text.trim(),
                                      myColorValue: _model.myColor,
                                      partnerNameValue: _model.partnerNameController.text.trim().isNotEmpty
                                        ? _model.partnerNameController.text.trim()
                                        : null,
                                      partnerColorValue: _model.partnerColor,
                                    );

                                    // Navigate to account transition page
                                    if (context.mounted) {
                                      context.pushNamed(
                                        AccountTransitionWidget.routeName,
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey: const TransitionInfo(
                                            hasTransition: true,
                                            transitionType: PageTransitionType.fade,
                                            duration: Duration(milliseconds: 300),
                                          ),
                                        },
                                      );
                                    }
                                  }
                                },
                                text: 'Continue',
                                options: FFButtonOptions(
                                  height: 56.0,
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required TextEditingController nameController,
    required FocusNode nameFocusNode,
    required String nameHint,
    required String? Function(BuildContext, String?) nameValidator,
    required Color? selectedColor,
    required Function(Color) onColorSelected,
    required String initial,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with breathing preview circle
          Row(
            children: [
              // Preview circle with breathing animation
              ScaleTransition(
                scale: _breathAnimation,
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: selectedColor ?? FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: (selectedColor ?? FlutterFlowTheme.of(context).primary).withValues(alpha: 0.4),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: FFAppState().currentFontFamily,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Name input
          TextFormField(
            controller: nameController,
            focusNode: nameFocusNode,
            onChanged: (val) {
              setState(() {}); // Update preview initial
              _checkGlow();
            },
            autofocus: false,
            decoration: InputDecoration(
              hintText: nameHint,
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 16.0,
              letterSpacing: 0.0,
            ),
            validator: (val) => nameValidator(context, val),
          ),
          const SizedBox(height: 16.0),

          // Color picker label
          Text(
            'Pick a color',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12.0),

          // Color palette with ring burst
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: ParentSetupEnhancedModel.colorPalette.map((color) {
              final isSelected = selectedColor?.value == color.value;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: SizedBox(
                  width: 44.0,
                  height: 44.0,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Ring burst animation (only on selected color)
                      if (isSelected)
                        AnimatedBuilder(
                          animation: _colorRingAnimation,
                          builder: (context, _) {
                            final ringSize = 44.0 + (16.0 * _colorRingAnimation.value);
                            return Positioned(
                              left: (44.0 - ringSize) / 2,
                              top: (44.0 - ringSize) / 2,
                              child: Container(
                                width: ringSize,
                                height: ringSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0 + (4.0 * _colorRingAnimation.value)),
                                  border: Border.all(
                                    color: color.withOpacity(1.0 - _colorRingAnimation.value),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isSelected
                                ? FlutterFlowTheme.of(context).primaryText
                                : Colors.transparent,
                            width: 3.0,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: color.withValues(alpha: 0.5),
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24.0,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
