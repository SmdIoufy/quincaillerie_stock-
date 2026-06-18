import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../catalogue/models/catalogue_models.dart';
import '../../catalogue/services/catalogue_provider.dart';
import '../../catalogue/widgets/catalogue_widgets.dart';
import '../models/vente_models.dart';
import '../services/vente_provider.dart';

/// Bottom sheet de sélection d'une variante à ajouter au panier.
/// Réutilise directement [CatalogueProvider.variantes].
class VariantePickerSheet extends StatefulWidget {
  const VariantePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    // On capture VenteProvider AVANT d'ouvrir le sheet (contexte parent valide)
    final venteProvider = context.read<VenteProvider>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogueProvider()),
          // Réinjecte VenteProvider capturé depuis le parent
          ChangeNotifierProvider.value(value: venteProvider),
        ],
        child: const VariantePickerSheet(),
      ),
    );
  }

  @override
  State<VariantePickerSheet> createState() => _VariantePickerSheetState();
}

class _VariantePickerSheetState extends State<VariantePickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().loadVariantes(reset: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CatalogueProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Ajouter un article',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() {});
                context.read<CatalogueProvider>().setVarSearch(v);
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un article…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                          context.read<CatalogueProvider>().setVarSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(prov, scrollController)),
        ],
      ),
    );
  }

  Widget _buildBody(CatalogueProvider prov, ScrollController scrollController) {
    if (prov.varStatus == CatalogueStatus.loading && prov.variantes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.varStatus == CatalogueStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(prov.varError ?? 'Erreur', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => prov.loadVariantes(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (prov.variantes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Aucun article trouvé',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notif) {
        final atBottom =
            notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200;
        final hasMore =
            prov.varMeta != null && prov.varPage < prov.varMeta!.totalPages;
        if (atBottom && hasMore && prov.varStatus != CatalogueStatus.loading) {
          prov.varPage += 1;
          prov.loadVariantes();
        }
        return false;
      },
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: prov.variantes.length +
            (prov.varStatus == CatalogueStatus.loading ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          if (i == prov.variantes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final variante = prov.variantes[i];
          return _VarianteTile(variante: variante);
        },
      ),
    );
  }
}

// ── Tuile variante ────────────────────────────────────────────────────────────

class _VarianteTile extends StatelessWidget {
  final VarianteProduit variante;
  const _VarianteTile({required this.variante});

  @override
  Widget build(BuildContext context) {
    final indisponible = variante.quantiteDisponible <= 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      enabled: !indisponible,
      title: Text(variante.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: indisponible ? Colors.grey.shade400 : null,
          )),
      subtitle: Text('${variante.prixVente.toStringAsFixed(0)} FCFA',
          style: TextStyle(color: indisponible ? Colors.grey.shade400 : null)),
      trailing: StockBadge(
        quantite: variante.quantiteDisponible,
        stockBas: variante.stockBas,
      ),
      onTap: indisponible ? null : () => _showQuantiteDialog(context, variante),
    );
  }

  /// Dialog qui demande quantité + remise avant d'ajouter au panier.
  Future<void> _showQuantiteDialog(
      BuildContext context, VarianteProduit variante) async {
    final qteCtrl = TextEditingController(text: '1');
    final remiseCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(variante.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info stock disponible
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text('Stock disponible : ${variante.quantiteDisponible}',
                        style: TextStyle(
                            color: Colors.blue.shade700, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quantité
              TextFormField(
                controller: qteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité *',
                  suffixText: 'unité(s)',
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Minimum 1';
                  if (n > variante.quantiteDisponible) {
                    return 'Max ${variante.quantiteDisponible}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Remise
              TextFormField(
                controller: remiseCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Remise',
                  suffixText: '%',
                  hintText: '0',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0 || n > 100) return '0 – 100 %';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    if (!context.mounted) return;

    final quantite = int.parse(qteCtrl.text);
    final remise = double.tryParse(remiseCtrl.text) ?? 0.0;

    final erreur = context.read<VenteProvider>().addLigneToPanier(
          LignePanier(
            varId: variante.id,
            label: variante.label,
            quantite: quantite,
            prixUnitaire: variante.prixVente,
            remise: remise,
            stockDisponible: variante.quantiteDisponible,
          ),
        );

    if (erreur != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erreur), backgroundColor: Colors.red),
      );
    } else if (context.mounted) {
      // Ferme le sheet après ajout réussi
      Navigator.pop(context);
    }
  }
}
