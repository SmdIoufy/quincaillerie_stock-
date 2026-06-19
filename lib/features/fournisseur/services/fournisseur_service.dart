import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

import '../models/fournisseur_models.dart';

class FournisseurService {
  final Dio _dio = DioClient.dio;

  Future<({List<Fournisseur> data, PaginatedMetaFournisseur meta})>
      fetchFournisseurs({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final resp = await _dio.get('/fournisseurs', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      data: (body['data'] as List)
          .map((e) => Fournisseur.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMetaFournisseur.fromJson(
          body['meta'] as Map<String, dynamic>),
    );
  }

  Future<Fournisseur> fetchFournisseurById(String id) async {
    final resp = await _dio.get('/fournisseurs/$id');
    return Fournisseur.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<Fournisseur> createFournisseur({
    required String nom,
    String? telephone,
    String? email,
  }) async {
    final resp = await _dio.post('/fournisseurs', data: {
      'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
    });
    return Fournisseur.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<Fournisseur> updateFournisseur(
    String id, {
    String? nom,
    String? telephone,
    String? email,
    bool? actif,
  }) async {
    final resp = await _dio.patch('/fournisseurs/$id', data: {
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (actif != null) 'actif': actif,
    });
    return Fournisseur.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteFournisseur(String id) async {
    await _dio.delete('/fournisseurs/$id');
  }
}
