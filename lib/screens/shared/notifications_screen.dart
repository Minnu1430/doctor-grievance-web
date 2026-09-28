import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state_view.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifProvider.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifProvider.fetchNotifications(),
        child: notifProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifProvider.notifications.isEmpty
                ? const EmptyStateView(
                    title: 'No Notifications',
                    message: 'You are all caught up. New grievance updates and messages will appear here.',
                    icon: Icons.notifications_off_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifProvider.notifications.length,
                    itemBuilder: (ctx, index) {
                      final item = notifProvider.notifications[index];
                      return _NotificationTile(
                        notification: item,
                        onTap: () async {
                          if (!item.isRead) {
                            await notifProvider.markAsRead(item.id);
                          }
                          if (item.complaintId != null && ctx.mounted) {
                            Navigator.pushNamed(
                              ctx,
                              AppRoutes.complaintDetails,
                              arguments: item.complaintId!,
                            );
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    DateTime? dt;
    try {
      dt = DateTime.parse(notification.createdAt);
    } catch (_) {}
    final formattedTime = dt != null ? DateFormat('dd MMM, hh:mm a').format(dt) : '';

    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUnread ? Colors.blue.shade200 : AppColors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnread ? AppColors.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.type == 'MESSAGE'
                ? Icons.message_outlined
                : notification.type == 'CASE_ASSIGNED'
                    ? Icons.assignment_ind_outlined
                    : Icons.notifications_active_outlined,
            color: isUnread ? Colors.white : Colors.grey.shade700,
            size: 18,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: isUnread ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            Text(formattedTime, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 12.5,
                color: isUnread ? Colors.black87 : AppColors.textSecondary,
              ),
            ),
            if (notification.complaintNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                'Related Case: ${notification.complaintNumber}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
            ],
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
