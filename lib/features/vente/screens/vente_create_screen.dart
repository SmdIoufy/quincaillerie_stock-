import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../clients/widgets/client_picker_sheet.dart';
import '../widgets/variante_picker_sheet.dart';
import '../models/vente_models.dart';
import '../services/vente_provider.dart';

class VenteCreateScreen extends StatefulWidget {
  const VenteCreateScreen({super.key});

  @override
  State<VenteCreateScreen> createState() => _VenteCreateScreenState();
}

class _VenteCreateScreenState extends State<VenteCreateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenteProvider>().startNewPanier();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VenteProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle vente'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                _ClientSelector(prov: prov),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Articles',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: () => VariantePickerSheet.show(context),
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

// ── Sélecteur client ──────────────────────────────────────────────────────────

class _ClientSelector extends StatelessWidget {
  final VenteProvider prov;
  const _ClientSelector({required this.prov});

  @override
  Widget build(BuildContext context) {
    final clientChoisi = prov.panierClientNom != null;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: clientChoisi
              ? AppColors.primary.withOpacity(0.12)
              : Colors.grey.shade200,
          child: Icon(
            clientChoisi ? Icons.person : Icons.person_outline,
            size: 18,
            color: clientChoisi ? AppColors.primary : Colors.grey.shade500,
          ),
        ),
        title: Text(
          prov.panierClientNom ?? 'Sélectionner un client *',
          style: TextStyle(
            color: clientChoisi ? null : Colors.grey.shade600,
            fontWeight: clientChoisi ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: clientChoisi
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                tooltip: 'Retirer le client',
                onPressed: () => prov.setPanierClient('', ''),
              )
            : const Icon(Icons.chevron_right),
        onTap: () async {
          final client = await ClientPickerSheet.show(context);
          if (client != null && context.mounted) {
            context
                .read<VenteProvider>()
                .setPanierClient(client.id, client.nom);
          }
        },
      ),
    );
  }
}

// ── Carte d'une ligne du panier ───────────────────────────────────────────────

class _PanierLigneCard extends StatelessWidget {
  final LignePanier ligne;
  const _PanierLigneCard({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<VenteProvider>();

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
                  onPressed: ligne.quantite < ligne.stockDisponible
                      ? () => prov.updateLignePanier(ligne.varId,
                          quantite: ligne.quantite + 1)
                      : null,
                ),
                const Spacer(),
                Text(
                  '${ligne.montantNet.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            if (ligne.quantite >= ligne.stockDisponible)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Stock max atteint (${ligne.stockDisponible})',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Barre du bas (total + bouton créer) ──────────────────────────────────────

// ── Barre du bas (total + bouton créer) ──────────────────────────────────────
// Remplace uniquement la classe _BottomBar dans vente_create_screen.dart

class _BottomBar extends StatelessWidget {
  final VenteProvider prov;
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
            offset: const Offset(0, -2),
          )
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
                  : const Text('Créer la vente',
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
        title: const Text('Créer la vente'),
        content: const Text(
          'Voulez-vous enregistrer cette vente en brouillon '
          'ou la valider directement ?\n\n'
          'La validation décrémente immédiatement le stock.',
        ),
        actions: [
          // Annuler — ferme le dialog sans rien faire
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Annuler'),
          ),
          // Brouillon
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'BROUILLON'),
            child: const Text('Brouillon'),
          ),
          // Valider directement
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () => Navigator.pop(ctx, 'VALIDEE'),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // L'utilisateur a fermé sans choisir
    if (choix == null) return;
    if (!context.mounted) return;

    // Étape 1 — créer la vente en BROUILLON (toujours)
    final ok = await context.read<VenteProvider>().submitPanier();
    if (!ok || !context.mounted) return;

    // Étape 2 — si l'utilisateur a choisi "Valider", on patch immédiatement
    if (choix == 'VALIDEE') {
      final vente = context.read<VenteProvider>().ventes.firstOrNull;
      if (vente != null && context.mounted) {
        await context.read<VenteProvider>().validerVente(vente.id);
      }
    }

    if (context.mounted) Navigator.pop(context);
  }
}
