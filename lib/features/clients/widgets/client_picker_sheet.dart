import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/client_models.dart';
import '../services/client_provider.dart';

class ClientPickerSheet extends StatefulWidget {
  const ClientPickerSheet({super.key});

  static Future<Client?> show(BuildContext context) {
    return showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider(
        create: (_) => ClientProvider(),
        child: const ClientPickerSheet(),
      ),
    );
  }

  @override
  State<ClientPickerSheet> createState() => _ClientPickerSheetState();
}

class _ClientPickerSheetState extends State<ClientPickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients(reset: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClientProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.50,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          // ── En-tête ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sélectionner un client',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Recherche ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() {});
                context.read<ClientProvider>().setSearch(v.isEmpty ? null : v);
              },
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                          context.read<ClientProvider>().setSearch(null);
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

          // ── Corps (liste) ─────────────────────────────────────────
          Expanded(child: _buildBody(prov, scrollController)),

          // ── Bouton fixe "Nouveau client" ──────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Nouveau client'),
                  onPressed: () => _showNouveauClientForm(context, prov),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ClientProvider prov, ScrollController scrollController) {
    if (prov.listStatus == ClientStatus.loading && prov.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.listStatus == ClientStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(prov.listError ?? 'Erreur', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => prov.loadClients(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (prov.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Aucun client trouvé',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez le bouton ci-dessous pour en créer un.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notif) {
        final atBottom =
            notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200;
        if (atBottom && prov.listStatus != ClientStatus.loading) {
          prov.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: prov.clients.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final client = prov.clients[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                client.initiales,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(client.nom,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: client.telephone != null && client.telephone!.isNotEmpty
                ? Text(client.telephone!)
                : client.email != null && client.email!.isNotEmpty
                    ? Text(client.email!)
                    : null,
            onTap: () => Navigator.pop(context, client),
          );
        },
      ),
    );
  }

  // ── Formulaire de création rapide ─────────────────────────────
  void _showNouveauClientForm(BuildContext context, ClientProvider prov) {
    final nomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
              // En-tête formulaire
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nouveau client',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nom (obligatoire)
              TextFormField(
                controller: nomCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return 'Minimum 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Téléphone (optionnel)
              TextFormField(
                controller: telCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Email (optionnel)
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !v.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bouton créer
              StatefulBuilder(
                builder: (ctx, setSt) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: prov.saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            final ok = await prov.createClient(
                              nom: nomCtrl.text.trim(),
                              telephone: telCtrl.text.trim().isEmpty
                                  ? null
                                  : telCtrl.text.trim(),
                              email: emailCtrl.text.trim().isEmpty
                                  ? null
                                  : emailCtrl.text.trim(),
                            );

                            if (!ctx.mounted) return;

                            if (ok) {
                              // Ferme le formulaire
                              Navigator.pop(ctx);
                              // Le client créé est en tête de prov.clients
                              // On le sélectionne et on ferme le picker
                              final nouveau = prov.clients.firstOrNull;
                              if (nouveau != null && context.mounted) {
                                Navigator.pop(context, nouveau);
                              }
                            } else {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      prov.saveError ?? 'Erreur de création'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: prov.saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Créer et sélectionner',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
