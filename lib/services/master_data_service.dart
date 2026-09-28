import '../models/category_model.dart';
import '../models/hospital_model.dart';
import '../models/user_model.dart';
import '../models/audit_model.dart';
import '../models/sla_model.dart';
import 'api_client.dart';

class MasterDataService {
  // Categories
  static Future<List<ComplaintCategory>> getCategories() async {
    try {
      final response = await ApiClient().get('/categories');
      if (response.data['success'] == true) {
        final list = response.data['categories'] as List;
        return list.map((c) => ComplaintCategory.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> createCategory(
      String name, String? description, int displayOrder) async {
    try {
      final response = await ApiClient().post('/categories', data: {
        'name': name.trim(),
        'description': description?.trim(),
        'display_order': displayOrder,
      });
      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> updateCategory(int id,
      {String? name,
      String? description,
      int? displayOrder,
      bool? isActive}) async {
    try {
      final response = await ApiClient().put('/categories/$id', data: {
        'name': name,
        'description': description,
        'display_order': displayOrder,
        'is_active': isActive,
      });
      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  // Hospitals
  static Future<List<Hospital>> getHospitals(
      {String? district, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (district != null) queryParams['district'] = district;
      if (search != null) queryParams['search'] = search;

      final response =
          await ApiClient().get('/hospitals', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final list = response.data['hospitals'] as List;
        return list.map((h) => Hospital.fromJson(h)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> createHospital(
      String name, String district, String? address, String? type) async {
    try {
      final response = await ApiClient().post('/hospitals', data: {
        'name': name.trim(),
        'district': district.trim(),
        'address': address?.trim(),
        'hospital_type': type?.trim(),
      });
      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to create hospital');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> updateHospital(int id,
      {String? name,
      String? district,
      String? address,
      String? type,
      bool? isActive}) async {
    try {
      final response = await ApiClient().put('/hospitals/$id', data: {
        'name': name,
        'district': district,
        'address': address,
        'hospital_type': type,
        'is_active': isActive,
      });
      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to update hospital');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  // Officers
  static Future<List<User>> getOfficers() async {
    try {
      final response = await ApiClient().get('/users/officers');
      if (response.data['success'] == true) {
        final list = response.data['officers'] as List;
        return list.map((u) => User.fromJson(u)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> createOfficer(
      String email, String password, String fullName, String? phone) async {
    try {
      final response = await ApiClient().post('/users/officers', data: {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'phone': phone?.trim(),
      });
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to create officer');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> updateOfficer(int id,
      {String? fullName, String? phone, bool? isActive}) async {
    try {
      final response = await ApiClient().put('/users/officers/$id', data: {
        'full_name': fullName,
        'phone': phone,
        'is_active': isActive,
      });
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update officer');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  // Doctors
  static Future<List<Map<String, dynamic>>> getDoctors(
      {String? search, String? district}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (district != null) queryParams['district'] = district;

      final response =
          await ApiClient().get('/doctors', queryParameters: queryParams);
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['doctors']);
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> toggleDoctorStatus(int doctorId, bool isActive) async {
    try {
      final response =
          await ApiClient().patch('/doctors/$doctorId/status', data: {
        'is_active': isActive,
      });
      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to update doctor status');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  // Audit Logs
  static Future<List<AuditLogItem>> getAuditLogs(
      {String? action, String? role}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (action != null) queryParams['action'] = action;
      if (role != null) queryParams['role'] = role;

      final response =
          await ApiClient().get('/audit-logs', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final list = response.data['audit_logs'] as List;
        return list.map((a) => AuditLogItem.fromJson(a)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  // SLA Settings
  static Future<List<SlaSettingItem>> getSlaSettings() async {
    try {
      final response = await ApiClient().get('/sla');
      if (response.data['success'] == true) {
        final list = response.data['sla_settings'] as List;
        return list.map((s) => SlaSettingItem.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> updateSlaSetting(String priority, int responseHours,
      int resolutionHours, String? description) async {
    try {
      final response = await ApiClient().put('/sla/$priority', data: {
        'target_response_hours': responseHours,
        'target_resolution_hours': resolutionHours,
        'description': description,
      });
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update SLA');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
