import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;

  Future<void> tryAutoLogin() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      // Restore session
      final user = await AuthService.fetchCurrentUser();
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      // If network fails but cached user exists
      final cached = await AuthService.getSavedUser();
      if (cached != null) {
        _currentUser = cached;
        _status = AuthStatus.authenticated;
      } else {
        await AuthService.clearAuthData();
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.login(email, password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String registrationNumber,
    required String specialization,
    int? hospitalId,
    required String department,
    required String district,
    String? qualification,
    int? experienceYears,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.registerDoctor(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        registrationNumber: registrationNumber,
        specialization: specialization,
        hospitalId: hospitalId,
        department: department,
        district: district,
        qualification: qualification,
        experienceYears: experienceYears,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      final user = await AuthService.fetchCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (_) {}
  }
}
