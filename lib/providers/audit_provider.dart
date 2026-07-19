import 'package:flutter/material.dart';
import '../models/audit_activite_model.dart';
import '../models/mouvement_stock_model.dart';
import '../services/audit_service.dart';

class AuditProvider extends ChangeNotifier {
  final _service = AuditService();

  List<AuditActiviteModel> activites = [];
  List<MouvementStockModel> mouvements = [];

  bool isLoadingActivites = false;
  bool isLoadingMouvements = false;
  String? errorMessage;

  DateTime? dateDebut;
  DateTime? dateFin;

  void setDateRange(DateTime? debut, DateTime? fin) {
    dateDebut = debut;
    dateFin = fin;
    notifyListeners();
    fetchActivites();
    fetchMouvements();
  }

  Future<void> fetchActivites() async {
    isLoadingActivites = true;
    errorMessage = null;
    notifyListeners();

    try {
      activites = await _service.fetchActivites(
        dateDebut: dateDebut,
        dateFin: dateFin,
      );
    } on Exception catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingActivites = false;
      notifyListeners();
    }
  }

  Future<void> fetchMouvements() async {
    isLoadingMouvements = true;
    errorMessage = null;
    notifyListeners();

    try {
      mouvements = await _service.fetchMouvementsStock(
        dateDebut: dateDebut,
        dateFin: dateFin,
      );
    } on Exception catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingMouvements = false;
      notifyListeners();
    }
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchActivites(), fetchMouvements()]);
  }
}