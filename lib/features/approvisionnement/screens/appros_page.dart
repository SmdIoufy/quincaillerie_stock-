import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../services/appro_provider.dart';
import 'appros_list_tab.dart';
import 'appro_create_screen.dart';

/// Page principale du module Approvisionnement.
/// ADMIN et GERANT ont les mêmes droits (cf. requireRole('admin', 'gerant')
/// sans distinction côté backend).
class ApprosPage extends StatelessWidget {
  const ApprosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApproProvider(),
      child: const _ApprosView(),
    );
  }
}

class _ApprosView extends StatelessWidget {
  const _ApprosView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Approvisionnements'),
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Nouvel appro', style: TextStyle(color: Colors.white)),
        onPressed: () {
          final approProvider = context.read<ApproProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: approProvider,
                child: const ApproCreateScreen(),
              ),
            ),
          );
        },
      ),
      body: const ApprosListTab(),
    );
  }
}
