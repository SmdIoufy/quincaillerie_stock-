import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

import '../models/appro_models.dart';
import '../../catalogue/models/catalogue_models.dart'; // PaginatedMeta

class ApproService {
  final Dio _dio = DioClient.dio;

  // ─── LISTE / DÉTAIL ───────────────────────────────────────────

  Future<({List<Approvisionnement> data, PaginatedMeta meta})>
      fetchApprovisionnements({
    int page = 1,
    int limit = 20,
    String? statut,
    String? fourId,
  }) async {
    final resp = await _dio.get('/approvisionnements', queryParameters: {
      'page': page,
      'limit': limit,
      if (statut != null && statut.isNotEmpty) 'statut': statut,
      if (fourId != null && fourId.isNotEmpty) 'Four_id': fourId,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      data: (body['data'] as List)
          .map((e) => Approvisionnement.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(body['meta'] as Map<String, dynamic>),
    );
  }

  Future<Approvisionnement> fetchApproById(String id) async {
    final resp = await _dio.get('/approvisionnements/$id');
    return Approvisionnement.fromJson(
        resp.data['data'] as Map<String, dynamic>);
  }

  // ─── CRÉATION ─────────────────────────────────────────────────

  Future<Approvisionnement> createAppro({
    required String fourId,
    required List<LigneApproPanier> lignes,
    double frais = 0,
    String? noteInterne,
  }) async {
    final resp = await _dio.post('/approvisionnements', data: {
      'Four_id': fourId,
      'frais': frais,
      if (noteInterne != null && noteInterne.isNotEmpty)
        'noteInterne': noteInterne,
      'lignes': lignes.map((l) => l.toApiJson()).toList(),
    });
    return Approvisionnement.fromJson(
        resp.data['data'] as Map<String, dynamic>);
  }

  // ─── CHANGEMENT DE STATUT (valider / annuler) ────────────────

  Future<Approvisionnement> updateStatut(String id, StatutAppro statut) async {
    final resp = await _dio.patch('/approvisionnements/$id/statut', data: {
      'statut': statutApproToApiString(statut),
    });
    return Approvisionnement.fromJson(
        resp.data['data'] as Map<String, dynamic>);
  }
}
