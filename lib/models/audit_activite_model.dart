class AuditActiviteModel {
  final String id;
  final DateTime dateCreation;
  final DateTime dateModification;
  final String? creePar;
  final String? modifiePar;
  final String typeEntite; // VENTE | APPROVISIONNEMENT | INVENTAIRE
  final String? reference;
  final String? statut;
  final String? clientOuFournisseur;

  AuditActiviteModel({
    required this.id,
    required this.dateCreation,
    required this.dateModification,
    this.creePar,
    this.modifiePar,
    required this.typeEntite,
    this.reference,
    this.statut,
    this.clientOuFournisseur,
  });

  factory AuditActiviteModel.fromJson(Map<String, dynamic> json) {
    return AuditActiviteModel(
      id: json['id'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      creePar: json['creePar'],
      modifiePar: json['modifiePar'],
      typeEntite: json['typeEntite'],
      reference: json['reference'],
      statut: json['statut'],
      clientOuFournisseur: json['clientOuFournisseur'],
    );
  }
}
