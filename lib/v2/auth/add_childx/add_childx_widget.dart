import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_date_time_picker.dart';
import '/components/onboarding_progress_indicator_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/momrise_confirmation.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'add_childx_model.dart';
export 'add_childx_model.dart';

class AddChildxWidget extends StatefulWidget {
  const AddChildxWidget({
    super.key,
    bool? isFirst,
  }) : isFirst = isFirst ?? true;

  final bool isFirst;

  static String routeName = 'addChildx';
  static String routePath = '/addChildx';

  @override
  State<AddChildxWidget> createState() => _AddChildxWidgetState();
}

class _AddChildxWidgetState extends State<AddChildxWidget> {
  late AddChildxModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddChildxModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Show a simple, intuitive date picker for birthday selection
  Future<void> _showSimpleDatePicker() async {
    final initialDate = _model.datePicked ?? DateTime.now();

    final selectedDate = await showCustomDateTimePicker(
      context: context,
      initialDateTime: initialDate,
      minimumDate: DateTime(1950),
      maximumDate: DateTime.now(),
      showTime: false, // Birthday doesn't need time
      title: 'Birth Date',
    );

    if (selectedDate != null) {
      setState(() {
        _model.datePicked = selectedDate;
        _model.selectedDate = selectedDate;
        _model.isBirthDaySelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent back navigation during onboarding (when isFirst is true)
    return PopScope(
      canPop: !widget.isFirst,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 50.0, 20.0, 50.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back arrow (only if not first child)
                  if (!widget.isFirst)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Align(
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
                    ),
                  // Progress indicator
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                    child: OnboardingProgressIndicator(
                      currentStep: 5,
                      totalSteps: 7,
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Container(
                      width: 182.0,
                      height: 156.0,
                      decoration: const BoxDecoration(),
                      child: Align(
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Image.asset(
                            'assets/images/image_22.png',
                            width: 200.0,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Please add your child’s details.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 32.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 22.0, 0.0, 40.0),
                      child: Text(
                        'Have more than one child? Don’t worry! \nYou can add them in a moment. ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                  Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Name or nickname',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBE3E0), // Teal border
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
                              fillColor: FlutterFlowTheme.of(context)
                                  .prim30, // Teal background
                              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                                  20.0, 20.0, 20.0, 20.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  letterSpacing: 0.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textControllerValidator
                                .asValidator(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // Male chip
                                    Expanded(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.gender = 'Male';
                                          _model.genderDropDownValue = 'Male';
                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          height: 57.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).prim30,
                                            borderRadius: BorderRadius.circular(14.0),
                                            border: Border.all(
                                              color: _model.gender == 'Male'
                                                  ? FlutterFlowTheme.of(context).primary
                                                  : const Color(0xFFCBE3E0),
                                              width: _model.gender == 'Male' ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Male',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: _model.gender == 'Male'
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    // Female chip
                                    Expanded(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.gender = 'Female';
                                          _model.genderDropDownValue = 'Female';
                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          height: 57.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).prim30,
                                            borderRadius: BorderRadius.circular(14.0),
                                            border: Border.all(
                                              color: _model.gender == 'Female'
                                                  ? FlutterFlowTheme.of(context).primary
                                                  : const Color(0xFFCBE3E0),
                                              width: _model.gender == 'Female' ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Female',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: _model.gender == 'Female'
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await _showSimpleDatePicker();
                                  },
                                  child: Container(
                                    width: 200.0,
                                    height: 57.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .prim30, // Teal background
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: const Color(0xFFCBE3E0),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 12.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              _model.datePicked != null
                                                  ? dateTimeFormat(
                                                      "M/d/yy",
                                                      _model.datePicked,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    )
                                                  : 'Birth date',
                                              '- -',
                                            ),
                                            style:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          'Andika New Basic',
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .black60,
                                                      letterSpacing: 0.0,
                                                    ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            size: 24.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 12.0)),
                          ),
                        ),
                        if (_model.isBirthDaySelected == false)
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Text(
                              'Please select your child birth date and gender',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          height: 125.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select color',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 0.0),
                                  // Child color palette - distinct from Mom (pink) and Dad (blue)
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Green - nature, growth
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFF81C784);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF81C784),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFF81C784)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Purple - playful, creative
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFB39DDB);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB39DDB),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFB39DDB)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Orange - warm, energetic
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFFB74D);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFB74D),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFFB74D)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Teal - calming, distinct
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFF4DB6AC);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4DB6AC),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFF4DB6AC)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Yellow - cheerful, sunny
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFFD54F);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD54F),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFFD54F)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Coral - warm but distinct from pink
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFF8A65);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF8A65),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFF8A65)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Red - bold, vibrant
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFF6B6B);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF6B6B),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFF6B6B)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Light Orange - soft, peachy
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFFA07A);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFA07A),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFFA07A)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Primary Teal - app primary color
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFF52A097);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF52A097),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFF52A097)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Light Teal - soft, airy
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFF95E1D3);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF95E1D3),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFF95E1D3)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Blue - sky, ocean
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFF5DADE2);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF5DADE2),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFF5DADE2)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Violet - whimsical, unique
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFEE82EE);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEE82EE),
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFEE82EE)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 5.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Spacer before buttons
                        const SizedBox(height: 24.0),
                        // Primary button - Add child and continue
                        FFButtonWidget(
                          onPressed: () async {
                            if (_model.formKey.currentState == null ||
                                !_model.formKey.currentState!.validate()) {
                              return;
                            }
                            if ((_model.isBirthDaySelected != null) &&
                                (_model.selectedDate != null) &&
                                (_model.gender != null &&
                                    _model.gender != '')) {
                              var childernRecordReference =
                                  ChildernRecord.collection.doc();
                              await childernRecordReference
                                  .set(createChildernRecordData(
                                name: _model.textController.text,
                                birthDay: _model.selectedDate,
                                selectedColor: _model.selectedCOolor,
                                userRef: currentUserReference,
                                id: '',
                                gender: _model.genderDropDownValue,
                              ));
                              _model.childedDoc =
                                  ChildernRecord.getDocumentFromData(
                                      createChildernRecordData(
                                        name: _model.textController.text,
                                        birthDay: _model.selectedDate,
                                        selectedColor: _model.selectedCOolor,
                                        userRef: currentUserReference,
                                        id: '',
                                        gender: _model.genderDropDownValue,
                                      ),
                                      childernRecordReference);

                              await currentUserReference!
                                  .update(createUsersRecordData(
                                firstChildCreated: true,
                              ));
                              FFAppState().selectedChildForMilestone =
                                  _model.childedDoc?.reference;
                              safeSetState(() {});

                              // Navigate based on whether this is first-time onboarding or adding another child
                              if (widget.isFirst) {
                                // First child - continue to parent setup
                                context.pushNamed(ParentSetupWidget.routeName);
                              } else {
                                // Adding another child - show confirmation and go back
                                if (mounted) {
                                  await MomRiseConfirmation.show(context, message: 'Child Added');
                                }
                                context.safePop();
                              }
                            } else {
                              _model.isBirthDaySelected = false;
                              safeSetState(() {});
                            }

                            safeSetState(() {});
                          },
                          text: 'Add child and continue',
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
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                        ),
                        // Spacing between buttons
                        const SizedBox(height: 12.0),
                        // Secondary button - Add another child (outlined style)
                        FFButtonWidget(
                            onPressed: () async {
                              if (_model.formKey.currentState == null ||
                                  !_model.formKey.currentState!.validate()) {
                                return;
                              }
                              if ((_model.isBirthDaySelected != null) &&
                                  (_model.selectedDate != null) &&
                                  (_model.gender != null &&
                                      _model.gender != '')) {
                                var childernRecordReference =
                                    ChildernRecord.collection.doc();
                                await childernRecordReference
                                    .set(createChildernRecordData(
                                  name: _model.textController.text,
                                  birthDay: _model.selectedDate,
                                  selectedColor: _model.selectedCOolor,
                                  userRef: currentUserReference,
                                  id: '',
                                  gender: _model.genderDropDownValue,
                                ));
                                _model.childedDocCopy2 =
                                    ChildernRecord.getDocumentFromData(
                                        createChildernRecordData(
                                          name: _model.textController.text,
                                          birthDay: _model.selectedDate,
                                          selectedColor: _model.selectedCOolor,
                                          userRef: currentUserReference,
                                          id: '',
                                          gender: _model.genderDropDownValue,
                                        ),
                                        childernRecordReference);

                                await currentUserReference!
                                    .update(createUsersRecordData(
                                  firstChildCreated: true,
                                ));

                                if (mounted) {
                                  await MomRiseConfirmation.show(context, message: 'Child Added');
                                }

                                context.pushNamed(
                                  AddChildxWidget.routeName,
                                  queryParameters: {
                                    'isFirst': serializeParam(
                                      false,
                                      ParamType.bool,
                                    ),
                                  }.withoutNulls,
                                );
                              } else {
                                _model.isBirthDaySelected = false;
                                safeSetState(() {});
                              }

                              safeSetState(() {});
                            },
                            text: 'Add another child',
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
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                        ),
                        // Bottom padding
                        const SizedBox(height: 24.0),
                      ].divide(const SizedBox(height: 16.0)),
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
