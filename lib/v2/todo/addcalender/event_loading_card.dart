import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class EventLoadingCard extends StatelessWidget {
  final String eventName;
  final String eventType;
  final DateTime eventDate;
  final int progress;
  final int total;
  final bool isExpanded;
  final List<String>? childInitials;

  const EventLoadingCard({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.progress,
    required this.total,
    required this.isExpanded,
    this.childInitials,
  });

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Color _getEventTypeColor() {
    switch (eventType) {
      case 'Todo':
        return const Color(0xFF1976D2);
      case 'Learning':
        return const Color(0xFF7C4DFF);
      case 'Activity':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF00897B);
    }
  }

  IconData _getEventTypeIcon() {
    switch (eventType) {
      case 'Todo':
        return Icons.check_box_outlined;
      case 'Learning':
        return Icons.school_outlined;
      case 'Activity':
        return Icons.play_circle_outline;
      default:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Calculate progress percentage
    final progressPercent = total > 0 ? progress / total : 0.0;

    // Element visibility based on progress
    final showBadge = progressPercent >= 0.1;
    final showTitle = progressPercent >= 0.25;
    final showTime = progressPercent >= 0.40;
    final showChildren = progressPercent >= 0.60 && childInitials != null && childInitials!.isNotEmpty;
    final showComplete = progressPercent >= 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      width: isExpanded ? screenSize.width : 320,
      height: isExpanded ? screenSize.height : 220,
      child: Card(
        elevation: isExpanded ? 0 : 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isExpanded ? 0 : 16),
        ),
        color: Colors.white,
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  AnimatedOpacity(
                    opacity: showBadge ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      scale: showBadge ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getEventTypeIcon(),
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              eventType,
                              style: theme.bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  AnimatedOpacity(
                    opacity: showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: AnimatedSlide(
                      offset: showTitle ? Offset.zero : const Offset(-0.1, 0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: Text(
                        eventName,
                        style: theme.bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Time
                  AnimatedOpacity(
                    opacity: showTime ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(eventDate),
                          style: theme.bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 14,
                            color: theme.secondaryText,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Child circles
                  if (childInitials != null && childInitials!.isNotEmpty)
                    AnimatedOpacity(
                      opacity: showChildren ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: Wrap(
                        spacing: 8,
                        children: childInitials!.map((initial) {
                          return CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.primary.withOpacity(0.2),
                            child: Text(
                              initial,
                              style: theme.bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.primary,
                                letterSpacing: 0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const Spacer(),

                  // Progress bar or completion checkmark
                  if (!showComplete)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar with smooth animation
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: progressPercent,
                            ),
                            builder: (context, value, _) => LinearProgressIndicator(
                              value: value,
                              backgroundColor: theme.primary.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress text
                        Text(
                          'Creating event $progress of $total...',
                          style: theme.bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 12,
                            color: theme.secondaryText,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    )
                  else
                    // Completion checkmark
                    Center(
                      child: AnimatedScale(
                        scale: showComplete ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
