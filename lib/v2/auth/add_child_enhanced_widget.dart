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
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'add_child_enhanced_model.dart';
export 'add_child_enhanced_model.dart';

class AddChildEnhancedWidget extends StatefulWidget {
  const AddChildEnhancedWidget({super.key});

  static String routeName = 'AddChildEnhanced';
  static String routePath = '/add-child-enhanced';

  @override
  State<AddChildEnhancedWidget> createState() => _AddChildEnhancedWidgetState();
}

class _AddChildEnhancedWidgetState extends State<AddChildEnhancedWidget>
    with TickerProviderStateMixin {
  late AddChildEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  Future<void> _selectBirthday() async {
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
    }
  }

  Future<void> _saveChild() async {
    // Validate inputs
    if (_model.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your child\'s name')),
      );
      return;
    }

    if (_model.selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birthday')),
      );
      return;
    }

    if (_model.selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }

    if (_model.selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a color')),
      );
      return;
    }

    // Save to local state (will be written to Firestore after signup)
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    demoData.setChildInfo(
      name: _model.nameController.text.trim(),
      birthdate: _model.selectedBirthday!,
      gender: _model.selectedGender,
    );

    // Dismiss keyboard before navigation
    FocusScope.of(context).unfocus();

    // Navigate to parent setup
    if (mounted) {
      context.pushNamed('ParentSetupEnhanced');
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Progress tracker
                    OnboardingProgressTracker(
                      currentStep: 1,
                      fadeAnimation: _fadeAnimation,
                    ),

                    const SizedBox(height: 24),

                    // Baby Mind Logo Animation
                    Center(
                      child: Lottie.asset(
                        'assets/animations/baby_mind_logo.json',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Heading
                    Text(
                      'Let\'s meet your\nlittle one',
                      style: FlutterFlowTheme.of(context)
                          .headlineLarge
                          .override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ).copyWith(height: 1.2),
                    ),

                    const SizedBox(height: 8),

                    Text(
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

                    const SizedBox(height: 32),

                    // White card container with form
                    Container(
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
                                    setState(() {
                                      _model.selectedGender = 'Girl';
                                    });
                                  },
                                  child: Container(
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
                                    setState(() {
                                      _model.selectedGender = 'Boy';
                                    });
                                  },
                                  child: Container(
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
                                  setState(() {
                                    _model.selectedColor = color;
                                  });
                                },
                                child: Container(
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
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    FFButtonWidget(
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

                    const SizedBox(height: 40),
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
