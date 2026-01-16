import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_streaming.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:convert';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'ai_chattest_assitant_widget.dart' show AiChattestAssitantWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
