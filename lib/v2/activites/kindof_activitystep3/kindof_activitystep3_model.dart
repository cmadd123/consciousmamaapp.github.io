import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/v2/learning_path/loading_learn_pass/loading_learn_pass_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'kindof_activitystep3_widget.dart' show KindofActivitystep3Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class KindofActivitystep3Model
    extends FlutterFlowModel<KindofActivitystep3Widget> {
  ///  Local state fields for this page.

  bool quitActivity = true;

  List<ActivityModelStruct> modelsofactivty = [];
  void addToModelsofactivty(ActivityModelStruct item) =>
      modelsofactivty.add(item);
  void removeFromModelsofactivty(ActivityModelStruct item) =>
      modelsofactivty.remove(item);
  void removeAtIndexFromModelsofactivty(int index) =>
      modelsofactivty.removeAt(index);
  void insertAtIndexInModelsofactivty(int index, ActivityModelStruct item) =>
      modelsofactivty.insert(index, item);
  void updateModelsofactivtyAtIndex(
          int index, Function(ActivityModelStruct) updateFn) =>
      modelsofactivty[index] = updateFn(modelsofactivty[index]);

  bool isloading = false;

  double? loadingIndecator = 0.0;

  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer3;
  InstantTimer? instantTimer1;
  InstantTimer? instantTimer2;
  // Stores action output result for [Custom Action - genrateAIActivity] action in Button widget.
  List<ActivityModelStruct>? activity;
  // Model for loadingLearnPass component.
  late LoadingLearnPassModel loadingLearnPassModel;

  @override
  void initState(BuildContext context) {
    loadingLearnPassModel = createModel(context, () => LoadingLearnPassModel());
  }

  @override
  void dispose() {
    instantTimer3?.cancel();
    instantTimer1?.cancel();
    instantTimer2?.cancel();
    loadingLearnPassModel.dispose();
  }
}
