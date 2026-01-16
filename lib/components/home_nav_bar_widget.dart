import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Navigation bar types to indicate which page is currently active
enum HomeNavPage { home, meals, calendar, activities }

/// Shared navigation bar widget matching the new home page design
/// Use this for consistent navigation across the app
class HomeNavBarWidget extends StatelessWidget {
  const HomeNavBarWidget({
    super.key,
    required this.currentPage,
  });

  final HomeNavPage currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, HomeNavPage.home, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(context, HomeNavPage.meals, Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Meals'),
              _buildNavItem(context, HomeNavPage.calendar, Icons.calendar_today_outlined, Icons.calendar_today, 'Calendar'),
              _buildNavItem(context, HomeNavPage.activities, Icons.play_circle_outline, Icons.play_circle, 'Activities'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    HomeNavPage page,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentPage == page;

    return InkWell(
      onTap: () {
        if (currentPage == page) return; // Already on this page

        // Use goNamed to replace current page instead of stacking
        switch (page) {
          case HomeNavPage.home:
            context.goNamed(HomeHybridWidget.routeName);
            break;
          case HomeNavPage.meals:
            context.goNamed('Meals');
            break;
          case HomeNavPage.calendar:
            context.goNamed(CalendarpageWidget.routeName);
            break;
          case HomeNavPage.activities:
            context.goNamed(FeelingBubblesWidget.routeName);
            break;
        }
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : const Color(0xFF9B8A9E),
              size: 24.0,
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : const Color(0xFF9B8A9E),
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
