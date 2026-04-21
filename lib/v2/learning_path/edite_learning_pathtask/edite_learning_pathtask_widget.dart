import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_date_time_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/momrise_confirmation.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'edite_learning_pathtask_model.dart';
export 'edite_learning_pathtask_model.dart';

class EditeLearningPathtaskWidget extends StatefulWidget {
  const EditeLearningPathtaskWidget({
    super.key,
    required this.learingTask,
  });

  final LearningPathTasksRecord? learingTask;

  static String routeName = 'EditeLearningPathtask';
  static String routePath = '/editeLearningPathtask';

  @override
  State<EditeLearningPathtaskWidget> createState() =>
      _EditeLearningPathtaskWidgetState();
}

class _EditeLearningPathtaskWidgetState
    extends State<EditeLearningPathtaskWidget> {
  late EditeLearningPathtaskModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditeLearningPathtaskModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.selectedDate = widget.learingTask?.taskTime;
      _model.seectedChild = widget.learingTask?.childRef;
      safeSetState(() {});
    });

    _model.textController1 ??= TextEditingController(
        text: valueOrDefault<String>(
      widget.learingTask?.title,
      'pathTitle',
    ));
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??=
        TextEditingController(text: widget.learingTask?.description);
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??=
        TextEditingController(text: widget.learingTask?.duration.toString());
    _model.textFieldFocusNode3 ??= FocusNode();
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                        child: Text(
                          'Edit Path Details',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Text(
                          'Edit your lesson details below to update',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: const Color(0xC6000000),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).prim30,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: const Color(0xFFCBE3E0),
                            width: 1.0,
                          ),
                        ),
                        child: SizedBox(
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
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Crafting a Potty Hat ',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
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
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            enableInteractiveSelection: true,
                            validator: _model.textController1Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final selectedDate = await showCustomDateTimePicker(
                                  context: context,
                                  initialDateTime: _model.datePicked ?? getCurrentTimestamp,
                                  minimumDate: DateTime(2020),
                                  maximumDate: DateTime(2050),
                                  showTime: false, // Date only for learning path tasks
                                  title: 'Select Date',
                                );

                                if (selectedDate != null) {
                                  safeSetState(() {
                                    _model.datePicked = selectedDate;
                                  });
                                }
                                _model.selectedDate = _model.datePicked;
                                safeSetState(() {});
                              },
                              child: Container(
                                width: 200.0,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).prim30,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(
                                    color: const Color(0xFFCBE3E0),
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 16.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            _model.selectedDate != null
                                                ? dateTimeFormat(
                                                    "M/d h:mm a",
                                                    _model.selectedDate,
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  )
                                                : '18/3 10:45',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_sharp,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 11.0)),
                      ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).prim30,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: const Color(0xFFCBE3E0),
                            width: 1.0,
                          ),
                        ),
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
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              hintText:
                                  'Create a special ‘potty’ using craft materials that your child can wear when they attempt to use the potty.',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
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
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 5,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            enableInteractiveSelection: true,
                            validator: _model.textController2Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration (minutes)',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).prim30,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: const Color(0xFFCBE3E0),
                            width: 1.0,
                          ),
                        ),
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
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'e.g. 15',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
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
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                            keyboardType: TextInputType.number,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            enableInteractiveSelection: true,
                            validator: _model.textController3Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 52.0,
                        ),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).prim30,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: const Color(0xFFCBE3E0),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 16.0, 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Select child',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 8.0, 0.0),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_sharp,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 24.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StreamBuilder<List<ChildernRecord>>(
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
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                List<ChildernRecord>
                                    listViewChildernRecordList = snapshot.data!;

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: listViewChildernRecordList.length,
                                  itemBuilder: (context, listViewIndex) {
                                    final listViewChildernRecord =
                                        listViewChildernRecordList[
                                            listViewIndex];
                                    return Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 20.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    _model.seectedChild =
                                                        listViewChildernRecord
                                                            .reference;
                                                    safeSetState(() {});
                                                  },
                                                  child: ClipOval(
                                                    child: Container(
                                                      width: 19.0,
                                                      height: 19.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .bordercolors,
                                                        ),
                                                      ),
                                                      child: Visibility(
                                                        visible: _model
                                                                .seectedChild ==
                                                            listViewChildernRecord
                                                                .reference,
                                                        child: Container(
                                                          width: 100.0,
                                                          height: 100.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .check_outlined,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .info,
                                                              size: 14.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  listViewChildernRecord.name,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: FFAppState().currentFontFamily,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ].divide(const SizedBox(width: 8.0)),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 24.0, 0.0),
                                            child: Container(
                                              width: 24.0,
                                              height: 24.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        3.0, 3.0, 3.0, 3.0),
                                                child: Container(
                                                  width: 100.0,
                                                  height: 100.0,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        listViewChildernRecord
                                                            .selectedColor,
                                                  ),
                                                ),
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
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24.0, 60.0, 24.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () async {
                                context.safePop();
                              },
                              text: 'Cancel',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
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
                                borderRadius: BorderRadius.circular(14.0),
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

                                await widget.learingTask!.programRef!
                                    .update(createLearningPathRecordData(
                                  childRef: _model.seectedChild,
                                ));
                                _model.pathref =
                                    await LearningPathRecord.getDocumentOnce(
                                        widget.learingTask!.programRef!);

                                await widget.learingTask!.reference
                                    .update(createLearningPathTasksRecordData(
                                  title: _model.textController1.text,
                                  taskTime: _model.selectedDate,
                                  description: _model.textController2.text,
                                  duration:
                                      int.tryParse(_model.textController3.text),
                                  programRef: widget.learingTask?.programRef,
                                ));

                                if (mounted) {
                                  await MomRiseConfirmation.show(context, message: 'Lesson Updated');
                                }

                                context.pushNamed(
                                  LearnPathDetialsWidget.routeName,
                                  queryParameters: {
                                    'leRef': serializeParam(
                                      _model.pathref?.reference,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );

                                safeSetState(() {});
                              },
                              text: 'Update',
                              options: FFButtonOptions(
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
                        ].divide(const SizedBox(width: 16.0)),
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
