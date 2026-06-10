import 'package:firebase_auth/firebase_auth.dart';
import '../core/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserModel> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    final response = await DioClient.dio.get('/users/me');
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> fetchCurrentUser() async {
    if (_auth.currentUser == null) return null;
    try {
      final response = await DioClient.dio.get('/users/me');
      return UserModel.fromJson(response.data['data']);
    } catch (_) {
      return null;
    }
  }
}
