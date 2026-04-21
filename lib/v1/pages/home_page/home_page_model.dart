import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v1/nav_bar/nav_bar_widget.dart';
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  bool isclosed = false;

  DocumentReference? chatRef;

  bool? isNew = true;

  int? index = 0;

  List<String> userMessage = [];
  void addToUserMessage(String item) => userMessage.add(item);
  void removeFromUserMessage(String item) => userMessage.remove(item);
  void removeAtIndexFromUserMessage(int index) => userMessage.removeAt(index);
  void insertAtIndexInUserMessage(int index, String item) =>
      userMessage.insert(index, item);
  void updateUserMessageAtIndex(int index, Function(String) updateFn) =>
      userMessage[index] = updateFn(userMessage[index]);

  int? index1 = 0;

  int activityindex = 0;

  double age = 1.0;

  List<ChildActivityStruct> homeActivityyModels = [];
  void addToHomeActivityyModels(ChildActivityStruct item) =>
      homeActivityyModels.add(item);
  void removeFromHomeActivityyModels(ChildActivityStruct item) =>
      homeActivityyModels.remove(item);
  void removeAtIndexFromHomeActivityyModels(int index) =>
      homeActivityyModels.removeAt(index);
  void insertAtIndexInHomeActivityyModels(
          int index, ChildActivityStruct item) =>
      homeActivityyModels.insert(index, item);
  void updateHomeActivityyModelsAtIndex(
          int index, Function(ChildActivityStruct) updateFn) =>
      homeActivityyModels[index] = updateFn(homeActivityyModels[index]);

  List<HomeActivtyModelStruct> homeModel = [];
  void addToHomeModel(HomeActivtyModelStruct item) => homeModel.add(item);
  void removeFromHomeModel(HomeActivtyModelStruct item) =>
      homeModel.remove(item);
  void removeAtIndexFromHomeModel(int index) => homeModel.removeAt(index);
  void insertAtIndexInHomeModel(int index, HomeActivtyModelStruct item) =>
      homeModel.insert(index, item);
  void updateHomeModelAtIndex(
          int index, Function(HomeActivtyModelStruct) updateFn) =>
      homeModel[index] = updateFn(homeModel[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in HomePage widget.
  List<ChildernRecord>? orgChild;
  // Stores action output result for [Firestore Query - Query a collection] action in HomePage widget.
  List<ActivitiesRecord>? orgActivity;
  // Model for NavBar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    navBarModel.dispose();
  }
}
