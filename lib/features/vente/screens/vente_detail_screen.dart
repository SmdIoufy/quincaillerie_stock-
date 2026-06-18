import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/vente_models.dart';
import '../services/vente_provider.dart';
import '../widgets/vente_widgets.dart';

class VenteDetailScreen extends StatefulWidget {
  final String venteId;
  const VenteDetailScreen({super.key, required this.venteId});

  @override
  State<VenteDetailScreen> createState() => _VenteDetailScreenState();
}

class _VenteDetailScreenState extends State<VenteDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenteProvider>().loadVenteDetail(widget.venteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VenteProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de la vente'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _buildBody(context, prov),
    );
  }

  Widget _buildBody(BuildContext context, VenteProvider prov) {
    if (prov.detailStatus == VenteStatus.loading &&
        prov.selectedVente == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.detailStatus == VenteStatus.error) {
      return VenteErrorState(
        message: prov.detailError ?? 'Erreur',
        onRetry: () => prov.loadVenteDetail(widget.venteId),
      );
    }

    final vente = prov.selectedVente;
    if (vente == null) {
      return const VenteEmptyState(message: 'Vente introuvable');
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadVenteDetail(widget.venteId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _Header(vente: vente),
          const SizedBox(height: 20),
          Text('Articles', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...vente.lignes.map((l) => _LigneCard(ligne: l)),
          const SizedBox(height: 20),
          _TotalCard(vente: vente),
          const SizedBox(height: 24),
          _ActionsRow(vente: vente),
          if (prov.statutActionError != null) ...[
            const SizedBox(height: 12),
            Text(
              prov.statutActionError!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Vente vente;
  const _Header({required this.vente});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vente.reference,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                StatutVenteBadge(statut: vente.statut),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(vente.clientNom ?? 'Client inconnu'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${vente.date.day.toString().padLeft(2, '0')}/'
                    '${vente.date.month.toString().padLeft(2, '0')}/'
                    '${vente.date.year}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneCard extends StatelessWidget {
  final LigneVente ligne;
  const _LigneCard({required this.ligne});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(ligne.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${ligne.quantite} × ${ligne.prixUnitaire.toStringAsFixed(0)} FCFA'
          '${ligne.remise > 0 ? ' (-${ligne.remise.toStringAsFixed(0)}%)' : ''}',
        ),
        trailing: Text(
          '${ligne.montantCalcule.toStringAsFixed(0)} FCFA',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final Vente vente;
  const _TotalCard({required this.vente});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(
            '${vente.montantTotal.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Actions disponibles selon le statut. ADMIN et GERANT voient exactement
/// les mêmes boutons — aucune restriction de rôle sur ces actions
/// (cf. requireRole('admin', 'gerant') appliqué globalement côté backend).
class _ActionsRow extends StatelessWidget {
  final Vente vente;
  const _ActionsRow({required this.vente});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VenteProvider>();

    if (vente.estTerminale) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (vente.peutValider)
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: prov.updatingStatut
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label:
                  const Text('Valider', style: TextStyle(color: Colors.white)),
              onPressed: prov.updatingStatut
                  ? null
                  : () async {
                      final ok = await showValiderConfirmDialog(
                          context, vente.reference);
                      if (ok) await prov.validerVente(vente.id);
                    },
            ),
          ),
        if (vente.peutValider && vente.peutAnnuler) const SizedBox(width: 12),
        if (vente.peutAnnuler)
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Annuler'),
              onPressed: prov.updatingStatut
                  ? null
                  : () async {
                      // Le stock n'est restitué que si la vente était VALIDEE
                      // (rien n'a été décrémenté pour une vente encore BROUILLON).
                      final stockSeraRestitue =
                          vente.statut == StatutVente.validee;
                      final ok = await showAnnulerConfirmDialog(
                        context,
                        vente.reference,
                        stockSeraRestitue,
                      );
                      if (ok) await prov.annulerVente(vente.id);
                    },
            ),
          ),
      ],
    );
  }
}
