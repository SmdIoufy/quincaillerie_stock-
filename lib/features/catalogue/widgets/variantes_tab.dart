import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../../../providers/auth_provider.dart';
import '../models/catalogue_models.dart';
import '../services/catalogue_provider.dart';
import '../widgets/catalogue_widgets.dart';

class VariantesTab extends StatefulWidget {
  const VariantesTab({super.key});

  @override
  State<VariantesTab> createState() => _VariantesTabState();
}

class _VariantesTabState extends State<VariantesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().loadVariantes(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CatalogueProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Column(
      children: [
        CatalogueSearchBar(
          hint: 'Rechercher une variante…',
          onChanged: context.read<CatalogueProvider>().setVarSearch,
        ),
        Expanded(child: _buildBody(prov, isAdmin)),
      ],
    );
  }

  Widget _buildBody(CatalogueProvider prov, bool isAdmin) {
    if (prov.varStatus == CatalogueStatus.loading && prov.variantes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.varStatus == CatalogueStatus.error) {
      return CatalogueErrorState(
        message: prov.varError ?? 'Erreur',
        onRetry: () => prov.loadVariantes(reset: true),
      );
    }
    if (prov.variantes.isEmpty) {
      return const CatalogueEmptyState(
        message: 'Aucune variante trouvée',
        icon: Icons.inventory_2_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => prov.loadVariantes(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: prov.variantes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _VarianteCard(
          variante: prov.variantes[i],
          isAdmin: isAdmin,
        ),
      ),
    );
  }
}

class _VarianteCard extends StatelessWidget {
  final VarianteProduit variante;
  final bool isAdmin;

  const _VarianteCard({required this.variante, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<CatalogueProvider>();

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icône
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: Colors.teal.shade400, size: 22),
            ),
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(variante.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Badge famille
                      _InfoChip(
                        label: variante.familleNom,
                        color: Colors.indigo.shade50,
                        textColor: Colors.indigo.shade700,
                      ),
                      // Prix
                      _InfoChip(
                        label: '${variante.prixVente.toStringAsFixed(0)} FCFA',
                        color: Colors.orange.shade50,
                        textColor: Colors.orange.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  StockBadge(
                    quantite: variante.quantiteDisponible,
                    stockBas: variante.stockBas,
                  ),
                ],
              ),
            ),

            // Actions (ADMIN seulement)
            if (isAdmin)
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _showVarianteForm(context, prov, variante: variante),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () async {
                      final ok = await showDeleteConfirmDialog(
                          context, variante.label);
                      if (ok) prov.deleteVariante(variante.id);
                    },
                    tooltip: 'Désactiver',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _InfoChip(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
    );
  }
}

void showVarianteForm(BuildContext context, CatalogueProvider prov,
        {VarianteProduit? variante}) =>
    _showVarianteForm(context, prov, variante: variante);

void _showVarianteForm(BuildContext context, CatalogueProvider prov,
    {VarianteProduit? variante}) {
  final dimCtrl = TextEditingController(text: variante?.dimension);
  final epCtrl = TextEditingController(text: variante?.epaisseur);
  final prixCtrl =
      TextEditingController(text: variante?.prixVente.toStringAsFixed(0));
  final achatCtrl =
      TextEditingController(text: variante?.prixAchatMoyen.toStringAsFixed(0));
  final seuilCtrl =
      TextEditingController(text: variante?.seuilAlerte.toString() ?? '0');
  String? selectedFamId = variante?.famId;
  final formKey = GlobalKey<FormState>();
  bool saving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SingleChildScrollView(
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
                variante == null ? 'Nouvelle variante' : 'Modifier la variante',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Dropdown familles
              DropdownButtonFormField<String>(
                initialValue: selectedFamId,
                decoration: const InputDecoration(labelText: 'Famille *'),
                items: prov.familles
                    .map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.nom, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedFamId = v),
                validator: (v) => v == null ? 'Sélectionnez une famille' : null,
              ),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: dimCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Dimension', hintText: 'ex: 10mm'),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                  controller: epCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Épaisseur', hintText: 'ex: 2mm'),
                )),
              ]),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: prixCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Prix vente *', suffixText: 'FCFA'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || double.tryParse(v) == null)
                      ? 'Invalide'
                      : null,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                  controller: achatCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Prix achat', suffixText: 'FCFA'),
                  keyboardType: TextInputType.number,
                )),
              ]),
              const SizedBox(height: 12),

              TextFormField(
                controller: seuilCtrl,
                decoration:
                    const InputDecoration(labelText: 'Seuil d\'alerte stock'),
                keyboardType: TextInputType.number,
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
                            'Fam_id': selectedFamId,
                            'dimension': dimCtrl.text.trim().isEmpty
                                ? null
                                : dimCtrl.text.trim(),
                            'epaisseur': epCtrl.text.trim().isEmpty
                                ? null
                                : epCtrl.text.trim(),
                            'prixVente': double.parse(prixCtrl.text.trim()),
                            'prixAchatMoyen':
                                double.tryParse(achatCtrl.text.trim()) ?? 0,
                            'seuilAlerte':
                                int.tryParse(seuilCtrl.text.trim()) ?? 0,
                          };
                          final ok = variante == null
                              ? await prov.createVariante(data)
                              : await prov.updateVariante(variante.id, data);
                          if (ok && ctx.mounted) Navigator.pop(ctx);
                          setState(() => saving = false);
                        },
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(variante == null ? 'Créer' : 'Enregistrer',
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
