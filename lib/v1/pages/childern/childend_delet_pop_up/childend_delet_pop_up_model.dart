import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'childend_delet_pop_up_widget.dart' show ChildendDeletPopUpWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChildendDeletPopUpModel
    extends FlutterFlowModel<ChildendDeletPopUpWidget> {
  ///  Local state fields for this component.

  int index = 0;

  List<DocumentReference> allchildTasks = [];
  void addToAllchildTasks(DocumentReference item) => allchildTasks.add(item);
  void removeFromAllchildTasks(DocumentReference item) =>
      allchildTasks.remove(item);
  void removeAtIndexFromAllchildTasks(int index) =>
      allchildTasks.removeAt(index);
  void insertAtIndexInAllchildTasks(int index, DocumentReference item) =>
      allchildTasks.insert(index, item);
  void updateAllchildTasksAtIndex(
          int index, Function(DocumentReference) updateFn) =>
      allchildTasks[index] = updateFn(allchildTasks[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<TasksRecord>? allchildeTaskToDelet;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChildernRecord>? listOfCHildren;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
