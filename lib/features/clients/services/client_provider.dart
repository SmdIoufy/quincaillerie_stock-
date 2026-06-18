import 'package:flutter/material.dart';
import '../models/client_models.dart';
import 'client_service.dart';

enum ClientStatus { initial, loading, success, error }

class ClientProvider extends ChangeNotifier {
  final _service = ClientService();

  // ─── LISTE ───────────────────────────────────────────────────────
  List<Client> clients = [];
  ClientStatus listStatus = ClientStatus.initial;
  String? listError;
  PaginatedMetaClient? listMeta;
  int page = 1;
  String? searchQuery;

  // ─── DÉTAIL / FORMULAIRE ─────────────────────────────────────────
  Client? selectedClient;
  ClientStatus detailStatus = ClientStatus.initial;
  String? detailError;

  bool saving = false;
  String? saveError;

  // ─── LISTE METHODS ───────────────────────────────────────────────

  Future<void> loadClients({bool reset = false}) async {
    if (reset) {
      page = 1;
      clients = [];
    }
    listStatus = ClientStatus.loading;
    listError = null;
    notifyListeners();
    try {
      final result = await _service.fetchClients(
        page: page,
        search: searchQuery,
      );
      clients = reset ? result.data : [...clients, ...result.data];
      listMeta = result.meta;
      listStatus = ClientStatus.success;
    } catch (e) {
      listError = _parseError(e);
      listStatus = ClientStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String? q) {
    searchQuery = (q == null || q.isEmpty) ? null : q;
    loadClients(reset: true);
  }

  Future<void> loadMore() async {
    if (listMeta == null) return;
    if (page >= listMeta!.totalPages) return;
    page += 1;
    await loadClients();
  }

  // ─── CRÉER ───────────────────────────────────────────────────────

  Future<bool> createClient({
    required String nom,
    String? telephone,
    String? email,
  }) async {
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      final created = await _service.createClient(
          nom: nom, telephone: telephone, email: email);
      clients = [created, ...clients];
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

  Future<bool> updateClient(
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
      final updated = await _service.updateClient(id,
          nom: nom, telephone: telephone, email: email, actif: actif);
      final idx = clients.indexWhere((c) => c.id == id);
      if (idx >= 0) clients[idx] = updated;
      if (selectedClient?.id == id) selectedClient = updated;
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

  Future<bool> deleteClient(String id) async {
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      await _service.deleteClient(id);
      clients = clients.where((c) => c.id != id).toList();
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
