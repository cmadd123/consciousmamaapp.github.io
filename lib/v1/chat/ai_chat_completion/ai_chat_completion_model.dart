import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_streaming.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v1/chat/chat/chat_widget.dart';
import 'dart:convert';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'ai_chat_completion_widget.dart' show AiChatCompletionWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
