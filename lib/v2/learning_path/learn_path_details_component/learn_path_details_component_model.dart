import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/compele_taskpopup/compele_taskpopup_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'learn_path_details_component_widget.dart'
    show LearnPathDetailsComponentWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LearnPathDetailsComponentModel
    extends FlutterFlowModel<LearnPathDetailsComponentWidget> {
  ///  Local state fields for this component.

  bool iscompleted = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Alert Dialog - Custom Dialog] action in Button widget.
  bool? isconfarim;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
