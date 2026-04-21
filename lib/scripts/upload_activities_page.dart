import 'package:flutter/material.dart';
import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'clear_and_reupload_activities.dart';

/// Simple page with a button to trigger activity upload
/// Navigate here once, tap the button, then remove this page
class UploadActivitiesPage extends StatefulWidget {
  const UploadActivitiesPage({super.key});

  @override
  State<UploadActivitiesPage> createState() => _UploadActivitiesPageState();
}

class _UploadActivitiesPageState extends State<UploadActivitiesPage> {
  bool _isUploading = false;
  String _status = 'Ready to clear and re-upload activities';

  Future<void> _handleUpload() async {
    setState(() {
      _isUploading = true;
      _status = 'Clearing old activities and uploading new ones...';
    });

    try {
      // Clear and re-upload with complete data
      await clearAndReuploadActivities();

      setState(() {
        _isUploading = false;
        _status = 'Upload complete! ✓';
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _status = 'Upload failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'Upload Activities',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: Colors.white,
                fontSize: 22.0,
                letterSpacing: 0.0,
              ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 80.0,
                color: FlutterFlowTheme.of(context).primary,
              ),
              const SizedBox(height: 32.0),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 48.0),
              if (!_isUploading)
                ElevatedButton(
                  onPressed: _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Clear & Re-upload Activities',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: Colors.white,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                )
              else
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              const SizedBox(height: 24.0),
              Text(
                'This will delete old activities and upload 10 new activities with descriptions',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
