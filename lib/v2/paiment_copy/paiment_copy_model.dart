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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
