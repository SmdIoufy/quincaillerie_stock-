// lib/features/dashboard/screens/dashboard_gerant_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';

class DashboardGerantScreen extends StatefulWidget {
  const DashboardGerantScreen({super.key});

  @override
  State<DashboardGerantScreen> createState() => _DashboardGerantScreenState();
}

class _DashboardGerantScreenState extends State<DashboardGerantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchAll();
    });
  }

  String _formatMontant(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.displayName ?? 'Gérant';
    final dashboard = context.watch<DashboardProvider>();
    final summary = dashboard.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, name),
      drawer: AppDrawer(
        userName: name,
        isAdmin: false,
        onLogout: () async {
          await context.read<AuthProvider>().logout();
          if (!context.mounted) return;
          context.go('/login');
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<DashboardProvider>().fetchAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SalesCard(
              montant: summary != null
                  ? '${_formatMontant(summary.totalVentesAujourdhui)} FCFA'
                  : '—',
              nombreVentes: summary?.nombreVentesAujourdhui,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatMiniCard(
                    label: 'Produits en stock',
                    value: summary != null ? '${summary.totalVariantes}' : '—',
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatMiniCard(
                    label: 'Ruptures',
                    value: summary != null ? '${summary.stockEnAlerte}' : '—',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Activité récente'),
            const SizedBox(height: 8),
            _RecentSaleItem(
                ref: 'Vente #1245',
                time: "Aujourd'hui, 10:30",
                amount: '45 000 FCFA'),
            _RecentSaleItem(
                ref: 'Vente #1244',
                time: "Aujourd'hui, 09:15",
                amount: '12 500 FCFA'),
            _RecentSaleItem(
                ref: 'Vente #1243', time: 'Hier, 16:40', amount: '8 000 FCFA'),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, isAdmin: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nouvelle vente',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, $name 👋',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            "Voici ce qui se passe aujourd'hui",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon:
              const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
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

class _SalesCard extends StatelessWidget {
  final String montant;
  final int? nombreVentes;

  const _SalesCard({required this.montant, this.nombreVentes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ventes aujourd'hui",
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const Icon(Icons.settings_outlined,
                  color: Colors.white54, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            montant,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          if (nombreVentes != null)
            Text(
              '$nombreVentes vente${nombreVentes! > 1 ? 's' : ''} aujourd\'hui',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
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

class _RecentSaleItem extends StatelessWidget {
  final String ref;
  final String time;
  final String amount;

  const _RecentSaleItem({
    required this.ref,
    required this.time,
    required this.amount,
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ref,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
