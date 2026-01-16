import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'addcalender_model.dart';
export 'addcalender_model.dart';

class AddcalenderWidget extends StatefulWidget {
  const AddcalenderWidget({
    super.key,
    String? fromPage,
    this.editTaskEvent,
  }) : this.fromPage = fromPage ?? 'Home';

  final String fromPage;
  final DocumentReference? editTaskEvent;

  static String routeName = 'addcalender';
  static String routePath = '/addcalender';

  @override
  State<AddcalenderWidget> createState() => _AddcalenderWidgetState();
}

class _AddcalenderWidgetState extends State<AddcalenderWidget> {
  late AddcalenderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddcalenderModel());

    // Load user's children and existing task/event data if editing
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.userChildren = await queryChildernRecordOnce(
        queryBuilder: (childernRecord) => childernRecord.where(
          'userRef',
          isEqualTo: currentUserReference,
        ),
      );

      // If editing, load the existing task/event data
      if (widget.editTaskEvent != null) {
        final taskEventDoc = await widget.editTaskEvent!.get();
        if (taskEventDoc.exists) {
          final taskEvent = EventAndTaskRecord.fromSnapshot(taskEventDoc);

          _model.nameController.text = taskEvent.name;
          _model.descriptionController.text = taskEvent.description;
          _model.selectedDate = taskEvent.date;
          // Normalize the type to 'Task' or 'Event'
          _model.selectedType = (taskEvent.typ == 'Tasks' || taskEvent.typ == 'Task') ? 'Task' : 'Event';
          _model.selectedChild = taskEvent.selectedChild;
          _model.recurringPattern = taskEvent.isrecurring ? 'Daily' : 'None'; // Default to Daily if recurring
          _model.assignToMom = taskEvent.assignedToMom;
          _model.assignToDad = taskEvent.assignedToDad;
        }
      } else {
        _model.selectedChild = _model.userChildren?.firstOrNull?.reference;
      }

      safeSetState(() {});
    });

    _model.nameController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.descriptionController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Unified date/time picker bottom sheet
  Future<void> _showDateTimePicker() async {
    DateTime tempDate = _model.selectedDate ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 400,
              decoration: BoxDecoration(
                color: FFAppState().isComfortMode
                    ? const Color(0xFF34495E)
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FFAppState().isComfortMode
                          ? const Color(0xFF7F8C8D)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header with Cancel/Done
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: FFAppState().isComfortMode
                                  ? const Color(0xFF95A5A6)
                                  : Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Andika New Basic',
                            ),
                          ),
                        ),
                        Text(
                          'Select Date & Time',
                          style: TextStyle(
                            color: FFAppState().isComfortMode
                                ? const Color(0xFFECF0F1)
                                : Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Andika New Basic',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _model.selectedDate = tempDate;
                              _model.isDateSelected = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Andika New Basic',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: FFAppState().isComfortMode
                        ? const Color(0xFF7F8C8D)
                        : const Color(0xFFE0E0E0),
                  ),
                  // Date & Time Picker
                  Expanded(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: FFAppState().isComfortMode
                                ? const Color(0xFFECF0F1)
                                : Colors.black87,
                            fontSize: 20,
                            fontFamily: 'Andika New Basic',
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: tempDate.isBefore(DateTime.now())
                            ? DateTime.now()
                            : tempDate,
                        minimumDate: DateTime.now().subtract(const Duration(minutes: 1)),
                        maximumDate: DateTime(2050),
                        use24hFormat: false,
                        onDateTimeChanged: (DateTime newDate) {
                          setModalState(() {
                            tempDate = newDate;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 50.0, 0.0, 0.0),
                            child: Text(
                              widget.editTaskEvent != null ? 'Edit' : 'Create New',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFFECF0F1)
                                        : FlutterFlowTheme.of(context).primaryText,
                                  ),
                            ),
                          ),
                        ),
                        // Task/Event Toggle
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: FFAppState().isComfortMode
                                  ? const Color(0xFF34495E)
                                  : FlutterFlowTheme.of(context).prim30,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                color: FFAppState().isComfortMode
                                    ? const Color(0xFF7F8C8D)
                                    : const Color(0xFFCBE3E0),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.selectedType = 'Task';
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _model.selectedType == 'Task'
                                            ? (FFAppState().isComfortMode
                                                ? const Color(0xFF7F8C8D)
                                                : FlutterFlowTheme.of(context).primary)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(25.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Task',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color: _model.selectedType == 'Task'
                                                  ? (FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : Colors.white)
                                                  : (FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : FlutterFlowTheme.of(context).primaryText),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.selectedType = 'Event';
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _model.selectedType == 'Event'
                                            ? (FFAppState().isComfortMode
                                                ? const Color(0xFF7F8C8D)
                                                : FlutterFlowTheme.of(context).primary)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(25.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Event',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color: _model.selectedType == 'Event'
                                                  ? (FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : Colors.white)
                                                  : (FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : FlutterFlowTheme.of(context).primaryText),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Name Field
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 30.0, 0.0, 0.0),
                          child: TextFormField(
                            controller: _model.nameController,
                            focusNode: _model.nameFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: '${_model.selectedType} Name',
                              labelStyle: FFAppState().isComfortMode
                                  ? FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: const Color(0xFF95A5A6),
                                        letterSpacing: 0.0,
                                      )
                                  : null,
                              hintText: 'Enter ${_model.selectedType.toLowerCase()} name...',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFF95A5A6)
                                        : null,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : const Color(0xFFCBE3E0),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                              filled: true,
                              fillColor: FFAppState().isComfortMode
                                  ? const Color(0xFF34495E)
                                  : FlutterFlowTheme.of(context).prim30,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 15.0, 20.0, 15.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFFECF0F1)
                                      : null,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        // Description Field
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: TextFormField(
                            controller: _model.descriptionController,
                            focusNode: _model.descriptionFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Description',
                              labelStyle: FFAppState().isComfortMode
                                  ? FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: const Color(0xFF95A5A6),
                                        letterSpacing: 0.0,
                                      )
                                  : null,
                              hintText: 'Enter description...',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFF95A5A6)
                                        : null,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : const Color(0xFFCBE3E0),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                              filled: true,
                              fillColor: FFAppState().isComfortMode
                                  ? const Color(0xFF34495E)
                                  : FlutterFlowTheme.of(context).prim30,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 15.0, 20.0, 15.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFFECF0F1)
                                      : null,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 3,
                          ),
                        ),
                        // Date/Time Picker
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () async {
                              await _showDateTimePicker();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 52.0,
                              decoration: BoxDecoration(
                                color: FFAppState().isComfortMode
                                    ? const Color(0xFF34495E)
                                    : FlutterFlowTheme.of(context).prim30,
                                borderRadius: BorderRadius.circular(29.0),
                                border: Border.all(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : const Color(0xFFCBE3E0),
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _model.selectedDate != null
                                          ? dateTimeFormat(
                                              "MMM d, y 'at' h:mm a",
                                              _model.selectedDate!,
                                              locale: FFLocalizations.of(context)
                                                  .languageCode,
                                            )
                                          : 'Select date and time',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            color: _model.selectedDate != null
                                                ? (FFAppState().isComfortMode
                                                    ? const Color(0xFFECF0F1)
                                                    : FlutterFlowTheme.of(context).primaryText)
                                                : (FFAppState().isComfortMode
                                                    ? const Color(0xFF95A5A6)
                                                    : FlutterFlowTheme.of(context).secondaryText),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: FFAppState().isComfortMode
                                          ? const Color(0xFF95A5A6)
                                          : FlutterFlowTheme.of(context).secondaryText,
                                      size: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Date validation error
                        if (!_model.isDateSelected && _model.showDateError)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 5.0, 0.0, 0.0),
                            child: Text(
                              'Please select a date and time',
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
                        // Child Selection Dropdown
                        if (_model.userChildren != null && _model.userChildren!.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 0.0, 8.0),
                                  child: Text(
                                    'Assign to Child (Optional)',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: FFAppState().isComfortMode
                                              ? const Color(0xFFECF0F1)
                                              : null,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 52.0,
                                  decoration: BoxDecoration(
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFF34495E)
                                        : FlutterFlowTheme.of(context).prim30,
                                    borderRadius: BorderRadius.circular(29.0),
                                    border: Border.all(
                                      color: FFAppState().isComfortMode
                                          ? const Color(0xFF7F8C8D)
                                          : const Color(0xFFCBE3E0),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<DocumentReference?>(
                                        value: _model.selectedChild,
                                        isExpanded: true,
                                        dropdownColor: FFAppState().isComfortMode
                                            ? const Color(0xFF34495E)
                                            : null,
                                        hint: Row(
                                          children: [
                                            Text(
                                              'Not assigned to any child',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Andika New Basic',
                                                    color: FFAppState().isComfortMode
                                                        ? const Color(0xFF95A5A6)
                                                        : FlutterFlowTheme.of(context).secondaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        items: [
                                          DropdownMenuItem<DocumentReference?>(
                                            value: null,
                                            child: Text(
                                              'None',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Andika New Basic',
                                                    color: FFAppState().isComfortMode
                                                        ? const Color(0xFFECF0F1)
                                                        : null,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                          ..._model.userChildren!
                                              .map((child) => DropdownMenuItem<DocumentReference?>(
                                                    value: child.reference,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 16.0,
                                                          height: 16.0,
                                                          decoration: BoxDecoration(
                                                            color: child.selectedColor,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                        SizedBox(width: 12.0),
                                                        Text(
                                                          child.name,
                                                          style: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: 'Andika New Basic',
                                                                color: FFAppState().isComfortMode
                                                                    ? const Color(0xFFECF0F1)
                                                                    : null,
                                                                letterSpacing: 0.0,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ],
                                        onChanged: (DocumentReference? value) {
                                          setState(() {
                                            _model.selectedChild = value;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FFAppState().isComfortMode
                                              ? const Color(0xFF95A5A6)
                                              : FlutterFlowTheme.of(context).secondaryText,
                                          size: 24.0,
                                        ),
                                        selectedItemBuilder: (BuildContext context) {
                                          return [
                                            Row(
                                              children: [
                                                Text(
                                                  'None',
                                                  style: FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Andika New Basic',
                                                        color: FFAppState().isComfortMode
                                                            ? const Color(0xFFECF0F1)
                                                            : null,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            ..._model.userChildren!.map((child) {
                                              return Row(
                                                children: [
                                                  Container(
                                                    width: 16.0,
                                                    height: 16.0,
                                                    decoration: BoxDecoration(
                                                      color: child.selectedColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.0),
                                                  Text(
                                                    child.name,
                                                    style: FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FFAppState().isComfortMode
                                                              ? const Color(0xFFECF0F1)
                                                              : null,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ];
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Recurring Dropdown
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 0.0, 8.0),
                                child: Text(
                                  'Repeat',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: FFAppState().isComfortMode
                                            ? const Color(0xFFECF0F1)
                                            : null,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF34495E)
                                      : FlutterFlowTheme.of(context).prim30,
                                  borderRadius: BorderRadius.circular(29.0),
                                  border: Border.all(
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFF7F8C8D)
                                        : const Color(0xFFCBE3E0),
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      12.0, 0.0, 12.0, 0.0),
                                  child: FlutterFlowDropDown<String>(
                                    controller: _model.recurringController ??=
                                        FormFieldController<String>('None'),
                                    options: const ['None', 'Daily', 'Weekly', 'Monthly'],
                                    onChanged: (val) => setState(
                                        () => _model.recurringPattern = val),
                                    width: double.infinity,
                                    height: 52.0,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          color: FFAppState().isComfortMode
                                              ? const Color(0xFFECF0F1)
                                              : null,
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'Select repeat pattern',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FFAppState().isComfortMode
                                          ? const Color(0xFF95A5A6)
                                          : FlutterFlowTheme.of(context).secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor: FFAppState().isComfortMode
                                        ? const Color(0xFF34495E)
                                        : Colors.transparent,
                                    elevation: 2.0,
                                    borderColor: Colors.transparent,
                                    borderWidth: 0.0,
                                    borderRadius: 12.0,
                                    margin: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 8.0, 0.0),
                                    hidesUnderline: true,
                                    isOverButton: false,
                                    isSearchable: false,
                                    isMultiSelect: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Assign To Section
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 0.0, 12.0),
                                child: Text(
                                  'Assign To',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: FFAppState().isComfortMode
                                            ? const Color(0xFFECF0F1)
                                            : null,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _model.assignToMom = !_model.assignToMom;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              16.0, 12.0, 16.0, 12.0),
                                          decoration: BoxDecoration(
                                            color: _model.assignToMom
                                                ? (FFAppState().isComfortMode
                                                    ? const Color(0xFF7F8C8D)
                                                    : const Color(0xFFE91E63))
                                                : (FFAppState().isComfortMode
                                                    ? const Color(0xFF34495E)
                                                    : FlutterFlowTheme.of(context)
                                                        .prim30),
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: FFAppState().isComfortMode
                                                  ? const Color(0xFF7F8C8D)
                                                  : const Color(0xFFE91E63),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _model.assignToMom
                                                    ? Icons.check_box
                                                    : Icons.check_box_outline_blank,
                                                color: _model.assignToMom
                                                    ? (FFAppState().isComfortMode
                                                        ? const Color(0xFFECF0F1)
                                                        : Colors.white)
                                                    : (FFAppState().isComfortMode
                                                        ? const Color(0xFF95A5A6)
                                                        : const Color(0xFFE91E63)),
                                                size: 20.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Mom',
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: _model.assignToMom
                                                          ? (FFAppState().isComfortMode
                                                              ? const Color(0xFFECF0F1)
                                                              : Colors.white)
                                                          : (FFAppState().isComfortMode
                                                              ? const Color(0xFFECF0F1)
                                                              : null),
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _model.assignToDad = !_model.assignToDad;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              16.0, 12.0, 16.0, 12.0),
                                          decoration: BoxDecoration(
                                            color: _model.assignToDad
                                                ? (FFAppState().isComfortMode
                                                    ? const Color(0xFF7F8C8D)
                                                    : const Color(0xFF2196F3))
                                                : (FFAppState().isComfortMode
                                                    ? const Color(0xFF34495E)
                                                    : FlutterFlowTheme.of(context)
                                                        .prim30),
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: FFAppState().isComfortMode
                                                  ? const Color(0xFF7F8C8D)
                                                  : const Color(0xFF2196F3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _model.assignToDad
                                                    ? Icons.check_box
                                                    : Icons.check_box_outline_blank,
                                                color: _model.assignToDad
                                                    ? (FFAppState().isComfortMode
                                                        ? const Color(0xFFECF0F1)
                                                        : Colors.white)
                                                    : (FFAppState().isComfortMode
                                                        ? const Color(0xFF95A5A6)
                                                        : const Color(0xFF2196F3)),
                                                size: 20.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Dad',
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: _model.assignToDad
                                                          ? (FFAppState().isComfortMode
                                                              ? const Color(0xFFECF0F1)
                                                              : Colors.white)
                                                          : (FFAppState().isComfortMode
                                                              ? const Color(0xFFECF0F1)
                                                              : null),
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
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
                              ),
                            ],
                          ),
                        ),
                      ].addToEnd(SizedBox(height: 100.0)),
                    ),
                  ),
                ),
              ),
              // Bottom buttons
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
                            color: FFAppState().isComfortMode
                                ? const Color(0xFF34495E)
                                : FlutterFlowTheme.of(context).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFFECF0F1)
                                      : FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FFAppState().isComfortMode
                                  ? const Color(0xFF7F8C8D)
                                  : FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            // Validate name
                            if (_model.nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a ${_model.selectedType.toLowerCase()} name'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            // Validate date
                            if (_model.selectedDate == null) {
                              setState(() {
                                _model.showDateError = true;
                              });
                              return;
                            }

                            // Check if we're editing or creating
                            if (widget.editTaskEvent != null) {
                              // Update existing task/event
                              await widget.editTaskEvent!.update(createEventAndTaskRecordData(
                                description: _model.descriptionController.text,
                                name: _model.nameController.text,
                                isrecurring: _model.recurringPattern != null && _model.recurringPattern != 'None',
                                selectedChild: _model.selectedChild ?? FFAppState().selectedChildForMilestone,
                                userRef: currentUserReference,
                                date: _model.selectedDate,
                                typ: _model.selectedType == 'Task' ? 'Task' : 'Event',
                                assignedToMom: _model.assignToMom,
                                assignedToDad: _model.assignToDad,
                              ));
                            } else {
                              // Create the initial task/event
                              await EventAndTaskRecord.collection
                                  .doc()
                                  .set(createEventAndTaskRecordData(
                                    description: _model.descriptionController.text,
                                    name: _model.nameController.text,
                                    isrecurring: _model.recurringPattern != null && _model.recurringPattern != 'None',
                                    selectedChild: _model.selectedChild ?? FFAppState().selectedChildForMilestone,
                                    userRef: currentUserReference,
                                    date: _model.selectedDate,
                                    typ: _model.selectedType == 'Task' ? 'Task' : 'Event',
                                    isCompleted: false,
                                    lastGenerated: getCurrentTimestamp,
                                    assignedToMom: _model.assignToMom,
                                    assignedToDad: _model.assignToDad,
                                  ));
                            }

                            // Generate recurring instances if needed (only for new tasks)
                            if (widget.editTaskEvent == null && _model.recurringPattern != null && _model.recurringPattern != 'None') {
                              DateTime nextDate = _model.selectedDate!;

                              // Generate next 12 instances
                              for (int i = 0; i < 12; i++) {
                                // Calculate next date based on pattern
                                if (_model.recurringPattern == 'Daily') {
                                  nextDate = nextDate.add(Duration(days: 1));
                                } else if (_model.recurringPattern == 'Weekly') {
                                  nextDate = nextDate.add(Duration(days: 7));
                                } else if (_model.recurringPattern == 'Monthly') {
                                  nextDate = DateTime(
                                    nextDate.year,
                                    nextDate.month + 1,
                                    nextDate.day,
                                    nextDate.hour,
                                    nextDate.minute,
                                  );
                                }

                                // Create the recurring instance
                                await EventAndTaskRecord.collection
                                    .doc()
                                    .set(createEventAndTaskRecordData(
                                      description: _model.descriptionController.text,
                                      name: _model.nameController.text,
                                      isrecurring: true,
                                      selectedChild: _model.selectedChild ?? FFAppState().selectedChildForMilestone,
                                      userRef: currentUserReference,
                                      date: nextDate,
                                      typ: _model.selectedType == 'Task' ? 'Task' : 'Event',
                                      isCompleted: false,
                                      lastGenerated: getCurrentTimestamp,
                                      assignedToMom: _model.assignToMom,
                                      assignedToDad: _model.assignToDad,
                                    ));
                              }
                            }

                            FFAppState().todocash = true;
                            setState(() {});

                            // Navigate back to calendar
                            context.pushNamed(CalendarpageWidget.routeName);
                          },
                          text: widget.editTaskEvent != null ? 'Update' : 'Create',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FFAppState().isComfortMode
                                ? const Color(0xFF7F8C8D)
                                : FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFFECF0F1)
                                      : Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
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
