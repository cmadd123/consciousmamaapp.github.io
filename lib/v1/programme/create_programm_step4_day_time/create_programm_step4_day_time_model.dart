import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'create_programm_step4_day_time_widget.dart'
    show CreateProgrammStep4DayTimeWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateProgrammStep4DayTimeModel
    extends FlutterFlowModel<CreateProgrammStep4DayTimeWidget> {
  ///  Local state fields for this page.

  String? selectedTime;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getTimezone] action in ParentingType widget.
  String? timezone;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
