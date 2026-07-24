import 'package:flutter/material.dart';
import 'confirm_share_dialog.dart';
import '/app_state.dart';
import 'package:flutter/services.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/creator_service.dart';

/// Bottom sheet for publishing the current week's meal plan to followers.
/// Only visible to users who have a creator profile.
class PublishMealPlanSheet extends StatefulWidget {
  final CreatorsRecord creator;

  const PublishMealPlanSheet({super.key, required this.creator});

  @override
  State<PublishMealPlanSheet> createState() => _PublishMealPlanSheetState();
}

class _PublishMealPlanSheetState extends State<PublishMealPlanSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    // Default title
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    _titleController.text = 'Week of ${months[now.month - 1]} ${now.day}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_titleController.text.trim().isEmpty) return;

    final ok = await confirmShareWithFollowers(context,
        what: 'This week\'s meal plan');
    if (!ok) return;

    setState(() => _isPublishing = true);
    HapticFeedback.mediumImpact();

    final error = await publishMealPlanToFollowers(
      creator: widget.creator,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (error == null) {
      // Success
      HapticFeedback.heavyImpact();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal plan published to your followers!'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20.0),

          // Title
          Text(
            'Publish to Followers',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Share this week\'s meal plan with everyone using your code',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily,
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 13.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 20.0),

          // Plan title
          TextField(
            controller: _titleController,
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
            ),
            decoration: InputDecoration(
              labelText: 'Plan Title',
              labelStyle: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 14.0,
              ),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).primaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
          ),
          const SizedBox(height: 12.0),

          // Description (optional)
          TextField(
            controller: _descController,
            maxLines: 2,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 14.0,
              ),
              hintText: 'e.g., Quick weeknight dinners the whole family will love',
              hintStyle: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.5),
                fontSize: 13.0,
              ),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).primaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
          ),
          const SizedBox(height: 8.0),

          // Info note
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your current week\'s meals will be packaged and shared. Followers can load them with one tap.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Publish button
          FFButtonWidget(
            onPressed: _isPublishing ? null : () => _publish(),
            text: _isPublishing ? 'Publishing...' : 'Publish Meal Plan',
            options: FFButtonOptions(
              width: double.infinity,
              height: 52.0,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
              borderRadius: BorderRadius.circular(14.0),
              disabledColor: Colors.grey,
            ),
          ),

          // Attribution
          const SizedBox(height: 10.0),
          Text(
            'Published as ${widget.creator.name} · Code: ${widget.creator.code}',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily,
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 11.0,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Show the publish meal plan bottom sheet.
/// Returns true if published successfully.
Future<bool?> showPublishMealPlanSheet(BuildContext context, CreatorsRecord creator) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PublishMealPlanSheet(creator: creator),
  );
}
