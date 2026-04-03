import 'package:flutter/material.dart';
import 'dart:convert';

/// Debug overlay widget that shows diagnostic information in the app
/// Displays as a floating card that can be expanded/collapsed
class DebugOverlayWidget extends StatefulWidget {
  const DebugOverlayWidget({
    super.key,
    required this.title,
    required this.debugData,
    this.isVisible = true,
  });

  final String title;
  final Map<String, dynamic> debugData;
  final bool isVisible;

  @override
  State<DebugOverlayWidget> createState() => _DebugOverlayWidgetState();
}

class _DebugOverlayWidgetState extends State<DebugOverlayWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 80.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.black.withValues(alpha: 0.9),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: _isExpanded ? 400.0 : 60.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar (always visible)
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bug_report,
                        color: Colors.amberAccent,
                        size: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white70,
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
              ),

              // Debug content (shown when expanded)
              if (_isExpanded)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white24,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: widget.debugData.entries.map((entry) {
                        return _buildDebugRow(entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, dynamic value) {
    String displayValue;
    Color valueColor;

    if (value == null) {
      displayValue = 'null';
      valueColor = Colors.grey;
    } else if (value is bool) {
      displayValue = value.toString();
      valueColor = value ? Colors.greenAccent : Colors.redAccent;
    } else if (value is String) {
      displayValue = value;
      valueColor = Colors.white;
    } else if (value is num) {
      displayValue = value.toString();
      valueColor = Colors.cyanAccent;
    } else if (value is Map || value is List) {
      // Pretty print JSON
      try {
        const encoder = JsonEncoder.withIndent('  ');
        displayValue = encoder.convert(value);
        valueColor = Colors.yellowAccent;
      } catch (e) {
        displayValue = value.toString();
        valueColor = Colors.white;
      }
    } else {
      displayValue = value.toString();
      valueColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Andika New Basic',
              color: Colors.white70,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            displayValue,
            style: TextStyle(
              fontFamily: 'Courier',
              color: valueColor,
              fontSize: 11.0,
            ),
            maxLines: displayValue.contains('\n') ? null : 3,
            overflow: displayValue.contains('\n') ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
