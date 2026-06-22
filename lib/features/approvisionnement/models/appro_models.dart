// ─────────────────────────────────────────────
// MODÈLES APPROVISIONNEMENT
// ─────────────────────────────────────────────

/// Statuts possibles d'un approvisionnement.
/// Cycle : BROUILLON → VALIDEE → ANNULEE (annulation possible même après VALIDEE,
/// avec débit du stock crédité précédemment — symétrique à la vente).
/// BROUILLON → ANNULEE directement ne touche pas au stock.
/// ANNULEE est un état terminal.
enum StatutAppro { brouillon, validee, annulee }

StatutAppro statutApproFromString(String? v) {
  switch (v) {
    case 'VALIDEE':
      return StatutAppro.validee;
    case 'ANNULEE':
      return StatutAppro.annulee;
    case 'BROUILLON':
    default:
      return StatutAppro.brouillon;
  }
}

String statutApproToApiString(StatutAppro s) {
  switch (s) {
    case StatutAppro.brouillon:
      return 'BROUILLON';
    case StatutAppro.validee:
      return 'VALIDEE';
    case StatutAppro.annulee:
      return 'ANNULEE';
  }
}

extension StatutApproLabel on StatutAppro {
  String get label {
    switch (this) {
      case StatutAppro.brouillon:
        return 'Brouillon';
      case StatutAppro.validee:
        return 'Validé';
      case StatutAppro.annulee:
        return 'Annulé';
    }
  }
}

/// Une ligne d'approvisionnement, telle que retournée par GET /approvisionnements/:id
class LigneAppro {
  final String id;
  final String varId;
  final int quantite;
  final double prixAchat;
  final double remise;

  // Champs présents via la jointure VarianteProduit/FamilleProduit
  final String? dimension;
  final String? familleNom;

  const LigneAppro({
    required this.id,
    required this.varId,
    required this.quantite,
    required this.prixAchat,
    required this.remise,
    this.dimension,
    this.familleNom,
  });

  factory LigneAppro.fromJson(Map<String, dynamic> j) => LigneAppro(
        id: j['id'] as String,
        varId: j['Var_id'] as String,
        quantite: j['quantite'] as int? ?? 0,
        // NUMERIC(15,2) → arrive en String depuis PostgreSQL, jamais "as num"
        prixAchat: double.parse((j['prixAchat'] ?? 0).toString()),
        remise: double.parse((j['remise'] ?? 0).toString()),
        dimension: j['dimension'] as String?,
        familleNom: j['familleNom'] as String?,
      );

  double get montantBrut => quantite * prixAchat;
  double get montantNet => montantBrut * (1 - remise / 100);

  String get label {
    final parts = [familleNom, dimension]
        .where((e) => e != null && e.isNotEmpty)
        .join(' · ');
    return parts.isEmpty ? 'Article' : parts;
  }
}

/// Un approvisionnement tel que retourné par GET /approvisionnements (liste)
/// ou GET /approvisionnements/:id (détail).
class Approvisionnement {
  final String id;
  final String fourId;
  final String reference;
  final DateTime date;
  final double frais;
  final String? noteInterne;
  final StatutAppro statut;
  final String? fournisseurNom;
  final List<LigneAppro> lignes;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;

  const Approvisionnement({
    required this.id,
    required this.fourId,
    required this.reference,
    required this.date,
    required this.frais,
    this.noteInterne,
    required this.statut,
    this.fournisseurNom,
    this.lignes = const [],
    required this.dateCreation,
    required this.dateModification,
    required this.version,
  });

  factory Approvisionnement.fromJson(Map<String, dynamic> j) =>
      Approvisionnement(
        id: j['id'] as String,
        fourId: j['Four_id'] as String,
        reference: j['reference'] as String? ?? '',
        date: j['date'] != null
            ? DateTime.parse(j['date'] as String)
            : DateTime.parse(j['dateCreation'] as String),
        frais: double.parse((j['frais'] ?? 0).toString()),
        noteInterne: j['noteInterne'] as String?,
        statut: statutApproFromString(j['statut'] as String?),
        fournisseurNom: j['fournisseurNom'] as String?,
        lignes: j['lignes'] != null
            ? (j['lignes'] as List)
                .map((l) => LigneAppro.fromJson(l as Map<String, dynamic>))
                .toList()
            : const [],
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        version: (j['version'] is int) ? j['version'] as int : 0,
      );

  /// Total = somme des lignes (montantNet) + frais.
  /// Le backend ne renvoie pas de montantTotal pré-calculé pour
  /// Approvisionnement (contrairement à Vente.montantTotal) — donc on le
  /// calcule côté Flutter à partir des lignes + frais.
  double get montantTotal =>
      lignes.fold(0.0, (sum, l) => sum + l.montantNet) + frais;

  bool get peutValider => statut == StatutAppro.brouillon;
  bool get peutAnnuler =>
      statut == StatutAppro.brouillon || statut == StatutAppro.validee;
  bool get estTerminale => statut == StatutAppro.annulee;
}

/// Une ligne du panier en cours de création, côté UI uniquement
/// (avant l'envoi à POST /approvisionnements).
/// Contrairement à LignePanier (vente), pas de notion de stock disponible
/// puisqu'on ajoute du stock, on n'en consomme pas.
class LigneApproPanier {
  final String varId;
  final String label;
  final int quantite;
  final double prixAchat;
  final double remise;

  const LigneApproPanier({
    required this.varId,
    required this.label,
    required this.quantite,
    required this.prixAchat,
    this.remise = 0,
  });

  double get montantBrut => quantite * prixAchat;
  double get montantNet => montantBrut * (1 - remise / 100);

  LigneApproPanier copyWith({
    int? quantite,
    double? prixAchat,
    double? remise,
  }) =>
      LigneApproPanier(
        varId: varId,
        label: label,
        quantite: quantite ?? this.quantite,
        prixAchat: prixAchat ?? this.prixAchat,
        remise: remise ?? this.remise,
      );

  Map<String, dynamic> toApiJson() => {
        'Var_id': varId,
        'quantite': quantite,
        'prixAchat': prixAchat,
        'remise': remise,
      };
}
