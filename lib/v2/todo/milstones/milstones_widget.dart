import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/custom_code/actions/index.dart' as actions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'milstones_model.dart';
export 'milstones_model.dart';

class MilstonesWidget extends StatefulWidget {
  const MilstonesWidget({super.key});

  static String routeName = 'milstones';
  static String routePath = '/milstones';

  @override
  State<MilstonesWidget> createState() => _MilstonesWidgetState();
}

class _MilstonesWidgetState extends State<MilstonesWidget> {
  late MilstonesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MilstonesModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Toggle milestone completion - handles both marking complete and incomplete
  Future<void> _toggleMilestoneCompletion({
    required DocumentReference childRef,
    required DocumentReference milestoneRef,
    required String category,
    required double childAge,
    required bool currentlyCompleted,
  }) async {
    try {
      if (currentlyCompleted) {
        // DELETE: Find and delete the accomplishment record
        // Use FirebaseFirestore directly for reliable querying
        final firestore = FirebaseFirestore.instance;
        final querySnapshot = await firestore
            .collection('children_accomlished_milestones')
            .where('child', isEqualTo: childRef)
            .where('milestone', isEqualTo: milestoneRef)
            .get();

        print('DEBUG: Found ${querySnapshot.docs.length} records to delete');
        print('DEBUG: childRef path: ${childRef.path}');
        print('DEBUG: milestoneRef path: ${milestoneRef.path}');

        if (querySnapshot.docs.isEmpty) {
          // Fallback: try to find by just the milestone reference
          final fallbackQuery = await firestore
              .collection('children_accomlished_milestones')
              .where('milestone', isEqualTo: milestoneRef)
              .get();
          print('DEBUG: Fallback found ${fallbackQuery.docs.length} records');
          for (final doc in fallbackQuery.docs) {
            print('DEBUG: Fallback doc data: ${doc.data()}');
            // Check if child matches
            final docChildRef = doc.data()['child'] as DocumentReference?;
            if (docChildRef != null && docChildRef.path == childRef.path) {
              print('DEBUG: Deleting doc ${doc.id}');
              await doc.reference.delete();
            }
          }
        } else {
          for (final doc in querySnapshot.docs) {
            print('DEBUG: Deleting doc ${doc.id}');
            await doc.reference.delete();
          }
        }
      } else {
        // CREATE: Add new accomplishment record
        final newDocRef = FirebaseFirestore.instance
            .collection('children_accomlished_milestones')
            .doc();

        await newDocRef.set({
          'child': childRef,
          'milestone': milestoneRef,
          'category': category,
          'age': childAge,
        });
        print('DEBUG: Created new record ${newDocRef.id}');
      }
    } catch (e) {
      print('ERROR in _toggleMilestoneCompletion: $e');
    }
  }

  void _showMilestoneBottomSheet({
    required BuildContext context,
    required SaticMilestonesRecord milestone,
    required bool isCompleted,
    required DocumentReference childRef,
    required double childAge,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Milestone title
                Text(
                  milestone.title,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                // Tip/Note
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF5F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFEE8B60),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isCompleted
                            ? 'Great job! Your child has achieved this milestone.'
                            : 'Tap below to mark as complete, or create a personalized learning path to help your child reach this milestone.',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(bottomSheetContext);
                          await _toggleMilestoneCompletion(
                            childRef: childRef,
                            milestoneRef: milestone.reference,
                            category: milestone.category,
                            childAge: childAge,
                            currentlyCompleted: isCompleted,
                          );
                        },
                        icon: Icon(
                          isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        label: Text(
                          isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).primary,
                            fontFamily: 'Andika New Basic',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: FlutterFlowTheme.of(context).primary),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (!isCompleted) ...[
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(bottomSheetContext);
                            context.pushNamed(
                              'learnPathSteponStep2',
                              queryParameters: {
                                'aiTextField': serializeParam(
                                  'Help my child: ${milestone.title}',
                                  ParamType.String,
                                ),
                              }.withoutNulls,
                            );
                          },
                          icon: Icon(Icons.route, color: Colors.white),
                          label: Text(
                            'Create Path',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Andika New Basic',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFFF5F2),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
                      child: StreamBuilder<ChildernRecord>(
                        stream: ChildernRecord.getDocument(
                            FFAppState().selectedChildForMilestone!),
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

                          final containerChildernRecord = snapshot.data!;

                          return Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              child: StreamBuilder<
                                  List<ChildrenAccomlishedMilestonesRecord>>(
                                stream:
                                    queryChildrenAccomlishedMilestonesRecord(
                                  queryBuilder:
                                      (childrenAccomlishedMilestonesRecord) =>
                                          childrenAccomlishedMilestonesRecord
                                              .where(
                                                'child',
                                                isEqualTo:
                                                    containerChildernRecord
                                                        .reference,
                                              )
                                              .where(
                                                'age',
                                                isEqualTo: functions
                                                    .newCobverBirthdayToAGe(
                                                        containerChildernRecord
                                                            .birthDay!),
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
                                  List<ChildrenAccomlishedMilestonesRecord>
                                      containerChildrenAccomlishedMilestonesRecordList =
                                      snapshot.data!;

                                  return Container(
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 26.0, 24.0, 0.0),
                                            child: Text(
                                              'Milestones',
                                              textAlign: TextAlign.center,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        fontSize: 24.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ),
                                        ),
                                        // Seed button (only shown if no milestones exist)
                                        StreamBuilder<List<SaticMilestonesRecord>>(
                                          stream: querySaticMilestonesRecord(
                                            queryBuilder: (q) => q.limit(1),
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.data?.isEmpty ?? true) {
                                              return Padding(
                                                padding: EdgeInsets.all(16),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    final count = await actions.seedMilestones();
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Added $count milestones!')),
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: FlutterFlowTheme.of(context).primary,
                                                    minimumSize: Size(double.infinity, 48),
                                                  ),
                                                  child: Text('Load Milestones', style: TextStyle(color: Colors.white, fontSize: 16)),
                                                ),
                                              );
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 52.0, 0.0, 0.0),
                                          child: StreamBuilder<
                                              List<ChildernRecord>>(
                                            stream: queryChildernRecord(
                                              queryBuilder: (childernRecord) =>
                                                  childernRecord.where(
                                                'userRef',
                                                isEqualTo:
                                                    containerChildernRecord
                                                        .userRef,
                                              ),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              List<ChildernRecord>
                                                  rowChildernRecordList =
                                                  snapshot.data!;

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: List.generate(
                                                      rowChildernRecordList
                                                          .length, (rowIndex) {
                                                    final rowChildernRecord =
                                                        rowChildernRecordList[
                                                            rowIndex];
                                                    return Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              -1.0, 0.0),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    24.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            FFAppState()
                                                                    .selectedChildForMilestone =
                                                                rowChildernRecord
                                                                    .reference;
                                                            safeSetState(() {});
                                                          },
                                                          child: Container(
                                                            width: 150.0,
                                                            height: 134.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rowChildernRecord
                                                                          .reference ==
                                                                      FFAppState()
                                                                          .selectedChildForMilestone
                                                                  ? Color(
                                                                      0x1D52A097)
                                                                  : Colors
                                                                      .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14.0),
                                                              border:
                                                                  Border.all(
                                                                color: rowChildernRecord
                                                                            .reference ==
                                                                        FFAppState()
                                                                            .selectedChildForMilestone
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .alternate,
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 66.0,
                                                                  height: 66.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: rowChildernRecord
                                                                        .selectedColor,
                                                                    shape: BoxShape
                                                                        .circle,
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
                                                                  valueOrDefault<
                                                                      String>(
                                                                    rowChildernRecord
                                                                        .name,
                                                                    'child name',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 20.0, 24.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'A collection of fun and engaging activities to support your child’s potty training journey.',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        color:
                                                            Color(0xC2000000),
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                percent: valueOrDefault<double>(
                                                  (int var1) {
                                                    return var1 > 25
                                                        ? 1.0
                                                        : var1 / 25.0;
                                                  }(containerChildrenAccomlishedMilestonesRecordList
                                                      .length),
                                                  0.0,
                                                ),
                                                radius: 40.0,
                                                lineWidth: 10.0,
                                                animation: true,
                                                animateFromLastPercent: true,
                                                progressColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                backgroundColor:
                                                    Color(0x6552A097),
                                                center: Text(
                                                  '${valueOrDefault<String>(
                                                    ((100 *
                                                                double.parse(
                                                                    valueOrDefault<
                                                                        double>(
                                                                  (int var1) {
                                                                    return var1 >
                                                                            25
                                                                        ? 1.0
                                                                        : var1 /
                                                                            25.0;
                                                                  }(containerChildrenAccomlishedMilestonesRecordList
                                                                      .length),
                                                                  0.0,
                                                                ).toStringAsFixed(
                                                                        2)))
                                                            .toInt())
                                                        .toString(),
                                                    '0',
                                                  )} %',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineSmall
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 40.0, 12.0, 0.0),
                                          child: StreamBuilder<
                                              List<SaticMilestonesRecord>>(
                                            stream: querySaticMilestonesRecord(
                                              queryBuilder:
                                                  (saticMilestonesRecord) =>
                                                      saticMilestonesRecord
                                                          .where(
                                                            'age',
                                                            isEqualTo: functions
                                                                .newCobverBirthdayToAGe(
                                                                    containerChildernRecord
                                                                        .birthDay!),
                                                          ),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // Filter locally for Physical milestones
                                              List<SaticMilestonesRecord>
                                                  containerSaticMilestonesRecordList =
                                                  snapshot.data!.where((m) => m.actGoal == ActGoalMilestones.Physical).toList();

                                              return Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.0),
                                                  border: Border.all(
                                                    color: Color(0xFF4CAF50),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10.0,
                                                                  10.0,
                                                                  10.0,
                                                                  0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Container(
                                                              width: 42.0,
                                                              height: 42.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(0xFF4CAF50),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.directions_run,
                                                                color: Colors.white,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        8.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Physical Milestones',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child: Text(
                                                                    'Age ${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt()} year${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt() == 1 ? '' : 's'}',
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          color: Color(0xFF4CAF50),
                                                                          fontSize: 14.0,
                                                                          letterSpacing: 0.0,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  0.0),
                                                      child:
                                                          LinearPercentIndicator(
                                                          percent:
                                                              valueOrDefault<
                                                                  double>(
                                                            (int var1) {
                                                              return var1 > 5
                                                                  ? 1.0
                                                                  : var1 / 5.0;
                                                            }(valueOrDefault<
                                                                int>(
                                                              containerChildrenAccomlishedMilestonesRecordList
                                                                  .where((e) =>
                                                                      e.category ==
                                                                      ActGoalMilestones
                                                                          .Physical
                                                                          .name)
                                                                  .toList()
                                                                  .length,
                                                              0,
                                                            )),
                                                            0.0,
                                                          ),
                                                          lineHeight: 12.0,
                                                          animation: true,
                                                          animateFromLastPercent:
                                                              true,
                                                          progressColor:
                                                              Color(0xFF4CAF50),
                                                          backgroundColor:
                                                              Color(0xFF4CAF50).withOpacity(0.2),
                                                          barRadius:
                                                              Radius.circular(
                                                                  8.0),
                                                          padding:
                                                              EdgeInsets.zero,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  20.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final saticmilston =
                                                              containerSaticMilestonesRecordList
                                                                  .toList();

                                                          return ListView
                                                              .builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                saticmilston
                                                                    .length,
                                                            itemBuilder: (context,
                                                                saticmilstonIndex) {
                                                              final saticmilstonItem =
                                                                  saticmilston[
                                                                      saticmilstonIndex];
                                                              final isCompleted = containerChildrenAccomlishedMilestonesRecordList
                                                                  .where((e) => e.milestone?.id == saticmilstonItem.reference.id)
                                                                  .toList()
                                                                  .isNotEmpty;
                                                              return Padding(
                                                                padding: EdgeInsets.only(bottom: 12.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    _showMilestoneBottomSheet(
                                                                      context: context,
                                                                      milestone: saticmilstonItem,
                                                                      isCompleted: isCompleted,
                                                                      childRef: containerChildernRecord.reference,
                                                                      childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                    );
                                                                  },
                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () async {
                                                                            await _toggleMilestoneCompletion(
                                                                              childRef: containerChildernRecord.reference,
                                                                              milestoneRef: saticmilstonItem.reference,
                                                                              category: saticmilstonItem.category,
                                                                              childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                              currentlyCompleted: isCompleted,
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                                                            color: const Color(0xFF4CAF50), // Physical category color
                                                                            size: 24.0,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 12.0),
                                                                        Expanded(
                                                                          child: Text(
                                                                            valueOrDefault<String>(
                                                                              saticmilstonItem.title,
                                                                              'title',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Andika New Basic',
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              fontSize: 15.0,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons.chevron_right,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          size: 20.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 20.0, 12.0, 0.0),
                                          child: StreamBuilder<
                                              List<SaticMilestonesRecord>>(
                                            stream: querySaticMilestonesRecord(
                                              queryBuilder:
                                                  (saticMilestonesRecord) =>
                                                      saticMilestonesRecord
                                                          .where(
                                                            'age',
                                                            isEqualTo: functions
                                                                .newCobverBirthdayToAGe(
                                                                    containerChildernRecord
                                                                        .birthDay!),
                                                          ),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // Filter locally for Cognitive milestones
                                              List<SaticMilestonesRecord>
                                                  containerSaticMilestonesRecordList =
                                                  snapshot.data!.where((m) => m.actGoal == ActGoalMilestones.Cognitive).toList();

                                              return Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.0),
                                                  border: Border.all(
                                                    color: Color(0xFF64B5F6),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10.0,
                                                                  10.0,
                                                                  10.0,
                                                                  0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Container(
                                                              width: 42.0,
                                                              height: 42.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(0xFF64B5F6),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.psychology,
                                                                color: Colors.white,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        8.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Cognitive Milestones',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child: Text(
                                                                    'Age ${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt()} year${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt() == 1 ? '' : 's'}',
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          color: Color(0xFF64B5F6),
                                                                          fontSize: 14.0,
                                                                          letterSpacing: 0.0,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  0.0),
                                                      child:
                                                          LinearPercentIndicator(
                                                        percent: valueOrDefault<
                                                            double>(
                                                          (int var1) {
                                                            return var1 > 5
                                                                ? 1.0
                                                                : var1 / 5.0;
                                                          }(valueOrDefault<int>(
                                                            containerChildrenAccomlishedMilestonesRecordList
                                                                .where((e) =>
                                                                    e.category ==
                                                                    ActGoalMilestones
                                                                        .Cognitive
                                                                        .name)
                                                                .toList()
                                                                .length,
                                                            0,
                                                          )),
                                                          0.0,
                                                        ),
                                                        lineHeight: 12.0,
                                                        animation: true,
                                                        animateFromLastPercent:
                                                            true,
                                                        progressColor:
                                                            Color(0xFF64B5F6),
                                                        backgroundColor:
                                                            Color(0xFF64B5F6).withOpacity(0.2),
                                                        barRadius:
                                                            Radius.circular(
                                                                8.0),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  20.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final saticmilston =
                                                              containerSaticMilestonesRecordList
                                                                  .toList();

                                                          return ListView
                                                              .builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                saticmilston
                                                                    .length,
                                                            itemBuilder: (context,
                                                                saticmilstonIndex) {
                                                              final saticmilstonItem =
                                                                  saticmilston[
                                                                      saticmilstonIndex];
                                                              final isCompleted = containerChildrenAccomlishedMilestonesRecordList
                                                                  .where((e) => e.milestone?.id == saticmilstonItem.reference.id)
                                                                  .toList()
                                                                  .isNotEmpty;
                                                              return Padding(
                                                                padding: EdgeInsets.only(bottom: 12.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    _showMilestoneBottomSheet(
                                                                      context: context,
                                                                      milestone: saticmilstonItem,
                                                                      isCompleted: isCompleted,
                                                                      childRef: containerChildernRecord.reference,
                                                                      childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                    );
                                                                  },
                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () async {
                                                                            await _toggleMilestoneCompletion(
                                                                              childRef: containerChildernRecord.reference,
                                                                              milestoneRef: saticmilstonItem.reference,
                                                                              category: saticmilstonItem.category,
                                                                              childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                              currentlyCompleted: isCompleted,
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                                                            color: const Color(0xFF64B5F6), // Cognitive category color
                                                                            size: 24.0,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 12.0),
                                                                        Expanded(
                                                                          child: Text(
                                                                            valueOrDefault<String>(
                                                                              saticmilstonItem.title,
                                                                              'title',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Andika New Basic',
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              fontSize: 15.0,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons.chevron_right,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          size: 20.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 20.0, 12.0, 20.0),
                                          child: StreamBuilder<
                                              List<SaticMilestonesRecord>>(
                                            stream: querySaticMilestonesRecord(
                                              queryBuilder:
                                                  (saticMilestonesRecord) =>
                                                      saticMilestonesRecord
                                                          .where(
                                                            'age',
                                                            isEqualTo: functions
                                                                .newCobverBirthdayToAGe(
                                                                    containerChildernRecord
                                                                        .birthDay!),
                                                          ),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // Filter locally for Selfcare milestones
                                              List<SaticMilestonesRecord>
                                                  containerSaticMilestonesRecordList =
                                                  snapshot.data!.where((m) => m.actGoal == ActGoalMilestones.Selfcare).toList();

                                              return Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.0),
                                                  border: Border.all(
                                                    color: Color(0xFFEE8B60),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10.0,
                                                                  10.0,
                                                                  10.0,
                                                                  0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Container(
                                                              width: 42.0,
                                                              height: 42.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(0xFFEE8B60),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.self_improvement,
                                                                color: Colors.white,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        8.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Self-care Milestones',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child: Text(
                                                                    'Age ${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt()} year${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt() == 1 ? '' : 's'}',
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          color: Color(0xFFEE8B60),
                                                                          fontSize: 14.0,
                                                                          letterSpacing: 0.0,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  0.0),
                                                      child:
                                                          LinearPercentIndicator(
                                                        percent: valueOrDefault<
                                                            double>(
                                                          (int var1) {
                                                            return var1 > 5
                                                                ? 1.0
                                                                : var1 / 5.0;
                                                          }(valueOrDefault<int>(
                                                            containerChildrenAccomlishedMilestonesRecordList
                                                                .where((e) =>
                                                                    e.category ==
                                                                    'Self-care')
                                                                .toList()
                                                                .length,
                                                            0,
                                                          )),
                                                          0.0,
                                                        ),
                                                        lineHeight: 12.0,
                                                        animation: true,
                                                        animateFromLastPercent:
                                                            true,
                                                        progressColor:
                                                            Color(0xFFEE8B60),
                                                        backgroundColor:
                                                            Color(0xFFEE8B60).withOpacity(0.2),
                                                        barRadius:
                                                            Radius.circular(
                                                                8.0),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  20.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final saticmilstonselfCare =
                                                              containerSaticMilestonesRecordList
                                                                  .toList();

                                                          return ListView
                                                              .builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                saticmilstonselfCare
                                                                    .length,
                                                            itemBuilder: (context,
                                                                saticmilstonselfCareIndex) {
                                                              final saticmilstonselfCareItem =
                                                                  saticmilstonselfCare[
                                                                      saticmilstonselfCareIndex];
                                                              final isCompleted = containerChildrenAccomlishedMilestonesRecordList
                                                                  .where((e) => e.milestone?.id == saticmilstonselfCareItem.reference.id)
                                                                  .toList()
                                                                  .isNotEmpty;
                                                              return Padding(
                                                                padding: EdgeInsets.only(bottom: 12.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    _showMilestoneBottomSheet(
                                                                      context: context,
                                                                      milestone: saticmilstonselfCareItem,
                                                                      isCompleted: isCompleted,
                                                                      childRef: containerChildernRecord.reference,
                                                                      childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                    );
                                                                  },
                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () async {
                                                                            await _toggleMilestoneCompletion(
                                                                              childRef: containerChildernRecord.reference,
                                                                              milestoneRef: saticmilstonselfCareItem.reference,
                                                                              category: saticmilstonselfCareItem.category,
                                                                              childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                              currentlyCompleted: isCompleted,
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                                                            color: const Color(0xFFEE8B60), // Self-care category color
                                                                            size: 24.0,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 12.0),
                                                                        Expanded(
                                                                          child: Text(
                                                                            valueOrDefault<String>(
                                                                              saticmilstonselfCareItem.title,
                                                                              'title',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Andika New Basic',
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              fontSize: 15.0,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons.chevron_right,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          size: 20.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 20.0, 12.0, 20.0),
                                          child: StreamBuilder<
                                              List<SaticMilestonesRecord>>(
                                            stream: querySaticMilestonesRecord(
                                              queryBuilder:
                                                  (saticMilestonesRecord) =>
                                                      saticMilestonesRecord
                                                          .where(
                                                            'age',
                                                            isEqualTo: functions
                                                                .newCobverBirthdayToAGe(
                                                                    containerChildernRecord
                                                                        .birthDay!),
                                                          ),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // Filter locally for Communication milestones
                                              List<SaticMilestonesRecord>
                                                  containerSaticMilestonesRecordList =
                                                  snapshot.data!.where((m) => m.actGoal == ActGoalMilestones.Communication).toList();

                                              return Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.0),
                                                  border: Border.all(
                                                    color: Color(0xFF52A097),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10.0,
                                                                  10.0,
                                                                  10.0,
                                                                  0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Container(
                                                              width: 42.0,
                                                              height: 42.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(0xFF52A097),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.record_voice_over,
                                                                color: Colors.white,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        8.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Communication Milestones',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child: Text(
                                                                    'Age ${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt()} year${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt() == 1 ? '' : 's'}',
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          color: Color(0xFF52A097),
                                                                          fontSize: 14.0,
                                                                          letterSpacing: 0.0,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  0.0),
                                                      child:
                                                          LinearPercentIndicator(
                                                        percent: valueOrDefault<
                                                            double>(
                                                          (int var1) {
                                                            return var1 > 5
                                                                ? 1.0
                                                                : var1 / 5.0;
                                                          }(valueOrDefault<int>(
                                                            containerChildrenAccomlishedMilestonesRecordList
                                                                .where((e) =>
                                                                    e.category ==
                                                                    ActGoalMilestones
                                                                        .Communication
                                                                        .name)
                                                                .toList()
                                                                .length,
                                                            0,
                                                          )),
                                                          0.0,
                                                        ),
                                                        lineHeight: 12.0,
                                                        animation: true,
                                                        animateFromLastPercent:
                                                            true,
                                                        progressColor:
                                                            Color(0xFF52A097),
                                                        backgroundColor:
                                                            Color(0xFF52A097).withOpacity(0.2),
                                                        barRadius:
                                                            Radius.circular(
                                                                8.0),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  20.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final saticmilston =
                                                              containerSaticMilestonesRecordList
                                                                  .toList();

                                                          return ListView
                                                              .builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                saticmilston
                                                                    .length,
                                                            itemBuilder: (context,
                                                                saticmilstonIndex) {
                                                              final saticmilstonItem =
                                                                  saticmilston[
                                                                      saticmilstonIndex];
                                                              final isCompleted = containerChildrenAccomlishedMilestonesRecordList
                                                                  .where((e) => e.milestone?.id == saticmilstonItem.reference.id)
                                                                  .toList()
                                                                  .isNotEmpty;
                                                              return Padding(
                                                                padding: EdgeInsets.only(bottom: 12.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    _showMilestoneBottomSheet(
                                                                      context: context,
                                                                      milestone: saticmilstonItem,
                                                                      isCompleted: isCompleted,
                                                                      childRef: containerChildernRecord.reference,
                                                                      childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                    );
                                                                  },
                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () async {
                                                                            await _toggleMilestoneCompletion(
                                                                              childRef: containerChildernRecord.reference,
                                                                              milestoneRef: saticmilstonItem.reference,
                                                                              category: saticmilstonItem.category,
                                                                              childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                              currentlyCompleted: isCompleted,
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                                                            color: const Color(0xFF52A097), // Communication category color
                                                                            size: 24.0,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 12.0),
                                                                        Expanded(
                                                                          child: Text(
                                                                            valueOrDefault<String>(
                                                                              saticmilstonItem.title,
                                                                              'title',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Andika New Basic',
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              fontSize: 15.0,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons.chevron_right,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          size: 20.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 20.0, 12.0, 20.0),
                                          child: StreamBuilder<
                                              List<SaticMilestonesRecord>>(
                                            stream: querySaticMilestonesRecord(
                                              queryBuilder:
                                                  (saticMilestonesRecord) =>
                                                      saticMilestonesRecord
                                                          .where(
                                                            'age',
                                                            isEqualTo: functions
                                                                .newCobverBirthdayToAGe(
                                                                    containerChildernRecord
                                                                        .birthDay!),
                                                          ),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // Filter locally for SocialEmotional milestones
                                              List<SaticMilestonesRecord>
                                                  containerSaticMilestonesRecordList =
                                                  snapshot.data!.where((m) => m.actGoal == ActGoalMilestones.SocialEmotional).toList();

                                              return Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.0),
                                                  border: Border.all(
                                                    color: Color(0xFFE57373),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10.0,
                                                                  10.0,
                                                                  10.0,
                                                                  0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Container(
                                                              width: 42.0,
                                                              height: 42.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(0xFFE57373),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.favorite,
                                                                color: Colors.white,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        8.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Social/Emotional Milestones',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child: Text(
                                                                    'Age ${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt()} year${functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toInt() == 1 ? '' : 's'}',
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          color: Color(0xFFE57373),
                                                                          fontSize: 14.0,
                                                                          letterSpacing: 0.0,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  0.0),
                                                      child:
                                                          LinearPercentIndicator(
                                                        percent: valueOrDefault<
                                                            double>(
                                                          (int var1) {
                                                            return var1 > 5
                                                                ? 1.0
                                                                : var1 / 5.0;
                                                          }(valueOrDefault<int>(
                                                            containerChildrenAccomlishedMilestonesRecordList
                                                                .where((e) =>
                                                                    e.category ==
                                                                    'Social/Emotional')
                                                                .toList()
                                                                .length,
                                                            0,
                                                          )),
                                                          0.0,
                                                        ),
                                                        lineHeight: 12.0,
                                                        animation: true,
                                                        animateFromLastPercent:
                                                            true,
                                                        progressColor:
                                                            Color(0xFFE57373),
                                                        backgroundColor:
                                                            Color(0xFFE57373).withOpacity(0.2),
                                                        barRadius:
                                                            Radius.circular(
                                                                8.0),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  20.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final saticmilston =
                                                              containerSaticMilestonesRecordList
                                                                  .toList();

                                                          return ListView
                                                              .builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                saticmilston
                                                                    .length,
                                                            itemBuilder: (context,
                                                                saticmilstonIndex) {
                                                              final saticmilstonItem =
                                                                  saticmilston[
                                                                      saticmilstonIndex];
                                                              final isCompleted = containerChildrenAccomlishedMilestonesRecordList
                                                                  .where((e) => e.milestone?.id == saticmilstonItem.reference.id)
                                                                  .toList()
                                                                  .isNotEmpty;
                                                              return Padding(
                                                                padding: EdgeInsets.only(bottom: 12.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    _showMilestoneBottomSheet(
                                                                      context: context,
                                                                      milestone: saticmilstonItem,
                                                                      isCompleted: isCompleted,
                                                                      childRef: containerChildernRecord.reference,
                                                                      childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                    );
                                                                  },
                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () async {
                                                                            await _toggleMilestoneCompletion(
                                                                              childRef: containerChildernRecord.reference,
                                                                              milestoneRef: saticmilstonItem.reference,
                                                                              category: saticmilstonItem.category,
                                                                              childAge: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                              currentlyCompleted: isCompleted,
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                                                            color: const Color(0xFFE57373), // Social/Emotional category color
                                                                            size: 24.0,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 12.0),
                                                                        Expanded(
                                                                          child: Text(
                                                                            valueOrDefault<String>(
                                                                              saticmilstonItem.title,
                                                                              'title',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Andika New Basic',
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              fontSize: 15.0,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons.chevron_right,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          size: 20.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ].addToEnd(SizedBox(height: 89.0)),
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.home,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
