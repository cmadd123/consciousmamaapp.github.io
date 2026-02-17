import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/animated_press_widget.dart';
import '/components/custom_date_time_picker.dart';
import '/components/parent_circle_widget.dart';
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
import 'package:flutter/scheduler.dart';
import 'addcalender_model.dart';
export 'addcalender_model.dart';

class AddcalenderWidget extends StatefulWidget {
  const AddcalenderWidget({
    super.key,
    String? fromPage,
    this.editTaskEvent,
    this.prefillName,
    this.prefillDescription,
  }) : this.fromPage = fromPage ?? 'Home';

  final String fromPage;
  final DocumentReference? editTaskEvent;

  /// Pre-fill the name field (e.g., from My Activities)
  final String? prefillName;

  /// Pre-fill the description field (e.g., from My Activities)
  final String? prefillDescription;

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

    // Load user's children, parent info, and existing task/event data if editing
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Load parent info
      if (currentUserReference != null) {
        final user = await UsersRecord.getDocumentOnce(currentUserReference!);
        _model.parentInfo = ParentDisplayInfo.fromUser(user);
      }

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

          // Store the full record for displaying Activity details as read-only
          _model.editingRecord = taskEvent;

          _model.nameController.text = taskEvent.name;
          _model.descriptionController.text = taskEvent.description;
          _model.selectedDate = taskEvent.date;
          // Normalize the type to 'Event' or 'Activity'
          _model.selectedType = (taskEvent.typ == 'Activity') ? 'Activity' : 'Event';
          // Load selected children
          if (taskEvent.selectedChildren.isNotEmpty) {
            _model.selectedChildren = taskEvent.selectedChildren.toSet();
          } else if (taskEvent.selectedChild != null) {
            _model.selectedChildren = {taskEvent.selectedChild!};
          }
          _model.selectedChild = taskEvent.selectedChild;
          // Load the actual recurring pattern from Firestore (not hardcoded!)
          _model.recurringPattern = taskEvent.hasRecurringPattern() ? taskEvent.recurringPattern : 'None';
          _model.endDate = taskEvent.endDate; // Load end date
          _model.repeatCount = taskEvent.repeatCount; // Load repeat count
          _model.customWeeklyDays = taskEvent.customWeeklyDays.toSet(); // Load custom weekly days
          _model.assignToMom = taskEvent.assignedToMom;
          _model.assignToDad = taskEvent.assignedToDad;

          // DEBUG: Log what was loaded from Firestore
          debugPrint('=== LOADING EVENT FOR EDIT ===');
          debugPrint('Event name: ${taskEvent.name}');
          debugPrint('isRecurring: ${taskEvent.isrecurring}');
          debugPrint('Recurring pattern from Firestore: ${taskEvent.hasRecurringPattern() ? taskEvent.recurringPattern : "NOT SET"}');
          debugPrint('End date from Firestore: ${taskEvent.hasEndDate() ? taskEvent.endDate : "NOT SET"}');
          debugPrint('Loaded into model: pattern=${_model.recurringPattern}, endDate=${_model.endDate}');
          debugPrint('==============================');
        }
      } else {
        // Don't auto-select first child - let user choose (per user request)
        // _model.selectedChild = _model.userChildren?.firstOrNull?.reference;
        // Pre-fill from activity if provided
        if (widget.prefillName != null && widget.prefillName!.isNotEmpty) {
          _model.nameController.text = widget.prefillName!;
        }
        if (widget.prefillDescription != null && widget.prefillDescription!.isNotEmpty) {
          _model.descriptionController.text = widget.prefillDescription!;
        }
        // Set type to Activity when coming from activities page
        if (widget.fromPage == 'activities') {
          _model.selectedType = 'Activity';
        }
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

  /// Returns true when editing an existing Activity (not Event)
  /// Activity details (name, description, etc.) should be read-only
  /// Only date and assignment can be changed
  bool get _isEditingActivity =>
      widget.editTaskEvent != null && _model.selectedType == 'Activity';

  // Helper to get day name for debug output
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return 'Unknown';
    }
  }

  // End date/time picker - Custom wheel picker
  Future<void> _showEndDateTimePicker() async {
    // Dismiss keyboard before showing picker
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final initialDate = _model.endDate ?? _model.selectedDate ?? DateTime.now();

    final selectedDate = await showCustomDateTimePicker(
      context: context,
      initialDateTime: initialDate,
      minimumDate: _model.selectedDate ?? DateTime.now(),
      maximumDate: DateTime(2050),
      showTime: true,
      title: 'End Date & Time',
    );

    if (selectedDate != null) {
      setState(() {
        _model.endDate = selectedDate;
        _model.isEndDateSelected = true;
      });
    }
  }

  // Date/time picker - Custom wheel picker
  Future<void> _showDateTimePicker() async {
    // Dismiss keyboard before showing picker
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final initialDate = _model.selectedDate ?? DateTime.now();

    final selectedDate = await showCustomDateTimePicker(
      context: context,
      initialDateTime: initialDate.isBefore(DateTime.now()) ? DateTime.now() : initialDate,
      minimumDate: DateTime.now().subtract(const Duration(days: 1)),
      maximumDate: DateTime(2050),
      showTime: true,
      title: 'Start Date & Time',
    );

    if (selectedDate != null) {
      setState(() {
        _model.selectedDate = selectedDate;
        _model.isDateSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComfort = FFAppState().isComfortMode;
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isComfort
            ? const Color(0xFF2C3E50)
            : theme.secondaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Form(
                key: _model.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => context.safePop(),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                    color: isComfort ? const Color(0xFFECF0F1) : theme.primaryText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.editTaskEvent != null ? 'Edit' : 'New ${_model.selectedType}',
                                style: theme.titleLarge.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  color: isComfort ? const Color(0xFFECF0F1) : theme.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // WHAT section with type toggle and name
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 20,
                                color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'What is it?',
                                style: theme.bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Event/Activity Toggle - smaller, inline
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                          child: Container(
                            height: 42.0,
                            decoration: BoxDecoration(
                              color: isComfort
                                  ? const Color(0xFF34495E)
                                  : theme.prim30,
                              borderRadius: BorderRadius.circular(21.0),
                              border: Border.all(
                                color: isComfort
                                    ? const Color(0xFF7F8C8D)
                                    : const Color(0xFFCBE3E0),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => setState(() => _model.selectedType = 'Event'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: _model.selectedType == 'Event'
                                          ? (isComfort ? const Color(0xFF7F8C8D) : theme.primary)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(21.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Event',
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        color: _model.selectedType == 'Event'
                                            ? Colors.white
                                            : (isComfort ? const Color(0xFFECF0F1) : theme.primaryText),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _model.selectedType = 'Activity'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: _model.selectedType == 'Activity'
                                          ? (isComfort ? const Color(0xFF7F8C8D) : theme.primary)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(21.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Activity',
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        color: _model.selectedType == 'Activity'
                                            ? Colors.white
                                            : (isComfort ? const Color(0xFFECF0F1) : theme.primaryText),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Name Field - read-only when editing an Activity
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: TextFormField(
                            controller: _model.nameController,
                            focusNode: _model.nameFocusNode,
                            autofocus: false,
                            readOnly: _isEditingActivity,
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
                              hintText: _isEditingActivity ? null : 'Enter ${_model.selectedType.toLowerCase()} name...',
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
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              filled: true,
                              fillColor: _isEditingActivity
                                  ? (FFAppState().isComfortMode
                                      ? const Color(0xFF2C3E50)
                                      : Colors.grey[100])
                                  : (FFAppState().isComfortMode
                                      ? const Color(0xFF34495E)
                                      : FlutterFlowTheme.of(context).prim30),
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
                        // Description Field - read-only when editing an Activity
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: TextFormField(
                            controller: _model.descriptionController,
                            focusNode: _model.descriptionFocusNode,
                            autofocus: false,
                            readOnly: _isEditingActivity,
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
                              hintText: _isEditingActivity ? null : 'Enter description...',
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
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FFAppState().isComfortMode
                                      ? const Color(0xFF7F8C8D)
                                      : FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              filled: true,
                              fillColor: _isEditingActivity
                                  ? (FFAppState().isComfortMode
                                      ? const Color(0xFF2C3E50)
                                      : Colors.grey[100])
                                  : (FFAppState().isComfortMode
                                      ? const Color(0xFF34495E)
                                      : FlutterFlowTheme.of(context).prim30),
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
                                borderRadius: BorderRadius.circular(14.0),
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
                        // End Date/Time Picker (for Events - multi-day support)
                        // Disabled when recurring pattern is selected
                        if (_model.selectedType == 'Event')
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: InkWell(
                              onTap: (_model.recurringPattern != null && _model.recurringPattern != 'None')
                                ? null // Disable when recurring
                                : () async {
                                  await _showEndDateTimePicker();
                                },
                              child: Opacity(
                                opacity: (_model.recurringPattern != null && _model.recurringPattern != 'None') ? 0.4 : 1.0,
                                child: Container(
                                  width: double.infinity,
                                  height: 52.0,
                                  decoration: BoxDecoration(
                                    color: FFAppState().isComfortMode
                                        ? const Color(0xFF34495E)
                                        : FlutterFlowTheme.of(context).prim30,
                                    borderRadius: BorderRadius.circular(14.0),
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
                                        _model.endDate != null
                                            ? 'End: ${dateTimeFormat(
                                                "MMM d, y 'at' h:mm a",
                                                _model.endDate!,
                                                locale: FFLocalizations.of(context)
                                                    .languageCode,
                                              )}'
                                            : 'End date (optional)',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color: _model.endDate != null
                                                  ? (FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : FlutterFlowTheme.of(context).primaryText)
                                                  : (FFAppState().isComfortMode
                                                      ? const Color(0xFF95A5A6)
                                                      : FlutterFlowTheme.of(context).secondaryText),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_model.endDate != null)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _model.endDate = null;
                                                  _model.isEndDateSelected = false;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Icon(
                                                  Icons.close,
                                                  color: FFAppState().isComfortMode
                                                      ? const Color(0xFF95A5A6)
                                                      : FlutterFlowTheme.of(context).secondaryText,
                                                  size: 18.0,
                                                ),
                                              ),
                                            ),
                                          Icon(
                                            Icons.date_range,
                                            color: FFAppState().isComfortMode
                                                ? const Color(0xFF95A5A6)
                                                : FlutterFlowTheme.of(context).secondaryText,
                                            size: 20.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                        // Parent Assignment - Mom/Dad chips (styled like child chips)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_alt_rounded,
                                      size: 20,
                                      color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Who's taking this on?",
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(optional)',
                                      style: theme.bodySmall.override(
                                        fontFamily: 'Andika New Basic',
                                        color: isComfort ? const Color(0xFF95A5A6) : const Color(0xFF9B8A9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    // Mom chip
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _model.assignToMom = !_model.assignToMom;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: _model.assignToMom
                                              ? (isComfort ? const Color(0xFF7F8C8D) : _model.parentInfo.myColor.withValues(alpha: 0.15))
                                              : (isComfort ? const Color(0xFF34495E) : const Color(0xFFF5F5F5)),
                                          borderRadius: BorderRadius.circular(20.0),
                                          border: Border.all(
                                            color: _model.assignToMom
                                                ? (isComfort ? const Color(0xFF95A5A6) : _model.parentInfo.myColor)
                                                : (isComfort ? const Color(0xFF7F8C8D) : Colors.transparent),
                                            width: _model.assignToMom ? 2.0 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 24.0,
                                              height: 24.0,
                                              decoration: BoxDecoration(
                                                color: _model.parentInfo.myColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _model.parentInfo.myInitial,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              _model.parentInfo.myName,
                                              style: theme.bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (_model.assignToMom) ...[
                                              const SizedBox(width: 4.0),
                                              Icon(
                                                Icons.check_circle,
                                                size: 16.0,
                                                color: isComfort ? const Color(0xFFECF0F1) : _model.parentInfo.myColor,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Partner chip
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _model.assignToDad = !_model.assignToDad;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: _model.assignToDad
                                              ? (isComfort ? const Color(0xFF7F8C8D) : _model.parentInfo.partnerColor.withValues(alpha: 0.15))
                                              : (isComfort ? const Color(0xFF34495E) : const Color(0xFFF5F5F5)),
                                          borderRadius: BorderRadius.circular(20.0),
                                          border: Border.all(
                                            color: _model.assignToDad
                                                ? (isComfort ? const Color(0xFF95A5A6) : _model.parentInfo.partnerColor)
                                                : (isComfort ? const Color(0xFF7F8C8D) : Colors.transparent),
                                            width: _model.assignToDad ? 2.0 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 24.0,
                                              height: 24.0,
                                              decoration: BoxDecoration(
                                                color: _model.parentInfo.partnerColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _model.parentInfo.partnerInitial,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              _model.parentInfo.partnerName,
                                              style: theme.bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (_model.assignToDad) ...[
                                              const SizedBox(width: 4.0),
                                              Icon(
                                                Icons.check_circle,
                                                size: 16.0,
                                                color: isComfort ? const Color(0xFFECF0F1) : _model.parentInfo.partnerColor,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Child Selection - Multi-select chips (with kids header)
                        if (_model.userChildren != null && _model.userChildren!.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.child_care_rounded,
                                        size: 20,
                                        color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'With which kids?',
                                        style: theme.bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(optional)',
                                        style: theme.bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: isComfort ? const Color(0xFF95A5A6) : const Color(0xFF9B8A9E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 8.0, 0.0),
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: _model.userChildren!.map((child) {
                                      final isSelected = _model.selectedChildren.contains(child.reference);
                                      final color = child.selectedColor ?? const Color(0xFF52A097);
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _model.selectedChildren.remove(child.reference);
                                              // Don't auto-select another child when removing one
                                              if (_model.selectedChild == child.reference) {
                                                _model.selectedChild = null;
                                              }
                                            } else {
                                              _model.selectedChildren.add(child.reference);
                                              // Only set selectedChild if it's currently null
                                              if (_model.selectedChild == null) {
                                                _model.selectedChild = child.reference;
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (FFAppState().isComfortMode
                                                    ? const Color(0xFF7F8C8D)
                                                    : color.withOpacity(0.15))
                                                : (FFAppState().isComfortMode
                                                    ? const Color(0xFF34495E)
                                                    : const Color(0xFFF5F5F5)),
                                            borderRadius: BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: isSelected
                                                  ? (FFAppState().isComfortMode
                                                      ? const Color(0xFF95A5A6)
                                                      : color)
                                                  : (FFAppState().isComfortMode
                                                      ? const Color(0xFF7F8C8D)
                                                      : Colors.transparent),
                                              width: isSelected ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 24.0,
                                                height: 24.0,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                child.name,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  color: FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : const Color(0xFF5D4E60),
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 4.0),
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 16.0,
                                                  color: FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : color,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Repeat - Chips style
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.repeat_rounded,
                                      size: 20,
                                      color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'How often?',
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: ['None', 'Daily', 'Weekly', 'Custom Weekly', 'Monthly'].map((option) {
                                    final isSelected = _model.recurringPattern == option;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _model.recurringPattern = option;
                                          // Clear end date when recurring is selected
                                          if (option != 'None') {
                                            _model.endDate = null;
                                            _model.isEndDateSelected = false;
                                            // Set default repeat count based on pattern
                                            if (_model.repeatCount == null) {
                                              _model.repeatCount = option == 'Daily' ? 30 : option == 'Custom Weekly' ? 12 : option == 'Weekly' ? 12 : 12;
                                            }
                                            // Clear custom weekly days when switching away from Custom Weekly
                                            if (option != 'Custom Weekly') {
                                              _model.customWeeklyDays.clear();
                                            }
                                          } else {
                                            // Clear repeat count and custom days when None is selected
                                            _model.repeatCount = null;
                                            _model.customWeeklyDays.clear();
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (FFAppState().isComfortMode
                                                  ? const Color(0xFF7F8C8D)
                                                  : FlutterFlowTheme.of(context).primary.withOpacity(0.15))
                                              : (FFAppState().isComfortMode
                                                  ? const Color(0xFF34495E)
                                                  : const Color(0xFFF5F5F5)),
                                          borderRadius: BorderRadius.circular(20.0),
                                          border: Border.all(
                                            color: isSelected
                                                ? (FFAppState().isComfortMode
                                                    ? const Color(0xFF95A5A6)
                                                    : FlutterFlowTheme.of(context).primary)
                                                : (FFAppState().isComfortMode
                                                    ? const Color(0xFF7F8C8D)
                                                    : Colors.transparent),
                                            width: isSelected ? 2.0 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              option == 'None' ? Icons.block :
                                              option == 'Daily' ? Icons.today :
                                              option == 'Weekly' ? Icons.view_week :
                                              Icons.calendar_month,
                                              size: 16.0,
                                              color: isSelected
                                                  ? (FFAppState().isComfortMode
                                                      ? const Color(0xFFECF0F1)
                                                      : FlutterFlowTheme.of(context).primary)
                                                  : (FFAppState().isComfortMode
                                                      ? const Color(0xFF95A5A6)
                                                      : const Color(0xFF9B8A9E)),
                                            ),
                                            const SizedBox(width: 6.0),
                                            Text(
                                              option,
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                color: isSelected
                                                    ? (FFAppState().isComfortMode
                                                        ? const Color(0xFFECF0F1)
                                                        : FlutterFlowTheme.of(context).primary)
                                                    : (FFAppState().isComfortMode
                                                        ? const Color(0xFFECF0F1)
                                                        : const Color(0xFF5D4E60)),
                                                fontSize: 14.0,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 4.0),
                                              Icon(
                                                Icons.check_circle,
                                                size: 16.0,
                                                color: FFAppState().isComfortMode
                                                    ? const Color(0xFFECF0F1)
                                                    : FlutterFlowTheme.of(context).primary,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Repeat Count Field (only shown when recurring pattern is NOT 'None')
                        if (_model.recurringPattern != null && _model.recurringPattern != 'None')
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                  child: Text(
                                    'Repeat ${_model.recurringPattern == 'Daily' ? 'for how many days?' : _model.recurringPattern == 'Weekly' ? 'for how many weeks?' : _model.recurringPattern == 'Custom Weekly' ? 'for how many weeks?' : 'for how many months?'}',
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: FFAppState().isComfortMode ? const Color(0xFF34495E) : FlutterFlowTheme.of(context).prim30,
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(
                                      color: FFAppState().isComfortMode ? const Color(0xFF7F8C8D) : const Color(0xFFCBE3E0),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_model.repeatCount ?? (_model.recurringPattern == 'Daily' ? 30 : _model.recurringPattern == 'Weekly' ? 12 : 12)}',
                                        style: theme.bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 16.0,
                                          color: isComfort ? const Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove_circle_outline, color: isComfort ? const Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText),
                                            onPressed: () {
                                              setState(() {
                                                final currentCount = _model.repeatCount ?? (_model.recurringPattern == 'Daily' ? 30 : 12);
                                                if (currentCount > 1) {
                                                  _model.repeatCount = currentCount - 1;
                                                }
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add_circle_outline, color: isComfort ? const Color(0xFF95A5A6) : FlutterFlowTheme.of(context).primary),
                                            onPressed: () {
                                              setState(() {
                                                final currentCount = _model.repeatCount ?? (_model.recurringPattern == 'Daily' ? 30 : 12);
                                                final max = _model.recurringPattern == 'Daily' ? 90 : _model.recurringPattern == 'Weekly' ? 52 : 24;
                                                if (currentCount < max) {
                                                  _model.repeatCount = currentCount + 1;
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Day Selector (only shown for Custom Weekly)
                        if (_model.recurringPattern == 'Custom Weekly')
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                  child: Text(
                                    'Which days of the week?',
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: isComfort ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                                // Tip explaining custom weekly
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16.0,
                                        color: isComfort ? const Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                      SizedBox(width: 6.0),
                                      Expanded(
                                        child: Text(
                                          'Example: Select Tuesday and Thursday for activities that repeat twice a week',
                                          style: theme.bodySmall.override(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 12.0,
                                            color: isComfort ? const Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                                            letterSpacing: 0.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Day selector chips (2 rows) - matching "How often?" style
                                Column(
                                  children: [
                                    // First row: Mon-Thu
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        {'label': 'Mon', 'value': 1},
                                        {'label': 'Tue', 'value': 2},
                                        {'label': 'Wed', 'value': 3},
                                        {'label': 'Thu', 'value': 4},
                                      ].map((day) {
                                        final isSelected = _model.customWeeklyDays.contains(day['value'] as int);
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                _model.customWeeklyDays.remove(day['value'] as int);
                                              } else {
                                                _model.customWeeklyDays.add(day['value'] as int);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (isComfort
                                                      ? const Color(0xFF7F8C8D)
                                                      : FlutterFlowTheme.of(context).primary.withOpacity(0.15))
                                                  : (isComfort
                                                      ? const Color(0xFF34495E)
                                                      : const Color(0xFFF5F5F5)),
                                              borderRadius: BorderRadius.circular(20.0),
                                              border: Border.all(
                                                color: isSelected
                                                    ? (isComfort
                                                        ? const Color(0xFF95A5A6)
                                                        : FlutterFlowTheme.of(context).primary)
                                                    : (isComfort
                                                        ? const Color(0xFF7F8C8D)
                                                        : Colors.transparent),
                                                width: isSelected ? 2.0 : 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  day['label'] as String,
                                                  style: theme.bodyMedium.override(
                                                    fontFamily: 'Andika New Basic',
                                                    fontSize: 14.0,
                                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                    color: isSelected
                                                        ? (isComfort
                                                            ? const Color(0xFFECF0F1)
                                                            : FlutterFlowTheme.of(context).primary)
                                                        : (isComfort
                                                            ? const Color(0xFFECF0F1)
                                                            : const Color(0xFF5D4E60)),
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                if (isSelected) ...[
                                                  const SizedBox(width: 4.0),
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 16.0,
                                                    color: isComfort
                                                        ? const Color(0xFFECF0F1)
                                                        : FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 8.0),
                                    // Second row: Fri-Sun
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        {'label': 'Fri', 'value': 5},
                                        {'label': 'Sat', 'value': 6},
                                        {'label': 'Sun', 'value': 7},
                                      ].map((day) {
                                        final isSelected = _model.customWeeklyDays.contains(day['value'] as int);
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                _model.customWeeklyDays.remove(day['value'] as int);
                                              } else {
                                                _model.customWeeklyDays.add(day['value'] as int);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (isComfort
                                                      ? const Color(0xFF7F8C8D)
                                                      : FlutterFlowTheme.of(context).primary.withOpacity(0.15))
                                                  : (isComfort
                                                      ? const Color(0xFF34495E)
                                                      : const Color(0xFFF5F5F5)),
                                              borderRadius: BorderRadius.circular(20.0),
                                              border: Border.all(
                                                color: isSelected
                                                    ? (isComfort
                                                        ? const Color(0xFF95A5A6)
                                                        : FlutterFlowTheme.of(context).primary)
                                                    : (isComfort
                                                        ? const Color(0xFF7F8C8D)
                                                        : Colors.transparent),
                                                width: isSelected ? 2.0 : 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  day['label'] as String,
                                                  style: theme.bodyMedium.override(
                                                    fontFamily: 'Andika New Basic',
                                                    fontSize: 14.0,
                                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                    color: isSelected
                                                        ? (isComfort
                                                            ? const Color(0xFFECF0F1)
                                                            : FlutterFlowTheme.of(context).primary)
                                                        : (isComfort
                                                            ? const Color(0xFFECF0F1)
                                                            : const Color(0xFF5D4E60)),
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                if (isSelected) ...[
                                                  const SizedBox(width: 4.0),
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 16.0,
                                                    color: isComfort
                                                        ? const Color(0xFFECF0F1)
                                                        : FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        // Delete Recurring Events Button (only when editing a recurring event)
                        if (widget.editTaskEvent != null)
                          FutureBuilder<DocumentSnapshot>(
                            future: widget.editTaskEvent!.get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              final taskEvent = EventAndTaskRecord.fromSnapshot(snapshot.data!);
                              if (!taskEvent.isrecurring) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 30.0, 0.0, 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 0.0, 12.0),
                                      child: Text(
                                        'Recurring Event',
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
                                    Center(
                                      child: _model.isDeleting
                                        ? BouncingDots(
                                            color: FlutterFlowTheme.of(context).primary,
                                            size: 12.0,
                                          )
                                        : InkWell(
                                        onTap: () async {
                                          // Show confirmation dialog
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                'Delete All Recurring Events?',
                                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                ),
                                              ),
                                              content: Text(
                                                'This will delete all instances of this recurring event. This action cannot be undone.',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text(
                                                    'Cancel',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: Text(
                                                    'Delete All',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            try {
                                              // Start deleting (no progress tracking - just show loading)
                                              if (mounted) {
                                                setState(() {
                                                  _model.isDeleting = true;
                                                });
                                              }

                                              // Find all recurring events with the same name and user
                                              final allRecurring = await queryEventAndTaskRecordOnce(
                                                queryBuilder: (q) => q
                                                    .where('user_ref', isEqualTo: currentUserReference)
                                                    .where('name', isEqualTo: taskEvent.name)
                                                    .where('isrecurring', isEqualTo: true),
                                              );

                                              // Delete all of them (no progress updates to avoid errors)
                                              for (final event in allRecurring) {
                                                try {
                                                  await event.reference.delete();
                                                } catch (deleteError) {
                                                  debugPrint('Error deleting single event: $deleteError');
                                                  // Continue with next event even if one fails
                                                }
                                              }

                                              FFAppState().todocash = true;

                                              // Fast navigation - no transition delay
                                              if (mounted && context.mounted) {
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) => const CalendarpageWidget(),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              debugPrint('Error deleting recurring events: $e');
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _model.isDeleting = false;
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                          decoration: BoxDecoration(
                                            color: FFAppState().isComfortMode
                                                ? const Color(0xFF34495E)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(14.0),
                                            border: Border.all(
                                              color: Colors.red,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.delete_forever_rounded,
                                                color: Colors.red,
                                                size: 20.0,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                'Delete All Recurring Events',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  color: Colors.red,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
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
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: FFAppState().isComfortMode
                              ? const LinearGradient(
                                  colors: [Color(0xFF7F8C8D), Color(0xFF7F8C8D)],
                                )
                              : LinearGradient(
                                  colors: [FlutterFlowTheme.of(context).primary, FlutterFlowTheme.of(context).primary],
                                ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _model.isSubmitting ? () {} : () async {
                            // LAYER 1: Debouncing - prevent double-tap
                            if (_model.isSubmitting) return;
                            setState(() => _model.isSubmitting = true);

                            try {
                              // Validate name
                              if (_model.nameController.text.trim().isEmpty) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please enter a ${_model.selectedType.toLowerCase()} name'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  setState(() {
                                    _model.isSubmitting = false;
                                    _model.creationStartTime = null;
                                  });
                                }
                                return;
                              }

                              // Validate date
                              if (_model.selectedDate == null) {
                                if (mounted) {
                                  setState(() {
                                    _model.showDateError = true;
                                    _model.isSubmitting = false;
                                    _model.creationStartTime = null;
                                  });
                                }
                                return;
                              }

                              // LAYER 2: Duplicate detection - check if identical entry exists
                              if (widget.editTaskEvent == null) {
                                final existingEvents = await EventAndTaskRecord.collection
                                  .where('user_ref', isEqualTo: currentUserReference)
                                  .where('name', isEqualTo: _model.nameController.text.trim())
                                  .where('date', isEqualTo: _model.selectedDate)
                                  .where('typ', isEqualTo: _model.selectedType)
                                  .get();

                                if (existingEvents.docs.isNotEmpty) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('This ${_model.selectedType.toLowerCase()} already exists for this date'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    setState(() {
                                      _model.isSubmitting = false;
                                      _model.creationStartTime = null;
                                    });
                                  }
                                  return;
                                }

                                // LAYER 3: Rate limiting - check daily limit (30 per day max)
                                final startOfDay = DateTime(_model.selectedDate!.year, _model.selectedDate!.month, _model.selectedDate!.day);
                                final endOfDay = startOfDay.add(Duration(days: 1));

                                final todayEvents = await EventAndTaskRecord.collection
                                  .where('user_ref', isEqualTo: currentUserReference)
                                  .where('date', isGreaterThanOrEqualTo: startOfDay)
                                  .where('date', isLessThan: endOfDay)
                                  .get();

                                if (todayEvents.docs.length >= 30) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Maximum 30 entries per day reached. Please choose a different date or clean up duplicates in Settings.'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    setState(() {
                                      _model.isSubmitting = false;
                                      _model.creationStartTime = null;
                                    });
                                  }
                                  return;
                                }
                              }

                            // Check if we're editing or creating
                            if (widget.editTaskEvent != null) {
                              // Get the current event to check if it was recurring
                              final eventDoc = await widget.editTaskEvent!.get();
                              final currentEvent = EventAndTaskRecord.fromSnapshot(eventDoc);
                              final wasRecurring = currentEvent.isrecurring;
                              final isNowRecurring = _model.recurringPattern != null && _model.recurringPattern != 'None';

                              // DEBUG: Log what's being saved
                              debugPrint('=== SAVING EVENT ===');
                              debugPrint('Event name: ${_model.nameController.text}');
                              debugPrint('Event date: ${_model.selectedDate}');
                              debugPrint('Event type: ${_model.selectedType}');
                              debugPrint('selectedChild: ${_model.selectedChild?.path ?? "null"}');
                              debugPrint('selectedChildren count: ${_model.selectedChildren.length}');
                              debugPrint('selectedChildren: ${_model.selectedChildren.map((ref) => ref.path).join(", ")}');
                              debugPrint('');
                              debugPrint('RECURRING INFO:');
                              debugPrint('  Was recurring: $wasRecurring');
                              debugPrint('  Is now recurring: $isNowRecurring');
                              debugPrint('  Recurring pattern: ${_model.recurringPattern ?? "None"}');
                              debugPrint('===================');

                              // Update the current instance
                              await widget.editTaskEvent!.update(createEventAndTaskRecordData(
                                description: _model.descriptionController.text,
                                name: _model.nameController.text,
                                isrecurring: isNowRecurring,
                                recurringPattern: _model.recurringPattern, // Save the pattern!
                                endDate: _model.endDate, // Save the end date!
                                repeatCount: _model.repeatCount, // Save repeat count!
                                customWeeklyDays: _model.customWeeklyDays.toList(), // Save custom weekly days!
                                selectedChild: _model.selectedChild, // Allow null (no child assigned)
                                selectedChildren: _model.selectedChildren.toList(), // Allow empty list
                                userRef: currentUserReference,
                                date: _model.selectedDate,
                                typ: _model.selectedType,
                                assignedToMom: _model.assignToMom,
                                assignedToDad: _model.assignToDad,
                              ));

                              // Handle recurring event changes
                              // Use simpler query to avoid Firestore index requirement
                              if (wasRecurring || isNowRecurring) {
                                // Get all recurring events with same name and user (simpler query)
                                final allRecurring = await queryEventAndTaskRecordOnce(
                                  queryBuilder: (q) => q
                                      .where('user_ref', isEqualTo: currentUserReference)
                                      .where('name', isEqualTo: currentEvent.name)
                                      .where('isrecurring', isEqualTo: true),
                                );

                                // Filter in memory for future dates (avoid complex Firestore query)
                                final futureEvents = allRecurring.where((event) {
                                  return event.date != null && event.date!.isAfter(_model.selectedDate!);
                                }).toList();

                                debugPrint('');
                                debugPrint('RECURRING EVENT QUERY RESULTS:');
                                debugPrint('  Total recurring events found: ${allRecurring.length}');
                                debugPrint('  Future events (after ${_model.selectedDate}): ${futureEvents.length}');
                                if (futureEvents.isNotEmpty) {
                                  debugPrint('  Future event dates:');
                                  for (final event in futureEvents.take(5)) {
                                    debugPrint('    - ${event.date?.toString().split(' ')[0]} (isRecurring: ${event.isrecurring})');
                                  }
                                  if (futureEvents.length > 5) {
                                    debugPrint('    ... and ${futureEvents.length - 5} more');
                                  }
                                }

                                if (wasRecurring && !isNowRecurring) {
                                  // Changed from recurring to non-recurring: Delete all future instances
                                  debugPrint('Converting recurring to non-recurring: deleting future instances');
                                  for (final event in futureEvents) {
                                    await event.reference.delete();
                                  }
                                  debugPrint('Deleted ${futureEvents.length} future recurring instances');
                                } else if (isNowRecurring && wasRecurring && currentEvent.recurringPattern != _model.recurringPattern) {
                                  // Pattern changed (Daily -> Weekly, etc.): Delete old instances and regenerate
                                  debugPrint('Pattern changed from ${currentEvent.recurringPattern} to ${_model.recurringPattern}');
                                  debugPrint('Deleting ${futureEvents.length} old instances and regenerating with new pattern');

                                  for (final event in futureEvents) {
                                    await event.reference.delete();
                                  }

                                  // Regenerate instances with new pattern (using repeat count)
                                  final count = _model.repeatCount ?? (_model.recurringPattern == 'Daily' ? 30 : 12);

                                  if (_model.recurringPattern == 'Custom Weekly') {
                                    // Custom Weekly: Generate instances for selected days only
                                    if (_model.customWeeklyDays.isEmpty) {
                                      debugPrint('ERROR: Custom Weekly selected but no days chosen');
                                    } else {
                                      debugPrint('Generating Custom Weekly: ${_model.customWeeklyDays.length} days per week for $count weeks');

                                      // Start from the Monday of the week containing the selected date
                                      final startDate = _model.selectedDate!;
                                      final daysUntilMonday = (startDate.weekday - DateTime.monday + 7) % 7;
                                      DateTime currentWeekStart = startDate.subtract(Duration(days: daysUntilMonday));

                                      debugPrint('Selected date: ${startDate.toString().split(' ')[0]} (${_getDayName(startDate.weekday)})');
                                      debugPrint('Starting from Monday: ${currentWeekStart.toString().split(' ')[0]}');

                                      for (int week = 0; week < count; week++) {
                                        for (int dayOfWeek in _model.customWeeklyDays.toList()..sort()) {
                                          // Calculate the date for this day of the week (1=Mon, 7=Sun)
                                          final daysToAdd = dayOfWeek - DateTime.monday;
                                          final instanceDate = currentWeekStart.add(Duration(days: daysToAdd));

                                          // Only create instances that are today or in the future
                                          if (instanceDate.isAfter(startDate.subtract(Duration(days: 1)))) {
                                            debugPrint('  Creating instance: ${instanceDate.toString().split(' ')[0]} (${_getDayName(dayOfWeek)})');

                                            await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                                              description: _model.descriptionController.text,
                                              name: _model.nameController.text,
                                              isrecurring: true,
                                              recurringPattern: _model.recurringPattern,
                                              endDate: _model.endDate,
                                              repeatCount: _model.repeatCount,
                                              customWeeklyDays: _model.customWeeklyDays.toList(),
                                              selectedChild: _model.selectedChild,
                                              selectedChildren: _model.selectedChildren.toList(),
                                              userRef: currentUserReference,
                                              date: instanceDate,
                                              typ: _model.selectedType,
                                              isCompleted: false,
                                              lastGenerated: getCurrentTimestamp,
                                              assignedToMom: _model.assignToMom,
                                              assignedToDad: _model.assignToDad,
                                            ));
                                          } else {
                                            debugPrint('  Skipping past date: ${instanceDate.toString().split(' ')[0]} (${_getDayName(dayOfWeek)})');
                                          }
                                        }
                                        // Move to next week
                                        currentWeekStart = currentWeekStart.add(Duration(days: 7));
                                      }
                                    }
                                  } else {
                                    // Standard patterns: Daily, Weekly, Monthly
                                    DateTime nextDate = _model.selectedDate!;
                                    for (int i = 0; i < count; i++) {
                                      // Calculate next date based on NEW pattern
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

                                      await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                                        description: _model.descriptionController.text,
                                        name: _model.nameController.text,
                                        isrecurring: true,
                                        recurringPattern: _model.recurringPattern,
                                        endDate: _model.endDate,
                                        repeatCount: _model.repeatCount,
                                        customWeeklyDays: _model.customWeeklyDays.toList(),
                                        selectedChild: _model.selectedChild,
                                        selectedChildren: _model.selectedChildren.toList(),
                                        userRef: currentUserReference,
                                        date: nextDate,
                                        typ: _model.selectedType,
                                        isCompleted: false,
                                        lastGenerated: getCurrentTimestamp,
                                        assignedToMom: _model.assignToMom,
                                        assignedToDad: _model.assignToDad,
                                      ));
                                    }
                                  }
                                  debugPrint('Regenerated $count instances with new ${_model.recurringPattern} pattern');
                                } else if (!wasRecurring && isNowRecurring) {
                                  // Changed from non-recurring to recurring: Generate new instances
                                  debugPrint('Converting non-recurring to recurring: generating future instances');
                                  final count = _model.repeatCount ?? (_model.recurringPattern == 'Daily' ? 30 : 12);

                                  if (_model.recurringPattern == 'Custom Weekly') {
                                    // Custom Weekly generation (same as pattern change logic)
                                    if (_model.customWeeklyDays.isEmpty) {
                                      debugPrint('ERROR: Custom Weekly selected but no days chosen');
                                    } else {
                                      debugPrint('Generating Custom Weekly: ${_model.customWeeklyDays.length} days per week for $count weeks');
                                      final startDate = _model.selectedDate!;
                                      final daysUntilMonday = (startDate.weekday - DateTime.monday + 7) % 7;
                                      DateTime currentWeekStart = startDate.subtract(Duration(days: daysUntilMonday));

                                      for (int week = 0; week < count; week++) {
                                        for (int dayOfWeek in _model.customWeeklyDays.toList()..sort()) {
                                          final daysToAdd = dayOfWeek - DateTime.monday;
                                          final instanceDate = currentWeekStart.add(Duration(days: daysToAdd));

                                          if (instanceDate.isAfter(startDate.subtract(Duration(days: 1)))) {
                                            await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                                              description: _model.descriptionController.text,
                                              name: _model.nameController.text,
                                              isrecurring: true,
                                              recurringPattern: _model.recurringPattern,
                                              endDate: _model.endDate,
                                              repeatCount: _model.repeatCount,
                                              customWeeklyDays: _model.customWeeklyDays.toList(),
                                              selectedChild: _model.selectedChild,
                                              selectedChildren: _model.selectedChildren.toList(),
                                              userRef: currentUserReference,
                                              date: instanceDate,
                                              typ: _model.selectedType,
                                              isCompleted: false,
                                              lastGenerated: getCurrentTimestamp,
                                              assignedToMom: _model.assignToMom,
                                              assignedToDad: _model.assignToDad,
                                            ));
                                          }
                                        }
                                        currentWeekStart = currentWeekStart.add(Duration(days: 7));
                                      }
                                    }
                                  } else {
                                    // Standard patterns: Daily, Weekly, Monthly
                                    DateTime nextDate = _model.selectedDate!;
                                    for (int i = 0; i < count; i++) {
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

                                      await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                                        description: _model.descriptionController.text,
                                        name: _model.nameController.text,
                                        isrecurring: true,
                                        recurringPattern: _model.recurringPattern,
                                        endDate: _model.endDate,
                                        repeatCount: _model.repeatCount,
                                        customWeeklyDays: _model.customWeeklyDays.toList(),
                                        selectedChild: _model.selectedChild,
                                        selectedChildren: _model.selectedChildren.toList(),
                                        userRef: currentUserReference,
                                        date: nextDate,
                                        typ: _model.selectedType,
                                        isCompleted: false,
                                        lastGenerated: getCurrentTimestamp,
                                        assignedToMom: _model.assignToMom,
                                        assignedToDad: _model.assignToDad,
                                      ));
                                    }
                                  }
                                  debugPrint('Generated $count new recurring instances');
                                } else if (isNowRecurring) {
                                  // Pattern unchanged: just update the details
                                  debugPrint('Pattern unchanged: updating ${futureEvents.length} instances');
                                  for (final event in futureEvents) {
                                    await event.reference.update(createEventAndTaskRecordData(
                                      description: _model.descriptionController.text,
                                      recurringPattern: _model.recurringPattern,
                                      endDate: _model.endDate,
                                      repeatCount: _model.repeatCount,
                                      customWeeklyDays: _model.customWeeklyDays.toList(),
                                      selectedChild: _model.selectedChild,
                                      selectedChildren: _model.selectedChildren.toList(),
                                      assignedToMom: _model.assignToMom,
                                      assignedToDad: _model.assignToDad,
                                    ));
                                  }
                                  debugPrint('Updated ${futureEvents.length} future recurring instances');
                                }
                              }
                            } else {
                              // Create the initial task/event
                              // For Custom Weekly, skip initial creation - the recurring generation handles all instances
                              if (_model.recurringPattern != 'Custom Weekly') {
                                await EventAndTaskRecord.collection
                                    .doc()
                                    .set(createEventAndTaskRecordData(
                                      description: _model.descriptionController.text,
                                      name: _model.nameController.text,
                                      isrecurring: _model.recurringPattern != null && _model.recurringPattern != 'None',
                                      recurringPattern: _model.recurringPattern, // Save pattern
                                      endDate: _model.endDate, // Save end date
                                      repeatCount: _model.repeatCount, // Save repeat count
                                      customWeeklyDays: _model.customWeeklyDays.toList(), // Save custom weekly days
                                      selectedChild: _model.selectedChild, // Don't force a child assignment
                                      selectedChildren: _model.selectedChildren.toList(),
                                      userRef: currentUserReference,
                                      date: _model.selectedDate,
                                      typ: _model.selectedType,
                                      isCompleted: false,
                                      lastGenerated: getCurrentTimestamp,
                                      assignedToMom: _model.assignToMom,
                                      assignedToDad: _model.assignToDad,
                                    ));
                              } else {
                                debugPrint('Skipping initial event creation for Custom Weekly (all instances handled by recurring generation)');
                              }
                            }

                            // Generate recurring instances if needed (only for new tasks)
                            if (widget.editTaskEvent == null && _model.recurringPattern != null && _model.recurringPattern != 'None') {
                              final count = _model.repeatCount ?? (_model.recurringPattern == 'Daily' ? 30 : 12);

                              // Set progress state for button indicator
                              setState(() {
                                _model.creatingProgress = 0;
                                _model.creatingTotal = count;
                                _model.creationStartTime = DateTime.now();
                              });

                              // Small delay to let the UI update
                              await Future.delayed(const Duration(milliseconds: 50));

                              debugPrint('');
                              debugPrint('=== GENERATING RECURRING INSTANCES ===');
                              debugPrint('Pattern: ${_model.recurringPattern}');
                              debugPrint('Starting date: ${_model.selectedDate}');
                              debugPrint('Repeat count: $count');

                              int successCount = 0;

                              if (_model.recurringPattern == 'Custom Weekly') {
                                // Custom Weekly: Generate instances for selected days only
                                if (_model.customWeeklyDays.isEmpty) {
                                  debugPrint('ERROR: Custom Weekly selected but no days chosen');
                                } else {
                                  debugPrint('Custom Weekly: ${_model.customWeeklyDays.length} days per week for $count weeks');

                                  // Start from the Monday of the week containing the selected date
                                  final startDate = _model.selectedDate!;
                                  final daysUntilMonday = (startDate.weekday - DateTime.monday + 7) % 7;
                                  DateTime currentWeekStart = startDate.subtract(Duration(days: daysUntilMonday));

                                  debugPrint('Selected date: ${startDate.toString().split(' ')[0]} (${_getDayName(startDate.weekday)})');
                                  debugPrint('Starting from Monday: ${currentWeekStart.toString().split(' ')[0]}');

                                  for (int week = 0; week < count; week++) {
                                    for (int dayOfWeek in _model.customWeeklyDays.toList()..sort()) {
                                      // Calculate the date for this day of the week (1=Mon, 7=Sun)
                                      final daysToAdd = dayOfWeek - DateTime.monday;
                                      final instanceDate = currentWeekStart.add(Duration(days: daysToAdd));

                                      // Only create instances that are today or in the future
                                      if (instanceDate.isAfter(startDate.subtract(Duration(days: 1)))) {
                                        debugPrint('  Creating instance: ${instanceDate.toString().split(' ')[0]} (${_getDayName(dayOfWeek)})');

                                        await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                                          description: _model.descriptionController.text,
                                          name: _model.nameController.text,
                                          isrecurring: true,
                                          recurringPattern: _model.recurringPattern,
                                          endDate: _model.endDate,
                                          repeatCount: _model.repeatCount,
                                          customWeeklyDays: _model.customWeeklyDays.toList(),
                                          selectedChild: _model.selectedChild,
                                          selectedChildren: _model.selectedChildren.toList(),
                                          userRef: currentUserReference,
                                          date: instanceDate,
                                          typ: _model.selectedType,
                                          isCompleted: false,
                                          lastGenerated: getCurrentTimestamp,
                                          assignedToMom: _model.assignToMom,
                                          assignedToDad: _model.assignToDad,
                                        ));

                                        successCount++;

                                        // Update progress with smooth delay
                                        setState(() {
                                          _model.creatingProgress = successCount;
                                        });
                                        await Future.delayed(const Duration(milliseconds: 300));
                                      } else {
                                        debugPrint('  Skipping past date: ${instanceDate.toString().split(' ')[0]} (${_getDayName(dayOfWeek)})');
                                      }
                                    }
                                    // Move to next week
                                    currentWeekStart = currentWeekStart.add(Duration(days: 7));
                                  }
                                }
                              } else {
                                // Standard patterns: Daily, Weekly, Monthly
                                debugPrint('Will create $count future instances...');
                                DateTime nextDate = _model.selectedDate!;

                                for (int i = 0; i < count; i++) {
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

                                  debugPrint('  Creating instance ${i + 1}/$count: ${nextDate.toString().split(' ')[0]}');

                                  await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                                    description: _model.descriptionController.text,
                                    name: _model.nameController.text,
                                    isrecurring: true,
                                    recurringPattern: _model.recurringPattern,
                                    endDate: _model.endDate,
                                    repeatCount: _model.repeatCount,
                                    customWeeklyDays: _model.customWeeklyDays.toList(),
                                    selectedChild: _model.selectedChild,
                                    selectedChildren: _model.selectedChildren.toList(),
                                    userRef: currentUserReference,
                                    date: nextDate,
                                    typ: _model.selectedType,
                                    isCompleted: false,
                                    lastGenerated: getCurrentTimestamp,
                                    assignedToMom: _model.assignToMom,
                                    assignedToDad: _model.assignToDad,
                                  ));

                                  successCount++;

                                  // Update progress with smooth delay
                                  setState(() {
                                    _model.creatingProgress = successCount;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 150));
                                }
                              }

                              debugPrint('Successfully created $successCount recurring instances');
                              debugPrint('======================================');
                            }

                              FFAppState().todocash = true;
                              if (mounted) {
                                setState(() {});
                              }

                              // Go back to previous page (calendar or home)
                              if (mounted && context.mounted) {
                                try {
                                  Navigator.of(context).pop();
                                } catch (navError) {
                                  debugPrint('Navigation error: $navError');
                                }

                                // Reset state after navigation
                                if (mounted) {
                                  setState(() {
                                    _model.isSubmitting = false;
                                    _model.creatingProgress = 0;
                                    _model.creatingTotal = 0;
                                    _model.creationStartTime = null;
                                  });
                                }
                              }
                            } catch (e) {
                              // Handle any errors during submission
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                // Reset on error
                                setState(() {
                                  _model.isSubmitting = false;
                                  _model.creationStartTime = null;
                                });
                              }
                            }
                                },
                                borderRadius: BorderRadius.circular(14.0),
                                child: Center(
                                  child: _model.isSubmitting
                                    ? (_model.creatingTotal > 0 &&
                                       _model.creationStartTime != null &&
                                       DateTime.now().difference(_model.creationStartTime!).inSeconds >= 2)
                                      ? Text(
                                          'Creating ${_model.creatingProgress} of ${_model.creatingTotal}...',
                                          style: FlutterFlowTheme.of(context).titleSmall.override(
                                            fontFamily: 'Andika New Basic',
                                            color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : Colors.white,
                                            letterSpacing: 0.0,
                                            fontSize: 14.0,
                                          ),
                                        )
                                      : BouncingDots(
                                          color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : Colors.white,
                                          size: 8.0,
                                        )
                                    : Text(
                                        widget.editTaskEvent != null ? 'Update' : 'Create',
                                        style: FlutterFlowTheme.of(context).titleSmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                ),
                          ), // Close InkWell
                        ), // Close Material
                ), // Close Container
              ),  // Close Expanded
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
