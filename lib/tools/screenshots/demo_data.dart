import 'package:flutter/material.dart';

/// Shared demo data and styling constants for screenshot shells.

// Brand colors
const kPrimary = Color(0xFF52A097);
const kSecondary = Color(0xFF39D2C0);
const kTertiary = Color(0xFFEE8B60);
const kGradientTop = Color(0xFFD7F2EB);
const kGradientBottom = Color(0xFFFFE9E1);
const kDarkBg = Color(0xFF2C3E50);
const kDarkBg2 = Color(0xFF34495E);
const kLightText = Color(0xFFECF0F1);
const kGrayText = Color(0xFF95A5A6);
const kDarkGray = Color(0xFF7F8C8D);

const kBrandGradient = LinearGradient(
  colors: [kGradientTop, kGradientBottom],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const kDarkGradient = LinearGradient(
  colors: [kDarkBg, kDarkBg2],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const kFontFamily = 'Andika New Basic';

// Demo children
class DemoChild {
  final String name;
  final String initial;
  final Color color;
  final String age;

  const DemoChild({
    required this.name,
    required this.initial,
    required this.color,
    required this.age,
  });
}

const demoChildren = [
  DemoChild(name: 'Emma', initial: 'E', color: Color(0xFFFF8A80), age: '2 years'),
  DemoChild(name: 'Lucas', initial: 'L', color: Color(0xFF80D8FF), age: '4 years'),
];

// Demo milestones
class DemoMilestone {
  final String title;
  final bool completed;

  const DemoMilestone({required this.title, this.completed = false});
}

// Bottom nav bar widget used across screenshots
class ScreenshotNavBar extends StatelessWidget {
  final int selectedIndex;

  const ScreenshotNavBar({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      _NavItem(icon: Icons.restaurant_menu_outlined, activeIcon: Icons.restaurant_menu, label: 'Meals'),
      _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendar'),
      _NavItem(icon: Icons.palette_outlined, activeIcon: Icons.palette, label: 'Activities'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = i == selectedIndex;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? items[i].activeIcon : items[i].icon,
                  color: active ? kPrimary : kDarkGray,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].label,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? kPrimary : kDarkGray,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
