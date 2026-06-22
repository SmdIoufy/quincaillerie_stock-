import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inventaire_provider.dart';
import '../widgets/ligne_inventaire_tile.dart';

class InventaireDetailScreen extends StatefulWidget {
  final String inventaireId;
  const InventaireDetailScreen({super.key, required this.inventaireId});

  @override
  State<InventaireDetailScreen> createState() => _InventaireDetailScreenState();
}

class _InventaireDetailScreenState extends State<InventaireDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventaireProvider>().loadDetail(widget.inventaireId);
    });
  }

  Future<void> _changeStatut(String statut) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(statut == 'VALIDE'
            ? 'Valider l\'inventaire'
            : 'Annuler l\'inventaire'),
        content: Text(statut == 'VALIDE'
            ? 'Les ajustements de stock seront appliqués. Cette action est irréversible.'
            : 'L\'inventaire sera annulé définitivement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: statut == 'ANNULE'
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(statut == 'VALIDE' ? 'Valider' : 'Annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final p = context.read<InventaireProvider>();
    final ok = await p.updateStatut(widget.inventaireId, statut);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Statut mis à jour' : (p.error ?? 'Erreur')),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventaireProvider>();

    if (provider.isLoadingDetail) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.detailError != null || provider.selected == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inventaire')),
        body: Center(child: Text(provider.detailError ?? 'Introuvable')),
      );
    }

    final inv = provider.selected!;
    final isEnCours = inv.statut == 'EN_COURS';

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.description ?? 'Inventaire'),
        actions: [
          if (isEnCours) ...[
            TextButton.icon(
              onPressed: () => _changeStatut('ANNULE'),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
            TextButton.icon(
              onPressed: () => _changeStatut('VALIDE'),
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label:
                  const Text('Valider', style: TextStyle(color: Colors.green)),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Résumé ────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row('Statut', inv.statut),
                  _Row('Qté théorique', '${inv.totalQuantiteTheorique}'),
                  _Row('Qté comptée', '${inv.totalQuantitePhysique}'),
                  _Row(
                    'Écart total',
                    '${inv.ecartTotal > 0 ? '+' : ''}${inv.ecartTotal}',
                    valueColor: inv.ecartTotal == 0
                        ? Colors.green
                        : inv.ecartTotal > 0
                            ? Colors.orange
                            : Colors.red,
                  ),
                  _Row('Valeur théorique',
                      '${inv.valeurStockTheorique.toStringAsFixed(0)} F'),
                  _Row('Valeur physique',
                      '${inv.valeurStockPhysique.toStringAsFixed(0)} F'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Lignes (${inv.lignes.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...inv.lignes.map((l) => LigneInventaireTile(ligne: l)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value,
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: valueColor)),
          ],
        ),
      );
}
