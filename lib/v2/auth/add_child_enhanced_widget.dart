import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_date_time_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/auth/onboarding_progress_tracker.dart';
import '/v2/auth/demo_data_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'add_child_enhanced_model.dart';
export 'add_child_enhanced_model.dart';

class AddChildEnhancedWidget extends StatefulWidget {
  const AddChildEnhancedWidget({
    super.key,
    this.isOnboarding = true,
  });

  final bool isOnboarding; // true = onboarding flow, false = settings flow

  static String routeName = 'AddChildEnhanced';
  static String routePath = '/add-child-enhanced';

  @override
  State<AddChildEnhancedWidget> createState() => _AddChildEnhancedWidgetState();
}

class _AddChildEnhancedWidgetState extends State<AddChildEnhancedWidget>
    with TickerProviderStateMixin {
  late AddChildEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Staggered entrance controllers
  late AnimationController _headingController;
  late AnimationController _subtitleController;
  late AnimationController _cardController;
  late AnimationController _buttonController;

  // Breathing element controller
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // Button glow pulse (activates when form is valid)
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Color picker ring burst
  late AnimationController _colorRingController;
  late Animation<double> _colorRingAnimation;

  // Color palette for child (curated to be distinct and playful)
  static const List<Color> childColorPalette = [
    Color(0xFFEC407A), // Pink
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFAB47BC), // Purple
    Color(0xFFFFCA28), // Yellow
    Color(0xFFFF7043), // Orange
    Color(0xFF26A69A), // Teal
    Color(0xFFEF5350), // Red
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddChildEnhancedModel());

    _model.nameController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    // Staggered entrance animations
    _headingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Breathing element — gentle scale pulse on the heading icon
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Button glow pulse — activates when form is complete
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Color ring burst — fires once on color selection
    _colorRingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _colorRingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _colorRingController, curve: Curves.easeOut),
    );

    // Stagger the entrances
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _headingController.forward();
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _subtitleController.forward();
      });
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) _cardController.forward();
      });
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headingController.dispose();
    _subtitleController.dispose();
    _cardController.dispose();
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

  Future<void> _selectBirthday() async {
    HapticFeedback.lightImpact();
    // Dismiss keyboard and remove cursor from name field
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    final initialDate = _model.selectedBirthday ?? DateTime.now();

    final selectedDate = await showCustomDateTimePicker(
      context: context,
      initialDateTime: initialDate,
      minimumDate: DateTime(1950),
      maximumDate: DateTime.now(),
      showTime: false,
      title: 'Birth Date',
    );

    if (selectedDate != null) {
      setState(() {
        _model.selectedBirthday = selectedDate;
      });
      _checkGlow();
    }
  }

  bool get _isFormComplete =>
      _model.nameController.text.trim().isNotEmpty &&
      _model.selectedBirthday != null &&
      _model.selectedGender != null &&
      _model.selectedColor != null;

  void _checkGlow() {
    if (_isFormComplete && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!_isFormComplete && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  bool _validateInputs() {
    if (_model.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your child\'s name')),
      );
      return false;
    }

    if (_model.selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birthday')),
      );
      return false;
    }

    if (_model.selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return false;
    }

    if (_model.selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a color')),
      );
      return false;
    }

    return true;
  }

  void _saveCurrentChild() {
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    demoData.addChild(
      name: _model.nameController.text.trim(),
      birthdate: _model.selectedBirthday!,
      gender: _model.selectedGender,
      color: _model.selectedColor,
    );
  }

  Future<void> _saveChildToFirestore() async {
    // Save directly to Firestore (for settings mode)
    final userId = currentUserUid;
    if (userId.isEmpty) return;

    await FirebaseFirestore.instance.collection('childern').add({
      'name': _model.nameController.text.trim(),
      'birth_day': _model.selectedBirthday!,
      'gender': _model.selectedGender,
      'selected_color': _model.selectedColor != null
          ? '#${_model.selectedColor!.value.toRadixString(16).substring(2)}'
          : null,
      'user_ref': FirebaseFirestore.instance.doc('users/$userId'),
      'created_time': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _saveChild() async {
    HapticFeedback.mediumImpact();
    if (!_validateInputs()) return;

    // Dismiss keyboard before saving
    FocusScope.of(context).unfocus();

    if (widget.isOnboarding) {
      // Onboarding mode: Save to DemoDataNotifier, navigate to parent setup
      _saveCurrentChild();

      if (mounted) {
        context.pushNamed(
          'ParentSetupEnhanced',
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
      }
    } else {
      // Settings mode: Save directly to Firestore, pop back
      try {
        await _saveChildToFirestore();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_model.nameController.text} added!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving child: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _addAnotherChild() async {
    HapticFeedback.mediumImpact();
    if (!_validateInputs()) return;

    final childName = _model.nameController.text.trim();

    if (widget.isOnboarding) {
      // Onboarding mode: Save to DemoDataNotifier
      _saveCurrentChild();
    } else {
      // Settings mode: Save to Firestore
      try {
        await _saveChildToFirestore();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving child: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // Reset form for next child
    setState(() {
      _model.nameController?.clear();
      _model.selectedBirthday = null;
      _model.selectedGender = null;
      _model.selectedColor = null;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$childName added! Add your next child.'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Progress tracker (immediate)
                  _staggeredEntry(
                    controller: _headingController,
                    child: OnboardingProgressTracker(
                      currentStep: 2,
                      fadeAnimation: CurvedAnimation(
                        parent: _headingController,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Heading with breathing icon
                  _staggeredEntry(
                    controller: _headingController,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add your child',
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ).copyWith(height: 1.2),
                          ),
                        ),
                        // Breathing element
                        ScaleTransition(
                          scale: _breathAnimation,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.child_care_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  _staggeredEntry(
                    controller: _subtitleController,
                    child: Text(
                      'This helps us personalize your experience',
                      style: FlutterFlowTheme.of(context)
                          .bodyLarge
                          .override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // White card container with form
                  _staggeredEntry(
                    controller: _cardController,
                    slideOffset: 30.0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          Text(
                            'Name',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _model.nameController,
                            focusNode: _model.nameFocusNode,
                            onChanged: (_) {
                              setState(() {});
                              _checkGlow();
                            },
                            decoration: InputDecoration(
                              hintText: 'e.g., Emma',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
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
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),

                          const SizedBox(height: 24),

                          // Birthday field
                          Text(
                            'Birthday',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectBirthday,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _model.selectedBirthday == null
                                        ? 'Select date'
                                        : DateFormat('MMMM d, y')
                                            .format(_model.selectedBirthday!),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          color: _model.selectedBirthday == null
                                              ? FlutterFlowTheme.of(context)
                                                  .secondaryText
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                        ),
                                  ),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 20.0,
                                    color:
                                        FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Gender selection
                          Text(
                            'Gender',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _model.selectedGender = 'Girl';
                                    });
                                    _checkGlow();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: _model.selectedGender == 'Girl'
                                          ? const Color(0xFFEC407A).withOpacity(0.15)
                                          : const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: _model.selectedGender == 'Girl'
                                            ? const Color(0xFFEC407A)
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Girl',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 16.0,
                                              fontWeight: _model.selectedGender == 'Girl'
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              letterSpacing: 0.0,
                                              color: _model.selectedGender == 'Girl'
                                                  ? const Color(0xFFEC407A)
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _model.selectedGender = 'Boy';
                                    });
                                    _checkGlow();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: _model.selectedGender == 'Boy'
                                          ? const Color(0xFF42A5F5).withOpacity(0.15)
                                          : const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: _model.selectedGender == 'Boy'
                                            ? const Color(0xFF42A5F5)
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Boy',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 16.0,
                                              fontWeight: _model.selectedGender == 'Boy'
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              letterSpacing: 0.0,
                                              color: _model.selectedGender == 'Boy'
                                                  ? const Color(0xFF42A5F5)
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Color picker
                          Text(
                            'Choose a color',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: childColorPalette.map((color) {
                              final isSelected = _model.selectedColor == color;
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _model.selectedColor = color;
                                  });
                                  // Fire ring burst animation
                                  _colorRingController.forward(from: 0.0);
                                  _checkGlow();
                                },
                                child: SizedBox(
                                  width: 56.0,
                                  height: 56.0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Ring burst animation (only on selected color)
                                      if (isSelected)
                                        AnimatedBuilder(
                                          animation: _colorRingAnimation,
                                          builder: (context, _) {
                                            final ringSize = 56.0 + (20.0 * _colorRingAnimation.value);
                                            return Positioned(
                                              left: (56.0 - ringSize) / 2,
                                              top: (56.0 - ringSize) / 2,
                                              child: Container(
                                                width: ringSize,
                                                height: ringSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
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
                                        width: 56.0,
                                        height: 56.0,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.transparent,
                                            width: 3.0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: color.withOpacity(0.4),
                                                    blurRadius: 8.0,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 28.0,
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
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  _staggeredEntry(
                    controller: _buttonController,
                    child: Column(
                      children: [
                        // Continue button with glow pulse
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28.0),
                                boxShadow: _isFormComplete
                                    ? [
                                        BoxShadow(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.4 * _glowAnimation.value),
                                          blurRadius: 16.0 * _glowAnimation.value,
                                          spreadRadius: 2.0 * _glowAnimation.value,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: child,
                            );
                          },
                          child: FFButtonWidget(
                            onPressed: _saveChild,
                            text: 'Continue',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              iconPadding: const EdgeInsets.all(0.0),
                              color: FlutterFlowTheme.of(context).primary,
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
                              hoverColor: FlutterFlowTheme.of(context).accent1,
                              hoverTextColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Add another child button
                        FFButtonWidget(
                          onPressed: _addAnotherChild,
                          text: 'Add another child',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 48.0,
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            iconPadding: const EdgeInsets.all(0.0),
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
