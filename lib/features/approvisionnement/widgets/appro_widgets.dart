import 'package:flutter/material.dart';
import '../../../core/constants/app-colors.dart';
import '../models/appro_models.dart';

// ─── BADGE STATUT APPRO ───────────────────────────────────────

class StatutApproBadge extends StatelessWidget {
  final StatutAppro statut;
  const StatutApproBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg, icon) = switch (statut) {
      StatutAppro.brouillon => (
          Colors.orange.shade50,
          Colors.orange.shade200,
          Colors.orange.shade700,
          Icons.edit_note,
        ),
      StatutAppro.validee => (
          Colors.green.shade50,
          Colors.green.shade200,
          Colors.green.shade700,
          Icons.check_circle_outline,
        ),
      StatutAppro.annulee => (
          Colors.red.shade50,
          Colors.red.shade200,
          Colors.red.shade700,
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            statut.label,
            style:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}

// ─── BARRE DE FILTRE PAR STATUT ───────────────────────────────────

class ApproFilterBar extends StatelessWidget {
  final String? statutFilter;
  final ValueChanged<String?> onStatutChanged;

  const ApproFilterBar({
    super.key,
    required this.statutFilter,
    required this.onStatutChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <String?, String>{
      null: 'Tous',
      'BROUILLON': 'Brouillon',
      'VALIDEE': 'Validé',
      'ANNULEE': 'Annulé',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: options.entries.map((e) {
            final selected = statutFilter == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) => onStatutChanged(e.key),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                backgroundColor: AppColors.surface,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── ÉTAT VIDE ────────────────────────────────────────────────

class ApproEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const ApproEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.local_shipping_outlined,
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

class ApproErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ApproErrorState({
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

// ─── DIALOGS DE CONFIRMATION (valider / annuler) ─────────────────

Future<bool> showValiderApproDialog(
    BuildContext context, String reference) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Valider l\'approvisionnement ?'),
          content: Text(
            'L\'approvisionnement "$reference" sera validé : le stock sera '
            'crédité et le prix d\'achat moyen recalculé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Valider', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> showAnnulerApproDialog(
    BuildContext context, String reference, bool stockSeraDebite) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Annuler l\'approvisionnement ?'),
          content: Text(
            stockSeraDebite
                ? 'L\'approvisionnement "$reference" sera annulé et le stock '
                    'précédemment crédité sera débité.'
                : 'L\'approvisionnement "$reference" sera annulé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Retour'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Annuler', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ??
      false;
}
