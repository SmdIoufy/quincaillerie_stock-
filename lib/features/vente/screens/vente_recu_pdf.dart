import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/vente_models.dart';

/// Génère le document PDF d'un reçu de vente.
/// Retourne les bytes du PDF prêts à être partagés ou sauvegardés.
Future<Uint8List> genererRecuPdf(RecuVente recu) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ── En-tête ──────────────────────────────────────────────
          _buildEnTete(recu),
          pw.SizedBox(height: 24),

          // ── Infos vente ──────────────────────────────────────────
          _buildInfosVente(recu),
          pw.SizedBox(height: 24),

          // ── Infos client ─────────────────────────────────────────
          _buildInfosClient(recu),
          pw.SizedBox(height: 24),

          // ── Tableau des lignes ───────────────────────────────────
          _buildTableauLignes(recu),
          pw.SizedBox(height: 16),

          // ── Totaux ───────────────────────────────────────────────
          _buildTotaux(recu),
          pw.SizedBox(height: 32),

          // ── Pied de page ─────────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Merci pour votre achat !',
              style: pw.TextStyle(
                color: PdfColors.grey600,
                fontSize: 11,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

// ── En-tête : nom de l'app + référence ────────────────────────────────────────

pw.Widget _buildEnTete(RecuVente recu) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'QUINCAILLERIE STOCK',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Gestion de stock & ventes',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey800,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'REÇU DE VENTE',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            recu.vente.reference,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ],
  );
}

// ── Infos vente (date, statut) ─────────────────────────────────────────────────

pw.Widget _buildInfosVente(RecuVente recu) {
  final date = recu.vente.date;
  final dateStr =
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      children: [
        _infoItem('Date', dateStr),
        pw.SizedBox(width: 32),
        _infoItem('Statut', recu.vente.statut.label.toUpperCase()),
        pw.SizedBox(width: 32),
        _infoItem('Référence', recu.vente.reference),
      ],
    ),
  );
}

// ── Infos client ───────────────────────────────────────────────────────────────

pw.Widget _buildInfosClient(RecuVente recu) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'CLIENT',
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
          color: PdfColors.grey600,
          letterSpacing: 1.2,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              recu.vente.clientNom ?? 'Client inconnu',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (recu.clientTelephone != null &&
                recu.clientTelephone!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text('Tél : ${recu.clientTelephone}',
                  style: const pw.TextStyle(fontSize: 11)),
            ],
            if (recu.clientEmail != null && recu.clientEmail!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text('Email : ${recu.clientEmail}',
                  style: const pw.TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    ],
  );
}

// ── Tableau des lignes ─────────────────────────────────────────────────────────

pw.Widget _buildTableauLignes(RecuVente recu) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'ARTICLES',
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
          color: PdfColors.grey600,
          letterSpacing: 1.2,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey200),
        columnWidths: {
          0: const pw.FlexColumnWidth(4), // Article
          1: const pw.FixedColumnWidth(60), // Qté
          2: const pw.FixedColumnWidth(80), // Prix unit.
          3: const pw.FixedColumnWidth(60), // Remise
          4: const pw.FixedColumnWidth(90), // Total
        },
        children: [
          // En-tête tableau
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            children: [
              _cellHeader('Article'),
              _cellHeader('Qté', center: true),
              _cellHeader('Prix unit.', center: true),
              _cellHeader('Remise', center: true),
              _cellHeader('Total', center: true),
            ],
          ),
          // Lignes
          ...recu.lignes.asMap().entries.map((entry) {
            final i = entry.key;
            final ligne = entry.value;
            final bg = i.isOdd ? PdfColors.grey50 : PdfColors.white;
            return pw.TableRow(
              decoration: pw.BoxDecoration(color: bg),
              children: [
                _cell(ligne.label),
                _cell('${ligne.quantite}', center: true),
                _cell('${ligne.prixUnitaire.toStringAsFixed(0)} F',
                    center: true),
                _cell(
                  ligne.remise > 0
                      ? '${ligne.remise.toStringAsFixed(0)}%'
                      : '-',
                  center: true,
                ),
                _cell('${ligne.montantCalcule.toStringAsFixed(0)} F',
                    center: true, bold: true),
              ],
            );
          }),
        ],
      ),
    ],
  );
}

// ── Totaux ─────────────────────────────────────────────────────────────────────

pw.Widget _buildTotaux(RecuVente recu) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      pw.Container(
        width: 260,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: PdfColors.grey200),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            _ligneTotal(
                'Sous-total', '${recu.totalBrut.toStringAsFixed(0)} FCFA'),
            if (recu.totalRemise > 0) ...[
              pw.SizedBox(height: 4),
              _ligneTotal(
                  'Remises', '- ${recu.totalRemise.toStringAsFixed(0)} FCFA',
                  color: PdfColors.red700),
            ],
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            _ligneTotal(
              'TOTAL NET',
              '${recu.totalNet.toStringAsFixed(0)} FCFA',
              bold: true,
              fontSize: 14,
            ),
          ],
        ),
      ),
    ],
  );
}

// ── Helpers ────────────────────────────────────────────────────────────────────

pw.Widget _infoItem(String label, String value) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      pw.SizedBox(height: 2),
      pw.Text(value,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    ],
  );
}

pw.Widget _cellHeader(String text, {bool center = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Text(
      text,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

pw.Widget _cell(String text, {bool center = false, bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Text(
      text,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

pw.Widget _ligneTotal(String label, String valeur,
    {bool bold = false,
    double fontSize = 11,
    PdfColor color = PdfColors.black}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
      pw.Text(
        valeur,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    ],
  );
}
