import '/flutter_flow/flutter_flow_util.dart';
import '/v2/learning_path/compele_taskpopup/compele_taskpopup_widget.dart';
import 'package:flutter/material.dart';
import 'popup_model.dart';
export 'popup_model.dart';

/// i want a pop up component that is that sure he want this task to be
/// completed or not
class PopupWidget extends StatefulWidget {
  const PopupWidget({super.key});

  static String routeName = 'popup';
  static String routePath = '/popup';

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {
  late PopupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0x80000000),
        body: SafeArea(
          top: true,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0x80000000),
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: wrapWithModel(
                    model: _model.compeleTaskpopupModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const CompeleTaskpopupWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
