class AppNotification {
  final int id;
  final int userId;
  final int? complaintId;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final String createdAt;
  final String? complaintNumber;

  AppNotification({
    required this.id,
    required this.userId,
    this.complaintId,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.type,
    required this.createdAt,
    this.complaintNumber,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId:
          json['user_id'] != null ? int.parse(json['user_id'].toString()) : 0,
      complaintId: json['complaint_id'] != null
          ? int.tryParse(json['complaint_id'].toString())
          : null,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'STATUS_CHANGE',
      createdAt: json['created_at'] ?? '',
      complaintNumber: json['complaint_number'],
    );
  }
}
