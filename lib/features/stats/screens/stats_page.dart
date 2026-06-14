import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../providers/auth_provider.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Statistiques')),
      bottomNavigationBar: AppBottomNav(currentIndex: 3, isAdmin: isAdmin),
      body: Center(
        child: Text(isAdmin
            ? 'Statistiques complètes (admin)'
            : 'Statistiques de base'),
      ),
    );
  }
}
