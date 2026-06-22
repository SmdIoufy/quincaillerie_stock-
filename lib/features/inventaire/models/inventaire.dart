import 'ligne_inventaire.dart';

class Inventaire {
  final String id;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;
  final DateTime? date;
  final String? description;
  final int totalQuantiteTheorique;
  final int totalQuantitePhysique;
  final int ecartTotal;
  final double valeurStockPhysique;
  final double valeurStockTheorique;
  final String statut;
  final List<LigneInventaire> lignes;

  const Inventaire({
    required this.id,
    required this.dateCreation,
    required this.dateModification,
    required this.version,
    this.date,
    this.description,
    required this.totalQuantiteTheorique,
    required this.totalQuantitePhysique,
    required this.ecartTotal,
    required this.valeurStockPhysique,
    required this.valeurStockTheorique,
    required this.statut,
    required this.lignes,
  });

  factory Inventaire.fromJson(Map<String, dynamic> j) => Inventaire(
        id: j['id'] as String,
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        version: (j['version'] is int) ? j['version'] as int : 0,
        date: j['date'] != null ? DateTime.parse(j['date'] as String) : null,
        description: j['description'] as String?,
        totalQuantiteTheorique: j['totalQuantiteTheorique'] as int? ?? 0,
        totalQuantitePhysique: j['totalQuantitePhysique'] as int? ?? 0,
        ecartTotal: j['ecartTotal'] as int? ?? 0,
        valeurStockPhysique:
            double.parse((j['valeurStockPhysique'] ?? '0').toString()),
        valeurStockTheorique:
            double.parse((j['valeurStockTheorique'] ?? '0').toString()),
        statut: j['statut'] as String,
        lignes: (j['lignes'] as List<dynamic>? ?? [])
            .map((e) => LigneInventaire.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
