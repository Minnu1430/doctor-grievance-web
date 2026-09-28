import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  static const String _tokenKey = 'tch_jwt_token';
  static const String _userKey = 'tch_user_data';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<String?> getToken() async {
    try {
      String? token = await _secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr);
        return User.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // API Calls
  static Future<User> login(String email, String password) async {
    try {
      final response = await ApiClient().post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      if (response.data['success'] == true) {
        final token = response.data['token'];
        final user = User.fromJson(response.data['user']);

        await saveToken(token);
        await saveUser(user);

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<User> registerDoctor({
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
    try {
      final response = await ApiClient().post('/auth/register', data: {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'phone': phone?.trim(),
        'registration_number': registrationNumber.trim(),
        'specialization': specialization.trim(),
        'hospital_id': hospitalId,
        'department': department.trim(),
        'district': district.trim(),
        'qualification': qualification?.trim(),
        'experience_years': experienceYears,
      });

      if (response.data['success'] == true) {
        final token = response.data['token'];
        final user = User.fromJson(response.data['user']);

        await saveToken(token);
        await saveUser(user);

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<User> fetchCurrentUser() async {
    try {
      final response = await ApiClient().get('/auth/me');
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['user']);
        await saveUser(user);
        return user;
      } else {
        throw Exception('Failed to restore session');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> logout() async {
    try {
      await ApiClient().post('/auth/logout');
    } catch (_) {}
    await clearAuthData();
  }

  static Future<void> updateDoctorProfile({
    String? fullName,
    String? phone,
    String? specialization,
    int? hospitalId,
    String? department,
    String? district,
    String? qualification,
    int? experienceYears,
  }) async {
    try {
      final response = await ApiClient().put('/doctors/profile', data: {
        'full_name': fullName,
        'phone': phone,
        'specialization': specialization,
        'hospital_id': hospitalId,
        'department': department,
        'district': district,
        'qualification': qualification,
        'experience_years': experienceYears,
      });

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
