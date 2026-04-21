import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'get_started_model.dart';
export 'get_started_model.dart';

class GetStartedWidget extends StatefulWidget {
  const GetStartedWidget({
    super.key,
    required this.childrean,
  });

  final DocumentReference? childrean;

  static String routeName = 'GetStarted';
  static String routePath = '/getStarted';

  @override
  State<GetStartedWidget> createState() => _GetStartedWidgetState();
}

class _GetStartedWidgetState extends State<GetStartedWidget> {
  late GetStartedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GetStartedModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, 1.0),
                  end: AlignmentDirectional(0, -1.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Container(
                          width: 182.0,
                          height: 152.8,
                          decoration: const BoxDecoration(),
                          child: Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.0),
                              child: Image.asset(
                                'assets/images/image_22.png',
                                width: 200.0,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Let’s get started on this journey together!',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 30.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 20.0),
                              child: Text(
                                'Congratulations on taking a proactive step towards creating a peaceful home. By choosing this app, you’re investing in a future where you feel confident in the rhythms you have set in place to help you and your family thrive.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 60.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        context.pushNamed(
                                            HomePageWidget.routeName);
                                      },
                                      text: 'Lets Get Started',
                                      options: FFButtonOptions(
                                        height: 48.0,
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(28.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(const SizedBox(width: 10.0)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 50.0),
                child: RichText(
                  textScaler: MediaQuery.of(context).textScaler,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'By Continuing, you are agree to our ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          decoration: TextDecoration.underline,
                        ),
                      )
                    ],
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0x8F000000),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
