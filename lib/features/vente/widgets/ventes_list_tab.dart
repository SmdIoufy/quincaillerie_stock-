import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/vente_models.dart';
import '../services/vente_provider.dart';
import '../widgets/vente_widgets.dart';
import '../screens/vente_detail_screen.dart';

class VentesListTab extends StatefulWidget {
  const VentesListTab({super.key});

  @override
  State<VentesListTab> createState() => _VentesListTabState();
}

class _VentesListTabState extends State<VentesListTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenteProvider>().loadVentes(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VenteProvider>();

    return Column(
      children: [
        VenteFilterBar(
          statutFilter: prov.statutFilter,
          onStatutChanged: context.read<VenteProvider>().setStatutFilter,
        ),
        Expanded(child: _buildBody(prov)),
      ],
    );
  }

  Widget _buildBody(VenteProvider prov) {
    if (prov.listStatus == VenteStatus.loading && prov.ventes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.listStatus == VenteStatus.error) {
      return VenteErrorState(
        message: prov.listError ?? 'Erreur',
        onRetry: () => prov.loadVentes(reset: true),
      );
    }
    if (prov.ventes.isEmpty) {
      return const VenteEmptyState(message: 'Aucune vente trouvée');
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadVentes(reset: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200) {
            prov.loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: prov.ventes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) => _VenteCard(vente: prov.ventes[i]),
        ),
      ),
    );
  }
}

class _VenteCard extends StatelessWidget {
  final Vente vente;
  const _VenteCard({required this.vente});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
        ),
        title: Text(vente.reference,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          vente.clientNom ?? 'Client inconnu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${vente.montantTotal.toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            StatutVenteBadge(statut: vente.statut),
          ],
        ),
        onTap: () {
          final venteProvider = context.read<VenteProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: venteProvider,
                child: VenteDetailScreen(venteId: vente.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
