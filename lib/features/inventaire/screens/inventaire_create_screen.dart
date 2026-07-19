import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inventaire_provider.dart';
import 'inventaire_variante_picker_sheet.dart';

/// Chaque ligne comptée par l'utilisateur (sélectionnée via le picker)
class _LigneForm {
  final String varId;
  final String label;
  final int quantitePhysique;
  final String? observation;

  _LigneForm({
    required this.varId,
    required this.label,
    required this.quantitePhysique,
    this.observation,
  });

  Map<String, dynamic> toJson() => {
        'Var_id': varId,
        'quantitePhysique': quantitePhysique,
        if (observation != null && observation!.isNotEmpty)
          'observation': observation,
      };
}

class InventaireCreateScreen extends StatefulWidget {
  const InventaireCreateScreen({super.key});

  @override
  State<InventaireCreateScreen> createState() => _InventaireCreateScreenState();
}

class _InventaireCreateScreenState extends State<InventaireCreateScreen> {
  final _descCtrl = TextEditingController();
  final List<_LigneForm> _lignes = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    final result = await InventaireVariantePickerSheet.show(context);
    if (result == null) return;

    setState(() {
      final index = _lignes.indexWhere((l) => l.varId == result.varId);
      final nouvelleLigne = _LigneForm(
        varId: result.varId,
        label: result.label,
        quantitePhysique: result.quantitePhysique,
        observation: result.observation,
      );

      if (index != -1) {
        // Variante déjà comptée : on remplace la ligne existante
        _lignes[index] = nouvelleLigne;
      } else {
        _lignes.add(nouvelleLigne);
      }
    });
  }

  void _removeLigne(int idx) => setState(() => _lignes.removeAt(idx));

  Future<void> _submit() async {
    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ajoutez au moins un article compté'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final p = context.read<InventaireProvider>();
    final ok = await p.create(
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      lignes: _lignes.map((l) => l.toJson()).toList(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(p.error ?? 'Erreur création'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel inventaire'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Créer',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Articles comptés (${_lignes.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openPicker,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un article'),
            ),
          ),
          const SizedBox(height: 16),
          if (_lignes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Aucun article compté pour l\'instant',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ..._lignes.asMap().entries.map((e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${e.key + 1}')),
                    title: Text(e.value.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Qté comptée : ${e.value.quantitePhysique}'
                        '${e.value.observation != null ? ' · ${e.value.observation}' : ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeLigne(e.key),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
