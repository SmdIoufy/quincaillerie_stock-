class MouvementStockModel {
  final String id;
  final String typeMouvement;
  final num quantite;
  final num quantiteAvant;
  final num quantiteApres;
  final String? refAuteur;
  final DateTime date;
  final String? raison;
  final String? dimension;
  final String? familleNom;
  final String sourceType; // VENTE | APPROVISIONNEMENT | INVENTAIRE | MANUEL
  final String? sourceReference;

  MouvementStockModel({
    required this.id,
    required this.typeMouvement,
    required this.quantite,
    required this.quantiteAvant,
    required this.quantiteApres,
    this.refAuteur,
    required this.date,
    this.raison,
    this.dimension,
    this.familleNom,
    required this.sourceType,
    this.sourceReference,
  });

  factory MouvementStockModel.fromJson(Map<String, dynamic> json) {
    return MouvementStockModel(
      id: json['id'],
      typeMouvement: json['typeMouvement'],
      quantite: json['quantite'],
      quantiteAvant: json['quantiteAvant'],
      quantiteApres: json['quantiteApres'],
      refAuteur: json['refAuteur'],
      date: DateTime.parse(json['date']),
      raison: json['raison'],
      dimension: json['dimension'],
      familleNom: json['familleNom'],
      sourceType: json['sourceType'],
      sourceReference: json['sourceReference'],
    );
  }
}
