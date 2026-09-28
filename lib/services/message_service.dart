import '../models/complaint_model.dart';
import 'api_client.dart';

class MessageService {
  static Future<List<ComplaintMessage>> getMessages(int complaintId) async {
    try {
      final response =
          await ApiClient().get('/complaints/$complaintId/messages');

      if (response.data['success'] == true) {
        final list = response.data['messages'] as List;
        return list.map((item) => ComplaintMessage.fromJson(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<ComplaintMessage> sendMessage(
    int complaintId,
    String message, {
    bool isInternalNote = false,
  }) async {
    try {
      final response =
          await ApiClient().post('/complaints/$complaintId/messages', data: {
        'message': message.trim(),
        'is_internal_note': isInternalNote,
      });

      if (response.data['success'] == true) {
        return ComplaintMessage.fromJson(response.data['complaint_message']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
