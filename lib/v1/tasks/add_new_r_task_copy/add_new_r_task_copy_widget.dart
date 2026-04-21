import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'add_new_r_task_copy_model.dart';
export 'add_new_r_task_copy_model.dart';

class AddNewRTaskCopyWidget extends StatefulWidget {
  const AddNewRTaskCopyWidget({super.key});

  @override
  State<AddNewRTaskCopyWidget> createState() => _AddNewRTaskCopyWidgetState();
}

class _AddNewRTaskCopyWidgetState extends State<AddNewRTaskCopyWidget> {
  late AddNewRTaskCopyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddNewRTaskCopyModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
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
        height: 500.0,
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
                Align(
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                    child: Text(
                      'Add New Task',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 28.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 50.0),
                    child: Text(
                      'Enter your task details below to create task.',
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
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
                            hintText: 'Title',
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
                          validator: _model.textController1Validator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Description',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
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
                                  20.0, 25.0, 0.0, 25.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 4,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController2Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final datePickedDate = await showDatePicker(
                            context: context,
                            initialDate: getCurrentTimestamp,
                            firstDate: getCurrentTimestamp,
                            lastDate: DateTime(2050),
                            builder: (context, child) {
                              return wrapInMaterialDatePickerTheme(
                                context,
                                child!,
                                headerBackgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                headerForegroundColor:
                                    FlutterFlowTheme.of(context).info,
                                headerTextStyle: FlutterFlowTheme.of(context)
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
                                    FlutterFlowTheme.of(context).primaryText,
                                selectedDateTimeBackgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                selectedDateTimeForegroundColor:
                                    FlutterFlowTheme.of(context).info,
                                actionButtonForegroundColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                iconSize: 24.0,
                              );
                            },
                          );

                          TimeOfDay? datePickedTime;
                          if (datePickedDate != null) {
                            datePickedTime = await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(getCurrentTimestamp),
                              builder: (context, child) {
                                return wrapInMaterialTimePickerTheme(
                                  context,
                                  child!,
                                  headerBackgroundColor:
                                      FlutterFlowTheme.of(context).primary,
                                  headerForegroundColor:
                                      FlutterFlowTheme.of(context).info,
                                  headerTextStyle: FlutterFlowTheme.of(context)
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
                                      FlutterFlowTheme.of(context).primaryText,
                                  selectedDateTimeBackgroundColor:
                                      FlutterFlowTheme.of(context).primary,
                                  selectedDateTimeForegroundColor:
                                      FlutterFlowTheme.of(context).info,
                                  actionButtonForegroundColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  iconSize: 24.0,
                                );
                              },
                            );
                          }

                          if (datePickedDate != null &&
                              datePickedTime != null) {
                            safeSetState(() {
                              _model.datePicked = DateTime(
                                datePickedDate.year,
                                datePickedDate.month,
                                datePickedDate.day,
                                datePickedTime!.hour,
                                datePickedTime.minute,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 20.0, 20.0, 20.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      valueOrDefault<String>(
                                        dateTimeFormat(
                                          "jm",
                                          _model.datePicked,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        'Select task Time',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
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
                      if (_model.isTaskTImeSelected == false)
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            'Please select Task Time',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: FlutterFlowTheme.of(context).error,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController3,
                            focusNode: _model.textFieldFocusNode3,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Select duration ',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
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
                                  20.0, 25.0, 0.0, 25.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController3Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .formTextFiledBackGround,
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    'Select child',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .black60,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 16.0, 0.0, 20.0),
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
                                  List<ChildernRecord>
                                      listViewChildernRecordList =
                                      snapshot.data!;

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        listViewChildernRecordList.length,
                                    itemBuilder: (context, listViewIndex) {
                                      final listViewChildernRecord =
                                          listViewChildernRecordList[
                                              listViewIndex];
                                      return Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Builder(
                                                    builder: (context) {
                                                      if (_model
                                                              .selectedChildern ==
                                                          listViewChildernRecord
                                                              .reference) {
                                                        return Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          10.0,
                                                                          0.0),
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  _model.selectedChildern =
                                                                      null;
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      10.0,
                                                                      0.0),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              _model.selectedChildern =
                                                                  listViewChildernRecord
                                                                      .reference;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: Container(
                                                              width: 20.0,
                                                              height: 20.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .black60,
                                                                  width: 2.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    listViewChildernRecord.name,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: FFAppState().currentFontFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black40,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 28.0,
                                              height: 28.0,
                                              decoration: BoxDecoration(
                                                color: listViewChildernRecord
                                                    .selectedColor,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_model.isChildSelected == false)
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            'please Select a child',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: FlutterFlowTheme.of(context).error,
                                  letterSpacing: 0.0,
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
                                if (_model.formKey.currentState == null ||
                                    !_model.formKey.currentState!.validate()) {
                                  return;
                                }
                                if (_model.selectedChildern?.id != null &&
                                    _model.selectedChildern?.id != '') {
                                  await TasksRecord.collection
                                      .doc()
                                      .set(createTasksRecordData(
                                        title: _model.textController1.text,
                                        description:
                                            _model.textController2.text,
                                        duration: double.tryParse(
                                            _model.textController3.text),
                                        createdBy: currentUserReference,
                                        selectedChild:
                                            _model.selectedChildern,
                                        taskDate: dateTimeFormat(
                                          "dd-MM-yyyy",
                                          _model.datepickerValue,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        taskStartTime: _model.datepickerValue,
                                      ));
                                  Navigator.pop(context);
                                } else {
                                  _model.isChildSelected = false;
                                  safeSetState(() {});
                                }
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
