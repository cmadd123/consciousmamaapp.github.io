import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'o_boarding_step1_widget.dart' show OBoardingStep1Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OBoardingStep1Model extends FlutterFlowModel<OBoardingStep1Widget> {
  ///  Local state fields for this page.

  // Changed to List for multi-select support
  List<String> selectedSupports = [];

  // Legacy field for compatibility
  String? get selectedSupport => selectedSupports.isNotEmpty ? selectedSupports.join(', ') : null;

  void toggleSupport(String support) {
    if (selectedSupports.contains(support)) {
      selectedSupports.remove(support);
    } else {
      selectedSupports.add(support);
    }
  }

  bool isSelected(String support) {
    return selectedSupports.contains(support);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
