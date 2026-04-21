import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'ai_chat_widget.dart' show AiChatWidget;
import 'package:flutter/material.dart';

class AiChatModel extends FlutterFlowModel<AiChatWidget> {
  ///  Local state fields for this page.

  List<MessagesRecord> messages = [];
  void addToMessages(MessagesRecord item) => messages.add(item);
  void removeFromMessages(MessagesRecord item) => messages.remove(item);
  void removeAtIndexFromMessages(int index) => messages.removeAt(index);
  void insertAtIndexInMessages(int index, MessagesRecord item) =>
      messages.insert(index, item);
  void updateMessagesAtIndex(int index, Function(MessagesRecord) updateFn) =>
      messages[index] = updateFn(messages[index]);

  DocumentReference? chatRef;

  bool isNew = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PromtTextFeild widget.
  FocusNode? promtTextFeildFocusNode;
  TextEditingController? promtTextFeildTextController;
  String? Function(BuildContext, String?)?
      promtTextFeildTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    promtTextFeildFocusNode?.dispose();
    promtTextFeildTextController?.dispose();
  }
}
