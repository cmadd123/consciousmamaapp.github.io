import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/activites/delete_activtyomponent/delete_activtyomponent_widget.dart';
import '/v2/todo/addcalender/addcalender_widget.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'activitycart_component_model.dart';
export 'activitycart_component_model.dart';

class ActivitycartComponentWidget extends StatefulWidget {
  const ActivitycartComponentWidget({
    super.key,
    required this.activty,
  });

  final ActivityRecord? activty;

  @override
  State<ActivitycartComponentWidget> createState() =>
      _ActivitycartComponentWidgetState();
}

class _ActivitycartComponentWidgetState
    extends State<ActivitycartComponentWidget> {
  late ActivitycartComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActivitycartComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0x5AFFD8E4),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 8.0, 0.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget!.activty?.title,
                        'Activity Title',
                      ),
                      style:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Andika New Basic',
                                letterSpacing: 0.0,
                              ),
                    ),
                  ),
                  StreamBuilder<List<FavActivityRecord>>(
                    stream: queryFavActivityRecord(
                      queryBuilder: (favActivityRecord) =>
                          favActivityRecord.where(
                        'activity_ref',
                        isEqualTo: widget!.activty?.reference,
                      ),
                      singleRecord: true,
                    ),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }
                      List<FavActivityRecord> containerFavActivityRecordList =
                          snapshot.data!;
                      final containerFavActivityRecord =
                          containerFavActivityRecordList.isNotEmpty
                              ? containerFavActivityRecordList.first
                              : null;

                      return Container(
                        decoration: BoxDecoration(),
                        child: Builder(
                          builder: (context) {
                            if (containerFavActivityRecord?.reference != null) {
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 7.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await containerFavActivityRecord!.reference
                                        .delete();
                                    safeSetState(() {});
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 18.0,
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 7.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await FavActivityRecord.collection
                                        .doc()
                                        .set(createFavActivityRecordData(
                                          activityRef:
                                              widget!.activty?.reference,
                                          userRef: currentUserReference,
                                        ));
                                    safeSetState(() {});
                                  },
                                  child: Icon(
                                    Icons.favorite_border_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 18.0,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 17.0,
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(3.0, 0.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget!.activty?.location,
                          'indoor',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(9.0, 0.0, 0.0, 0.0),
                      child: Icon(
                        Icons.bolt_outlined,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 17.0,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(3.0, 0.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget!.activty?.energy,
                          'medium',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (_model.isviewDetails == false)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          _model.isviewDetails = true;
                          safeSetState(() {});
                        },
                        child: Text(
                          'View Details',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xBF000000),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_model.isviewDetails == true)
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
                        child: Text(
                          'Description:',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 65.0, 0.0),
                        child: Text(
                          valueOrDefault<String>(
                            widget!.activty?.description,
                            'activityDescrption',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xC4000000),
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(2.0, 20.0, 0.0, 0.0),
                        child: Text(
                          'Things Needed:',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
                        child: Text(
                          valueOrDefault<String>(
                            widget!.activty?.thingsNeeded,
                            'None',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: Color(0xC4000000),
                                fontSize: 10.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(2.0, 20.0, 0.0, 0.0),
                        child: Text(
                          'Safety Concerns:',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  2.0, 0.0, 20.0, 20.0),
                              child: Text(
                                valueOrDefault<String>(
                                  widget!.activty?.activitySafetyConcerns,
                                  'activity_safety_concerns',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: Color(0xC4000000),
                                      fontSize: 10.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) => InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return Dialog(
                                    elevation: 0,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    alignment: AlignmentDirectional(0.0, 0.0)
                                        .resolve(Directionality.of(context)),
                                    child: DeleteActivtyomponentWidget(
                                      activty: widget!.activty!.reference,
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              FFIcons.kfluentDelete28Regular,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Quick Add buttons
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Quick add to today button
                          InkWell(
                            onTap: () async {
                              await _showQuickAddSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_circle_outline,
                                    size: 14.0,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 4.0),
                                  const Text(
                                    'Today',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 12.0,
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Schedule button
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddcalenderWidget(
                                    fromPage: 'activities',
                                    prefillName: widget!.activty?.title ?? '',
                                    prefillDescription: widget!.activty?.description ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    'Schedule',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 12.0,
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickAddSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityQuickAddSheet(
        activity: widget!.activty!,
      ),
    );
  }
}

/// Quick add bottom sheet for system activities
class _ActivityQuickAddSheet extends StatefulWidget {
  final ActivityRecord activity;

  const _ActivityQuickAddSheet({required this.activity});

  @override
  State<_ActivityQuickAddSheet> createState() => _ActivityQuickAddSheetState();
}

class _ActivityQuickAddSheetState extends State<_ActivityQuickAddSheet> {
  List<ChildernRecord>? _userChildren;
  Set<DocumentReference> _selectedChildren = {};
  bool _assignToMom = false;
  bool _assignToDad = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserChildren();
  }

  Future<void> _loadUserChildren() async {
    final children = await queryChildernRecordOnce(
      queryBuilder: (childernRecord) => childernRecord.where(
        'userRef',
        isEqualTo: currentUserReference,
      ),
    );
    if (mounted) {
      setState(() {
        _userChildren = children;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20.0),
        decoration: BoxDecoration(
          color: FFAppState().isComfortMode ? const Color(0xFF34495E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: FFAppState().isComfortMode ? const Color(0xFF7F8C8D) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Title
              Text(
                'Add to Today',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Andika New Basic',
                  color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.activity.title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: FFAppState().isComfortMode ? const Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 20.0),

              // Assign to Parents
              Text(
                'Assign to',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  // Mom chip
                  GestureDetector(
                    onTap: () => setState(() => _assignToMom = !_assignToMom),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _assignToMom
                            ? const Color(0xFFEC407A).withOpacity(0.15)
                            : (FFAppState().isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: _assignToMom ? const Color(0xFFEC407A) : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEC407A),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('M', style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Mom',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_assignToMom) ...[
                            const SizedBox(width: 6.0),
                            const Icon(Icons.check_circle, size: 18.0, color: Color(0xFFEC407A)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Dad chip
                  GestureDetector(
                    onTap: () => setState(() => _assignToDad = !_assignToDad),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _assignToDad
                            ? const Color(0xFF1976D2).withOpacity(0.15)
                            : (FFAppState().isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: _assignToDad ? const Color(0xFF1976D2) : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1976D2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('D', style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Dad',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_assignToDad) ...[
                            const SizedBox(width: 6.0),
                            const Icon(Icons.check_circle, size: 18.0, color: Color(0xFF1976D2)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Children selection
              if (_userChildren != null && _userChildren!.isNotEmpty) ...[
                const SizedBox(height: 20.0),
                Text(
                  'For children',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: _userChildren!.map((child) {
                    final isSelected = _selectedChildren.contains(child.reference);
                    final color = child.selectedColor ?? const Color(0xFF52A097);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedChildren.remove(child.reference);
                          } else {
                            _selectedChildren.add(child.reference);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : (FFAppState().isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  child.name.isNotEmpty ? child.name[0].toLowerCase() : 'c',
                                  style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              child.name,
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                color: FFAppState().isComfortMode ? const Color(0xFFECF0F1) : const Color(0xFF5D4E60),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6.0),
                              Icon(Icons.check_circle, size: 18.0, color: color),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24.0),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FFButtonWidget(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    try {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      await EventAndTaskRecord.collection.doc().set(createEventAndTaskRecordData(
                        name: widget.activity.title,
                        description: widget.activity.description,
                        isrecurring: false,
                        selectedChildren: _selectedChildren.toList(),
                        userRef: currentUserReference,
                        date: today,
                        typ: 'Task',
                        isCompleted: false,
                        assignedToMom: _assignToMom,
                        assignedToDad: _assignToDad,
                      ));

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.activity.title} added to today!'),
                            backgroundColor: const Color(0xFF4CAF50),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error adding activity: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  text: _isLoading ? 'Adding...' : 'Add to Today',
                  options: FFButtonOptions(
                    height: 50.0,
                    color: const Color(0xFF4CAF50),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Andika New Basic',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
