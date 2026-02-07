import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/v2/auth/onboarding_progress_tracker.dart';
import '/v2/auth/demo_data_notifier.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
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
                          // Back arrow
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
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
                          // Progress tracker
                          OnboardingProgressTracker(
                            currentStep: 2,
                            fadeAnimation: _fadeAnimation,
                          ),
                          const SizedBox(height: 32.0),

                          // Title
                        Text(
                          'Now, let\'s set up your family!',
                          style: FlutterFlowTheme.of(context).headlineMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Choose names and colors for you and your partner. These will appear throughout the app.',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // === YOUR SECTION ===
                        _buildSectionCard(
                          context,
                          title: 'You',
                          subtitle: 'What should we call you?',
                          nameController: _model.myNameController!,
                          nameFocusNode: _model.myNameFocusNode!,
                          nameHint: 'Your name or nickname',
                          nameValidator: _model.myNameControllerValidator!,
                          selectedColor: _model.myColor,
                          onColorSelected: (color) {
                            setState(() {
                              _model.myColor = color;
                            });
                          },
                          initial: _model.myNameController!.text.isNotEmpty
                              ? _model.myNameController!.text[0].toUpperCase()
                              : 'M',
                        ),
                        const SizedBox(height: 20.0),

                        // === PARTNER SECTION ===
                        _buildSectionCard(
                          context,
                          title: 'Your Partner (Optional)',
                          subtitle: 'What should we call them?',
                          nameController: _model.partnerNameController!,
                          nameFocusNode: _model.partnerNameFocusNode!,
                          nameHint: 'Partner\'s name or nickname (optional)',
                          nameValidator: _model.partnerNameControllerValidator!,
                          selectedColor: _model.partnerColor,
                          onColorSelected: (color) {
                            setState(() {
                              _model.partnerColor = color;
                            });
                          },
                          initial: _model.partnerNameController!.text.isNotEmpty
                              ? _model.partnerNameController!.text[0].toUpperCase()
                              : 'P',
                        ),
                        const SizedBox(height: 32.0),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 56.0,
                          child: FFButtonWidget(
                            onPressed: () async {
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

                                // Navigate to features overview
                                if (context.mounted) {
                                  context.pushNamed('FeaturesEnhanced');
                                }
                              }
                            },
                            text: 'Continue',
                            options: FFButtonOptions(
                              height: 56.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Andika New Basic',
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
                        const SizedBox(height: 16.0),
                      ],
                    ),
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with preview circle
          Row(
            children: [
              // Preview circle showing selected color and initial
              Container(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Andika New Basic',
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
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
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
            onChanged: (val) => setState(() {}), // Update preview initial
            autofocus: false,
            decoration: InputDecoration(
              isDense: true,
              hintText: nameHint,
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'Andika New Basic',
                letterSpacing: 0.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCBE3E0),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).prim30,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              letterSpacing: 0.0,
            ),
            validator: (val) => nameValidator(context, val),
          ),
          const SizedBox(height: 16.0),

          // Color picker label
          Text(
            'Pick a color',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12.0),

          // Color palette
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: ParentSetupEnhancedModel.colorPalette.map((color) {
              final isSelected = selectedColor?.value == color.value;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: AnimatedContainer(
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
