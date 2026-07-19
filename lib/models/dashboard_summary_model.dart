class VentesParStatutModel {
  final int count;
  final double total;

  VentesParStatutModel({required this.count, required this.total});

  factory VentesParStatutModel.fromJson(Map<String, dynamic> json) {
    return VentesParStatutModel(
      count: json['count'],
      total: double.parse(json['total'].toString()),
    );
  }
}

class TopVarianteModel {
  final String varianteId;
  final String dimension;
  final double prixVente;
  final String familleNom;
  final String categorieNom;
  final int totalQuantiteVendue;
  final double totalMontantVente;
  final int nombreVentes;

  TopVarianteModel({
    required this.varianteId,
    required this.dimension,
    required this.prixVente,
    required this.familleNom,
    required this.categorieNom,
    required this.totalQuantiteVendue,
    required this.totalMontantVente,
    required this.nombreVentes,
  });

  factory TopVarianteModel.fromJson(Map<String, dynamic> json) {
    return TopVarianteModel(
      varianteId: json['varianteId'],
      dimension: json['dimension'],
      prixVente: double.parse(json['prixVente'].toString()),
      familleNom: json['familleNom'],
      categorieNom: json['categorieNom'],
      totalQuantiteVendue: int.parse(json['totalQuantiteVendue'].toString()),
      totalMontantVente: double.parse(json['totalMontantVente'].toString()),
      nombreVentes: int.parse(json['nombreVentes'].toString()),
    );
  }
}

class DashboardSummaryModel {
  final int totalClients;
  final int totalFournisseurs;
  final int totalVariantes;
  final double totalVentesAujourdhui;
  final int nombreVentesAujourdhui;
  final double totalVentesMois;
  final int nombreVentesMois;
  final int stockEnAlerte;
  final Map<String, VentesParStatutModel> ventesParStatut;

  DashboardSummaryModel({
    required this.totalClients,
    required this.totalFournisseurs,
    required this.totalVariantes,
    required this.totalVentesAujourdhui,
    required this.nombreVentesAujourdhui,
    required this.totalVentesMois,
    required this.nombreVentesMois,
    required this.stockEnAlerte,
    required this.ventesParStatut,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final statutMap = <String, VentesParStatutModel>{};
    (json['ventesParStatut'] as Map<String, dynamic>).forEach((key, value) {
      statutMap[key] = VentesParStatutModel.fromJson(value);
    });

    return DashboardSummaryModel(
      totalClients: json['totalClients'],
      totalFournisseurs: json['totalFournisseurs'],
      totalVariantes: json['totalVariantes'],
      totalVentesAujourdhui:
          double.parse(json['totalVentesAujourdhui'].toString()),
      nombreVentesAujourdhui: json['nombreVentesAujourdhui'],
      totalVentesMois: double.parse(json['totalVentesMois'].toString()),
      nombreVentesMois: json['nombreVentesMois'],
      stockEnAlerte: json['stockEnAlerte'],
      ventesParStatut: statutMap,
    );
  }
}
