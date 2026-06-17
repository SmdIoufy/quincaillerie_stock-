import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

import '../models/catalogue_models.dart';

class CatalogueService {
  final Dio _dio = DioClient.dio;

  // ─── CATÉGORIES ───────────────────────────────────────────────

  Future<({List<Categorie> data, PaginatedMeta meta})> fetchCategories({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final resp = await _dio.get('/catalogue/categories', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      data: (body['data'] as List)
          .map((e) => Categorie.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(body['meta'] as Map<String, dynamic>),
    );
  }

  Future<Categorie> createCategorie(Map<String, dynamic> data) async {
    final resp = await _dio.post('/catalogue/categories', data: data);
    return Categorie.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<Categorie> updateCategorie(
      String id, Map<String, dynamic> data) async {
    final resp = await _dio.patch('/catalogue/categories/$id', data: data);
    return Categorie.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCategorie(String id) async {
    await _dio.delete('/catalogue/categories/$id');
  }

  // ─── FAMILLES ─────────────────────────────────────────────────

  Future<({List<FamilleProduit> data, PaginatedMeta meta})> fetchFamilles({
    int page = 1,
    int limit = 20,
    String? search,
    String? catId,
  }) async {
    final resp = await _dio.get('/catalogue/familles', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (catId != null && catId.isNotEmpty) 'Cat_id': catId,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      data: (body['data'] as List)
          .map((e) => FamilleProduit.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(body['meta'] as Map<String, dynamic>),
    );
  }

  Future<FamilleProduit> createFamille(Map<String, dynamic> data) async {
    final resp = await _dio.post('/catalogue/familles', data: data);
    return FamilleProduit.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<FamilleProduit> updateFamille(
      String id, Map<String, dynamic> data) async {
    final resp = await _dio.patch('/catalogue/familles/$id', data: data);
    return FamilleProduit.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteFamille(String id) async {
    await _dio.delete('/catalogue/familles/$id');
  }

  // ─── VARIANTES ────────────────────────────────────────────────

  Future<({List<VarianteProduit> data, PaginatedMeta meta})> fetchVariantes({
    int page = 1,
    int limit = 20,
    String? search,
    String? famId,
  }) async {
    final resp = await _dio.get('/catalogue/variantes', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (famId != null && famId.isNotEmpty) 'Fam_id': famId,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      data: (body['data'] as List)
          .map((e) => VarianteProduit.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(body['meta'] as Map<String, dynamic>),
    );
  }

  Future<VarianteProduit> createVariante(Map<String, dynamic> data) async {
    final resp = await _dio.post('/catalogue/variantes', data: data);
    return VarianteProduit.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<VarianteProduit> updateVariante(
      String id, Map<String, dynamic> data) async {
    final resp = await _dio.patch('/catalogue/variantes/$id', data: data);
    return VarianteProduit.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteVariante(String id) async {
    await _dio.delete('/catalogue/variantes/$id');
  }
}
