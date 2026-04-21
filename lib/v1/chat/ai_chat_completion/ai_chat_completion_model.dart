import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'ai_chat_completion_widget.dart' show AiChatCompletionWidget;
import 'package:flutter/material.dart';

class AiChatCompletionModel extends FlutterFlowModel<AiChatCompletionWidget> {
  ///  Local state fields for this page.

  bool isNew = true;

  int index = 0;

  bool isloadingData = false;

  List<ChatCompletioninputItemStruct> messages = [];
  void addToMessages(ChatCompletioninputItemStruct item) => messages.add(item);
  void removeFromMessages(ChatCompletioninputItemStruct item) =>
      messages.remove(item);
  void removeAtIndexFromMessages(int index) => messages.removeAt(index);
  void insertAtIndexInMessages(int index, ChatCompletioninputItemStruct item) =>
      messages.insert(index, item);
  void updateMessagesAtIndex(
          int index, Function(ChatCompletioninputItemStruct) updateFn) =>
      messages[index] = updateFn(messages[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in AiChatCompletion widget.
  List<ChildernRecord>? myChildren;
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
