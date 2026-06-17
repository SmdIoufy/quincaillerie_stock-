import 'package:flutter/material.dart';
import '../../../core/constants/app-colors.dart';

// ─── BARRE DE RECHERCHE ───────────────────────────────────────

class CatalogueSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const CatalogueSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<CatalogueSearchBar> createState() => _CatalogueSearchBarState();
}

class _CatalogueSearchBarState extends State<CatalogueSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
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
    );
  }
}

// ─── ÉTAT VIDE ────────────────────────────────────────────────

class CatalogueEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const CatalogueEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── ÉTAT ERREUR ──────────────────────────────────────────────

class CatalogueErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CatalogueErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DIALOG CONFIRMATION SUPPRESSION ─────────────────────────

Future<bool> showDeleteConfirmDialog(BuildContext context, String nom) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Désactiver ?'),
          content: Text('Voulez-vous désactiver "$nom" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Désactiver',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ??
      false;
}

// ─── CHIP BADGE STOCK ─────────────────────────────────────────

class StockBadge extends StatelessWidget {
  final int quantite;
  final bool stockBas;

  const StockBadge({super.key, required this.quantite, required this.stockBas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: stockBas ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stockBas ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stockBas ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 13,
            color: stockBas ? Colors.red.shade600 : Colors.green.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            '$quantite',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: stockBas ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
