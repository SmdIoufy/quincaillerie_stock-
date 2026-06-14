import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserModel> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      /// 🔥 FORCE REFRESH TOKEN (important pour custom claims)
      final tokenResult = await user.getIdTokenResult(true);
      final token = await user.getIdToken(true);

      /// 🧪 LOG COMPLET JWT
      debugPrint("══════════════════════════════");
      debugPrint("🔥 JWT TOKEN:");
      debugPrint(token);

      debugPrint("══════════════════════════════");
      debugPrint("🔐 TOKEN CLAIMS:");
      debugPrint(tokenResult.claims.toString());

      debugPrint("👤 ROLE FROM TOKEN:");
      debugPrint(tokenResult.claims?['role'].toString());

      debugPrint("══════════════════════════════");
    }

    /// 📡 Appel backend existant (NE PAS CHANGER)
    final response = await DioClient.dio.get('/users/me');

    debugPrint("📡 BACKEND RESPONSE:");
    debugPrint(response.data.toString());

    return UserModel.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> fetchCurrentUser() async {
    if (_auth.currentUser == null) return null;

    try {
      final user = _auth.currentUser;

      final tokenResult = await user!.getIdTokenResult(true);

      debugPrint("🔍 FETCH CURRENT USER ROLE:");
      debugPrint(tokenResult.claims?['role'].toString());

      final response = await DioClient.dio.get('/users/me');

      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      debugPrint("❌ ERROR fetchCurrentUser: $e");
      return null;
    }
  }
}
