import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

import '../models/vente_models.dart';
import '../../catalogue/models/catalogue_models.dart';

class VenteService {
  final Dio _dio = DioClient.dio;

  // ─── LISTE / DÉTAIL ───────────────────────────────────────────

  Future<({List<Vente> data, PaginatedMeta meta})> fetchVentes({
    int page = 1,
    int limit = 20,
    String? statut,
    String? cliId,
  }) async {
    final resp = await _dio.get('/ventes', queryParameters: {
      'page': page,
      'limit': limit,
      if (statut != null && statut.isNotEmpty) 'statut': statut,
      if (cliId != null && cliId.isNotEmpty) 'Cli_id': cliId,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      data: (body['data'] as List)
          .map((e) => Vente.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(body['meta'] as Map<String, dynamic>),
    );
  }

  Future<Vente> fetchVenteById(String id) async {
    final resp = await _dio.get('/ventes/$id');
    return Vente.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<RecuVente> fetchRecu(String id) async {
    final resp = await _dio.get('/ventes/$id/recu');
    return RecuVente.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  // ─── CRÉATION ─────────────────────────────────────────────────

  Future<Vente> createVente({
    required String cliId,
    required List<LignePanier> lignes,
  }) async {
    final resp = await _dio.post('/ventes', data: {
      'Cli_id': cliId,
      'lignes': lignes.map((l) => l.toApiJson()).toList(),
    });
    return Vente.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  // ─── CHANGEMENT DE STATUT (valider / annuler) ────────────────

  Future<Vente> updateStatut(String id, StatutVente statut) async {
    final resp = await _dio.patch('/ventes/$id/statut', data: {
      'statut': statutVenteToApiString(statut),
    });
    return Vente.fromJson(resp.data['data'] as Map<String, dynamic>);
  }
}
