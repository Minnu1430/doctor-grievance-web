import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await NotificationService.getNotifications();
      _notifications = data['notifications'] ?? [];
      _unreadCount = data['unread_count'] ?? 0;
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx >= 0 && !_notifications[idx].isRead) {
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        await fetchNotifications();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      _unreadCount = 0;
      await fetchNotifications();
    } catch (_) {}
  }
}
