import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class ShellTab {
  const ShellTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Hosts a `StatefulNavigationShell` (one IndexedStack per tab) and renders a
/// Material 3 `NavigationBar` at the bottom. Used by both the patient and
/// doctor route trees — the tab list is the only difference.
class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    required this.tabs,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellTab> tabs;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <NavigationDestination>[
          for (final ShellTab t in tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon, color: AppColors.primary),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
