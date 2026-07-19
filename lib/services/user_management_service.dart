import '../models/user_model.dart';
import '../core/dio_client.dart';

class UserManagementService {
  final _dio = DioClient.dio;

  Future<List<UserModel>> fetchUsers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _dio.get(
      '/users',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> createUser({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
  }) async {
    final response = await _dio.post(
      '/users',
      data: {
        'email': email,
        'password': password,
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
      },
    );

    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<UserModel> toggleActive(String id, bool isActive) async {
    final response = await _dio.patch(
      '/users/$id',
      data: {'isActive': isActive},
    );

    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
