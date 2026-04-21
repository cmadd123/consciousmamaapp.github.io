import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
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
  }) : isMealPlan = isMealPlan ?? false;

  final bool isMealPlan;
  final bool? isGenrateForm;
  final bool showNavigationOptions;

  @override
  State<CongForANewMealWidget> createState() => _CongForANewMealWidgetState();
}

class _CongForANewMealWidgetState extends State<CongForANewMealWidget> {
  late CongForANewMealModel _model;
  final bool _isNavigating = false;

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
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                boxShadow: const [
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
                padding: const EdgeInsets.all(16.0),
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
                                fontFamily: FFAppState().currentFontFamily,
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
                            fontFamily: FFAppState().currentFontFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ].divide(const SizedBox(height: 8.0)),
                ),
                // Show navigation options if requested
                if (widget.showNavigationOptions) ...[
                  FFButtonWidget(
                    onPressed: () async {
                      // Close dialog first
                      Navigator.of(context).pop();

                      // Wait a frame then navigate
                      await Future.delayed(const Duration(milliseconds: 50));
                      if (mounted) {
                        // Pop recipe page and push to meal plan in one operation
                        context.goNamed(CreateMealPlanWidget.routeName);
                      }
                    },
                    text: 'Go to Meal Plan',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding: const EdgeInsets.all(8.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: FlutterFlowTheme.of(context).info,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      // Close dialog first
                      Navigator.of(context).pop();

                      // Wait a frame then navigate
                      await Future.delayed(const Duration(milliseconds: 50));
                      if (mounted) {
                        // Pop recipe page and push to cookbook in one operation
                        context.goNamed(FavMealPageWidget.routeName);
                      }
                    },
                    text: 'Go to Cookbook',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding: const EdgeInsets.all(8.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Colors.transparent,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: FFAppState().currentFontFamily,
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
                      // Close dialog first
                      Navigator.of(context).pop();

                      // Wait a frame then navigate
                      await Future.delayed(const Duration(milliseconds: 50));
                      if (!mounted) return;

                      if (widget.isMealPlan == true) {
                        if (widget.isGenrateForm == false) {
                          // Pop recipe page and push to meal planner in one operation
                          context.goNamed(CreateMealPlanWidget.routeName);
                        } else {
                          context.goNamed(GenrateFormCookWidget.routeName);
                        }
                      } else {
                        // Recipe saved to cookbook - navigate to cookbook
                        context.goNamed(FavMealPageWidget.routeName);
                      }
                    },
                    text: 'Continue',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding: const EdgeInsets.all(8.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: FlutterFlowTheme.of(context).info,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
              ].divide(const SizedBox(height: 20.0)),
            ),
          ),
        ),
            // White overlay to cover any transition flashes
            if (_isNavigating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
