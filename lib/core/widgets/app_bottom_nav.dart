import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app-colors.dart';
import '../navigation/nav_items.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;

  const AppBottomNav({
    required this.currentIndex,
    required this.isAdmin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final items = NavItems.bottomNav;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.surface,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      elevation: 8,
      onTap: (index) {
        final item = items[index];
        if (item.route == '/plus') {
          Scaffold.of(context).openDrawer();
          return;
        }
        if (item.route == NavItems.bottomNav[currentIndex].route) return;
        context.go(item.route);
      },
      items: items
          .map((e) => BottomNavigationBarItem(
                icon: Icon(e.icon),
                activeIcon: Icon(e.activeIcon),
                label: e.label,
              ))
          .toList(),
    );
  }
}
