import 'package:flutter/material.dart';
import '../models/vente_models.dart';
import '../../catalogue/models/catalogue_models.dart';
import 'vente_service.dart';

enum VenteStatus { initial, loading, success, error }

class VenteProvider extends ChangeNotifier {
  final _service = VenteService();

  // ─── LISTE DES VENTES ─────────────────────────────────────────
  List<Vente> ventes = [];
  VenteStatus listStatus = VenteStatus.initial;
  String? listError;
  PaginatedMeta? listMeta;
  int page = 1;
  String? statutFilter; // null = tous les statuts
  String? cliIdFilter;

  // ─── DÉTAIL D'UNE VENTE ───────────────────────────────────────
  Vente? selectedVente;
  VenteStatus detailStatus = VenteStatus.initial;
  String? detailError;

  // ─── REÇU ───────────────────────────────────────────────────
  RecuVente? recu;
  VenteStatus recuStatus = VenteStatus.initial;
  String? recuError;

  // ─── PANIER EN COURS DE CRÉATION (état purement local) ────────
  String? panierCliId;
  String? panierClientNom;
  List<LignePanier> panierLignes = [];
  bool creating = false;
  String? createError;

  // ─── ACTION STATUT (valider / annuler) ─────────────────────────
  bool updatingStatut = false;
  String? statutActionError;

  // ─── LISTE METHODS ─────────────────────────────────────────────

  Future<void> loadVentes({bool reset = false}) async {
    if (reset) {
      page = 1;
      ventes = [];
    }
    listStatus = VenteStatus.loading;
    listError = null;
    notifyListeners();
    try {
      final result = await _service.fetchVentes(
        page: page,
        statut: statutFilter,
        cliId: cliIdFilter,
      );
      ventes = reset ? result.data : [...ventes, ...result.data];
      listMeta = result.meta;
      listStatus = VenteStatus.success;
    } catch (e) {
      listError = _parseError(e);
      listStatus = VenteStatus.error;
    }
    notifyListeners();
  }

  void setStatutFilter(String? v) {
    statutFilter = v;
    loadVentes(reset: true);
  }

  void setCliIdFilter(String? v) {
    cliIdFilter = v;
    loadVentes(reset: true);
  }

  Future<void> loadMore() async {
    if (listMeta == null) return;
    if (page >= listMeta!.totalPages) return;
    page += 1;
    await loadVentes();
  }

  // ─── DÉTAIL METHODS ─────────────────────────────────────────────

  Future<void> loadVenteDetail(String id) async {
    detailStatus = VenteStatus.loading;
    detailError = null;
    notifyListeners();
    try {
      selectedVente = await _service.fetchVenteById(id);
      detailStatus = VenteStatus.success;
    } catch (e) {
      detailError = _parseError(e);
      detailStatus = VenteStatus.error;
    }
    notifyListeners();
  }

  // ─── REÇU METHODS ───────────────────────────────────────────────

  Future<void> loadRecu(String id) async {
    recuStatus = VenteStatus.loading;
    recuError = null;
    notifyListeners();
    try {
      recu = await _service.fetchRecu(id);
      recuStatus = VenteStatus.success;
    } catch (e) {
      recuError = _parseError(e);
      recuStatus = VenteStatus.error;
    }
    notifyListeners();
  }

  // ─── PANIER METHODS (création) ───────────────────────────────────

  void startNewPanier({String? cliId, String? clientNom}) {
    panierCliId = cliId;
    panierClientNom = clientNom;
    panierLignes = [];
    createError = null;
    notifyListeners();
  }

  void setPanierClient(String cliId, String clientNom) {
    panierCliId = cliId;
    panierClientNom = clientNom;
    notifyListeners();
  }

  /// Ajoute une variante au panier, ou augmente la quantité si déjà présente.
  /// Bloque côté UI si la quantité demandée dépasse le stock disponible
  /// (le serveur revalidera de toute façon, mais on évite l'aller-retour inutile).
  String? addLigneToPanier(LignePanier ligne) {
    final idx = panierLignes.indexWhere((l) => l.varId == ligne.varId);
    if (idx >= 0) {
      final existante = panierLignes[idx];
      final nouvelleQte = existante.quantite + ligne.quantite;
      if (nouvelleQte > existante.stockDisponible) {
        return 'Stock insuffisant (disponible : ${existante.stockDisponible})';
      }
      panierLignes[idx] = existante.copyWith(quantite: nouvelleQte);
    } else {
      if (ligne.quantite > ligne.stockDisponible) {
        return 'Stock insuffisant (disponible : ${ligne.stockDisponible})';
      }
      panierLignes = [...panierLignes, ligne];
    }
    notifyListeners();
    return null;
  }

  void updateLignePanier(String varId, {int? quantite, double? remise}) {
    final idx = panierLignes.indexWhere((l) => l.varId == varId);
    if (idx < 0) return;
    panierLignes[idx] = panierLignes[idx].copyWith(
      quantite: quantite,
      remise: remise,
    );
    notifyListeners();
  }

  void removeLignePanier(String varId) {
    panierLignes = panierLignes.where((l) => l.varId != varId).toList();
    notifyListeners();
  }

  double get panierTotal =>
      panierLignes.fold(0.0, (sum, l) => sum + l.montantNet);

  Future<bool> submitPanier() async {
    if (panierCliId == null) {
      createError = 'Veuillez sélectionner un client';
      notifyListeners();
      return false;
    }
    if (panierLignes.isEmpty) {
      createError = 'Veuillez ajouter au moins un article';
      notifyListeners();
      return false;
    }
    creating = true;
    createError = null;
    notifyListeners();
    try {
      await _service.createVente(cliId: panierCliId!, lignes: panierLignes);
      panierLignes = [];
      panierCliId = null;
      panierClientNom = null;
      creating = false;
      await loadVentes(reset: true);
      return true;
    } catch (e) {
      createError = _parseError(e);
      creating = false;
      notifyListeners();
      return false;
    }
  }

  // ─── ACTIONS STATUT (valider / annuler) ──────────────────────────

  Future<bool> validerVente(String id) =>
      _changerStatut(id, StatutVente.validee);

  Future<bool> annulerVente(String id) =>
      _changerStatut(id, StatutVente.annulee);

  Future<bool> _changerStatut(String id, StatutVente statut) async {
    updatingStatut = true;
    statutActionError = null;
    notifyListeners();
    try {
      final updated = await _service.updateStatut(id, statut);
      selectedVente = updated;
      // reflète aussi le changement dans la liste si la vente y est déjà chargée
      final idx = ventes.indexWhere((v) => v.id == id);
      if (idx >= 0) ventes[idx] = updated;
      updatingStatut = false;
      notifyListeners();
      return true;
    } catch (e) {
      statutActionError = _parseError(e);
      updatingStatut = false;
      notifyListeners();
      return false;
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────

  String _parseError(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Une erreur est survenue';
  }
}
