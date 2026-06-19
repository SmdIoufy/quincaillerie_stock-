// ─────────────────────────────────────────────
// MODÈLE FOURNISSEUR
// Champs exacts issus du backend : b.id, b.dateCreation, b.dateModification,
// b.version, f.nom, f.telephone, f.email, f.actif
// ─────────────────────────────────────────────

class Fournisseur {
  final String id;
  final String nom;
  final String? telephone;
  final String? email;
  final bool actif;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int version;

  const Fournisseur({
    required this.id,
    required this.nom,
    this.telephone,
    this.email,
    required this.actif,
    required this.dateCreation,
    required this.dateModification,
    required this.version,
  });

  factory Fournisseur.fromJson(Map<String, dynamic> j) => Fournisseur(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? '',
        telephone: j['telephone'] as String?,
        email: j['email'] as String?,
        actif: j['actif'] as bool? ?? true,
        dateCreation: DateTime.parse(j['dateCreation'] as String),
        dateModification: DateTime.parse(j['dateModification'] as String),
        version: (j['version'] is int) ? j['version'] as int : 0,
      );

  /// Initiales pour l'avatar (ex: "Ets Diallo & Fils" → "ED")
  String get initiales {
    final parts = nom.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.isNotEmpty ? nom[0].toUpperCase() : '?';
  }
}

/// Meta de pagination — réutilisée depuis catalogue, identique
class PaginatedMetaFournisseur {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginatedMetaFournisseur({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginatedMetaFournisseur.fromJson(Map<String, dynamic> j) =>
      PaginatedMetaFournisseur(
        page: j['page'] as int? ?? 1,
        limit: j['limit'] as int? ?? 20,
        total: j['total'] as int? ?? 0,
        totalPages: j['totalPages'] as int? ?? 1,
      );
}
