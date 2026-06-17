import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/catalogue_models.dart';
import '../services/catalogue_provider.dart';
import '../widgets/catalogue_widgets.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().loadCategories(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CatalogueProvider>();

    return Column(
      children: [
        CatalogueSearchBar(
          hint: 'Rechercher une catégorie…',
          onChanged: context.read<CatalogueProvider>().setCatSearch,
        ),
        Expanded(child: _buildBody(prov)),
      ],
    );
  }

  Widget _buildBody(CatalogueProvider prov) {
    if (prov.catStatus == CatalogueStatus.loading && prov.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.catStatus == CatalogueStatus.error) {
      return CatalogueErrorState(
        message: prov.catError ?? 'Erreur',
        onRetry: () => prov.loadCategories(reset: true),
      );
    }
    if (prov.categories.isEmpty) {
      return const CatalogueEmptyState(
        message: 'Aucune catégorie trouvée',
        icon: Icons.category_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadCategories(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: prov.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _CategorieCard(cat: prov.categories[i]),
      ),
    );
  }
}

class _CategorieCard extends StatelessWidget {
  final Categorie cat;
  const _CategorieCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<CatalogueProvider>();

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Text(
            cat.nom.substring(0, 1).toUpperCase(),
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title:
            Text(cat.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: cat.description != null && cat.description!.isNotEmpty
            ? Text(cat.description!,
                maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showForm(context, prov, cat: cat),
              tooltip: 'Modifier',
            ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () async {
                final ok = await showDeleteConfirmDialog(context, cat.nom);
                if (ok) prov.deleteCategorie(cat.id);
              },
              tooltip: 'Désactiver',
            ),
          ],
        ),
      ),
    );
  }
}

void showCategorieForm(BuildContext context, CatalogueProvider prov,
        {Categorie? cat}) =>
    _showForm(context, prov, cat: cat);

void _showForm(BuildContext context, CatalogueProvider prov, {Categorie? cat}) {
  final nomCtrl = TextEditingController(text: cat?.nom);
  final descCtrl = TextEditingController(text: cat?.description);
  final formKey = GlobalKey<FormState>();
  bool saving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat == null ? 'Nouvelle catégorie' : 'Modifier la catégorie',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Minimum 2 caractères'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => saving = true);
                          final data = {
                            'nom': nomCtrl.text.trim(),
                            'description': descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                          };
                          final ok = cat == null
                              ? await prov.createCategorie(data)
                              : await prov.updateCategorie(cat.id, data);
                          if (ok && ctx.mounted) Navigator.pop(ctx);
                          setState(() => saving = false);
                        },
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(cat == null ? 'Créer' : 'Enregistrer',
                          style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
