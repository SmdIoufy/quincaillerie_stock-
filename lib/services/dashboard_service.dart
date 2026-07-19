import '../core/dio_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardService {
  Future<DashboardSummaryModel> fetchDashboard() async {
    final response = await DioClient.dio.get('/statistiques/dashboard');
    final data = response.data['data'];
    if (data == null) {
      throw Exception(
        'Réponse invalide de /statistiques/dashboard : ${response.data}',
      );
    }
    return DashboardSummaryModel.fromJson(data);
  }

  Future<List<TopVarianteModel>> fetchTopVariantes({int limit = 5}) async {
    final response = await DioClient.dio.get(
      '/statistiques/variantes-plus-vendues',
      queryParameters: {'limit': limit},
    );
    final data = response.data['data'];
    if (data == null) {
      throw Exception(
        'Réponse invalide de /statistiques/variantes-plus-vendues : ${response.data}',
      );
    }
    final List list = data;
    return list.map((json) => TopVarianteModel.fromJson(json)).toList();
  }
}
