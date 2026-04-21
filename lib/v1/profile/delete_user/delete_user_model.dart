import '/flutter_flow/flutter_flow_util.dart';
import 'delete_user_widget.dart' show DeleteUserWidget;
import 'package:flutter/material.dart';

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
