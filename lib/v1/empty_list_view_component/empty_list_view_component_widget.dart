import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'empty_list_view_component_model.dart';
export 'empty_list_view_component_model.dart';

class EmptyListViewComponentWidget extends StatefulWidget {
  const EmptyListViewComponentWidget({
    super.key,
    required this.icon,
    String? message,
  }) : this.message = message ?? 'No Tasks Yet';

  final Widget? icon;
  final String message;

  @override
  State<EmptyListViewComponentWidget> createState() =>
      _EmptyListViewComponentWidgetState();
}

class _EmptyListViewComponentWidgetState
    extends State<EmptyListViewComponentWidget> {
  late EmptyListViewComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyListViewComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400.0,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget!.icon!,
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: Text(
              valueOrDefault<String>(
                widget!.message,
                'No task yet',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
