import 'package:flutter/material.dart';
import 'demo_data.dart';

/// Screenshot shell for the Home screen.
/// Dark theme with greeting, date, and navigation cards.
class ScreenshotHome extends StatelessWidget {
  const ScreenshotHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kDarkGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      Container(
                        width: 80,
                        height: 70,
                        decoration: BoxDecoration(
                          color: kLightText.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.park_outlined,
                          size: 40,
                          color: kLightText,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Greeting
                      const Text(
                        'Good morning, Sarah',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 18,
                          color: kLightText,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Date
                      const Text(
                        'Monday, February 17',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14,
                          color: kGrayText,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Calendar/Tasks card
                      const _HomeCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Playdate at 2:00 PM',
                        subtitle: 'Emma & Lucas',
                        childDots: [Color(0xFFFF8A80), Color(0xFF80D8FF)],
                      ),

                      const SizedBox(height: 20),

                      // Meals card
                      const _HomeCard(
                        icon: Icons.restaurant_outlined,
                        title: 'Dinner: Chicken Stir Fry',
                        subtitle: 'Family meal',
                        childDots: [],
                      ),

                      const SizedBox(height: 20),

                      // Activities card
                      const _HomeCard(
                        icon: Icons.palette_outlined,
                        title: 'Find an activity',
                        subtitle: 'Based on your mood',
                        childDots: [],
                        isEmpty: true,
                      ),

                      const SizedBox(height: 60),

                      // More link
                      const Text(
                        'More',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14,
                          color: kDarkGray,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              const ScreenshotNavBar(selectedIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> childDots;
  final bool isEmpty;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.childDots = const [],
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: isEmpty ? Colors.transparent : const Color(0xFF3D566E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEmpty ? kDarkGray : kGrayText,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGrayText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kLightText,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ...childDots.map((c) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                            ),
                          )),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12,
                          color: kGrayText,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kGrayText, size: 18),
        ],
      ),
    );
  }
}
