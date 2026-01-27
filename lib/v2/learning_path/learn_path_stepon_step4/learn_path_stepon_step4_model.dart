import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'learn_path_stepon_step4_widget.dart' show LearnPathSteponStep4Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LearnPathSteponStep4Model
    extends FlutterFlowModel<LearnPathSteponStep4Widget> {
  ///  Local state fields for this page.

  String? selectedTime = 'Morning';

  bool isloading = false;

  double loadingProgress = 0.0;

  String selectedPuzzleTheme = 'dinosaurs';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in Button widget.
  ChildernRecord? childDoc;
  InstantTimer? instantTimer3;
  InstantTimer? instantTimer1;
  InstantTimer? instantTimer2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer3?.cancel();
    instantTimer1?.cancel();
    instantTimer2?.cancel();
  }
}
