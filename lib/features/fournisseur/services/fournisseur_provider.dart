import 'package:flutter/material.dart';
import '../models/fournisseur_models.dart';
import 'fournisseur_service.dart';

enum FournisseurStatus { initial, loading, success, error }

class FournisseurProvider extends ChangeNotifier {
  final _service = FournisseurService();

  // ─── LISTE ───────────────────────────────────────────────────────
  List<Fournisseur> fournisseurs = [];
  FournisseurStatus listStatus = FournisseurStatus.initial;
  String? listError;
  PaginatedMetaFournisseur? listMeta;
  int page = 1;
  String? searchQuery;

  // ─── DÉTAIL / FORMULAIRE ─────────────────────────────────────────
  Fournisseur? selectedFournisseur;
  FournisseurStatus detailStatus = FournisseurStatus.initial;
  String? detailError;

  bool saving = false;
  String? saveError;

  // ─── LISTE METHODS ───────────────────────────────────────────────

  Future<void> loadFournisseurs({bool reset = false}) async {
    if (reset) {
      page = 1;
      fournisseurs = [];
    }
    listStatus = FournisseurStatus.loading;
    listError = null;
    notifyListeners();
    try {
      final result = await _service.fetchFournisseurs(
        page: page,
        search: searchQuery,
      );
      fournisseurs = reset ? result.data : [...fournisseurs, ...result.data];
      listMeta = result.meta;
      listStatus = FournisseurStatus.success;
    } catch (e) {
      listError = _parseError(e);
      listStatus = FournisseurStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String? q) {
    searchQuery = (q == null || q.isEmpty) ? null : q;
    loadFournisseurs(reset: true);
  }

  Future<void> loadMore() async {
    if (listMeta == null) return;
    if (page >= listMeta!.totalPages) return;
    page += 1;
    await loadFournisseurs();
  }

  // ─── CRÉER ───────────────────────────────────────────────────────

  Future<bool> createFournisseur({
    required String nom,
    String? telephone,
    String? email,
  }) async {
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      final created = await _service.createFournisseur(
          nom: nom, telephone: telephone, email: email);
      fournisseurs = [created, ...fournisseurs];
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      saveError = _parseError(e);
      saving = false;
      notifyListeners();
      return false;
    }
  }

  // ─── MODIFIER ────────────────────────────────────────────────────

  Future<bool> updateFournisseur(
    String id, {
    String? nom,
    String? telephone,
    String? email,
    bool? actif,
  }) async {
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      final updated = await _service.updateFournisseur(id,
          nom: nom, telephone: telephone, email: email, actif: actif);
      final idx = fournisseurs.indexWhere((f) => f.id == id);
      if (idx >= 0) fournisseurs[idx] = updated;
      if (selectedFournisseur?.id == id) selectedFournisseur = updated;
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      saveError = _parseError(e);
      saving = false;
      notifyListeners();
      return false;
    }
  }

  // ─── DÉSACTIVER ──────────────────────────────────────────────────

  Future<bool> deleteFournisseur(String id) async {
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      await _service.deleteFournisseur(id);
      fournisseurs = fournisseurs.where((f) => f.id != id).toList();
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      saveError = _parseError(e);
      saving = false;
      notifyListeners();
      return false;
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────

  String _parseError(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Une erreur est survenue';
  }
}
