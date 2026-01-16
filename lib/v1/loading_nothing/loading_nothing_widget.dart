import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'loading_nothing_model.dart';
export 'loading_nothing_model.dart';

class LoadingNothingWidget extends StatefulWidget {
  const LoadingNothingWidget({super.key});

  @override
  State<LoadingNothingWidget> createState() => _LoadingNothingWidgetState();
}

class _LoadingNothingWidgetState extends State<LoadingNothingWidget> {
  late LoadingNothingModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingNothingModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
    );
  }
}
