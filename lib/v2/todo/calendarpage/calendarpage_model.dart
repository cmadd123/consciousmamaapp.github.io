import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'calendarpage_widget.dart' show CalendarpageWidget;
import 'package:flutter/material.dart';

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
