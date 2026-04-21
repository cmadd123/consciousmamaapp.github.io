import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'ai_chattest_assitant_widget.dart' show AiChattestAssitantWidget;
import 'package:flutter/material.dart';

class AiChattestAssitantModel
    extends FlutterFlowModel<AiChattestAssitantWidget> {
  ///  Local state fields for this page.

  bool isNew = true;

  int index = 0;

  bool isloadingData = false;

  List<MessagesForSteamStruct> messages = [];
  void addToMessages(MessagesForSteamStruct item) => messages.add(item);
  void removeFromMessages(MessagesForSteamStruct item) => messages.remove(item);
  void removeAtIndexFromMessages(int index) => messages.removeAt(index);
  void insertAtIndexInMessages(int index, MessagesForSteamStruct item) =>
      messages.insert(index, item);
  void updateMessagesAtIndex(
          int index, Function(MessagesForSteamStruct) updateFn) =>
      messages[index] = updateFn(messages[index]);

  String? threadID;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (createThreadN)] action in AiChattestAssitant widget.
  ApiCallResponse? apiResultvao;
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
