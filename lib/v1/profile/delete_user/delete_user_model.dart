import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'delete_user_widget.dart' show DeleteUserWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeleteUserModel extends FlutterFlowModel<DeleteUserWidget> {
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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
