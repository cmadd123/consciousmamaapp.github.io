import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'kindof_activitystep_model.dart';
export 'kindof_activitystep_model.dart';

class KindofActivitystepWidget extends StatefulWidget {
  const KindofActivitystepWidget({super.key});

  static String routeName = 'kindofActivitystep';
  static String routePath = '/kindofActivitystep';

  @override
  State<KindofActivitystepWidget> createState() =>
      _KindofActivitystepWidgetState();
}

class _KindofActivitystepWidgetState extends State<KindofActivitystepWidget> {
  late KindofActivitystepModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KindofActivitystepModel());
  }

  @override
  void dispose() {
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
        backgroundColor: FFAppState().isComfortMode
            ? const Color(0xFF2C3E50)
            : FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
                child: Material(
                  color: Colors.transparent,
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.9,
                    decoration: BoxDecoration(
                      color: FFAppState().isComfortMode
                          ? const Color(0xFF34495E)
                          : FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: FFAppState().isComfortMode
                            ? const Color(0xFF7F8C8D)
                            : FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15.0, 150.0, 0.0, 0.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.0),
                                    child: Image.asset(
                                      'assets/images/321.png',
                                      width: 79.0,
                                      height: 87.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 8.0, 24.0, 0.0),
                                child: Text(
                                  'Who is this activity for? ',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontSize: 24.0,
                                        color: FFAppState().isComfortMode
                                            ? const Color(0xFFECF0F1)
                                            : null,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 18.0, 0.0, 0.0),
                                child: Text(
                                  'Select one or more children',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: FFAppState().isComfortMode
                                            ? const Color(0xFF95A5A6)
                                            : const Color(0xC0000000),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: StreamBuilder<List<ChildernRecord>>(
                                  stream: queryChildernRecord(
                                    queryBuilder: (childernRecord) =>
                                        childernRecord.where(
                                      'userRef',
                                      isEqualTo: currentUserReference,
                                    ),
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<ChildernRecord> rowChildernRecordList =
                                        snapshot.data!;

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                            rowChildernRecordList.length,
                                            (rowIndex) {
                                          final rowChildernRecord =
                                              rowChildernRecordList[rowIndex];
                                          return Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 0.0, 0.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                _model.selectedCHild =
                                                    rowChildernRecord.reference;
                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: 150.0,
                                                height: 134.0,
                                                decoration: BoxDecoration(
                                                  color: _model.selectedCHild ==
                                                          rowChildernRecord
                                                              .reference
                                                      ? const Color(0x1D52A097)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14.0),
                                                  border: Border.all(
                                                    color: _model
                                                                .selectedCHild ==
                                                            rowChildernRecord
                                                                .reference
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                        : Colors.transparent,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 66.0,
                                                      height: 66.0,
                                                      decoration: BoxDecoration(
                                                        color: rowChildernRecord
                                                            .selectedColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          rowChildernRecord.name.isNotEmpty
                                                              ? rowChildernRecord.name[0].toUpperCase()
                                                              : 'C',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 28.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      rowChildernRecord.name,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: FFAppState().currentFontFamily,
                                                            color: FFAppState().isComfortMode
                                                                ? const Color(0xFFECF0F1)
                                                                : null,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).divide(const SizedBox(width: 16.0)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ].addToStart(const SizedBox(height: 2.0)),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 35.0, 20.0, 20.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    context.safePop();
                                  },
                                  text: 'Back',
                                  options: FFButtonOptions(
                                    width: 112.0,
                                    height: 40.0,
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
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 35.0, 20.0, 20.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    context.pushNamed(
                                      KindofActivitystep2Widget.routeName,
                                      queryParameters: {
                                        'selectedChild': serializeParam(
                                          _model.selectedCHild,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  text: 'Next',
                                  options: FFButtonOptions(
                                    width: 112.0,
                                    height: 40.0,
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
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
