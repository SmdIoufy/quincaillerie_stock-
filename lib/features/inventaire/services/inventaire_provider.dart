import 'package:flutter/foundation.dart';
import '../models/inventaire.dart';
import 'inventaire_service.dart';

class InventaireProvider extends ChangeNotifier {
  final InventaireService _service = InventaireService();

  // ── List state ──────────────────────────────────────────────
  List<Inventaire> inventaires = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;
  String? statutFilter;

  // ── Detail state ─────────────────────────────────────────────
  Inventaire? selected;
  bool isLoadingDetail = false;
  String? detailError;

  String _parseError(dynamic e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> loadInventaires({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      inventaires = [];
    }
    if (currentPage == 1) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }
    error = null;
    notifyListeners();

    try {
      final result = await _service.findAll(
        page: currentPage,
        limit: 20,
        statut: statutFilter,
      );
      inventaires = [...inventaires, ...result.data];
      totalPages = result.totalPages;
    } catch (e) {
      error = _parseError(e);
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (currentPage >= totalPages || isLoadingMore) return;
    currentPage++;
    await loadInventaires();
  }

  void setStatutFilter(String? statut) {
    statutFilter = statut;
    loadInventaires(reset: true);
  }

  Future<void> loadDetail(String id) async {
    isLoadingDetail = true;
    detailError = null;
    notifyListeners();
    try {
      selected = await _service.findById(id);
    } catch (e) {
      detailError = _parseError(e);
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    String? description,
    required List<Map<String, dynamic>> lignes,
  }) async {
    try {
      final inv =
          await _service.create(description: description, lignes: lignes);
      inventaires = [inv, ...inventaires];
      notifyListeners();
      return true;
    } catch (e) {
      error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatut(String id, String statut) async {
    try {
      final updated = await _service.updateStatut(id, statut);
      // Mettre à jour dans la liste
      final idx = inventaires.indexWhere((i) => i.id == id);
      if (idx != -1) inventaires[idx] = updated;
      // Mettre à jour le détail si ouvert
      if (selected?.id == id) selected = updated;
      notifyListeners();
      return true;
    } catch (e) {
      error = _parseError(e);
      notifyListeners();
      return false;
    }
  }
}
