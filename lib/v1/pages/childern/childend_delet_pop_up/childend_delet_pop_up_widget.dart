import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'childend_delet_pop_up_model.dart';
export 'childend_delet_pop_up_model.dart';

class ChildendDeletPopUpWidget extends StatefulWidget {
  const ChildendDeletPopUpWidget({
    super.key,
    required this.child,
  });

  final DocumentReference? child;

  @override
  State<ChildendDeletPopUpWidget> createState() =>
      _ChildendDeletPopUpWidgetState();
}

class _ChildendDeletPopUpWidgetState extends State<ChildendDeletPopUpWidget> {
  late ChildendDeletPopUpModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChildendDeletPopUpModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      height: 320.0,
      constraints: BoxConstraints(
        minWidth: 374.0,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: Container(
                  width: 75.0,
                  height: 75.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Triangular-flag.png',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, -1.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Text(
                  'Are you sure!',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Andika New Basic',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, -1.0),
              child: Text(
                'Are you sure you want to delete child. If you proceed further the child details will be deleted permanently.',
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
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
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Color(0x0052A097),
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).primary,
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
                      await widget!.child!.delete();
                      _model.allchildeTaskToDelet = await queryTasksRecordOnce(
                        queryBuilder: (tasksRecord) => tasksRecord.where(
                          'selected_child',
                          isEqualTo: widget!.child,
                        ),
                      );
                      _model.allchildTasks = _model.allchildeTaskToDelet!
                          .map((e) => e.reference)
                          .toList()
                          .cast<DocumentReference>();
                      safeSetState(() {});
                      while (_model.allchildTasks.length > _model.index) {
                        await _model.allchildeTaskToDelet!
                            .elementAtOrNull(_model.index)!
                            .reference
                            .delete();
                        _model.index = _model.index + 1;
                        safeSetState(() {});
                      }
                      FFAppState().clearChildrenCache();
                      FFAppState().editing = !(FFAppState().editing ?? true);
                      _model.updatePage(() {});
                      _model.listOfCHildren = await queryChildernRecordOnce(
                        queryBuilder: (childernRecord) => childernRecord.where(
                          'userRef',
                          isEqualTo: currentUserReference,
                        ),
                      );
                      if (_model.listOfCHildren != null &&
                          (_model.listOfCHildren)!.isNotEmpty) {
                        Navigator.pop(context);
                      } else {
                        await currentUserReference!
                            .update(createUsersRecordData(
                          firstChildCreated: false,
                        ));

                        context.pushNamed(
                          FirstChildWidget.routeName,
                          queryParameters: {
                            'isFirst': serializeParam(
                              false,
                              ParamType.bool,
                            ),
                          }.withoutNulls,
                        );
                      }

                      safeSetState(() {});
                    },
                    text: 'Delete',
                    options: FFButtonOptions(
                      height: 49.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Andika New Basic',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
              ].divide(SizedBox(width: 20.0)),
            ),
          ].divide(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
