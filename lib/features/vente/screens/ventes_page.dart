import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../services/vente_provider.dart';
import '../widgets/ventes_list_tab.dart';
import 'vente_create_screen.dart';

/// Page principale du module Vente.
/// Contrairement au Catalogue, ADMIN et GERANT ont exactement les mêmes
/// droits ici (cf. requireRole('admin', 'gerant') sans distinction côté
/// backend) — donc pas de logique conditionnelle sur le rôle, pas d'onglets
/// multiples, un seul FAB visible pour tous.
class VentesPage extends StatelessWidget {
  const VentesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VenteProvider(),
      child: const _VentesView(),
    );
  }
}

class _VentesView extends StatelessWidget {
  const _VentesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ventes'),
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Nouvelle vente', style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<VenteProvider>(),
              child: const VenteCreateScreen(),
            ),
          ),
        ),
      ),
      body: const VentesListTab(),
    );
  }
}
