import '../core/dio_client.dart';
import '../models/audit_activite_model.dart';
import '../models/mouvement_stock_model.dart';

class AuditService {
  Future<List<AuditActiviteModel>> fetchActivites({
    int page = 1,
    int limit = 20,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final response = await DioClient.dio.get('/audit/activites', queryParameters: {
      'page': page,
      'limit': limit,
      if (dateDebut != null) 'dateDebut': dateDebut.toIso8601String(),
      if (dateFin != null) 'dateFin': dateFin.toIso8601String(),
    });

    final List data = response.data['data'];
    return data.map((json) => AuditActiviteModel.fromJson(json)).toList();
  }

  Future<List<MouvementStockModel>> fetchMouvementsStock({
    int page = 1,
    int limit = 20,
    String? typeMouvement,
    String? varId,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final response = await DioClient.dio.get('/audit/mouvements-stock', queryParameters: {
      'page': page,
      'limit': limit,
      if (typeMouvement != null) 'typeMouvement': typeMouvement,
      if (varId != null) 'Var_id': varId,
      if (dateDebut != null) 'dateDebut': dateDebut.toIso8601String(),
      if (dateFin != null) 'dateFin': dateFin.toIso8601String(),
    });

    final List data = response.data['data'];
    return data.map((json) => MouvementStockModel.fromJson(json)).toList();
  }
}