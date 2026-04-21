import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/auth/demo_data_notifier.dart';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'sign_up_model.dart';
export 'sign_up_model.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  static String routeName = 'signUp';
  static String routePath = '/signUp';

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget>
    with TickerProviderStateMixin {
  late SignUpModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Staggered entrance controllers
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _fieldsController;
  late AnimationController _buttonController;
  late AnimationController _socialController;

  // Button glow animation
  late AnimationController _buttonGlowController;
  late Animation<double> _buttonGlowAnimation;

  // Form validation tracking for micro-interactions
  bool _usernameValid = false;
  bool _emailValid = false;
  bool _passwordValid = false;

  // Focus tracking for glow effect
  int? _focusedFieldIndex;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignUpModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    // Pre-fill username from onboarding data
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    if (demoData.myName != null && demoData.myName!.isNotEmpty) {
      _model.textController1!.text = demoData.myName!;
      _usernameValid = true;
    }

    // Add listeners for field validation
    _model.textController1!.addListener(_onFieldChanged);
    _model.textController2!.addListener(_onFieldChanged);
    _model.textController3!.addListener(_onFieldChanged);

    // Focus listeners for glow effect
    _model.textFieldFocusNode1!.addListener(() {
      setState(() => _focusedFieldIndex = _model.textFieldFocusNode1!.hasFocus ? 0 : (_focusedFieldIndex == 0 ? null : _focusedFieldIndex));
    });
    _model.textFieldFocusNode2!.addListener(() {
      setState(() => _focusedFieldIndex = _model.textFieldFocusNode2!.hasFocus ? 1 : (_focusedFieldIndex == 1 ? null : _focusedFieldIndex));
    });
    _model.textFieldFocusNode3!.addListener(() {
      setState(() => _focusedFieldIndex = _model.textFieldFocusNode3!.hasFocus ? 2 : (_focusedFieldIndex == 2 ? null : _focusedFieldIndex));
    });

    // Initialize staggered entrance controllers
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _socialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Button glow animation (pulses when form is valid)
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _buttonGlowAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _buttonGlowController, curve: Curves.easeInOut),
    );

    // Start staggered entrances
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _logoController.forward();
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _titleController.forward();
      });
      Future.delayed(const Duration(milliseconds: 240), () {
        if (mounted) _subtitleController.forward();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _fieldsController.forward();
      });
      Future.delayed(const Duration(milliseconds: 560), () {
        if (mounted) _buttonController.forward();
      });
      Future.delayed(const Duration(milliseconds: 680), () {
        if (mounted) _socialController.forward();
      });
    });
  }

  void _onFieldChanged() {
    final newUsernameValid = (_model.textController1?.text ?? '').trim().isNotEmpty;
    final newEmailValid = (_model.textController2?.text ?? '').contains('@');
    final newPasswordValid = (_model.textController3?.text ?? '').length >= 6;

    if (newUsernameValid != _usernameValid ||
        newEmailValid != _emailValid ||
        newPasswordValid != _passwordValid) {
      setState(() {
        _usernameValid = newUsernameValid;
        _emailValid = newEmailValid;
        _passwordValid = newPasswordValid;
      });

      // Start/stop glow based on form validity
      if (_usernameValid && _emailValid && _passwordValid) {
        if (!_buttonGlowController.isAnimating) {
          _buttonGlowController.repeat(reverse: true);
        }
      } else {
        _buttonGlowController.stop();
        _buttonGlowController.value = 0.0;
      }
    }
  }

  bool get _formIsValid => _usernameValid && _emailValid && _passwordValid;

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    _socialController.dispose();
    _buttonGlowController.dispose();
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
      child: SlideTransition(position: slideAnim, child: child),
    );
  }

  Widget _buildFormField({
    required int index,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hintText,
    required bool isValid,
    bool isPassword = false,
  }) {
    final isFocused = _focusedFieldIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.0),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.25),
                  blurRadius: 12.0,
                  spreadRadius: 1.0,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        obscureText: isPassword ? !_model.passwordVisibility : false,
        decoration: InputDecoration(
          isDense: true,
          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                letterSpacing: 0.0,
              ),
          hintText: hintText,
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                letterSpacing: 0.0,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isValid
                  ? FlutterFlowTheme.of(context).primary.withOpacity(0.4)
                  : const Color(0x00000000),
              width: isValid ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(27.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(27.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(27.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(27.0),
          ),
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 20.0),
          suffixIcon: isPassword
              ? InkWell(
                  onTap: () => safeSetState(
                    () => _model.passwordVisibility = !_model.passwordVisibility,
                  ),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    _model.passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 22,
                  ),
                )
              : isValid
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 22,
                        ),
                      ),
                    )
                  : null,
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              letterSpacing: 0.0,
            ),
        cursorColor: FlutterFlowTheme.of(context).primaryText,
        validator: index == 0
            ? _model.textController1Validator.asValidator(context)
            : index == 1
                ? _model.textController2Validator.asValidator(context)
                : _model.textController3Validator.asValidator(context),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    HapticFeedback.mediumImpact();

    // Validate inputs
    if (_model.textController2?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    if (_model.textController3?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    // Create account with email/password
    GoRouter.of(context).prepareAuthEvent();

    final user = await authManager.createAccountWithEmail(
      context,
      _model.textController2!.text,
      _model.textController3!.text,
    );

    if (user == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    if (!mounted) return;

    // Save demo data to Firestore
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    await demoData.saveToFirestore();

    // Navigate to welcome celebration
    if (mounted) {
      HapticFeedback.heavyImpact();
      context.pushNamed(
        'WelcomeCelebration',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 400),
          ),
        },
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();
    GoRouter.of(context).prepareAuthEvent();
    final user = await authManager.signInWithGoogle(context);
    if (user == null) return;

    // Save demo data to Firestore
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    await demoData.saveToFirestore();

    // Navigate to welcome celebration
    if (context.mounted) {
      HapticFeedback.heavyImpact();
      context.pushNamed(
        'WelcomeCelebration',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 400),
          ),
        },
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    HapticFeedback.mediumImpact();
    GoRouter.of(context).prepareAuthEvent();
    final user = await authManager.signInWithApple(context);
    if (user == null) return;

    // Save demo data to Firestore
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    await demoData.saveToFirestore();

    // Navigate to welcome celebration
    if (context.mounted) {
      HapticFeedback.heavyImpact();
      context.pushNamed(
        'WelcomeCelebration',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 400),
          ),
        },
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
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40.0),
                    // Logo
                    _staggeredEntry(
                      controller: _logoController,
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: Color(0x1A000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/image_22.png',
                            width: 72.0,
                            height: 72.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32.0),

                    // Title
                    _staggeredEntry(
                      controller: _titleController,
                      child: Text(
                        'Create an Account',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 32.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),

                    const SizedBox(height: 12.0),

                    // Subtitle
                    _staggeredEntry(
                      controller: _subtitleController,
                      child: Text(
                        'Enter details to create your account.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // Form fields
                    _staggeredEntry(
                      controller: _fieldsController,
                      slideOffset: 30.0,
                      child: Column(
                        children: [
                          _buildFormField(
                            index: 0,
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            hintText: 'Username',
                            isValid: _usernameValid,
                          ),
                          _buildFormField(
                            index: 1,
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            hintText: 'Enter your email',
                            isValid: _emailValid,
                          ),
                          _buildFormField(
                            index: 2,
                            controller: _model.textController3,
                            focusNode: _model.textFieldFocusNode3,
                            hintText: 'Enter your password',
                            isValid: _passwordValid,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28.0),

                    // Create account button with glow
                    _staggeredEntry(
                      controller: _buttonController,
                      child: AnimatedBuilder(
                        animation: _buttonGlowAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28.0),
                              boxShadow: _formIsValid
                                  ? [
                                      BoxShadow(
                                        color: FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.4),
                                        blurRadius: _buttonGlowAnimation.value + 4,
                                        spreadRadius: _buttonGlowAnimation.value / 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: child,
                          );
                        },
                        child: FFButtonWidget(
                          onPressed: _isSubmitting ? null : _handleSignUp,
                          text: _isSubmitting ? 'Creating...' : 'Create account',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Or continue with
                    _staggeredEntry(
                      controller: _socialController,
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                'Or continue with',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),

                          // Social buttons
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: _handleGoogleSignIn,
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: const Color(0x6552A097),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 18.0, 0.0),
                                          child: ClipRRect(
                                            child: SizedBox(
                                              width: 24.0,
                                              height: 24.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/Google.png',
                                                  width: 20.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Google',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: _handleAppleSignIn,
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: const Color(0x6552A097),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 18.0, 0.0),
                                          child: ClipRRect(
                                            child: SizedBox(
                                              width: 24.0,
                                              height: 24.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/Vector.png',
                                                  width: 20.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Apple',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Already have an account
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 27.0, 0.0, 40.0),
                            child: Center(
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Already have an account?',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ' Login',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                      mouseCursor: SystemMouseCursors.click,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          context.pushNamed(LoginWidget.routeName);
                                        },
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ),
                          ),

                          // Terms
                          Center(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 50.0),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'By Continuing, you are agree to our ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: const Color(0x8F000000),
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
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
}
