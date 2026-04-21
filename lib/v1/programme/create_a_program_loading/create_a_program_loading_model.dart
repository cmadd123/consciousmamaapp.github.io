import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_a_program_loading_widget.dart' show CreateAProgramLoadingWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class CreateAProgramLoadingModel
    extends FlutterFlowModel<CreateAProgramLoadingWidget> {
  ///  Local state fields for this page.

  double progresseBarValue = 0.0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Cloud Function - generateChildTasks] action in CreateAProgramLoading widget.
  GenerateChildTasksCloudFunctionCallResponse? cloudFunctiond71;
  // State field(s) for Timer widget.
  final timerInitialTimeMs = 1000;
  int timerMilliseconds = 1000;
  String timerValue = StopWatchTimer.getDisplayTime(
    1000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerController.dispose();
  }
}
