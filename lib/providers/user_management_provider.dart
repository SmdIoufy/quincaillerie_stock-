import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/user_management_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementService _service = UserManagementService();

  List<UserModel> users = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchUsers({String? search}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      users = await _service.fetchUsers(search: search);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
  }) async {
    errorMessage = null;
    try {
      final created = await _service.createUser(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );
      users.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleActive(UserModel user) async {
    final index = users.indexWhere((u) => u.id == user.id);
    if (index == -1) return;

    final previous = users[index];
    final optimistic = previous.copyWith(isActive: !previous.isActive);

    users[index] = optimistic;
    notifyListeners();

    try {
      final updated = await _service.toggleActive(user.id, optimistic.isActive);
      final updatedIndex = users.indexWhere((u) => u.id == updated.id);
      if (updatedIndex != -1) {
        users[updatedIndex] = updated;
        notifyListeners();
      }
    } catch (e) {
      users[index] = previous;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
