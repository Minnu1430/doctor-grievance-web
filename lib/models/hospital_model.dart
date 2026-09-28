class Hospital {
  final int id;
  final String name;
  final String district;
  final String? address;
  final String? hospitalType;
  final bool isActive;

  Hospital({
    required this.id,
    required this.name,
    required this.district,
    this.address,
    this.hospitalType,
    this.isActive = true,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      district: json['district'] ?? '',
      address: json['address'],
      hospitalType: json['hospital_type'] ?? json['hospitalType'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'address': address,
      'hospital_type': hospitalType,
      'is_active': isActive,
    };
  }
}
