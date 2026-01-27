import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Navigation bar types to indicate which page is currently active
/// Use 'homeSubpage' for pages that are children of home but should allow
/// navigating back to the home page
enum HomeNavPage { home, homeSubpage, meals, calendar, settings }

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
              _buildSettingsItem(context),
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
    // For home, also highlight if on a subpage
    final isSelected = currentPage == page ||
        (page == HomeNavPage.home && currentPage == HomeNavPage.homeSubpage);

    return InkWell(
      onTap: () {
        // Always allow navigation - even if button is lit (user might be on a subpage)
        // Use goNamed to replace current page instead of stacking
        switch (page) {
          case HomeNavPage.home:
            context.goNamed(HomeHybridWidget.routeName);
            break;
          case HomeNavPage.homeSubpage:
            // This shouldn't be called directly
            break;
          case HomeNavPage.meals:
            context.goNamed('Meals');
            break;
          case HomeNavPage.calendar:
            context.goNamed(CalendarpageWidget.routeName);
            break;
          case HomeNavPage.settings:
            context.goNamed(ProfileWidget.routeName);
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

  /// Settings gear icon - smaller, no label, just a gear
  Widget _buildSettingsItem(BuildContext context) {
    final isSelected = currentPage == HomeNavPage.settings;

    return InkWell(
      onTap: () {
        context.goNamed(ProfileWidget.routeName);
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.settings : Icons.settings_outlined,
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : const Color(0xFF9B8A9E),
              size: 22.0,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Settings',
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
