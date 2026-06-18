// ─────────────────────────────────────────────
// MODÈLES VENTE
// ─────────────────────────────────────────────

/// Statuts possibles d'une vente.
/// Cycle : BROUILLON → VALIDEE → ANNULEE (annulation possible même après VALIDEE, avec retour de stock)
/// BROUILLON → ANNULEE directement est également possible (aucun mouvement de stock dans ce cas).
/// ANNULEE est un état terminal : plus aucune transition n'est permise.
enum StatutVente { brouillon, validee, annulee }

StatutVente statutVenteFromString(String? v) {
  switch (v) {
    case 'VALIDEE':
      return StatutVente.validee;
    case 'ANNULEE':
      return StatutVente.annulee;
    case 'BROUILLON':
    default:
      return StatutVente.brouillon;
  }
}

String statutVenteToApiString(StatutVente s) {
  switch (s) {
    case StatutVente.brouillon:
      return 'BROUILLON';
    case StatutVente.validee:
      return 'VALIDEE';
    case StatutVente.annulee:
      return 'ANNULEE';
  }
}

extension StatutVenteLabel on StatutVente {
  String get label {
    switch (this) {
      case StatutVente.brouillon:
        return 'Brouillon';
      case StatutVente.validee:
        return 'Validée';
      case StatutVente.annulee:
        return 'Annulée';
    }
  }
}

/// Une ligne de vente, telle que retournée par GET /ventes/:id (vente.lignes)
/// ou par GET /ventes/:id/recu (lignes formatées avec montants calculés).
class LigneVente {
  final String id;
  final String varId;
  final int quantite;
  final double prixUnitaire;
  final double coutUnitaire;
  final double remise;

  // Champs présents uniquement via findById() (jointure VarianteProduit/FamilleProduit)
  final String? dimension;
  final String? familleNom;

  // Champs présents uniquement via le reçu (vente.recu.service.js)
  final double? montantBrut;
  final double? montantRemise;
  final double? montantNet;

  const LigneVente({
    required this.id,
    required this.varId,
    required this.quantite,
    required this.prixUnitaire,
    required this.coutUnitaire,
    required this.remise,
    this.dimension,
    this.familleNom,
    this.montantBrut,
    this.montantRemise,
    this.montantNet,
  });

  factory LigneVente.fromJson(Map<String, dynamic> j) => LigneVente(
        id: j['id'] as String,
        varId: j['Var_id'] as String,
        quantite: j['quantite'] as int? ?? 0,
        // NUMERIC(15,2) → arrive en String depuis PostgreSQL, jamais "as num"
        prixUnitaire: double.parse((j['prixUnitaire'] ?? 0).toString()),
        coutUnitaire: double.parse((j['coutUnitaire'] ?? 0).toString()),
        remise: double.parse((j['remise'] ?? 0).toString()),
        dimension: j['dimension'] as String?,
        familleNom: j['familleNom'] as String?,
        montantBrut: j['montantBrut'] != null
            ? double.parse(j['montantBrut'].toString())
            : null,
        montantRemise: j['montantRemise'] != null
            ? double.parse(j['montantRemise'].toString())
            : null,
        montantNet: j['montantNet'] != null
            ? double.parse(j['montantNet'].toString())
            : null,
      );

  /// Montant net de la ligne, recalculé localement si l'API ne l'a pas fourni
  /// (ex: retour de findById qui n'inclut pas les totaux du reçu).
  double get montantCalcule =>
      montantNet ?? (quantite * prixUnitaire * (1 - remise / 100));

  String get label {
    final parts = [familleNom, dimension]
        .where((e) => e != null && e.isNotEmpty)
        .join(' · ');
    return parts.isEmpty ? 'Article' : parts;
  }
}

/// Une vente telle que retournée par GET /ventes (liste) ou GET /ventes/:id (détail).
class Vente {
  final String id;
  final String cliId;
  final String reference;
  final DateTime date;
  final double montantTotal;
  final StatutVente statut;
  final String? clientNom;
  final List<LigneVente> lignes;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;

  const Vente({
    required this.id,
    required this.cliId,
    required this.reference,
    required this.date,
    required this.montantTotal,
    required this.statut,
    this.clientNom,
    this.lignes = const [],
    required this.dateCreation,
    required this.dateModification,
    required this.version,
  });

  factory Vente.fromJson(Map<String, dynamic> j) => Vente(
        id: j['id'] as String,
        cliId: j['Cli_id'] as String,
        reference: j['reference'] as String? ?? '',
        date: j['date'] != null
            ? DateTime.parse(j['date'] as String)
            : DateTime.parse(j['dateCreation'] as String),
        // NUMERIC(15,2) → String depuis PostgreSQL
        montantTotal: double.parse((j['montantTotal'] ?? 0).toString()),
        statut: statutVenteFromString(j['statut'] as String?),
        clientNom: j['clientNom'] as String?,
        lignes: j['lignes'] != null
            ? (j['lignes'] as List)
                .map((l) => LigneVente.fromJson(l as Map<String, dynamic>))
                .toList()
            : const [],
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        // garde-fou cohérent avec le principe retenu : Number.isInteger() + fallback 0
        version: (j['version'] is int) ? j['version'] as int : 0,
      );

  bool get peutValider => statut == StatutVente.brouillon;
  bool get peutAnnuler =>
      statut == StatutVente.brouillon || statut == StatutVente.validee;
  bool get estTerminale => statut == StatutVente.annulee;
}

/// Une ligne du panier en cours de création, côté UI uniquement
/// (avant l'envoi à POST /ventes). Ne correspond à aucun modèle backend.
class LignePanier {
  final String varId;
  final String label;
  final int quantite;
  final double prixUnitaire;
  final double remise;
  final int stockDisponible;

  const LignePanier({
    required this.varId,
    required this.label,
    required this.quantite,
    required this.prixUnitaire,
    this.remise = 0,
    required this.stockDisponible,
  });

  double get montantBrut => quantite * prixUnitaire;
  double get montantNet => montantBrut * (1 - remise / 100);

  LignePanier copyWith({
    int? quantite,
    double? prixUnitaire,
    double? remise,
  }) =>
      LignePanier(
        varId: varId,
        label: label,
        quantite: quantite ?? this.quantite,
        prixUnitaire: prixUnitaire ?? this.prixUnitaire,
        remise: remise ?? this.remise,
        stockDisponible: stockDisponible,
      );

  Map<String, dynamic> toApiJson() => {
        'Var_id': varId,
        'quantite': quantite,
        'prixUnitaire': prixUnitaire,
        'remise': remise,
      };
}

/// Reçu complet d'une vente (GET /ventes/:id/recu) — vente + client + lignes + totaux.
class RecuVente {
  final Vente vente;
  final String? clientTelephone;
  final String? clientEmail;
  final List<LigneVente> lignes;
  final double totalBrut;
  final double totalRemise;
  final double totalNet;

  const RecuVente({
    required this.vente,
    this.clientTelephone,
    this.clientEmail,
    required this.lignes,
    required this.totalBrut,
    required this.totalRemise,
    required this.totalNet,
  });

  factory RecuVente.fromJson(Map<String, dynamic> j) {
    final venteJson = j['vente'] as Map<String, dynamic>;
    final client = venteJson['client'] as Map<String, dynamic>?;
    final totals = venteJson['totals'] as Map<String, dynamic>? ?? {};
    final lignesJson = (j['lignes'] as List? ?? []);

    return RecuVente(
      vente: Vente.fromJson({
        ...venteJson,
        'clientNom': client?['nom'],
        // le reçu n'a pas de tableau "lignes" imbriqué dans vente, on le construit séparément
      }),
      clientTelephone: client?['telephone'] as String?,
      clientEmail: client?['email'] as String?,
      lignes: lignesJson
          .map((l) => LigneVente.fromJson(l as Map<String, dynamic>))
          .toList(),
      totalBrut: double.parse((totals['montantBrut'] ?? 0).toString()),
      totalRemise: double.parse((totals['montantRemise'] ?? 0).toString()),
      totalNet: double.parse((totals['montantNet'] ?? 0).toString()),
    );
  }
}
