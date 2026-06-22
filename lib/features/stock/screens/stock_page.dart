import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../catalogue/models/catalogue_models.dart';
import '../../catalogue/services/catalogue_provider.dart';
import '../../catalogue/widgets/catalogue_widgets.dart';
import '../../approvisionnement/services/appro_provider.dart';
import '../../approvisionnement/screens/appro_create_screen.dart';

/// Page Stock — vue d'ensemble du stock de chaque variante.
/// Réutilise CatalogueProvider.variantes (quantiteDisponible, seuilAlerte,
/// stockBas déjà présents). Accessible à tout le monde (ADMIN et GERANT).
/// Aucun endpoint Stock dédié côté backend — le stock est géré exclusivement
/// via les MouvementStock générés par Vente/Approvisionnement/Inventaire.
class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatalogueProvider(),
      child: const _StockView(),
    );
  }
}

class _StockView extends StatefulWidget {
  const _StockView();

  @override
  State<_StockView> createState() => _StockViewState();
}

class _StockViewState extends State<_StockView> {
  bool _filtreStockBasUniquement = false;
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

    final variantesAffichees = _filtreStockBasUniquement
        ? prov.variantes.where((v) => v.stockBas).toList()
        : prov.variantes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stock'),
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label:
            const Text('Approvisionner', style: TextStyle(color: Colors.white)),
        onPressed: () => _ouvrirNouvelAppro(context),
      ),
      body: Column(
        children: [
          // ── Recherche ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

          // ── Filtre stock bas ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Stock bas uniquement'),
                  selected: _filtreStockBasUniquement,
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: _filtreStockBasUniquement
                        ? Colors.white
                        : Colors.orange.shade600,
                  ),
                  selectedColor: Colors.orange.shade600,
                  labelStyle: TextStyle(
                    color: _filtreStockBasUniquement
                        ? Colors.white
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (v) =>
                      setState(() => _filtreStockBasUniquement = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Liste ────────────────────────────────────────────────
          Expanded(child: _buildBody(prov, variantesAffichees)),
        ],
      ),
    );
  }

  Widget _buildBody(
      CatalogueProvider prov, List<VarianteProduit> variantesAffichees) {
    if (prov.varStatus == CatalogueStatus.loading && prov.variantes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.varStatus == CatalogueStatus.error) {
      return CatalogueErrorState(
        message: prov.varError ?? 'Erreur',
        onRetry: () => prov.loadVariantes(reset: true),
      );
    }

    if (variantesAffichees.isEmpty) {
      return CatalogueEmptyState(
        message: _filtreStockBasUniquement
            ? 'Aucun article en stock bas'
            : 'Aucun article trouvé',
        icon: _filtreStockBasUniquement
            ? Icons.check_circle_outline
            : Icons.inventory_2_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadVariantes(reset: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          final atBottom =
              notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200;
          final hasMore =
              prov.varMeta != null && prov.varPage < prov.varMeta!.totalPages;
          if (atBottom &&
              hasMore &&
              prov.varStatus != CatalogueStatus.loading) {
            prov.varPage += 1;
            prov.loadVariantes();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: variantesAffichees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) => _StockCard(variante: variantesAffichees[i]),
        ),
      ),
    );
  }

  void _ouvrirNouvelAppro(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ApproProvider(),
          child: const ApproCreateScreen(),
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final VarianteProduit variante;
  const _StockCard({required this.variante});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: variante.stockBas
              ? Colors.red.shade50
              : AppColors.primary.withValues(alpha: 0.12),
          child: Icon(
            variante.stockBas
                ? Icons.warning_amber_rounded
                : Icons.inventory_2_outlined,
            color: variante.stockBas ? Colors.red.shade600 : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(variante.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Seuil alerte : ${variante.seuilAlerte}'
          '${variante.quantiteReservee > 0 ? ' · Réservé : ${variante.quantiteReservee}' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: StockBadge(
          quantite: variante.quantiteDisponible,
          stockBas: variante.stockBas,
        ),
      ),
    );
  }
}
