import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import '../models/inventaire.dart';

typedef InventaireListResult = ({
  List<Inventaire> data,
  int total,
  int totalPages,
});

class InventaireService {
  final Dio _dio = DioClient.dio;

  String _parseError(dynamic e) {
    if (e is DioException) {
      final msg = e.response?.data?['message'];
      if (msg != null) return msg.toString().replaceFirst('Exception: ', '');
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  Future<InventaireListResult> findAll({
    int page = 1,
    int limit = 20,
    String? statut,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (statut != null) 'statut': statut,
    };
    final res = await _dio.get('/inventaires', queryParameters: params);
    final body = res.data as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>;
    return (
      data: (body['data'] as List<dynamic>)
          .map((e) => Inventaire.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int,
      totalPages: meta['totalPages'] as int,
    );
  }

  Future<Inventaire> findById(String id) async {
    final res = await _dio.get('/inventaires/$id');
    return Inventaire.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<Inventaire> create({
    String? description,
    required List<Map<String, dynamic>> lignes,
  }) async {
    final res = await _dio.post('/inventaires', data: {
      if (description != null && description.isNotEmpty)
        'description': description,
      'lignes': lignes,
    });
    return Inventaire.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<Inventaire> updateStatut(String id, String statut) async {
    final res =
        await _dio.patch('/inventaires/$id/statut', data: {'statut': statut});
    return Inventaire.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
