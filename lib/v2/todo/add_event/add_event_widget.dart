import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_date_time_picker.dart';
import '/components/parent_circle_widget.dart';
import '/custom_code/actions/notification_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/momrise_confirmation.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_event_model.dart';
export 'add_event_model.dart';

class AddEventWidget extends StatefulWidget {
  const AddEventWidget({
    super.key,
    required this.pageCurrent,
  });

  final String? pageCurrent;

  static String routeName = 'AddEvent';
  static String routePath = '/addEvent';

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  late AddEventModel _model;
  late ParentDisplayInfo _parentInfo;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddEventModel());
    _parentInfo = ParentDisplayInfo.fromUser(currentUserDocument);

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _showDateTimePicker() async {
    final initialDate = _model.selectedDate ?? DateTime.now();

    final selectedDate = await showCustomDateTimePicker(
      context: context,
      initialDateTime: initialDate.isBefore(DateTime.now()) ? DateTime.now() : initialDate,
      minimumDate: DateTime.now().subtract(const Duration(days: 1)),
      maximumDate: DateTime(2050),
      showTime: true,
      title: 'Select Date & Time',
      minuteInterval: 5,
    );

    if (selectedDate != null) {
      safeSetState(() {
        _model.datePicked = selectedDate;
        _model.selectedDate = selectedDate;
        _model.isSelecedDate = false;
      });
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Form(
                key: _model.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 50.0, 0.0, 0.0),
                            child: Text(
                              'Add Event',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Text(
                              'Edit your event details below',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xC6000000),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                        if (false)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 52.0, 0.0, 0.0),
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
                                          FlutterFlowTheme.of(context).primary,
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
                                    children: [
                                      // Children selection (multi-select)
                                      ...List.generate(
                                          rowChildernRecordList.length,
                                          (rowIndex) {
                                        final rowChildernRecord =
                                            rowChildernRecordList[rowIndex];
                                        final isSelected = _model.selectedChildren
                                            .contains(rowChildernRecord.reference);
                                        return Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              // Toggle selection for multi-select
                                              if (isSelected) {
                                                _model.selectedChildren.remove(rowChildernRecord.reference);
                                              } else {
                                                _model.selectedChildren.add(rowChildernRecord.reference);
                                              }
                                              // Keep selectedChild for backwards compatibility
                                              _model.selectedChild = _model.selectedChildren.isNotEmpty
                                                  ? _model.selectedChildren.first
                                                  : null;
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              width: 110.0,
                                              height: 134.0,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Color(0x1D52A097)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(14.0),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? FlutterFlowTheme.of(context).primary
                                                      : FlutterFlowTheme.of(context).alternate,
                                                  width: isSelected ? 2.0 : 1.0,
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisSize: MainAxisSize.max,
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
                                                                ? rowChildernRecord.name[0].toLowerCase()
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
                                                        valueOrDefault<String>(
                                                          rowChildernRecord.name,
                                                          'child name',
                                                        ),
                                                        style: FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  'Andika New Basic',
                                                              letterSpacing: 0.0,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Checkmark for selected
                                                  if (isSelected)
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 16.0),
                                      // Mom selection
                                      Align(
                                        alignment: AlignmentDirectional(-1.0, 0.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            _model.assignedToMom = !_model.assignedToMom;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 110.0,
                                            height: 134.0,
                                            decoration: BoxDecoration(
                                              color: _model.assignedToMom
                                                  ? _parentInfo.myColor.withOpacity(0.15)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.assignedToMom
                                                    ? _parentInfo.myColor
                                                    : FlutterFlowTheme.of(context).alternate,
                                                width: _model.assignedToMom ? 2.0 : 1.0,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 66.0,
                                                      height: 66.0,
                                                      decoration: BoxDecoration(
                                                        color: _parentInfo.myColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _parentInfo.myInitial,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 28.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      _parentInfo.myName,
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Andika New Basic',
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                if (_model.assignedToMom)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: _parentInfo.myColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      // Dad selection
                                      Align(
                                        alignment: AlignmentDirectional(-1.0, 0.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            _model.assignedToDad = !_model.assignedToDad;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 110.0,
                                            height: 134.0,
                                            decoration: BoxDecoration(
                                              color: _model.assignedToDad
                                                  ? _parentInfo.partnerColor.withOpacity(0.15)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: _model.assignedToDad
                                                    ? _parentInfo.partnerColor
                                                    : FlutterFlowTheme.of(context).alternate,
                                                width: _model.assignedToDad ? 2.0 : 1.0,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 66.0,
                                                      height: 66.0,
                                                      decoration: BoxDecoration(
                                                        color: _parentInfo.partnerColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _parentInfo.partnerInitial,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 28.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      _parentInfo.partnerName,
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Andika New Basic',
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                if (_model.assignedToDad)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: _parentInfo.partnerColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 30.0, 0.0, 0.0),
                          child: Container(
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).prim30,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: Color(0xFFCBE3E0),
                                width: 1.0,
                              ),
                            ),
                            child: Container(
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
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                  hintText: 'Event Name ',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
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
                                      fontFamily: 'Andika New Basic',
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
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 30.0, 0.0, 0.0),
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
                                    await _showDateTimePicker();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).prim30,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: Color(0xFFCBE3E0),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 16.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  dateTimeFormat(
                                                    "M/d h:mm a",
                                                    _model.selectedDate,
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  ),
                                                  'Event Date',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
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
                            ].divide(SizedBox(width: 11.0)),
                          ),
                        ),
                        if (_model.isSelecedDate)
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  2.0, 7.0, 0.0, 0.0),
                              child: Text(
                                'please selecte a data',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).error,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 30.0, 0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).prim30,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: Color(0xFFCBE3E0),
                                width: 1.0,
                              ),
                            ),
                            child: Container(
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
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                  hintText: 'Event Details/Notes',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
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
                                      fontFamily: 'Andika New Basic',
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 20.0),
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
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).primary,
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
                            // Validate event name is not empty
                            if (_model.textController1.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter an event name'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            if (_model.selectedDate != null) {
                              final eventRef = EventAndTaskRecord.collection.doc();
                              await eventRef.set(createEventAndTaskRecordData(
                                    selectedChild: _model.selectedChild ?? FFAppState().selectedChildForMilestone,
                                    selectedChildren: _model.selectedChildren.toList(),
                                    name: _model.textController1.text,
                                    description: _model.textController2.text,
                                    isrecurring: false,
                                    userRef: currentUserReference,
                                    date: _model.selectedDate,
                                    typ: 'Event',
                                    isCompleted: false,
                                    assignedToMom: _model.assignedToMom,
                                    assignedToDad: _model.assignedToDad,
                                  ));

                              // Schedule a 15-min-before reminder. Notification id is derived
                              // from the doc id so we can cancel/reschedule deterministically
                              // if the event is edited or deleted later. Fire-and-forget — a
                              // failed schedule must not block event creation.
                              try {
                                await notificationService.initialize();
                                await notificationService.scheduleCalendarReminder(
                                  notificationId: eventRef.id.hashCode & 0x7fffffff,
                                  eventName: _model.textController1.text,
                                  eventTime: _model.selectedDate!,
                                  minutesBefore: 15,
                                  eventId: eventRef.id,
                                );
                              } catch (e) {
                                debugPrint('Failed to schedule calendar reminder: $e');
                              }

                              FFAppState().todocash = true;
                              safeSetState(() {});

                              if (mounted) {
                                await MomRiseConfirmation.show(context, message: 'Event Created');
                              }

                              context.pushNamed(CalendarpageWidget.routeName);
                            } else {
                              _model.isSelecedDate = true;
                              safeSetState(() {});
                            }
                          },
                          text: 'Create',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                    ].divide(SizedBox(width: 16.0)),
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
