import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../providers/auth_provider.dart';

class VentesPage extends StatelessWidget {
  const VentesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ventes')),
      bottomNavigationBar: AppBottomNav(currentIndex: 1, isAdmin: isAdmin),
      body: const Center(child: Text('Liste des ventes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
