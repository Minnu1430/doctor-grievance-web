class ComplaintCategory {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int displayOrder;

  ComplaintCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintCategory(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      displayOrder: json['display_order'] != null
          ? int.tryParse(json['display_order'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }
}
