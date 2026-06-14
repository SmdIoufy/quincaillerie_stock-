import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app-colors.dart';
import '../navigation/nav_items.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final bool isAdmin;
  final Future<void> Function() onLogout;

  const AppDrawer({
    required this.userName,
    required this.isAdmin,
    required this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final items = NavItems.drawerItems(isAdmin);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAdmin ? 'Administrateur' : 'Gérant',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    selected: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  ...items.map((item) => _DrawerItem(
                        icon: item.icon,
                        label: item.label,
                        onTap: () {
                          Navigator.pop(context);
                          context.go(item.route);
                        },
                      )),
                  const Divider(height: 28),
                  _DrawerAction(
                    icon: Icons.logout_rounded,
                    label: 'Déconnexion',
                    color: AppColors.error,
                    onTap: () async {
                      Navigator.pop(context);
                      await onLogout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        selected ? AppColors.primary.withOpacity(0.10) : AppColors.background;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              selected ? AppColors.primary.withOpacity(0.12) : AppColors.border,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: selected ? AppColors.primary : AppColors.textSecondary),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  const _DrawerAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        onTap: () async => onTap(),
      ),
    );
  }
}
