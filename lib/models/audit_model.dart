class AuditLogItem {
  final int id;
  final int? userId;
  final String? role;
  final String action;
  final String? entityType;
  final String? entityId;
  final dynamic metadata;
  final String? ipAddress;
  final String createdAt;
  final String? userName;
  final String? userEmail;

  AuditLogItem({
    required this.id,
    this.userId,
    this.role,
    required this.action,
    this.entityType,
    this.entityId,
    this.metadata,
    this.ipAddress,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory AuditLogItem.fromJson(Map<String, dynamic> json) {
    return AuditLogItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      role: json['role'],
      action: json['action'] ?? '',
      entityType: json['entity_type'],
      entityId: json['entity_id']?.toString(),
      metadata: json['metadata'],
      ipAddress: json['ip_address'],
      createdAt: json['created_at'] ?? '',
      userName: json['user_name'],
      userEmail: json['user_email'],
    );
  }
}
