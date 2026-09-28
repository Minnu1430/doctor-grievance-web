class SlaSettingItem {
  final int id;
  final String priority;
  final int targetResponseHours;
  final int targetResolutionHours;
  final String? description;

  SlaSettingItem({
    required this.id,
    required this.priority,
    required this.targetResponseHours,
    required this.targetResolutionHours,
    this.description,
  });

  factory SlaSettingItem.fromJson(Map<String, dynamic> json) {
    return SlaSettingItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      priority: json['priority'] ?? '',
      targetResponseHours: json['target_response_hours'] != null
          ? int.parse(json['target_response_hours'].toString())
          : 24,
      targetResolutionHours: json['target_resolution_hours'] != null
          ? int.parse(json['target_resolution_hours'].toString())
          : 72,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priority': priority,
      'target_response_hours': targetResponseHours,
      'target_resolution_hours': targetResolutionHours,
      'description': description,
    };
  }
}
