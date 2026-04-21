import 'package:flutter/material.dart';
import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'clear_and_reupload_activities.dart';
import 'clear_duplicate_events.dart';
import 'clear_duplicate_learning_paths.dart';

/// Page with buttons to clean up duplicate data
/// Addresses issue where testers see 160+ duplicate events, 300+ activities, duplicate learning paths
class CleanupDuplicatesPage extends StatefulWidget {
  const CleanupDuplicatesPage({super.key});

  static String routeName = 'CleanupDuplicates';
  static String routePath = '/cleanup-duplicates';

  @override
  State<CleanupDuplicatesPage> createState() => _CleanupDuplicatesPageState();
}

class _CleanupDuplicatesPageState extends State<CleanupDuplicatesPage> {
  bool _isProcessing = false;
  String _status = 'Ready to clean up duplicate data';

  Future<void> _cleanupActivities() async {
    if (_isProcessing) return; // Prevent double-tap

    setState(() {
      _isProcessing = true;
      _status = 'Deleting old activities...';
    });

    try {
      print('🔥 CLEANUP STARTED - Deleting and re-uploading activities');
      await clearAndReuploadActivities();
      print('✅ CLEANUP COMPLETE!');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = '✓ Successfully deleted duplicates and uploaded 30 new activities!';
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Deleted all old activities and uploaded 30 new activities.\n\nGo to Activities → Situations tab to see them.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ CLEANUP FAILED: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'Activities cleanup failed: $e';
        });
      }
    }
  }

  Future<void> _cleanupEvents() async {
    setState(() {
      _isProcessing = true;
      _status = 'Cleaning up duplicate events...';
    });

    try {
      await clearDuplicateEvents();
      setState(() {
        _isProcessing = false;
        _status = 'Events cleaned up successfully! ✓';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Events cleanup failed: $e';
      });
    }
  }

  Future<void> _cleanupLearningPaths() async {
    setState(() {
      _isProcessing = true;
      _status = 'Cleaning up duplicate learning paths...';
    });

    try {
      await clearDuplicateLearningPaths();
      setState(() {
        _isProcessing = false;
        _status = 'Learning paths cleaned up successfully! ✓';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Learning paths cleanup failed: $e';
      });
    }
  }

  Future<void> _cleanupAll() async {
    setState(() {
      _isProcessing = true;
      _status = 'Cleaning up all duplicates...';
    });

    try {
      await clearAndReuploadActivities();
      await clearDuplicateEvents();
      await clearDuplicateLearningPaths();

      setState(() {
        _isProcessing = false;
        _status = 'All cleanup complete! ✓';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Cleanup failed: $e';
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
          'Clean Up Duplicates',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cleaning_services,
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
              if (!_isProcessing) ...[
                // Clean All button
                _buildCleanupButton(
                  context,
                  'Clean All Duplicates',
                  'Remove duplicates from activities, events, and learning paths',
                  _cleanupAll,
                  Colors.red,
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                // Individual cleanup buttons
                _buildCleanupButton(
                  context,
                  'Clean Activities',
                  'Delete all and re-upload from clean JSON',
                  _cleanupActivities,
                  FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(height: 16.0),
                _buildCleanupButton(
                  context,
                  'Clean Events',
                  'Remove duplicate calendar events',
                  _cleanupEvents,
                  FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(height: 16.0),
                _buildCleanupButton(
                  context,
                  'Clean Learning Paths',
                  'Remove duplicate learning paths and tasks',
                  _cleanupLearningPaths,
                  FlutterFlowTheme.of(context).primary,
                ),
              ] else
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              const SizedBox(height: 32.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Warning',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'This will permanently delete duplicate data. For activities, it deletes ALL and re-uploads from clean source. For events and learning paths, it keeps one copy of each unique item.',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: Colors.orange[900],
                            fontSize: 13.0,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanupButton(
    BuildContext context,
    String title,
    String description,
    VoidCallback onPressed,
    Color color,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color, width: 2.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x1A000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: color,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              description,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 13.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
