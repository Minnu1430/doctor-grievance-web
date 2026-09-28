import '../models/complaint_model.dart';
import 'api_client.dart';

class ComplaintService {
  static Future<List<Complaint>> getComplaints({
    String? status,
    String? priority,
    int? categoryId,
    int? hospitalId,
    String? search,
    bool? assignedOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'All') queryParams['status'] = status;
      if (priority != null && priority != 'All')
        queryParams['priority'] = priority;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (hospitalId != null) queryParams['hospital_id'] = hospitalId;
      if (search != null && search.trim().isNotEmpty)
        queryParams['search'] = search.trim();
      if (assignedOnly != null)
        queryParams['assigned_only'] = assignedOnly.toString();

      final response =
          await ApiClient().get('/complaints', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final list = response.data['complaints'] as List;
        return list.map((item) => Complaint.fromJson(item)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load complaints');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<Map<String, dynamic>> getComplaintDetails(
      int complaintId) async {
    try {
      final response = await ApiClient().get('/complaints/$complaintId');

      if (response.data['success'] == true) {
        final complaint = Complaint.fromJson(response.data['complaint']);
        final documents = (response.data['documents'] as List)
            .map((d) => ComplaintDocument.fromJson(d))
            .toList();
        final messages = (response.data['messages'] as List)
            .map((m) => ComplaintMessage.fromJson(m))
            .toList();
        final history = (response.data['history'] as List)
            .map((h) => ComplaintHistory.fromJson(h))
            .toList();
        final resolution = response.data['resolution'] != null
            ? Resolution.fromJson(response.data['resolution'])
            : null;

        return {
          'complaint': complaint,
          'documents': documents,
          'messages': messages,
          'history': history,
          'resolution': resolution,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load details');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<Complaint> submitComplaint({
    required int categoryId,
    required String priority,
    required String subject,
    required String description,
    required String incidentDate,
    int? hospitalId,
    String? department,
    String? involvedPerson,
    String? additionalInfo,
    bool isDraft = false,
  }) async {
    try {
      final response = await ApiClient().post('/complaints', data: {
        'category_id': categoryId,
        'priority': priority,
        'subject': subject.trim(),
        'description': description.trim(),
        'incident_date': incidentDate,
        'hospital_id': hospitalId,
        'department': department?.trim(),
        'involved_person': involvedPerson?.trim(),
        'additional_info': additionalInfo?.trim(),
        'is_draft': isDraft,
      });

      if (response.data['success'] == true) {
        return Complaint.fromJson(response.data['complaint']);
      } else {
        throw Exception(response.data['message'] ?? 'Submission failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> updateComplaintStatus(int complaintId, String newStatus,
      {String? comments, String? reason}) async {
    try {
      final response =
          await ApiClient().patch('/complaints/$complaintId/status', data: {
        'status': newStatus,
        'comments': comments ?? reason,
      });

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Status update failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> assignOfficer(int complaintId, int officerId,
      {String? comments}) async {
    try {
      final response =
          await ApiClient().post('/complaints/$complaintId/assign', data: {
        'officer_id': officerId,
        'comments': comments,
      });

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Officer assignment failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<Resolution> submitResolution(int complaintId,
      {required String actionTaken, required String resolutionSummary}) async {
    try {
      final response =
          await ApiClient().post('/complaints/$complaintId/resolution', data: {
        'action_taken': actionTaken.trim(),
        'resolution_summary': resolutionSummary.trim(),
      });

      if (response.data['success'] == true) {
        return Resolution.fromJson(response.data['resolution']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Resolution submission failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> submitFeedback(
    int complaintId, {
    String? feedback,
    int? rating,
    bool reopenRequested = false,
    String? reopenReason,
  }) async {
    try {
      final response =
          await ApiClient().post('/complaints/$complaintId/feedback', data: {
        'doctor_feedback': feedback?.trim(),
        'doctor_rating': rating,
        'reopen_requested': reopenRequested,
        'reopen_reason': reopenReason?.trim(),
      });

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Feedback submission failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
