import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inventaire_provider.dart';

/// Chaque ligne saisie par l'utilisateur
class _LigneForm {
  String varId;
  int quantitePhysique;
  String? observation;

  _LigneForm({
    required this.varId,
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

  // Contrôleurs pour l'ajout d'une ligne
  final _varIdCtrl = TextEditingController();
  final _qteCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _descCtrl.dispose();
    _varIdCtrl.dispose();
    _qteCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _addLigne() {
    final varId = _varIdCtrl.text.trim();
    final qte = int.tryParse(_qteCtrl.text.trim()) ?? -1;

    if (varId.isEmpty || qte < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID variante et quantité requis')),
      );
      return;
    }

    setState(() {
      _lignes.add(_LigneForm(
        varId: varId,
        quantitePhysique: qte,
        observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      ));
      _varIdCtrl.clear();
      _qteCtrl.clear();
      _obsCtrl.clear();
    });
  }

  void _removeLigne(int idx) => setState(() => _lignes.removeAt(idx));

  Future<void> _submit() async {
    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ajoutez au moins une ligne'),
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
          // ── Description ──────────────────────────────────────
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Ajouter une ligne ─────────────────────────────────
          Text('Lignes de comptage',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _varIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID Variante (UUID)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _qteCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantité comptée',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _obsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Observation (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addLigne,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter la ligne'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Liste des lignes saisies ──────────────────────────
          ..._lignes.asMap().entries.map((e) => ListTile(
                leading: CircleAvatar(child: Text('${e.key + 1}')),
                title: Text(e.value.varId,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
                subtitle: Text('Qté : ${e.value.quantitePhysique}'
                    '${e.value.observation != null ? ' · ${e.value.observation}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeLigne(e.key),
                ),
              )),
        ],
      ),
    );
  }
}
