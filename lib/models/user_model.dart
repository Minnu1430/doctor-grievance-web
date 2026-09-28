class User {
  final int id;
  final String email;
  final String role;
  final String fullName;
  final String? phone;
  final bool isActive;
  final String? createdAt;
  final DoctorProfile? doctorProfile;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.isActive = true,
    this.createdAt,
    this.doctorProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] ?? '',
      role: json['role'] ?? 'Doctor',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      phone: json['phone'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] ?? json['created_at'],
      doctorProfile: json['doctorProfile'] != null
          ? DoctorProfile.fromJson(json['doctorProfile'])
          : (json['doctor_profile'] != null
              ? DoctorProfile.fromJson(json['doctor_profile'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'fullName': fullName,
      'phone': phone,
      'isActive': isActive,
      'createdAt': createdAt,
      'doctorProfile': doctorProfile?.toJson(),
    };
  }

  bool get isDoctor => role == 'Doctor';
  bool get isOfficer => role == 'Complaint Officer';
  bool get isAdmin => role == 'Council Admin';
  bool get isSuperAdmin => role == 'Super Admin';
  bool get isAnyAdmin => role == 'Council Admin' || role == 'Super Admin';
}

class DoctorProfile {
  final int? id;
  final int userId;
  final String registrationNumber;
  final String specialization;
  final int? hospitalId;
  final String department;
  final String district;
  final String? qualification;
  final int? experienceYears;
  final String? hospitalName;

  DoctorProfile({
    this.id,
    required this.userId,
    required this.registrationNumber,
    required this.specialization,
    this.hospitalId,
    required this.department,
    required this.district,
    this.qualification,
    this.experienceYears,
    this.hospitalName,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId:
          json['user_id'] != null ? int.parse(json['user_id'].toString()) : 0,
      registrationNumber: json['registration_number'] ?? '',
      specialization: json['specialization'] ?? '',
      hospitalId: json['hospital_id'] != null
          ? int.tryParse(json['hospital_id'].toString())
          : null,
      department: json['department'] ?? '',
      district: json['district'] ?? '',
      qualification: json['qualification'],
      experienceYears: json['experience_years'] != null
          ? int.tryParse(json['experience_years'].toString())
          : null,
      hospitalName: json['hospital_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'registration_number': registrationNumber,
      'specialization': specialization,
      'hospital_id': hospitalId,
      'department': department,
      'district': district,
      'qualification': qualification,
      'experience_years': experienceYears,
      'hospital_name': hospitalName,
    };
  }
}
