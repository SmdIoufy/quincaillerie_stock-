import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inventaire_provider.dart';
import '../models/inventaire.dart';
import 'inventaire_detail_screen.dart';
import 'inventaire_create_screen.dart';

class InventaireListScreen extends StatefulWidget {
  const InventaireListScreen({super.key});

  @override
  State<InventaireListScreen> createState() => _InventaireListScreenState();
}

class _InventaireListScreenState extends State<InventaireListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventaireProvider>().loadInventaires(reset: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<InventaireProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _statutColor(String statut) => switch (statut) {
        'EN_COURS' => Colors.orange,
        'VALIDE' => Colors.green,
        'ANNULE' => Colors.red,
        _ => Colors.grey,
      };

  String _statutLabel(String statut) => switch (statut) {
        'EN_COURS' => 'En cours',
        'VALIDE' => 'Validé',
        'ANNULE' => 'Annulé',
        _ => statut,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventaireProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaires'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => provider.setStatutFilter(v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Tous')),
              const PopupMenuItem(value: 'EN_COURS', child: Text('En cours')),
              const PopupMenuItem(value: 'VALIDE', child: Text('Validé')),
              const PopupMenuItem(value: 'ANNULE', child: Text('Annulé')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final p = context.read<InventaireProvider>();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: p,
                child: const InventaireCreateScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Builder(builder: (_) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && provider.inventaires.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.error!,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.loadInventaires(reset: true),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }
        if (provider.inventaires.isEmpty) {
          return const Center(child: Text('Aucun inventaire'));
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              provider.inventaires.length + (provider.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (i == provider.inventaires.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final inv = provider.inventaires[i];
            return _InventaireCard(
              inventaire: inv,
              statutColor: _statutColor(inv.statut),
              statutLabel: _statutLabel(inv.statut),
              onTap: () async {
                final p = context.read<InventaireProvider>();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: p,
                      child: InventaireDetailScreen(inventaireId: inv.id),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}

class _InventaireCard extends StatelessWidget {
  final Inventaire inventaire;
  final Color statutColor;
  final String statutLabel;
  final VoidCallback onTap;

  const _InventaireCard({
    required this.inventaire,
    required this.statutColor,
    required this.statutLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inv = inventaire;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          inv.description ?? 'Inventaire du ${_formatDate(inv.dateCreation)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Écart : ${inv.ecartTotal > 0 ? '+' : ''}${inv.ecartTotal} '
          '· ${inv.totalQuantitePhysique} unités comptées',
        ),
        trailing: Chip(
          label: Text(statutLabel,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: statutColor,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
