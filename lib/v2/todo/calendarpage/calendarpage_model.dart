import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'calendarpage_widget.dart' show CalendarpageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CalendarpageModel extends FlutterFlowModel<CalendarpageWidget> {
  ///  Local state fields for this page.

  DateTime? selecteddate;

  String selectedFilter = 'All';

  DocumentReference? selectedChildFilter;

  // Multi-select child filters
  Set<DocumentReference> selectedChildFilters = {};

  // Parent filters
  bool filterByMom = false;
  bool filterByDad = false;

  // Parent display info (loaded from current user)
  ParentDisplayInfo parentInfo = ParentDisplayInfo.defaults();

  // Debug state
  bool showDebugPanel = false;
  List<String> debugLogs = [];

  ///  State fields for stateful widgets in this page.

  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {}
}
