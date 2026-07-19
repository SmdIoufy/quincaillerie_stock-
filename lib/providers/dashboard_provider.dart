import 'package:flutter/material.dart';
import '../models/dashboard_summary_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _service = DashboardService();

  DashboardSummaryModel? summary;
  List<TopVarianteModel> topVariantes = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchDashboard(),
        _service.fetchTopVariantes(limit: 5),
      ]);
      summary = results[0] as DashboardSummaryModel;
      topVariantes = results[1] as List<TopVarianteModel>;
    } on Exception catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Conservé pour compatibilité avec le code existant qui appelle fetchSummary()
  Future<void> fetchSummary() => fetchAll();
}
