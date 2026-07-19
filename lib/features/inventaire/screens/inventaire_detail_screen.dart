import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../pdf/inventaire_pdf.dart';
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
    final ecartValeur = inv.valeurStockPhysique - inv.valeurStockTheorique;
    final agregat = _aggregerEcarts(inv.lignes);

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.description ?? 'Inventaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exporter en PDF',
            onPressed: () async {
              final bytes = await genererInventairePdf(inv);
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'inventaire_${inv.id.substring(0, 8)}.pdf',
              );
            },
          ),
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
          // (bandeau perte/excédent global déjà présent)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Détail des écarts',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Excédents (${agregat.nbGains} article${agregat.nbGains > 1 ? 's' : ''})',
                          style: const TextStyle(color: Colors.grey)),
                      Text(
                        '+${agregat.totalGains.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Manquants (${agregat.nbPertes} article${agregat.nbPertes > 1 ? 's' : ''})',
                          style: const TextStyle(color: Colors.grey)),
                      Text(
                        '${agregat.totalPertes.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Conformes', style: TextStyle(color: Colors.grey)),
                      Text(
                          '${agregat.nbConformes} article${agregat.nbConformes > 1 ? 's' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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

// Ajout utilitaire (hors classe _InventaireDetailScreenState)
class _EcartsAgreges {
  final double totalGains;
  final double totalPertes;
  final int nbGains;
  final int nbPertes;
  final int nbConformes;

  _EcartsAgreges({
    required this.totalGains,
    required this.totalPertes,
    required this.nbGains,
    required this.nbPertes,
    required this.nbConformes,
  });
}

_EcartsAgreges _aggregerEcarts(List<dynamic> lignes) {
  double gains = 0;
  double pertes = 0;
  int nbGains = 0;
  int nbPertes = 0;
  int nbConformes = 0;

  for (final ligne in lignes) {
    final valeurEcart = ligne.ecart * ligne.prixAchatSnapshot;
    if (ligne.ecart > 0) {
      gains += valeurEcart;
      nbGains++;
    } else if (ligne.ecart < 0) {
      pertes += valeurEcart; // déjà négatif
      nbPertes++;
    } else {
      nbConformes++;
    }
  }

  return _EcartsAgreges(
    totalGains: gains,
    totalPertes: pertes,
    nbGains: nbGains,
    nbPertes: nbPertes,
    nbConformes: nbConformes,
  );
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
