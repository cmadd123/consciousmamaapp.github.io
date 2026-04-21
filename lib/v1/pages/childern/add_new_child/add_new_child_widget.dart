import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'add_new_child_model.dart';
export 'add_new_child_model.dart';

class AddNewChildWidget extends StatefulWidget {
  const AddNewChildWidget({super.key});

  @override
  State<AddNewChildWidget> createState() => _AddNewChildWidgetState();
}

class _AddNewChildWidgetState extends State<AddNewChildWidget> {
  late AddNewChildModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddNewChildModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 500.0,
        height: 600.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(27.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                  child: Text(
                    'Add child details',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 28.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 50.0),
                  child: Text(
                    'Enter your child details.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            hintText: 'Name',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(27.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
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
                            contentPadding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 20.0),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    letterSpacing: 0.0,
                                  ),
                          cursorColor: FlutterFlowTheme.of(context).primaryText,
                          validator: _model.textControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  final datePickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: getCurrentTimestamp,
                                    firstDate: DateTime(1900),
                                    lastDate: getCurrentTimestamp,
                                    builder: (context, child) {
                                      return wrapInMaterialDatePickerTheme(
                                        context,
                                        child!,
                                        headerBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        headerForegroundColor:
                                            FlutterFlowTheme.of(context).info,
                                        headerTextStyle:
                                            FlutterFlowTheme.of(context)
                                                .headlineLarge
                                                .override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontSize: 32.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                        pickerBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        pickerForegroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        selectedDateTimeBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        selectedDateTimeForegroundColor:
                                            FlutterFlowTheme.of(context).info,
                                        actionButtonForegroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        iconSize: 24.0,
                                      );
                                    },
                                  );

                                  if (datePickedDate != null) {
                                    safeSetState(() {
                                      _model.datePicked = DateTime(
                                        datePickedDate.year,
                                        datePickedDate.month,
                                        datePickedDate.day,
                                      );
                                    });
                                  } else if (_model.datePicked != null) {
                                    safeSetState(() {
                                      _model.datePicked = getCurrentTimestamp;
                                    });
                                  }
                                  _model.datepickerValue = _model.datePicked;
                                  safeSetState(() {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .formTextFiledBackGround,
                                    borderRadius: BorderRadius.circular(27.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            20.0, 16.0, 20.0, 16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              valueOrDefault<String>(
                                                dateTimeFormat(
                                                  "yMMMd",
                                                  _model.datePicked,
                                                  locale: FFLocalizations.of(
                                                          context)
                                                      .languageCode,
                                                ),
                                                'Birth date',
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: FFAppState().currentFontFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ].divide(const SizedBox(width: 10.0)),
                        ),
                      ),
                      if (_model.isBirthDateSelected == false)
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            'Please select your child birth date',
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
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .formTextFiledBackGround,
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
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.selectedColor =
                                            const Color(0x5752A097);
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        constraints: const BoxConstraints(
                                          minWidth: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0x5752A097),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: valueOrDefault<Color>(
                                              _model.selectedColor ==
                                                      const Color(0x5752A097)
                                                  ? FlutterFlowTheme.of(context)
                                                      .primaryText
                                                  : Colors.transparent,
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.selectedColor =
                                            const Color(0xFFFCF3E9);
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFCF3E9),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: valueOrDefault<Color>(
                                              _model.selectedColor ==
                                                      const Color(0xFFFCF3E9)
                                                  ? FlutterFlowTheme.of(context)
                                                      .primaryText
                                                  : Colors.transparent,
                                              Colors.transparent,
                                            ),
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.selectedColor =
                                            const Color(0xFFFCE9F7);
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        constraints: const BoxConstraints(
                                          minWidth: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFCE9F7),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: _model.selectedColor ==
                                                    const Color(0xFFFCE9F7)
                                                ? FlutterFlowTheme.of(context)
                                                    .primaryText
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.selectedColor =
                                            const Color(0xFFE9E9FC);
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9E9FC),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: _model.selectedColor ==
                                                    const Color(0xFFE9E9FC)
                                                ? FlutterFlowTheme.of(context)
                                                    .primaryText
                                                : Colors.transparent,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.selectedColor =
                                            const Color(0xFFFCE9E9);
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFCE9E9),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: _model.selectedColor ==
                                                    const Color(0xFFFCE9E9)
                                                ? FlutterFlowTheme.of(context)
                                                    .primaryText
                                                : Colors.transparent,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 5.0)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              text: 'Cancel',
                              options: FFButtonOptions(
                                height: 49.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: const Color(0x0052A097),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () async {
                                _model.alluserChild =
                                    await queryChildernRecordOnce(
                                  queryBuilder: (childernRecord) =>
                                      childernRecord.where(
                                    'userRef',
                                    isEqualTo: currentUserReference,
                                  ),
                                );
                                _model.children = _model.alluserChild!
                                    .toList()
                                    .cast<ChildernRecord>();
                                safeSetState(() {});
                                if (functions.checkChildreanName(
                                    _model.children.toList(),
                                    _model.textController.text)!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'There is a child with the same name',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).error,
                                    ),
                                  );
                                } else {
                                  if (_model.formKey.currentState == null ||
                                      !_model.formKey.currentState!
                                          .validate()) {
                                    return;
                                  }
                                  if (_model.datepickerValue != null) {
                                    await ChildernRecord.collection
                                        .doc()
                                        .set(createChildernRecordData(
                                          name: _model.textController.text,
                                          selectedColor: _model.selectedColor,
                                          userRef: currentUserReference,
                                          birthDay: _model.datepickerValue,
                                        ));
                                    FFAppState().clearChildrenCache();
                                    FFAppState().activityFinalModel = [];
                                    safeSetState(() {});

                                    if (context.mounted) {
                                      context
                                          .pushNamed(ChildrenWidget.routeName);
                                    }
                                  } else {
                                    _model.isBirthDateSelected = false;
                                    safeSetState(() {});
                                  }
                                }

                                safeSetState(() {});
                              },
                              text: 'Add',
                              options: FFButtonOptions(
                                height: 48.0,
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
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 10.0)),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
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
