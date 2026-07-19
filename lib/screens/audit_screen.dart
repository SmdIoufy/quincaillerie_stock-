import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audit_activite_model.dart';
import '../models/mouvement_stock_model.dart';
import '../providers/audit_provider.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<AuditProvider>();
    final now = DateTime.now();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: (provider.dateDebut != null && provider.dateFin != null)
          ? DateTimeRange(start: provider.dateDebut!, end: provider.dateFin!)
          : null,
    );

    if (range != null) {
      provider.setDateRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activités'),
            Tab(text: 'Mouvements de stock'),
          ],
        ),
        actions: [
          Consumer<AuditProvider>(
            builder: (context, provider, _) {
              final hasFilter = provider.dateDebut != null;
              return IconButton(
                icon: Icon(
                    hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined),
                tooltip: 'Filtrer par date',
                onPressed: _pickDateRange,
              );
            },
          ),
          Consumer<AuditProvider>(
            builder: (context, provider, _) {
              if (provider.dateDebut == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Réinitialiser le filtre',
                onPressed: () => provider.setDateRange(null, null),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActivitesTab(),
          _MouvementsTab(),
        ],
      ),
    );
  }
}

class _ActivitesTab extends StatelessWidget {
  const _ActivitesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingActivites && provider.activites.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null && provider.activites.isEmpty) {
          return Center(child: Text('Erreur : ${provider.errorMessage}'));
        }
        if (provider.activites.isEmpty) {
          return const Center(child: Text('Aucune activité'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchActivites,
          child: ListView.separated(
            itemCount: provider.activites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _ActiviteTile(item: provider.activites[index]),
          ),
        );
      },
    );
  }
}

class _ActiviteTile extends StatelessWidget {
  final AuditActiviteModel item;
  const _ActiviteTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(item.typeEntite[0])),
      title: Text(item.reference ?? item.typeEntite),
      subtitle: Text(
        '${item.typeEntite} · ${item.statut ?? ''}'
        '${item.clientOuFournisseur != null ? ' · ${item.clientOuFournisseur}' : ''}',
      ),
      trailing: Text(
        '${item.dateCreation.day}/${item.dateCreation.month}/${item.dateCreation.year}',
      ),
    );
  }
}

class _MouvementsTab extends StatelessWidget {
  const _MouvementsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingMouvements && provider.mouvements.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null && provider.mouvements.isEmpty) {
          return Center(child: Text('Erreur : ${provider.errorMessage}'));
        }
        if (provider.mouvements.isEmpty) {
          return const Center(child: Text('Aucun mouvement'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchMouvements,
          child: ListView.separated(
            itemCount: provider.mouvements.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _MouvementTile(item: provider.mouvements[index]),
          ),
        );
      },
    );
  }
}

class _MouvementTile extends StatelessWidget {
  final MouvementStockModel item;
  const _MouvementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isEntree = item.quantiteApres >= item.quantiteAvant;
    return ListTile(
      leading: Icon(
        isEntree ? Icons.arrow_downward : Icons.arrow_upward,
        color: isEntree ? Colors.green : Colors.red,
      ),
      title: Text('${item.familleNom ?? ''} ${item.dimension ?? ''}'.trim()),
      subtitle: Text(
        '${item.typeMouvement} · ${item.quantiteAvant} → ${item.quantiteApres}'
        '${item.sourceReference != null ? ' · ${item.sourceReference}' : ''}',
      ),
      trailing: Text(
        '${item.date.day}/${item.date.month}/${item.date.year}',
      ),
    );
  }
}
