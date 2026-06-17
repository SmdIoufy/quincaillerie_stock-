import 'package:flutter/material.dart';
import '../models/catalogue_models.dart';
import '../services/catalogue_service.dart';

enum CatalogueStatus { initial, loading, success, error }

class CatalogueProvider extends ChangeNotifier {
  final _service = CatalogueService();

  // ─── CATÉGORIES ───────────────────────────────────────────────
  List<Categorie> categories = [];
  CatalogueStatus catStatus = CatalogueStatus.initial;
  String? catError;
  PaginatedMeta? catMeta;
  int catPage = 1;
  String catSearch = '';

  // ─── FAMILLES ─────────────────────────────────────────────────
  List<FamilleProduit> familles = [];
  CatalogueStatus famStatus = CatalogueStatus.initial;
  String? famError;
  PaginatedMeta? famMeta;
  int famPage = 1;
  String famSearch = '';
  String? famCatFilter;

  // ─── VARIANTES ────────────────────────────────────────────────
  List<VarianteProduit> variantes = [];
  CatalogueStatus varStatus = CatalogueStatus.initial;
  String? varError;
  PaginatedMeta? varMeta;
  int varPage = 1;
  String varSearch = '';
  String? varFamFilter;

  // ─── CATÉGORIES METHODS ───────────────────────────────────────

  Future<void> loadCategories({bool reset = false}) async {
    if (reset) {
      catPage = 1;
      categories = [];
    }
    catStatus = CatalogueStatus.loading;
    catError = null;
    notifyListeners();
    try {
      final result =
          await _service.fetchCategories(page: catPage, search: catSearch);
      categories = reset ? result.data : [...categories, ...result.data];
      catMeta = result.meta;
      catStatus = CatalogueStatus.success;
    } catch (e) {
      catError = _parseError(e);
      catStatus = CatalogueStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createCategorie(Map<String, dynamic> data) async {
    try {
      await _service.createCategorie(data);
      await loadCategories(reset: true);
      return true;
    } catch (e) {
      catError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategorie(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateCategorie(id, data);
      await loadCategories(reset: true);
      return true;
    } catch (e) {
      catError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategorie(String id) async {
    try {
      await _service.deleteCategorie(id);
      await loadCategories(reset: true);
      return true;
    } catch (e) {
      catError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  void setCatSearch(String v) {
    catSearch = v;
    loadCategories(reset: true);
  }

  // ─── FAMILLES METHODS ─────────────────────────────────────────

  Future<void> loadFamilles({bool reset = false}) async {
    if (reset) {
      famPage = 1;
      familles = [];
    }
    famStatus = CatalogueStatus.loading;
    famError = null;
    notifyListeners();
    try {
      final result = await _service.fetchFamilles(
        page: famPage,
        search: famSearch,
        catId: famCatFilter,
      );
      familles = reset ? result.data : [...familles, ...result.data];
      famMeta = result.meta;
      famStatus = CatalogueStatus.success;
    } catch (e) {
      famError = _parseError(e);
      famStatus = CatalogueStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createFamille(Map<String, dynamic> data) async {
    try {
      await _service.createFamille(data);
      await loadFamilles(reset: true);
      return true;
    } catch (e) {
      famError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFamille(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateFamille(id, data);
      await loadFamilles(reset: true);
      return true;
    } catch (e) {
      famError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFamille(String id) async {
    try {
      await _service.deleteFamille(id);
      await loadFamilles(reset: true);
      return true;
    } catch (e) {
      famError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  void setFamSearch(String v) {
    famSearch = v;
    loadFamilles(reset: true);
  }

  void setFamCatFilter(String? v) {
    famCatFilter = v;
    loadFamilles(reset: true);
  }

  // ─── VARIANTES METHODS ────────────────────────────────────────

  Future<void> loadVariantes({bool reset = false}) async {
    if (reset) {
      varPage = 1;
      variantes = [];
    }
    varStatus = CatalogueStatus.loading;
    varError = null;
    notifyListeners();
    try {
      final result = await _service.fetchVariantes(
        page: varPage,
        search: varSearch,
        famId: varFamFilter,
      );
      variantes = reset ? result.data : [...variantes, ...result.data];
      varMeta = result.meta;
      varStatus = CatalogueStatus.success;
    } catch (e) {
      varError = _parseError(e);
      varStatus = CatalogueStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createVariante(Map<String, dynamic> data) async {
    try {
      await _service.createVariante(data);
      await loadVariantes(reset: true);
      return true;
    } catch (e) {
      varError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVariante(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateVariante(id, data);
      await loadVariantes(reset: true);
      return true;
    } catch (e) {
      varError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVariante(String id) async {
    try {
      await _service.deleteVariante(id);
      await loadVariantes(reset: true);
      return true;
    } catch (e) {
      varError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  void setVarSearch(String v) {
    varSearch = v;
    loadVariantes(reset: true);
  }

  void setVarFamFilter(String? v) {
    varFamFilter = v;
    loadVariantes(reset: true);
  }

  // ─── HELPERS ──────────────────────────────────────────────────

  String _parseError(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Une erreur est survenue';
  }
}
