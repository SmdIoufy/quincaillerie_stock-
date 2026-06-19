import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app-colors.dart';
import '../models/vente_models.dart';
import '../services/vente_provider.dart';
import 'vente_recu_pdf.dart';

/// Écran d'aperçu du reçu d'une vente.
/// Accessible depuis :
///   - Le détail d'une vente (bouton "Voir le reçu")
///   - Automatiquement après validation d'une vente
class VenteRecuScreen extends StatefulWidget {
  final String venteId;

  const VenteRecuScreen({super.key, required this.venteId});

  @override
  State<VenteRecuScreen> createState() => _VenteRecuScreenState();
}

class _VenteRecuScreenState extends State<VenteRecuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenteProvider>().loadRecu(widget.venteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VenteProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reçu de vente'),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Bouton partager / exporter PDF
          if (prov.recuStatus == VenteStatus.success && prov.recu != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Partager le PDF',
              onPressed: () => _partagerPdf(context, prov.recu!),
            ),
        ],
      ),
      body: _buildBody(prov),
    );
  }

  Widget _buildBody(VenteProvider prov) {
    if (prov.recuStatus == VenteStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.recuStatus == VenteStatus.error) {
      return Center(child: Text(prov.recuError ?? 'Erreur inconnue'));
    }

    final recu = prov.recu;
    if (recu == null) return const Center(child: Text('Reçu null'));

    return PdfPreview(
      build: (format) async {
        try {
          final bytes = await genererRecuPdf(recu);
          return Uint8List.fromList(bytes);
        } catch (e, stack) {
          debugPrint('ERREUR PDF: $e');
          debugPrint('$stack');
          rethrow;
        }
      },
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowPrinting: true,
      allowSharing: true,
      pdfFileName: 'recu_${recu.vente.reference}.pdf',
    );
  }

  Future<void> _partagerPdf(BuildContext context, RecuVente recu) async {
    try {
      // Génère les bytes et ouvre le share sheet natif
      await Printing.sharePdf(
        bytes: Uint8List.fromList(await genererRecuPdf(recu)),
        filename: 'recu_${recu.vente.reference}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur export PDF : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
