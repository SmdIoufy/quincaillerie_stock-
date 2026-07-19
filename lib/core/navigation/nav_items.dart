import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class NavItems {
  static const accueil = NavItem(
    label: 'Accueil',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    route: '/dashboard',
  );

  static const vente = NavItem(
    label: 'Vente',
    icon: Icons.shopping_cart_outlined,
    activeIcon: Icons.shopping_cart_rounded,
    route: '/ventes',
  );

  static const stock = NavItem(
    label: 'Stock',
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    route: '/stock',
  );

  static const stats = NavItem(
    label: 'Stats',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    route: '/stats',
  );

  static const catalogue = NavItem(
    label: 'Catalogue',
    icon: Icons.category_outlined,
    activeIcon: Icons.category_rounded,
    route: '/catalogue',
  );

  static const plus = NavItem(
    label: 'Plus',
    icon: Icons.more_horiz,
    activeIcon: Icons.more_horiz,
    route: '/plus',
  );

  static const utilisateurs = NavItem(
    label: 'Utilisateurs',
    icon: Icons.people_outline,
    activeIcon: Icons.people_rounded,
    route: '/users',
  );

  static const audit = NavItem(
    label: 'Audit système',
    icon: Icons.history,
    activeIcon: Icons.history,
    route: '/audit',
  );

  static const inventaire = NavItem(
    label: 'Inventaire',
    icon: Icons.checklist_outlined,
    activeIcon: Icons.checklist_rounded,
    route: '/inventaire',
  );

  static List<NavItem> bottomNav = [accueil, vente, stock, stats, inventaire];

  static List<NavItem> drawerItems(bool isAdmin) {
    final common = [vente, stock, stats, catalogue];
    if (isAdmin) {
      return [...common, utilisateurs, audit];
    }
    return common;
  }
}
