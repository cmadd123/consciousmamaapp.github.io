import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mixin that provides staggered entrance animations for page content.
///
/// Usage:
/// 1. Add `with PageAnimationMixin` to your State class
/// 2. Change `State<X>` to use `TickerProviderStateMixin`
/// 3. Call `initPageAnimations(itemCount)` in initState after super.initState()
/// 4. Call `disposePageAnimations()` in dispose before super.dispose()
/// 5. Wrap sections with `animateItem(index, child)`
/// 6. Optionally use `breathingWidget(child)` for one breathing element
mixin PageAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _pageEntranceController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];
  int _animItemCount = 0;

  void initPageAnimations({int itemCount = 6}) {
    _animItemCount = itemCount;

    // Entrance controller - drives all staggered items
    _pageEntranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + (itemCount * 150)),
    );

    // Create staggered animations for each item
    for (int i = 0; i < itemCount; i++) {
      final start = (i * 0.15).clamp(0.0, 0.6);
      final end = (start + 0.45).clamp(0.0, 1.0);

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _pageEntranceController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageEntranceController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // Breathing controller - gentle continuous animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _breathingAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _breathingController.repeat(reverse: true);

    // Start entrance after the route fade transition completes (200ms)
    // This prevents double-fading (route fade + entrance fade overlapping)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _pageEntranceController.forward();
        });
      }
    });
  }

  void disposePageAnimations() {
    _pageEntranceController.dispose();
    _breathingController.dispose();
  }

  /// Wrap a section widget with staggered fade+slide entrance
  Widget animateItem(int index, Widget child) {
    if (index >= _animItemCount) return child;
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  /// Wrap one element with a gentle breathing scale animation
  Widget breathingWidget(Widget child) {
    return ScaleTransition(
      scale: _breathingAnimation,
      child: child,
    );
  }
}

/// Shows a bottom sheet with a blurred background overlay
Future<T?> showBlurredBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double blurAmount = 5.0,
  bool isScrollControlled = false,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    barrierColor: Colors.transparent,
    builder: (ctx) {
      return Stack(
        children: [
          // Blurred backdrop
          GestureDetector(
            onTap: isDismissible ? () => Navigator.pop(ctx) : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Actual sheet content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFF34495E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: builder(ctx),
            ),
          ),
        ],
      );
    },
  );
}

/// Self-animating cascade item for use in ListViews and dynamic content.
/// Each item fades+slides in with a stagger delay based on its index.
/// Set [bounce] to true for a scale overshoot effect (good for buttons).
class CascadeItem extends StatefulWidget {
  final int index;
  final int baseDelayMs;
  final int staggerMs;
  final bool bounce;
  final bool slideFromTop;
  final bool slideFromRight;
  final Widget child;

  const CascadeItem({
    super.key,
    required this.index,
    this.baseDelayMs = 200,
    this.staggerMs = 120,
    this.bounce = false,
    this.slideFromTop = false,
    this.slideFromRight = false,
    required this.child,
  });

  @override
  State<CascadeItem> createState() => _CascadeItemState();
}

class _CascadeItemState extends State<CascadeItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.bounce ? 500 : 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.slideFromRight
          ? const Offset(0.3, 0)
          : Offset(0, widget.slideFromTop ? -0.2 : 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = widget.bounce
        ? Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
          ))
        : _fadeAnimation; // reuse fade as 0-1 driver when not bouncing

    final delay = widget.baseDelayMs + (widget.index * widget.staggerMs);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bounce) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      );
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Pulsing placeholder that breathes between two opacity levels.
/// Use inside StreamBuilders while data loads.
class PulsingPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;
  final int durationMs;

  const PulsingPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 14.0,
    this.color,
    this.durationMs = 1200,
  });

  @override
  State<PulsingPlaceholder> createState() => _PulsingPlaceholderState();
}

class _PulsingPlaceholderState extends State<PulsingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _opacity = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color ?? Colors.grey.shade300,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Calendar skeleton loader — pulsing shapes that match the schedule list layout.
class CalendarScheduleSkeleton extends StatelessWidget {
  final bool isComfortMode;

  const CalendarScheduleSkeleton({super.key, this.isComfortMode = false});

  @override
  Widget build(BuildContext context) {
    final color = isComfortMode ? Colors.white.withOpacity(0.15) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              PulsingPlaceholder(width: 4.0, height: 44.0, borderRadius: 2.0, color: color, durationMs: 1200 + (i * 200)),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PulsingPlaceholder(height: 14.0, borderRadius: 7.0, color: color, durationMs: 1200 + (i * 200)),
                    const SizedBox(height: 6.0),
                    PulsingPlaceholder(width: 120.0, height: 10.0, borderRadius: 5.0, color: color, durationMs: 1400 + (i * 200)),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              PulsingPlaceholder(width: 28.0, height: 28.0, borderRadius: 6.0, color: color, durationMs: 1300 + (i * 200)),
            ],
          ),
        )),
      ),
    );
  }
}

/// Full calendar page skeleton — filter circles + calendar grid + schedule
class CalendarPageSkeleton extends StatelessWidget {
  final bool isComfortMode;

  const CalendarPageSkeleton({super.key, this.isComfortMode = false});

  @override
  Widget build(BuildContext context) {
    final color = isComfortMode ? Colors.white.withOpacity(0.15) : null;
    return Column(
      children: [
        // Filter circles placeholder
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: PulsingPlaceholder(
                width: 40.0, height: 40.0, borderRadius: 20.0,
                color: color, durationMs: 1200 + (i * 100),
              ),
            )),
          ),
        ),
        // Calendar grid placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Month header
              PulsingPlaceholder(width: 160.0, height: 20.0, borderRadius: 10.0, color: color, durationMs: 1100),
              const SizedBox(height: 16.0),
              // Day-of-week row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) => PulsingPlaceholder(
                  width: 24.0, height: 12.0, borderRadius: 6.0,
                  color: color, durationMs: 1200 + (i * 50),
                )),
              ),
              const SizedBox(height: 12.0),
              // 5 rows of day cells
              ...List.generate(5, (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (col) => PulsingPlaceholder(
                    width: 32.0, height: 32.0, borderRadius: 16.0,
                    color: color, durationMs: 1200 + (row * 100) + (col * 30),
                  )),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

/// Micro-celebration: quick scale bounce + haptic on save actions
void microCelebrate(BuildContext context) {
  HapticFeedback.mediumImpact();
}
