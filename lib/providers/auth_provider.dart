import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();
  final _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  AuthProvider() {
    _bootstrap();
  }

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => user != null;
  bool get isInitialized => _isInitialized;

  bool get isAdmin => user?.role == "ADMIN";
  bool get isGerant => user?.role == "GERANT";

  Future<String?> _extractRoleFromToken() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final result = await currentUser.getIdTokenResult(true);
    return result.claims?['role'] as String?;
  }

  Future<void> _bootstrap() async {
    await loadCurrentUser();
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _service.login(email, password);

      final tokenRole = await _extractRoleFromToken();

      if (tokenRole != null && user != null) {
        user = user!.copyWith(role: tokenRole);
      }

      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    user = null;
    notifyListeners();
    await _service.logout();
  }

  Future<void> loadCurrentUser() async {
    user = await _service.fetchCurrentUser();

    final tokenRole = await _extractRoleFromToken();

    if (tokenRole != null && user != null) {
      user = user!.copyWith(role: tokenRole);
    }

    notifyListeners();
  }
}
