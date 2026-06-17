import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../providers/auth_provider.dart';
import '../models/catalogue_models.dart';
import '../services/catalogue_provider.dart';
import '../widgets/catalogue_widgets.dart';

class FamillesTab extends StatefulWidget {
  const FamillesTab({super.key});

  @override
  State<FamillesTab> createState() => _FamillesTabState();
}

class _FamillesTabState extends State<FamillesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().loadFamilles(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CatalogueProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Column(
      children: [
        CatalogueSearchBar(
          hint: 'Rechercher une famille…',
          onChanged: context.read<CatalogueProvider>().setFamSearch,
        ),
        Expanded(child: _buildBody(prov, isAdmin)),
      ],
    );
  }

  Widget _buildBody(CatalogueProvider prov, bool isAdmin) {
    if (prov.famStatus == CatalogueStatus.loading && prov.familles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.famStatus == CatalogueStatus.error) {
      return CatalogueErrorState(
        message: prov.famError ?? 'Erreur',
        onRetry: () => prov.loadFamilles(reset: true),
      );
    }
    if (prov.familles.isEmpty) {
      return const CatalogueEmptyState(
        message: 'Aucune famille trouvée',
        icon: Icons.folder_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadFamilles(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: prov.familles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _FamilleCard(
          famille: prov.familles[i],
          isAdmin: isAdmin,
        ),
      ),
    );
  }
}

class _FamilleCard extends StatelessWidget {
  final FamilleProduit famille;
  final bool isAdmin;

  const _FamilleCard({required this.famille, required this.isAdmin});

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
          backgroundColor: Colors.indigo.shade50,
          child: Icon(Icons.folder_outlined,
              color: Colors.indigo.shade400, size: 20),
        ),
        title: Text(famille.nom,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge catégorie
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                famille.categorieNom,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (famille.uniteMesure != null && famille.uniteMesure!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text('Unité : ${famille.uniteMesure}',
                    style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _showFamilleForm(context, prov, famille: famille),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () async {
                      final ok =
                          await showDeleteConfirmDialog(context, famille.nom);
                      if (ok) prov.deleteFamille(famille.id);
                    },
                    tooltip: 'Désactiver',
                  ),
                ],
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

void showFamilleForm(BuildContext context, CatalogueProvider prov,
        {FamilleProduit? famille}) =>
    _showFamilleForm(context, prov, famille: famille);

void _showFamilleForm(BuildContext context, CatalogueProvider prov,
    {FamilleProduit? famille}) {
  final nomCtrl = TextEditingController(text: famille?.nom);
  final descCtrl = TextEditingController(text: famille?.description);
  final uniteCtrl = TextEditingController(text: famille?.uniteMesure);
  String? selectedCatId = famille?.catId;
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
                famille == null ? 'Nouvelle famille' : 'Modifier la famille',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Dropdown catégories
              DropdownButtonFormField<String>(
                initialValue: selectedCatId,
                decoration: const InputDecoration(labelText: 'Catégorie *'),
                items: prov.categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nom),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedCatId = v),
                validator: (v) =>
                    v == null ? 'Sélectionnez une catégorie' : null,
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 12),

              TextFormField(
                controller: uniteCtrl,
                decoration: const InputDecoration(
                    labelText: 'Unité de mesure', hintText: 'ex: kg, m, pièce'),
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
                            'Cat_id': selectedCatId,
                            'description': descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                            'uniteMesure': uniteCtrl.text.trim().isEmpty
                                ? null
                                : uniteCtrl.text.trim(),
                          };
                          final ok = famille == null
                              ? await prov.createFamille(data)
                              : await prov.updateFamille(famille.id, data);
                          if (ok && ctx.mounted) Navigator.pop(ctx);
                          setState(() => saving = false);
                        },
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(famille == null ? 'Créer' : 'Enregistrer',
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
