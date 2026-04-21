import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Shows the add todo bottom sheet
Future<Map<String, dynamic>?> showAddTodoBottomSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>?>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const AddTodoBottomSheet(),
  );
}

class AddTodoBottomSheet extends StatelessWidget {
  const AddTodoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Add To-Do',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick add option
                _TodoOption(
                  icon: Icons.flash_on_rounded,
                  title: 'Quick Add',
                  subtitle: 'Just add the to-do, no assignments',
                  isPrimary: true,
                  onTap: () {
                    Navigator.pop(context, {'mode': 'quick'});
                  },
                ),
                const SizedBox(height: 12.0),
                // Assign to someone option
                _TodoOption(
                  icon: Icons.people_rounded,
                  title: 'Assign to Someone',
                  subtitle: 'Add and assign to family members',
                  isPrimary: false,
                  onTap: () {
                    Navigator.pop(context, {'mode': 'assign'});
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoOption extends StatelessWidget {
  const _TodoOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = FlutterFlowTheme.of(context).primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isPrimary ? primaryColor : const Color(0xFFE0E0E0),
            width: isPrimary ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: isPrimary ? primaryColor.withValues(alpha: 0.15) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Icon(
                icon,
                color: isPrimary ? primaryColor : const Color(0xFF666666),
                size: 24.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xFF888888),
                          fontSize: 13.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isPrimary ? primaryColor : const Color(0xFFCCCCCC),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
