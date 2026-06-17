import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../providers/auth_provider.dart';
import '../services/catalogue_provider.dart';
import '../widgets/categories_tab.dart';
import '../widgets/familles_tab.dart';
import '../widgets/variantes_tab.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = context.read<AuthProvider>().isAdmin;
    // ADMIN → 3 onglets | GERANT → 2 onglets
    _tabController = TabController(
      length: _isAdmin ? 3 : 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatalogueProvider(),
      child: _CatalogueView(
        tabController: _tabController,
        isAdmin: _isAdmin,
      ),
    );
  }
}

class _CatalogueView extends StatelessWidget {
  final TabController tabController;
  final bool isAdmin;

  const _CatalogueView({
    required this.tabController,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CatalogueProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catalogue'),
        centerTitle: false,
        elevation: 0,
        bottom: TabBar(
          controller: tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: [
            if (isAdmin)
              const Tab(
                  icon: Icon(Icons.category_outlined), text: 'Catégories'),
            const Tab(icon: Icon(Icons.folder_outlined), text: 'Familles'),
            const Tab(
                icon: Icon(Icons.inventory_2_outlined), text: 'Variantes'),
          ],
        ),
      ),

      // FAB dynamique selon l'onglet actif (ADMIN seulement)
      floatingActionButton: isAdmin
          ? AnimatedBuilder(
              animation: tabController,
              builder: (_, __) {
                final idx = tabController.index;
                final labels = ['Catégorie', 'Famille', 'Variante'];
                final icons = [Icons.category, Icons.folder, Icons.inventory_2];
                return FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  icon: Icon(icons[idx], color: Colors.white),
                  label: Text('Ajouter ${labels[idx]}',
                      style: const TextStyle(color: Colors.white)),
                  onPressed: () => _onFabPressed(context, prov, idx),
                );
              },
            )
          : null,

      body: TabBarView(
        controller: tabController,
        children: [
          if (isAdmin) const CategoriesTab(),
          const FamillesTab(),
          const VariantesTab(),
        ],
      ),
    );
  }

  void _onFabPressed(BuildContext context, CatalogueProvider prov, int idx) {
    if (!isAdmin) return;
    switch (idx) {
      case 0:
        // Onglet Catégories
        showCategorieForm(context, prov);
        break;
      case 1:
        // Onglet Familles — charger les catégories si pas encore chargées
        if (prov.categories.isEmpty) prov.loadCategories(reset: true);
        showFamilleForm(context, prov);
        break;
      case 2:
        // Onglet Variantes — charger les familles si pas encore chargées
        if (prov.familles.isEmpty) prov.loadFamilles(reset: true);
        showVarianteForm(context, prov);
        break;
    }
  }
}
