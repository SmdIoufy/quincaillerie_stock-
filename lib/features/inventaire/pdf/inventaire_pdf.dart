import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/inventaire.dart';
import '../models/ligne_inventaire.dart';

/// Génère le document PDF du rapport d'un inventaire (gains/pertes par ligne + totaux).
Future<Uint8List> genererInventairePdf(Inventaire inv) async {
  final doc = pw.Document();

  final ecartValeur = inv.valeurStockPhysique - inv.valeurStockTheorique;
  final agregat = _aggregerEcarts(inv.lignes);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        _buildEnTete(inv),
        pw.SizedBox(height: 24),
        _buildInfosInventaire(inv),
        pw.SizedBox(height: 24),
        _buildTableauLignes(inv.lignes),
        pw.SizedBox(height: 16),
        _buildTotaux(agregat, ecartValeur),
        pw.SizedBox(height: 32),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Rapport généré automatiquement',
            style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: 11,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

// ── Agrégation gains / pertes ──────────────────────────────────────────────────

class _EcartsAgreges {
  final double totalGains;
  final double totalPertes;
  final int nbGains;
  final int nbPertes;
  final int nbConformes;

  _EcartsAgreges({
    required this.totalGains,
    required this.totalPertes,
    required this.nbGains,
    required this.nbPertes,
    required this.nbConformes,
  });
}

_EcartsAgreges _aggregerEcarts(List<LigneInventaire> lignes) {
  double gains = 0;
  double pertes = 0;
  int nbGains = 0;
  int nbPertes = 0;
  int nbConformes = 0;

  for (final ligne in lignes) {
    final valeurEcart = ligne.ecart * ligne.prixAchatSnapshot;
    if (ligne.ecart > 0) {
      gains += valeurEcart;
      nbGains++;
    } else if (ligne.ecart < 0) {
      pertes += valeurEcart;
      nbPertes++;
    } else {
      nbConformes++;
    }
  }

  return _EcartsAgreges(
    totalGains: gains,
    totalPertes: pertes,
    nbGains: nbGains,
    nbPertes: nbPertes,
    nbConformes: nbConformes,
  );
}

// ── En-tête ────────────────────────────────────────────────────────────────────

pw.Widget _buildEnTete(Inventaire inv) {
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
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
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
              'RAPPORT D\'INVENTAIRE',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            inv.description ?? 'Inventaire ${inv.id.substring(0, 8)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    ],
  );
}

// ── Infos inventaire ─────────────────────────────────────────────────────────

pw.Widget _buildInfosInventaire(Inventaire inv) {
  final date = inv.date ?? inv.dateCreation;
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
        _infoItem('Statut', inv.statut),
        pw.SizedBox(width: 32),
        _infoItem('Articles comptés', '${inv.lignes.length}'),
      ],
    ),
  );
}

// ── Tableau des lignes (gains en vert, pertes en rouge) ───────────────────────

pw.Widget _buildTableauLignes(List<LigneInventaire> lignes) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'DÉTAIL PAR ARTICLE',
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
          0: const pw.FlexColumnWidth(3), // Article
          1: const pw.FixedColumnWidth(55), // Qté théo
          2: const pw.FixedColumnWidth(55), // Qté phys
          3: const pw.FixedColumnWidth(50), // Écart qté
          4: const pw.FixedColumnWidth(90), // Valeur écart
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            children: [
              _cellHeader('Article'),
              _cellHeader('Théo.', center: true),
              _cellHeader('Physique', center: true),
              _cellHeader('Écart', center: true),
              _cellHeader('Valeur', center: true),
            ],
          ),
          ...lignes.asMap().entries.map((entry) {
            final i = entry.key;
            final ligne = entry.value;
            final bg = i.isOdd ? PdfColors.grey50 : PdfColors.white;
            final valeurEcart = ligne.ecart * ligne.prixAchatSnapshot;
            final couleurEcart = ligne.ecart > 0
                ? PdfColors.orange700
                : ligne.ecart < 0
                    ? PdfColors.red700
                    : PdfColors.grey700;

            final nomArticle = [ligne.familleNom, ligne.dimension]
                .where((s) => s != null && s.isNotEmpty)
                .join(' ');

            return pw.TableRow(
              decoration: pw.BoxDecoration(color: bg),
              children: [
                _cell(nomArticle.isEmpty ? ligne.varId : nomArticle),
                _cell('${ligne.quantiteTheorique}', center: true),
                _cell('${ligne.quantitePhysique}', center: true),
                _cell(
                  '${ligne.ecart > 0 ? '+' : ''}${ligne.ecart}',
                  center: true,
                  bold: true,
                  color: couleurEcart,
                ),
                _cell(
                  '${valeurEcart > 0 ? '+' : ''}${valeurEcart.toStringAsFixed(0)} F',
                  center: true,
                  bold: true,
                  color: couleurEcart,
                ),
              ],
            );
          }),
        ],
      ),
    ],
  );
}

// ── Totaux : gains, pertes, net ────────────────────────────────────────────────

pw.Widget _buildTotaux(_EcartsAgreges agregat, double ecartValeur) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      pw.Container(
        width: 280,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: PdfColors.grey200),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            _ligneTotal(
              'Excédents (${agregat.nbGains} article${agregat.nbGains > 1 ? 's' : ''})',
              '+${agregat.totalGains.toStringAsFixed(0)} FCFA',
              color: PdfColors.orange700,
            ),
            pw.SizedBox(height: 6),
            _ligneTotal(
              'Manquants (${agregat.nbPertes} article${agregat.nbPertes > 1 ? 's' : ''})',
              '${agregat.totalPertes.toStringAsFixed(0)} FCFA',
              color: PdfColors.red700,
            ),
            pw.SizedBox(height: 6),
            _ligneTotal(
              'Conformes',
              '${agregat.nbConformes} article${agregat.nbConformes > 1 ? 's' : ''}',
              color: PdfColors.grey700,
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            _ligneTotal(
              ecartValeur == 0
                  ? 'AUCUN ÉCART'
                  : ecartValeur < 0
                      ? 'PERTE NETTE'
                      : 'EXCÉDENT NET',
              '${ecartValeur > 0 ? '+' : ''}${ecartValeur.toStringAsFixed(0)} FCFA',
              bold: true,
              fontSize: 14,
              color: ecartValeur == 0
                  ? PdfColors.green700
                  : ecartValeur < 0
                      ? PdfColors.red800
                      : PdfColors.orange800,
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

pw.Widget _cell(String text,
    {bool center = false, bool bold = false, PdfColor? color}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Text(
      text,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? PdfColors.black,
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
