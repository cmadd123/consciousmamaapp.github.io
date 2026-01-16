import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Shows the grocery list options as a bottom sheet
Future<void> showGroceryListBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const GroceryListBottomSheet(),
  );
}

class GroceryListBottomSheet extends StatelessWidget {
  const GroceryListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Add to Grocery List',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // This Week option
              _GroceryOption(
                icon: Icons.calendar_view_week_rounded,
                title: 'This Week',
                subtitle: 'Add ingredients for the next 7 days',
                isPrimary: true,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    AddToGroceryWidget.routeName,
                    queryParameters: {
                      'isWeekly': serializeParam(true, ParamType.bool),
                    }.withoutNulls,
                  );
                },
              ),
              SizedBox(height: 12.0),
              // Today only option
              _GroceryOption(
                icon: Icons.today_rounded,
                title: 'Today Only',
                subtitle: 'Just ingredients for today\'s meals',
                isPrimary: false,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    AddToGroceryWidget.routeName,
                    queryParameters: {
                      'isellectAll': serializeParam(true, ParamType.bool),
                    }.withoutNulls,
                  );
                },
              ),
              SizedBox(height: 12.0),
              // Manual selection option
              _GroceryOption(
                icon: Icons.checklist_rounded,
                title: 'Let Me Select',
                subtitle: 'Pick specific meals to shop for',
                isPrimary: false,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    AddToGroceryWidget.routeName,
                    queryParameters: {
                      'isellectAll': serializeParam(false, ParamType.bool),
                    }.withoutNulls,
                  );
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

class _GroceryOption extends StatelessWidget {
  const _GroceryOption({
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
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor.withValues(alpha: 0.1) : Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isPrimary ? primaryColor : Color(0xFFE0E0E0),
            width: isPrimary ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: isPrimary ? primaryColor.withValues(alpha: 0.15) : Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: isPrimary ? primaryColor : Color(0xFF666666),
                size: 24.0,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF888888),
                          fontSize: 13.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isPrimary ? primaryColor : Color(0xFFCCCCCC),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
