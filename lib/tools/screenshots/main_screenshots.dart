import 'package:flutter/material.dart';
import 'screenshot_home.dart';
import 'screenshot_feelings.dart';
import 'screenshot_meal_plan.dart';
import 'screenshot_milestones.dart';
import 'screenshot_learning_path.dart';
import 'screenshot_calendar.dart';

/// Screenshot helper tool for App Store screenshots.
///
/// Run with: flutter run -t lib/tools/screenshots/main_screenshots.dart
///
/// This bypasses Firebase entirely and renders each key screen
/// with hardcoded demo data for clean screenshot capture.
void main() {
  runApp(const ScreenshotApp());
}

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MomRise Screenshots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: FFAppState().currentFontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF52A097)),
        useMaterial3: true,
      ),
      home: const ScreenshotGallery(),
    );
  }
}

class ScreenshotGallery extends StatefulWidget {
  const ScreenshotGallery({super.key});

  @override
  State<ScreenshotGallery> createState() => _ScreenshotGalleryState();
}

class _ScreenshotGalleryState extends State<ScreenshotGallery> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_ScreenshotPage> _pages = const [
    _ScreenshotPage(title: '1. Home', widget: ScreenshotHome()),
    _ScreenshotPage(title: '2. Feelings', widget: ScreenshotFeelings()),
    _ScreenshotPage(title: '3. Meal Plan', widget: ScreenshotMealPlan()),
    _ScreenshotPage(title: '4. Milestones', widget: ScreenshotMilestones()),
    _ScreenshotPage(title: '5. Learning Path', widget: ScreenshotLearningPath()),
    _ScreenshotPage(title: '6. Calendar', widget: ScreenshotCalendar()),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index].widget,
          ),
          // Navigation overlay (tap edges to navigate, hidden during screenshots)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _currentPage > 0
                          ? () => _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                    ),
                    Text(
                      '${_pages[_currentPage].title} (${_currentPage + 1}/${_pages.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: _currentPage < _pages.length - 1
                          ? () => _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotPage {
  final String title;
  final Widget widget;

  const _ScreenshotPage({required this.title, required this.widget});
}
