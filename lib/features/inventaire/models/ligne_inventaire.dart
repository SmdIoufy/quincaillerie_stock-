class LigneInventaire {
  final String id;
  final String varId;
  final int quantiteTheorique;
  final int quantitePhysique;
  final int ecart;
  final double prixAchatSnapshot;
  final double prixVenteSnapshot;
  final String? observation;
  final String? dimension;
  final String? familleNom;

  const LigneInventaire({
    required this.id,
    required this.varId,
    required this.quantiteTheorique,
    required this.quantitePhysique,
    required this.ecart,
    required this.prixAchatSnapshot,
    required this.prixVenteSnapshot,
    this.observation,
    this.dimension,
    this.familleNom,
  });

  factory LigneInventaire.fromJson(Map<String, dynamic> j) => LigneInventaire(
        id: j['id'] as String,
        varId: j['Var_id'] as String,
        quantiteTheorique: j['quantiteTheorique'] as int? ?? 0,
        quantitePhysique: j['quantitePhysique'] as int? ?? 0,
        ecart: j['ecart'] as int? ?? 0,
        prixAchatSnapshot:
            double.parse((j['prixAchatSnapshot'] ?? '0').toString()),
        prixVenteSnapshot:
            double.parse((j['prixVenteSnapshot'] ?? '0').toString()),
        observation: j['observation'] as String?,
        dimension: j['dimension'] as String?,
        familleNom: j['familleNom'] as String?,
      );
}
