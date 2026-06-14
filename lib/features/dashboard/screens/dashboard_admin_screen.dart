// lib/features/dashboard/screens/dashboard_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../providers/auth_provider.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.displayName ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, name),
      drawer: AppDrawer(
        userName: name,
        isAdmin: true,
        onLogout: () async {
          await context.read<AuthProvider>().logout();
          if (!context.mounted) return;
          context.go('/login');
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, isAdmin: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI row 1
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: "Ventes aujourd'hui",
                  value: '125 000',
                  unit: 'FCFA',
                  trend: '+15%',
                  trendUp: true,
                  iconColor: AppColors.primary,
                  icon: Icons.point_of_sale_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  label: 'Ventes ce mois',
                  value: '2 850 000',
                  unit: 'FCFA',
                  trend: '+8%',
                  trendUp: true,
                  iconColor: AppColors.accent,
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'Produits en stock',
                  value: '320',
                  unit: 'articles',
                  iconColor: AppColors.success,
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  label: 'Ruptures',
                  value: '12',
                  unit: 'produits',
                  iconColor: AppColors.error,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Top produits vendus
          const _SectionTitle(title: 'Produits les plus vendus'),
          const SizedBox(height: 10),
          _TopProductItem(rank: 1, name: 'Clou 5cm', qty: '520 unités'),
          _TopProductItem(rank: 2, name: 'Ciment 50kg', qty: '120 unités'),
          _TopProductItem(rank: 3, name: 'Peinture 20L', qty: '80 unités'),
          _TopProductItem(rank: 4, name: 'Marteau', qty: '60 unités'),
          const SizedBox(height: 20),

          // Menu admin rapide
          const _SectionTitle(title: 'Administration'),
          const SizedBox(height: 10),
          _AdminMenuGrid(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Text(
            'Administrateur',
            style: TextStyle(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          tooltip: 'Déconnexion',
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            context.go('/login');
          },
        ),
      ],
    );
  }
}

// ─── KPI Card ────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? trend;
  final bool trendUp;
  final Color iconColor;
  final IconData icon;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.iconColor,
    required this.icon,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Text(unit,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              if (trend != null) ...[
                const SizedBox(width: 6),
                Text(
                  trend!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: trendUp ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Top produit ─────────────────────────────────────────────────────────────

class _TopProductItem extends StatelessWidget {
  final int rank;
  final String name;
  final String qty;

  const _TopProductItem({
    required this.rank,
    required this.name,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: rank == 1 ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            qty,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Admin menu grille ────────────────────────────────────────────────────────

class _AdminMenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuEntry(
          Icons.people_outline, 'Utilisateurs', AppColors.primary, '/users'),
      _MenuEntry(
          Icons.bar_chart_rounded, 'Rapports', AppColors.accent, '/stats'),
      _MenuEntry(
          Icons.history, 'Audit système', AppColors.textSecondary, '/audit'),
      _MenuEntry(Icons.category_outlined, 'Catalogue', AppColors.success,
          '/catalogue'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: items
          .map(
            (e) => InkWell(
              onTap: () => context.go(e.route),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(e.icon, color: e.color, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      e.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _MenuEntry(this.icon, this.label, this.color, this.route);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
