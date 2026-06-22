import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/appro_models.dart';
import '../services/appro_provider.dart';
import '../widgets/appro_widgets.dart';

import '../screens/appro_detail_screen.dart';

class ApprosListTab extends StatefulWidget {
  const ApprosListTab({super.key});

  @override
  State<ApprosListTab> createState() => _ApprosListTabState();
}

class _ApprosListTabState extends State<ApprosListTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApproProvider>().loadApprovisionnements(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ApproProvider>();

    return Column(
      children: [
        ApproFilterBar(
          statutFilter: prov.statutFilter,
          onStatutChanged: context.read<ApproProvider>().setStatutFilter,
        ),
        Expanded(child: _buildBody(prov)),
      ],
    );
  }

  Widget _buildBody(ApproProvider prov) {
    if (prov.listStatus == ApproStatus.loading &&
        prov.approvisionnements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.listStatus == ApproStatus.error) {
      return ApproErrorState(
        message: prov.listError ?? 'Erreur',
        onRetry: () => prov.loadApprovisionnements(reset: true),
      );
    }
    if (prov.approvisionnements.isEmpty) {
      return const ApproEmptyState(message: 'Aucun approvisionnement trouvé');
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadApprovisionnements(reset: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200) {
            prov.loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: prov.approvisionnements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) =>
              _ApproCard(appro: prov.approvisionnements[i]),
        ),
      ),
    );
  }
}

class _ApproCard extends StatelessWidget {
  final Approvisionnement appro;
  const _ApproCard({required this.appro});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(Icons.local_shipping_outlined,
              color: AppColors.primary, size: 20),
        ),
        title: Text(appro.reference,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          appro.fournisseurNom ?? 'Fournisseur inconnu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${appro.montantTotal.toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            StatutApproBadge(statut: appro.statut),
          ],
        ),
        onTap: () {
          final approProvider = context.read<ApproProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: approProvider,
                child: ApproDetailScreen(approId: appro.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
