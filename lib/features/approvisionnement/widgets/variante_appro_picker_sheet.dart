// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../catalogue/models/catalogue_models.dart';
import '../../catalogue/services/catalogue_provider.dart';
import '../../catalogue/widgets/catalogue_widgets.dart';
import '../models/appro_models.dart';
import '../services/appro_provider.dart';

/// Bottom sheet de sélection d'une variante à ajouter au panier
/// d'approvisionnement. Contrairement au picker de vente, pas de blocage
/// de quantité par rapport au stock — on AJOUTE du stock, on n'en consomme pas.
class VarianteApproPickerSheet extends StatefulWidget {
  const VarianteApproPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    final approProvider = context.read<ApproProvider>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogueProvider()),
          ChangeNotifierProvider.value(value: approProvider),
        ],
        child: const VarianteApproPickerSheet(),
      ),
    );
  }

  @override
  State<VarianteApproPickerSheet> createState() =>
      _VarianteApproPickerSheetState();
}

class _VarianteApproPickerSheetState extends State<VarianteApproPickerSheet> {
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
          return _VarianteApproTile(variante: variante);
        },
      ),
    );
  }
}

class _VarianteApproTile extends StatelessWidget {
  final VarianteProduit variante;
  const _VarianteApproTile({required this.variante});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(variante.label,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        'Prix achat actuel : ${variante.prixAchatMoyen.toStringAsFixed(0)} FCFA',
      ),
      trailing: StockBadge(
        quantite: variante.quantiteDisponible,
        stockBas: variante.stockBas,
      ),
      onTap: () => _showQuantitePrixDialog(context, variante),
    );
  }

  /// Dialog qui demande quantité, prix d'achat (pré-rempli avec le
  /// prixAchatMoyen actuel mais modifiable) et remise.
  Future<void> _showQuantitePrixDialog(
      BuildContext context, VarianteProduit variante) async {
    final qteCtrl = TextEditingController(text: '1');
    final prixCtrl =
        TextEditingController(text: variante.prixAchatMoyen.toStringAsFixed(0));
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
                    Expanded(
                      child: Text(
                        'Stock actuel : ${variante.quantiteDisponible}',
                        style: TextStyle(
                            color: Colors.blue.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: qteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité reçue *',
                  suffixText: 'unité(s)',
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Minimum 1';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: prixCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prix d\'achat unitaire *',
                  suffixText: 'FCFA',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: remiseCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Remise fournisseur',
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
    final prixAchat = double.parse(prixCtrl.text);
    final remise = double.tryParse(remiseCtrl.text) ?? 0.0;

    context.read<ApproProvider>().addLigneToPanier(
          LigneApproPanier(
            varId: variante.id,
            label: variante.label,
            quantite: quantite,
            prixAchat: prixAchat,
            remise: remise,
          ),
        );

    if (context.mounted) Navigator.pop(context);
  }
}
