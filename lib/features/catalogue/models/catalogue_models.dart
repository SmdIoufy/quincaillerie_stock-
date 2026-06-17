// ─────────────────────────────────────────────
// MODÈLES CATALOGUE
// ─────────────────────────────────────────────

class Categorie {
  final String id;
  final String nom;
  final String? description;
  final bool actif;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;

  const Categorie({
    required this.id,
    required this.nom,
    this.description,
    required this.actif,
    required this.dateCreation,
    required this.dateModification,
    required this.version,
  });

  factory Categorie.fromJson(Map<String, dynamic> j) => Categorie(
        id: j['id'] as String,
        nom: j['nom'] as String,
        description: j['description'] as String?,
        actif: j['actif'] as bool? ?? true,
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        version: j['version'] as int? ?? 0,
      );
}

class FamilleProduit {
  final String id;
  final String catId;
  final String nom;
  final String? description;
  final String? uniteMesure;
  final bool actif;
  final String categorieNom;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;

  const FamilleProduit({
    required this.id,
    required this.catId,
    required this.nom,
    this.description,
    this.uniteMesure,
    required this.actif,
    required this.categorieNom,
    required this.dateCreation,
    required this.dateModification,
    required this.version,
  });

  factory FamilleProduit.fromJson(Map<String, dynamic> j) => FamilleProduit(
        id: j['id'] as String,
        catId: j['Cat_id'] as String,
        nom: j['nom'] as String,
        description: j['description'] as String?,
        uniteMesure: j['uniteMesure'] as String?,
        actif: j['actif'] as bool? ?? true,
        categorieNom: j['categorieNom'] as String? ?? '',
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        version: j['version'] as int? ?? 0,
      );
}

class VarianteProduit {
  final String id;
  final String famId;
  final String stoId;
  final String? dimension;
  final String? epaisseur;
  final double prixVente;
  final double prixAchatMoyen;
  final int seuilAlerte;
  final bool actif;
  final String familleNom;
  final int quantiteDisponible;
  final int quantiteReservee;
  final int seuilMinimum;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;

  const VarianteProduit({
    required this.id,
    required this.famId,
    required this.stoId,
    this.dimension,
    this.epaisseur,
    required this.prixVente,
    required this.prixAchatMoyen,
    required this.seuilAlerte,
    required this.actif,
    required this.familleNom,
    required this.quantiteDisponible,
    required this.quantiteReservee,
    required this.seuilMinimum,
    required this.dateCreation,
    required this.dateModification,
    required this.version,
  });

  factory VarianteProduit.fromJson(Map<String, dynamic> j) => VarianteProduit(
        id: j['id'] as String,
        famId: j['Fam_id'] as String,
        stoId: j['Sto_id'] as String,
        dimension: j['dimension'] as String?,
        epaisseur: j['epaisseur'] as String?,
        prixVente: double.parse(j['prixVente'].toString()),
        prixAchatMoyen: double.parse(j['prixAchatMoyen'].toString()),
        seuilAlerte: j['seuilAlerte'] as int? ?? 0,
        actif: j['actif'] as bool? ?? true,
        familleNom: j['familleNom'] as String? ?? '',
        quantiteDisponible: j['quantiteDisponible'] as int? ?? 0,
        quantiteReservee: j['quantiteReservee'] as int? ?? 0,
        seuilMinimum: j['seuilMinimum'] as int? ?? 0,
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        version: j['version'] as int? ?? 0,
      );

  String get label {
    final parts = [familleNom, dimension, epaisseur]
        .where((e) => e != null && e.isNotEmpty)
        .join(' · ');
    return parts.isEmpty ? 'Variante' : parts;
  }

  bool get stockBas => quantiteDisponible <= seuilAlerte;
}

class PaginatedMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginatedMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginatedMeta.fromJson(Map<String, dynamic> j) => PaginatedMeta(
        page: j['page'] as int,
        limit: j['limit'] as int,
        total: j['total'] as int,
        totalPages: j['totalPages'] as int,
      );
}
