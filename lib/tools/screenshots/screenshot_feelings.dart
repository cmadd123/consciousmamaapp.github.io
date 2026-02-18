import 'package:flutter/material.dart';
import 'demo_data.dart';

/// Screenshot shell for the Feeling Bubbles (Activities) screen.
/// Light gradient with 10 mood bubbles in a 2-column grid.
class ScreenshotFeelings extends StatelessWidget {
  const ScreenshotFeelings({super.key});

  static const _feelings = [
    _Feeling('\u{1F60C}', 'Something calming, please.'),
    _Feeling('\u{26A1}', "They've got allll the wiggles."),
    _Feeling('\u{1F9E9}', 'Their brain wants a job.'),
    _Feeling('\u{1F3A8}', "Let's spark some creativity."),
    _Feeling('\u{1F3AF}', 'I need them to play on their own for a bit.'),
    _Feeling('\u{1F495}', 'We could use a little connection.'),
    _Feeling('\u{1F33F}', 'We should probably get outside.'),
    _Feeling('\u{23F1}\u{FE0F}', 'No energy left for setup.'),
    _Feeling('\u{2728}', "They're craving sensory stuff today."),
    _Feeling('\u{1F3C3}', 'Help me channel this energy somewhere.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBrandGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Text(
                          'Activities',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Tab bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _Tab(label: 'Feelings', selected: true),
                              _Tab(label: 'Situations', selected: false),
                              _Tab(label: 'My Week', selected: false),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // "I need..." subtitle
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'I need...',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action buttons row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            _ActionButton(icon: Icons.favorite, color: Colors.red, label: 'Favorites'),
                            const SizedBox(width: 10),
                            _ActionButton(icon: Icons.add_circle_outline, color: kPrimary, label: 'Custom'),
                            const SizedBox(width: 10),
                            _ActionButton(icon: Icons.list_alt, color: const Color(0xFF9C27B0), label: 'Browse'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Feelings grid
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        child: Column(
                          children: [
                            for (int i = 0; i < _feelings.length; i += 2)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(child: _FeelingBubble(feeling: _feelings[i])),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: i + 1 < _feelings.length
                                          ? _FeelingBubble(feeling: _feelings[i + 1])
                                          : const SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const ScreenshotNavBar(selectedIndex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;

  const _Tab({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ActionButton({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeelingBubble extends StatelessWidget {
  final _Feeling feeling;

  const _FeelingBubble({required this.feeling});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            feeling.emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            feeling.text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Feeling {
  final String emoji;
  final String text;

  const _Feeling(this.emoji, this.text);
}
