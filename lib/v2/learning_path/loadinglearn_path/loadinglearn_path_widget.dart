import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v2/learning_path/loading_learn_pass/loading_learn_pass_widget.dart';
import 'package:flutter/material.dart';
import 'loadinglearn_path_model.dart';
export 'loadinglearn_path_model.dart';

class LoadinglearnPathWidget extends StatefulWidget {
  const LoadinglearnPathWidget({super.key});

  static String routeName = 'LoadinglearnPath';
  static String routePath = '/loadinglearnPath';

  @override
  State<LoadinglearnPathWidget> createState() => _LoadinglearnPathWidgetState();
}

class _LoadinglearnPathWidgetState extends State<LoadinglearnPathWidget> {
  late LoadinglearnPathModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadinglearnPathModel());
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
        backgroundColor: const Color(0xFFEDFFFD),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
                child: Material(
                  color: Colors.transparent,
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.9,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        wrapWithModel(
                          model: _model.loadingLearnPassModel,
                          updateCallback: () => safeSetState(() {}),
                          updateOnChange: true,
                          child: const LoadingLearnPassWidget(
                            title:
                                'Hold on. We are generating your learning path. ',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
