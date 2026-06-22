import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../fournisseur/widgets/fournisseur_picker_sheet.dart';
import '../models/appro_models.dart';
import '../services/appro_provider.dart';
import '../widgets/variante_appro_picker_sheet.dart';

class ApproCreateScreen extends StatefulWidget {
  const ApproCreateScreen({super.key});

  @override
  State<ApproCreateScreen> createState() => _ApproCreateScreenState();
}

class _ApproCreateScreenState extends State<ApproCreateScreen> {
  final _fraisCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApproProvider>().startNewPanier();
    });
  }

  @override
  void dispose() {
    _fraisCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ApproProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvel approvisionnement'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                _FournisseurSelector(prov: prov),
                const SizedBox(height: 16),

                // Frais
                TextField(
                  controller: _fraisCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Frais (transport, douane...)',
                    suffixText: 'FCFA',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    context.read<ApproProvider>().setPanierFrais(n);
                  },
                ),
                const SizedBox(height: 12),

                // Note interne
                TextField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Note interne (optionnel)',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) =>
                      context.read<ApproProvider>().setPanierNoteInterne(v),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Articles',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: () => VarianteApproPickerSheet.show(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (prov.panierLignes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Aucun article ajouté',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...prov.panierLignes.map((l) => _PanierLigneCard(ligne: l)),
              ],
            ),
          ),
          _BottomBar(prov: prov),
        ],
      ),
    );
  }
}

// ── Sélecteur fournisseur ───────────────────────────────────────────────────

class _FournisseurSelector extends StatelessWidget {
  final ApproProvider prov;
  const _FournisseurSelector({required this.prov});

  @override
  Widget build(BuildContext context) {
    final fournisseurChoisi = prov.panierFournisseurNom != null;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: fournisseurChoisi
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.grey.shade200,
          child: Icon(
            fournisseurChoisi
                ? Icons.local_shipping
                : Icons.local_shipping_outlined,
            size: 18,
            color: fournisseurChoisi ? AppColors.primary : Colors.grey.shade500,
          ),
        ),
        title: Text(
          prov.panierFournisseurNom ?? 'Sélectionner un fournisseur *',
          style: TextStyle(
            color: fournisseurChoisi ? null : Colors.grey.shade600,
            fontWeight: fournisseurChoisi ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: fournisseurChoisi
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                tooltip: 'Retirer le fournisseur',
                onPressed: () => prov.setPanierFournisseur('', ''),
              )
            : const Icon(Icons.chevron_right),
        onTap: () async {
          final fournisseur = await FournisseurPickerSheet.show(context);
          if (fournisseur != null && context.mounted) {
            context
                .read<ApproProvider>()
                .setPanierFournisseur(fournisseur.id, fournisseur.nom);
          }
        },
      ),
    );
  }
}

// ── Carte d'une ligne du panier ──────────────────────────────────────────────

class _PanierLigneCard extends StatelessWidget {
  final LigneApproPanier ligne;
  const _PanierLigneCard({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<ApproProvider>();

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(ligne.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => prov.removeLignePanier(ligne.varId),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: ligne.quantite > 1
                      ? () => prov.updateLignePanier(ligne.varId,
                          quantite: ligne.quantite - 1)
                      : null,
                ),
                Text('${ligne.quantite}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => prov.updateLignePanier(ligne.varId,
                      quantite: ligne.quantite + 1),
                ),
                const Spacer(),
                Text(
                  '${ligne.montantNet.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${ligne.prixAchat.toStringAsFixed(0)} FCFA / unité'
                '${ligne.remise > 0 ? ' (-${ligne.remise.toStringAsFixed(0)}%)' : ''}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barre du bas ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final ApproProvider prov;
  const _BottomBar({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prov.createError != null) ...[
            Text(prov.createError!,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${prov.panierTotal.toStringAsFixed(0)} FCFA',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed:
                  prov.creating ? null : () => _showChoixStatutDialog(context),
              child: prov.creating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Créer l\'approvisionnement',
                      style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChoixStatutDialog(BuildContext context) async {
    final choix = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Créer l\'approvisionnement'),
        content: const Text(
          'Voulez-vous enregistrer en brouillon ou valider directement ?\n\n'
          'La validation crédite immédiatement le stock et recalcule '
          'le prix d\'achat moyen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Annuler'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'BROUILLON'),
            child: const Text('Brouillon'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, 'VALIDEE'),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (choix == null) return;
    if (!context.mounted) return;

    final ok = await context.read<ApproProvider>().submitPanier();
    if (!ok || !context.mounted) return;

    if (choix == 'VALIDEE') {
      final appro =
          context.read<ApproProvider>().approvisionnements.firstOrNull;
      if (appro != null && context.mounted) {
        await context.read<ApproProvider>().validerAppro(appro.id);
      }
    }

    if (context.mounted) Navigator.pop(context);
  }
}
