import 'package:flutter/material.dart';
import '../features/auth_repo.dart';
import '../models/patient.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  Patient? _current;

  AuthProvider() {
    // attempt to restore persisted user when provider is created
    restore();
  }

  Patient? get current => _current;

  bool get isLoggedIn => _current != null;

  Future<bool> login(String username, String password) async {
    final p = await _repo.login(username, password);
    if (p != null) {
      _current = p;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _repo.logout();
    _current = null;
    notifyListeners();
  }

  Future<void> restore() async {
    final p = await _repo.getCurrentPatient();
    if (p != null) {
      _current = p;
      notifyListeners();
    }
  }
}
