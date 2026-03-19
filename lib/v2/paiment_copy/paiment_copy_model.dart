import '/flutter_flow/flutter_flow_model.dart';
import 'paiment_copy_widget.dart' show PaimentCopyWidget;
import 'package:flutter/material.dart';

class PaimentCopyModel extends FlutterFlowModel<PaimentCopyWidget> {
  /// Selected plan: 'yearly' (default/best value) or 'monthly'
  String selectedPayment = 'yearly';

  /// Processing state (shows loading during Stripe payment sheet)
  bool isProcessing = false;

  /// Success screen state
  bool showSuccessScreen = false;

  /// Debug error message (visible on screen)
  String? debugError;

  /// Debug logs (visible on screen)
  List<String> debugLogs = [];

  void addDebugLog(String log) {
    debugLogs.add('${DateTime.now().toLocal().toString().substring(11, 19)} - $log');
    if (debugLogs.length > 10) {
      debugLogs.removeAt(0); // Keep only last 10 logs
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
