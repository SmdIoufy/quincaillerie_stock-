import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/appro_models.dart';
import '../services/appro_provider.dart';
import '../widgets/appro_widgets.dart';

class ApproDetailScreen extends StatefulWidget {
  final String approId;
  const ApproDetailScreen({super.key, required this.approId});

  @override
  State<ApproDetailScreen> createState() => _ApproDetailScreenState();
}

class _ApproDetailScreenState extends State<ApproDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApproProvider>().loadApproDetail(widget.approId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ApproProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail approvisionnement'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _buildBody(context, prov),
    );
  }

  Widget _buildBody(BuildContext context, ApproProvider prov) {
    if (prov.detailStatus == ApproStatus.loading &&
        prov.selectedAppro == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.detailStatus == ApproStatus.error) {
      return ApproErrorState(
        message: prov.detailError ?? 'Erreur',
        onRetry: () => prov.loadApproDetail(widget.approId),
      );
    }

    final appro = prov.selectedAppro;
    if (appro == null) {
      return const ApproEmptyState(message: 'Approvisionnement introuvable');
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadApproDetail(widget.approId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _Header(appro: appro),
          const SizedBox(height: 20),
          Text('Articles', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...appro.lignes.map((l) => _LigneCard(ligne: l)),
          const SizedBox(height: 20),
          _TotalCard(appro: appro),
          const SizedBox(height: 24),
          _ActionsRow(appro: appro),
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

// ── En-tête ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Approvisionnement appro;
  const _Header({required this.appro});

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
                Text(appro.reference,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                StatutApproBadge(statut: appro.statut),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(appro.fournisseurNom ?? 'Fournisseur inconnu'),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.event_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text('${appro.date.day.toString().padLeft(2, '0')}/'
                  '${appro.date.month.toString().padLeft(2, '0')}/'
                  '${appro.date.year}'),
            ]),
            if (appro.noteInterne != null && appro.noteInterne!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appro.noteInterne!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Ligne article ─────────────────────────────────────────────────────────────

class _LigneCard extends StatelessWidget {
  final LigneAppro ligne;
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
          '${ligne.quantite} × ${ligne.prixAchat.toStringAsFixed(0)} FCFA'
          '${ligne.remise > 0 ? ' (-${ligne.remise.toStringAsFixed(0)}%)' : ''}',
        ),
        trailing: Text(
          '${ligne.montantNet.toStringAsFixed(0)} FCFA',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Total ─────────────────────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final Approvisionnement appro;
  const _TotalCard({required this.appro});

  @override
  Widget build(BuildContext context) {
    final sousTotal = appro.lignes.fold(0.0, (sum, l) => sum + l.montantNet);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sous-total articles'),
              Text('${sousTotal.toStringAsFixed(0)} FCFA'),
            ],
          ),
          if (appro.frais > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frais'),
                Text('${appro.frais.toStringAsFixed(0)} FCFA'),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text(
                '${appro.montantTotal.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Actions valider / annuler ─────────────────────────────────────────────────

class _ActionsRow extends StatelessWidget {
  final Approvisionnement appro;
  const _ActionsRow({required this.appro});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ApproProvider>();

    if (appro.estTerminale) return const SizedBox.shrink();

    return Row(
      children: [
        if (appro.peutValider)
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
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check, color: Colors.white),
              label:
                  const Text('Valider', style: TextStyle(color: Colors.white)),
              onPressed: prov.updatingStatut
                  ? null
                  : () async {
                      final ok = await showValiderApproDialog(
                          context, appro.reference);
                      if (ok) await prov.validerAppro(appro.id);
                    },
            ),
          ),
        if (appro.peutValider && appro.peutAnnuler) const SizedBox(width: 12),
        if (appro.peutAnnuler)
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
                      final stockSeraDebite =
                          appro.statut == StatutAppro.validee;
                      final ok = await showAnnulerApproDialog(
                          context, appro.reference, stockSeraDebite);
                      if (ok) await prov.annulerAppro(appro.id);
                    },
            ),
          ),
      ],
    );
  }
}
