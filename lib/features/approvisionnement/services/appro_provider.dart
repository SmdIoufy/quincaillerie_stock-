import 'package:flutter/material.dart';
import '../models/appro_models.dart';
import '../../catalogue/models/catalogue_models.dart';
import 'appro_service.dart';

enum ApproStatus { initial, loading, success, error }

class ApproProvider extends ChangeNotifier {
  final _service = ApproService();

  // ─── LISTE ─────────────────────────────────────────────────────
  List<Approvisionnement> approvisionnements = [];
  ApproStatus listStatus = ApproStatus.initial;
  String? listError;
  PaginatedMeta? listMeta;
  int page = 1;
  String? statutFilter;
  String? fourIdFilter;

  // ─── DÉTAIL ────────────────────────────────────────────────────
  Approvisionnement? selectedAppro;
  ApproStatus detailStatus = ApproStatus.initial;
  String? detailError;

  // ─── PANIER EN COURS DE CRÉATION ────────────────────────────────
  String? panierFourId;
  String? panierFournisseurNom;
  double panierFrais = 0;
  String? panierNoteInterne;
  List<LigneApproPanier> panierLignes = [];
  bool creating = false;
  String? createError;

  // ─── ACTION STATUT (valider / annuler) ──────────────────────────
  bool updatingStatut = false;
  String? statutActionError;

  // ─── LISTE METHODS ───────────────────────────────────────────────

  Future<void> loadApprovisionnements({bool reset = false}) async {
    if (reset) {
      page = 1;
      approvisionnements = [];
    }
    listStatus = ApproStatus.loading;
    listError = null;
    notifyListeners();
    try {
      final result = await _service.fetchApprovisionnements(
        page: page,
        statut: statutFilter,
        fourId: fourIdFilter,
      );
      approvisionnements =
          reset ? result.data : [...approvisionnements, ...result.data];
      listMeta = result.meta;
      listStatus = ApproStatus.success;
    } catch (e) {
      listError = _parseError(e);
      listStatus = ApproStatus.error;
    }
    notifyListeners();
  }

  void setStatutFilter(String? v) {
    statutFilter = v;
    loadApprovisionnements(reset: true);
  }

  Future<void> loadMore() async {
    if (listMeta == null) return;
    if (page >= listMeta!.totalPages) return;
    page += 1;
    await loadApprovisionnements();
  }

  // ─── DÉTAIL METHODS ─────────────────────────────────────────────

  Future<void> loadApproDetail(String id) async {
    detailStatus = ApproStatus.loading;
    detailError = null;
    notifyListeners();
    try {
      selectedAppro = await _service.fetchApproById(id);
      detailStatus = ApproStatus.success;
    } catch (e) {
      detailError = _parseError(e);
      detailStatus = ApproStatus.error;
    }
    notifyListeners();
  }

  // ─── PANIER METHODS (création) ───────────────────────────────────

  void startNewPanier({String? fourId, String? fournisseurNom}) {
    panierFourId = fourId;
    panierFournisseurNom = fournisseurNom;
    panierFrais = 0;
    panierNoteInterne = null;
    panierLignes = [];
    createError = null;
    notifyListeners();
  }

  void setPanierFournisseur(String fourId, String fournisseurNom) {
    panierFourId = fourId;
    panierFournisseurNom = fournisseurNom;
    notifyListeners();
  }

  void setPanierFrais(double frais) {
    panierFrais = frais;
    notifyListeners();
  }

  void setPanierNoteInterne(String? note) {
    panierNoteInterne = note;
    notifyListeners();
  }

  /// Ajoute une variante au panier, ou augmente la quantité si déjà présente.
  /// Pas de blocage stock ici — contrairement à la vente, l'approvisionnement
  /// AJOUTE du stock, donc aucune limite de quantité disponible à vérifier.
  void addLigneToPanier(LigneApproPanier ligne) {
    final idx = panierLignes.indexWhere((l) => l.varId == ligne.varId);
    if (idx >= 0) {
      final existante = panierLignes[idx];
      panierLignes[idx] =
          existante.copyWith(quantite: existante.quantite + ligne.quantite);
    } else {
      panierLignes = [...panierLignes, ligne];
    }
    notifyListeners();
  }

  void updateLignePanier(String varId,
      {int? quantite, double? prixAchat, double? remise}) {
    final idx = panierLignes.indexWhere((l) => l.varId == varId);
    if (idx < 0) return;
    panierLignes[idx] = panierLignes[idx].copyWith(
      quantite: quantite,
      prixAchat: prixAchat,
      remise: remise,
    );
    notifyListeners();
  }

  void removeLignePanier(String varId) {
    panierLignes = panierLignes.where((l) => l.varId != varId).toList();
    notifyListeners();
  }

  double get panierTotal =>
      panierLignes.fold(0.0, (sum, l) => sum + l.montantNet) + panierFrais;

  Future<bool> submitPanier() async {
    if (panierFourId == null) {
      createError = 'Veuillez sélectionner un fournisseur';
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
      await _service.createAppro(
        fourId: panierFourId!,
        lignes: panierLignes,
        frais: panierFrais,
        noteInterne: panierNoteInterne,
      );
      panierLignes = [];
      panierFourId = null;
      panierFournisseurNom = null;
      panierFrais = 0;
      panierNoteInterne = null;
      creating = false;
      await loadApprovisionnements(reset: true);
      return true;
    } catch (e) {
      createError = _parseError(e);
      creating = false;
      notifyListeners();
      return false;
    }
  }

  // ─── ACTIONS STATUT (valider / annuler) ──────────────────────────

  Future<bool> validerAppro(String id) =>
      _changerStatut(id, StatutAppro.validee);

  Future<bool> annulerAppro(String id) =>
      _changerStatut(id, StatutAppro.annulee);

  Future<bool> _changerStatut(String id, StatutAppro statut) async {
    updatingStatut = true;
    statutActionError = null;
    notifyListeners();
    try {
      final updated = await _service.updateStatut(id, statut);
      selectedAppro = updated;
      final idx = approvisionnements.indexWhere((a) => a.id == id);
      if (idx >= 0) approvisionnements[idx] = updated;
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
