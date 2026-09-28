import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await ApiClient().get('/notifications');

      if (response.data['success'] == true) {
        final list = (response.data['notifications'] as List)
            .map((item) => AppNotification.fromJson(item))
            .toList();
        final unreadCount = response.data['unread_count'] is int
            ? response.data['unread_count']
            : int.tryParse(response.data['unread_count'].toString()) ?? 0;

        return {
          'notifications': list,
          'unread_count': unreadCount,
        };
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    try {
      await ApiClient().patch('/notifications/$notificationId/read');
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await ApiClient().patch('/notifications/read-all');
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
