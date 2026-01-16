import '/components/congratulations_p_o_p_up_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'compele_taskpopup_model.dart';
export 'compele_taskpopup_model.dart';

/// Return type for the completion popup - contains feedback data
class TaskCompletionResult {
  final bool confirmed;
  final String? feedback; // 'great', 'okay', 'struggled'
  final String? note;

  TaskCompletionResult({
    required this.confirmed,
    this.feedback,
    this.note,
  });
}

class CompeleTaskpopupWidget extends StatefulWidget {
  const CompeleTaskpopupWidget({super.key});

  @override
  State<CompeleTaskpopupWidget> createState() => _CompeleTaskpopupWidgetState();
}

class _CompeleTaskpopupWidgetState extends State<CompeleTaskpopupWidget> {
  late CompeleTaskpopupModel _model;
  String? _selectedFeedback;
  final TextEditingController _noteController = TextEditingController();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompeleTaskpopupModel());
  }

  @override
  void dispose() {
    _noteController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  Widget _buildFeedbackOption(
    BuildContext context,
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    final isSelected = _selectedFeedback == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFeedback = value;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected ? color : FlutterFlowTheme.of(context).alternate,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: isSelected ? color : FlutterFlowTheme.of(context).secondaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 340.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Color(0x33000000),
              offset: Offset(0.0, 10.0),
            )
          ],
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with celebration icon
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration_outlined,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 32.0,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'How did it go?',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Andika New Basic',
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Your feedback helps track progress',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 14.0,
                    ),
              ),
              SizedBox(height: 20.0),
              // Feedback options
              Row(
                children: [
                  _buildFeedbackOption(
                    context,
                    'great',
                    Icons.sentiment_very_satisfied_outlined,
                    'Great!',
                    Color(0xFF4CAF50),
                  ),
                  SizedBox(width: 8.0),
                  _buildFeedbackOption(
                    context,
                    'okay',
                    Icons.sentiment_satisfied_outlined,
                    'Okay',
                    Color(0xFFFF9800),
                  ),
                  SizedBox(width: 8.0),
                  _buildFeedbackOption(
                    context,
                    'struggled',
                    Icons.sentiment_dissatisfied_outlined,
                    'Struggled',
                    Color(0xFFF44336),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              // Optional note field
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Add a note (optional)',
                    hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                    contentPadding: EdgeInsets.all(12.0),
                    border: InputBorder.none,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                      ),
                ),
              ),
              SizedBox(height: 20.0),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () async {
                        Navigator.pop(
                          context,
                          TaskCompletionResult(confirmed: false),
                        );
                      },
                      text: 'Cancel',
                      options: FFButtonOptions(
                        height: 44.0,
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Builder(
                      builder: (context) => FFButtonWidget(
                        onPressed: () async {
                          // Show congratulations popup
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: CongratulationsPOPUpWidget(),
                              );
                            },
                          );

                          Navigator.pop(
                            context,
                            TaskCompletionResult(
                              confirmed: true,
                              feedback: _selectedFeedback,
                              note: _noteController.text.isNotEmpty
                                  ? _noteController.text
                                  : null,
                            ),
                          );
                        },
                        text: 'Complete',
                        icon: Icon(
                          Icons.check_circle_outline,
                          size: 18.0,
                        ),
                        options: FFButtonOptions(
                          height: 44.0,
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Andika New Basic',
                                color: Colors.white,
                              ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
