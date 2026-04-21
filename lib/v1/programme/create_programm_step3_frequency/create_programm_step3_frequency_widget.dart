import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'create_programm_step3_frequency_model.dart';
export 'create_programm_step3_frequency_model.dart';

class CreateProgrammStep3FrequencyWidget extends StatefulWidget {
  const CreateProgrammStep3FrequencyWidget({
    super.key,
    required this.description,
    required this.child,
  });

  final String? description;
  final ChildernRecord? child;

  static String routeName = 'CreateProgrammStep3Frequency';
  static String routePath = '/createProgrammStep3Frequency';

  @override
  State<CreateProgrammStep3FrequencyWidget> createState() =>
      _CreateProgrammStep3FrequencyWidgetState();
}

class _CreateProgrammStep3FrequencyWidgetState
    extends State<CreateProgrammStep3FrequencyWidget> {
  late CreateProgrammStep3FrequencyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateProgrammStep3FrequencyModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Helper to get emoji for frequency index
  String _getFrequencyEmoji(int index) {
    const emojis = ['🔥', '⭐', '🌟', '💫', '✨', '🎯', '🎪', '🎨', '🎭', '🎪'];
    return emojis[index % emojis.length];
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
        backgroundColor: const Color(0xFFFFF5F2),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Main card container
                  Material(
                    color: Colors.transparent,
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Progress indicator row
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 5.0,
                                      height: 5.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0x6652A097),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 3.0),
                                    Container(
                                      width: 5.0,
                                      height: 5.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0x6652A097),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 3.0),
                                    Container(
                                      width: 33.0,
                                      height: 5.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        borderRadius: BorderRadius.circular(3.0),
                                      ),
                                    ),
                                    const SizedBox(width: 3.0),
                                    Container(
                                      width: 5.0,
                                      height: 5.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0x6652A097),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Step 3/4',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: FlutterFlowTheme.of(context).primary,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            // Decorative image
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/321.png',
                                    width: 79.0,
                                    height: 87.0,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            // Title
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                              child: Text(
                                'How often should we do activities?',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 24.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            // Subtitle
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 20.0),
                              child: Text(
                                'Pick a frequency that works for your family',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            // Frequency grid
                            Builder(
                              builder: (context) {
                                final frequency = FFAppConstants.ProgramSelectedFrequnce.toList();

                                return Wrap(
                                  spacing: 10.0,
                                  runSpacing: 10.0,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(frequency.length, (frequencyIndex) {
                                    final frequencyItem = frequency[frequencyIndex];
                                    final isSelected = _model.frequencyItem == frequencyIndex;

                                    return InkWell(
                                      onTap: () {
                                        _model.frequencyItem = frequencyIndex;
                                        safeSetState(() {});
                                      },
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width - 74) / 2,
                                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? FlutterFlowTheme.of(context).primary.withOpacity(0.15)
                                              : const Color(0xFFFFF5F2),
                                          borderRadius: BorderRadius.circular(16.0),
                                          border: Border.all(
                                            color: isSelected
                                                ? FlutterFlowTheme.of(context).primary
                                                : const Color(0x3352A097),
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                                    blurRadius: 8.0,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getFrequencyEmoji(frequencyIndex),
                                              style: const TextStyle(fontSize: 28.0),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              frequencyItem,
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                fontSize: 13.0,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                color: isSelected
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : FlutterFlowTheme.of(context).primaryText,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(height: 4.0),
                                              Icon(
                                                Icons.check_circle,
                                                color: FlutterFlowTheme.of(context).primary,
                                                size: 18.0,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                            // Buttons row
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 10.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          context.safePop();
                                        },
                                        text: 'Back',
                                        options: FFButtonOptions(
                                          width: 112.0,
                                          height: 40.0,
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context).primary,
                                          textStyle: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: Colors.white,
                                                letterSpacing: 0.0,
                                              ),
                                          elevation: 0.0,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 0.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          if (_model.frequencyItem != null) {
                                            context.pushNamed(
                                              CreateProgrammStep4DayTimeWidget.routeName,
                                              queryParameters: {
                                                'description': serializeParam(
                                                  widget.description,
                                                  ParamType.String,
                                                ),
                                                'selectedChild': serializeParam(
                                                  widget.child,
                                                  ParamType.Document,
                                                ),
                                                'frequencyText': serializeParam(
                                                  valueOrDefault<int>(
                                                        _model.frequencyItem,
                                                        0,
                                                      ) +
                                                      1,
                                                  ParamType.int,
                                                ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                'selectedChild': widget.child,
                                              },
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Please select a frequency',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  ),
                                                ),
                                                duration: const Duration(milliseconds: 4000),
                                                backgroundColor: FlutterFlowTheme.of(context).error,
                                              ),
                                            );
                                          }
                                        },
                                        text: 'Next',
                                        options: FFButtonOptions(
                                          width: 112.0,
                                          height: 40.0,
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context).primary,
                                          textStyle: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: Colors.white,
                                                letterSpacing: 0.0,
                                              ),
                                          elevation: 0.0,
                                          borderRadius: BorderRadius.circular(8.0),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
