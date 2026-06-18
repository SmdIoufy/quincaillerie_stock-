import '../../../core/dio_client.dart';
import '../models/client_models.dart';

class ClientService {
  // ── Lister (paginé, avec recherche, actif=true par défaut) ──────
  Future<({List<Client> data, PaginatedMetaClient meta})> fetchClients({
    int page = 1,
    int limit = 20,
    String? search,
    bool actif = true,
  }) async {
    final resp = await DioClient.dio.get(
      '/clients',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        'actif': actif,
      },
    );
    final body = resp.data as Map<String, dynamic>;
    final data = (body['data'] as List)
        .map((e) => Client.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta =
        PaginatedMetaClient.fromJson(body['meta'] as Map<String, dynamic>);
    return (data: data, meta: meta);
  }

  // ── Récupérer par ID ─────────────────────────────────────────────
  Future<Client> fetchClientById(String id) async {
    final resp = await DioClient.dio.get('/clients/$id');
    return Client.fromJson(
        (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // ── Créer ────────────────────────────────────────────────────────
  Future<Client> createClient({
    required String nom,
    String? telephone,
    String? email,
  }) async {
    final resp = await DioClient.dio.post('/clients', data: {
      'nom': nom,
      if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return Client.fromJson(
        (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // ── Modifier ─────────────────────────────────────────────────────
  Future<Client> updateClient(
    String id, {
    String? nom,
    String? telephone,
    String? email,
    bool? actif,
  }) async {
    final resp = await DioClient.dio.patch('/clients/$id', data: {
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (actif != null) 'actif': actif,
    });
    return Client.fromJson(
        (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // ── Désactiver (soft delete) ──────────────────────────────────────
  Future<void> deleteClient(String id) async {
    await DioClient.dio.delete('/clients/$id');
  }
}
