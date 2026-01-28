import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cong_for_a_new_meal_model.dart';
export 'cong_for_a_new_meal_model.dart';

///  i want to mak a pop up that is congartion the user for adding adding a
/// new meal
class CongForANewMealWidget extends StatefulWidget {
  const CongForANewMealWidget({
    super.key,
    bool? isMealPlan,
    required this.isGenrateForm,
    this.showNavigationOptions = false,
  }) : this.isMealPlan = isMealPlan ?? false;

  final bool isMealPlan;
  final bool? isGenrateForm;
  final bool showNavigationOptions;

  @override
  State<CongForANewMealWidget> createState() => _CongForANewMealWidgetState();
}

class _CongForANewMealWidgetState extends State<CongForANewMealWidget> {
  late CongForANewMealModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CongForANewMealModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 12.0,
                color: Color(0x33000000),
                offset: Offset(
                  0.0,
                  4.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent2,
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: FlutterFlowTheme.of(context).success,
                    size: 48.0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Congratulations!',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                    ),
                    Text(
                      widget.isMealPlan
                          ? 'Your new meal has been successfully added to your meal plan.'
                          : 'Your new meal has been saved to your cookbook.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ].divide(SizedBox(height: 8.0)),
                ),
                // Show navigation options if requested
                if (widget.showNavigationOptions) ...[
                  FFButtonWidget(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      context.pushNamed(CreateMealPlanWidget.routeName);
                    },
                    text: 'Go to Meal Plan',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding: EdgeInsets.all(8.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).info,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      context.pushNamed(FavMealPageWidget.routeName);
                    },
                    text: 'Go to Cookbook',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding: EdgeInsets.all(8.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Colors.transparent,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ] else
                  FFButtonWidget(
                    onPressed: () async {
                      if (widget!.isMealPlan == true) {
                        if (widget!.isGenrateForm == false) {
                          if (Navigator.of(context).canPop()) {
                            context.pop();
                          }
                          context.pushNamed(CreateMealPlanWidget.routeName);
                        } else {
                          if (Navigator.of(context).canPop()) {
                            context.pop();
                          }
                          context.pushNamed(GenrateFormCookWidget.routeName);
                        }
                      } else {
                        // Recipe saved to cookbook - navigate to cookbook
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        }
                        context.pushNamed(FavMealPageWidget.routeName);
                      }
                    },
                    text: 'Continue',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding: EdgeInsets.all(8.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).info,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
              ].divide(SizedBox(height: 20.0)),
            ),
          ),
        ),
      ),
    );
  }
}
