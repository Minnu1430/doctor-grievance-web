class Complaint {
  final int id;
  final String complaintNumber;
  final int doctorId;
  final int categoryId;
  final String priority;
  final String status;
  final String subject;
  final String description;
  final String incidentDate;
  final int? hospitalId;
  final String? department;
  final String? involvedPerson;
  final String? additionalInfo;
  final int? assignedOfficerId;
  final String? targetResolutionDate;
  final bool isConfidential;
  final String createdAt;
  final String? updatedAt;

  // Joined metadata
  final String? doctorName;
  final String? doctorEmail;
  final String? doctorPhone;
  final String? doctorRegNo;
  final String? categoryName;
  final String? hospitalName;
  final String? hospitalDistrict;
  final String? assignedOfficerName;
  final String? assignedOfficerEmail;

  Complaint({
    required this.id,
    required this.complaintNumber,
    required this.doctorId,
    required this.categoryId,
    required this.priority,
    required this.status,
    required this.subject,
    required this.description,
    required this.incidentDate,
    this.hospitalId,
    this.department,
    this.involvedPerson,
    this.additionalInfo,
    this.assignedOfficerId,
    this.targetResolutionDate,
    this.isConfidential = true,
    required this.createdAt,
    this.updatedAt,
    this.doctorName,
    this.doctorEmail,
    this.doctorPhone,
    this.doctorRegNo,
    this.categoryName,
    this.hospitalName,
    this.hospitalDistrict,
    this.assignedOfficerName,
    this.assignedOfficerEmail,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      complaintNumber:
          json['complaint_number'] ?? json['complaintNumber'] ?? '',
      doctorId: json['doctor_id'] != null
          ? int.parse(json['doctor_id'].toString())
          : 0,
      categoryId: json['category_id'] != null
          ? int.parse(json['category_id'].toString())
          : 0,
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Submitted',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      incidentDate: json['incident_date'] ?? '',
      hospitalId: json['hospital_id'] != null
          ? int.tryParse(json['hospital_id'].toString())
          : null,
      department: json['department'],
      involvedPerson: json['involved_person'],
      additionalInfo: json['additional_info'],
      assignedOfficerId: json['assigned_officer_id'] != null
          ? int.tryParse(json['assigned_officer_id'].toString())
          : null,
      targetResolutionDate: json['target_resolution_date'],
      isConfidential: json['is_confidential'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      doctorName: json['doctor_name'],
      doctorEmail: json['doctor_email'],
      doctorPhone: json['doctor_phone'],
      doctorRegNo: json['doctor_reg_no'],
      categoryName: json['category_name'],
      hospitalName: json['hospital_name'],
      hospitalDistrict: json['hospital_district'],
      assignedOfficerName: json['assigned_officer_name'],
      assignedOfficerEmail: json['assigned_officer_email'],
    );
  }
}

class ComplaintDocument {
  final int id;
  final int complaintId;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final int uploadedBy;
  final String createdAt;
  final String? uploaderName;

  ComplaintDocument({
    required this.id,
    required this.complaintId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedBy,
    required this.createdAt,
    this.uploaderName,
  });

  factory ComplaintDocument.fromJson(Map<String, dynamic> json) {
    return ComplaintDocument(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      complaintId: json['complaint_id'] != null
          ? int.parse(json['complaint_id'].toString())
          : 0,
      fileName: json['file_name'] ?? json['fileName'] ?? '',
      filePath: json['file_path'] ?? json['filePath'] ?? '',
      fileSize: json['file_size'] != null
          ? int.parse(json['file_size'].toString())
          : 0,
      mimeType: json['mime_type'] ?? json['mimeType'] ?? '',
      uploadedBy: json['uploaded_by'] != null
          ? int.parse(json['uploaded_by'].toString())
          : 0,
      createdAt: json['created_at'] ?? '',
      uploaderName: json['uploader_name'],
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isPdf =>
      mimeType.contains('pdf') || fileName.toLowerCase().endsWith('.pdf');
  bool get isImage =>
      mimeType.contains('image') ||
      fileName.toLowerCase().endsWith('.jpg') ||
      fileName.toLowerCase().endsWith('.jpeg') ||
      fileName.toLowerCase().endsWith('.png');
}

class ComplaintMessage {
  final int id;
  final int complaintId;
  final int senderId;
  final String message;
  final bool isInternalNote;
  final String createdAt;
  final String? senderName;
  final String? senderRole;

  ComplaintMessage({
    required this.id,
    required this.complaintId,
    required this.senderId,
    required this.message,
    this.isInternalNote = false,
    required this.createdAt,
    this.senderName,
    this.senderRole,
  });

  factory ComplaintMessage.fromJson(Map<String, dynamic> json) {
    return ComplaintMessage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      complaintId: json['complaint_id'] != null
          ? int.parse(json['complaint_id'].toString())
          : 0,
      senderId: json['sender_id'] != null
          ? int.parse(json['sender_id'].toString())
          : 0,
      message: json['message'] ?? '',
      isInternalNote: json['is_internal_note'] ?? false,
      createdAt: json['created_at'] ?? '',
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
    );
  }
}

class ComplaintHistory {
  final int id;
  final int complaintId;
  final String? previousStatus;
  final String newStatus;
  final int changedBy;
  final String? comments;
  final String createdAt;
  final String? changerName;
  final String? changerRole;

  ComplaintHistory({
    required this.id,
    required this.complaintId,
    this.previousStatus,
    required this.newStatus,
    required this.changedBy,
    this.comments,
    required this.createdAt,
    this.changerName,
    this.changerRole,
  });

  factory ComplaintHistory.fromJson(Map<String, dynamic> json) {
    return ComplaintHistory(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      complaintId: json['complaint_id'] != null
          ? int.parse(json['complaint_id'].toString())
          : 0,
      previousStatus: json['previous_status'],
      newStatus: json['new_status'] ?? '',
      changedBy: json['changed_by'] != null
          ? int.parse(json['changed_by'].toString())
          : 0,
      comments: json['comments'],
      createdAt: json['created_at'] ?? '',
      changerName: json['changer_name'],
      changerRole: json['changer_role'],
    );
  }
}

class Resolution {
  final int id;
  final int complaintId;
  final String actionTaken;
  final String resolutionSummary;
  final int resolvedBy;
  final String? doctorFeedback;
  final int? doctorRating;
  final bool reopenRequested;
  final String? reopenReason;
  final String resolvedAt;
  final String? resolverName;

  Resolution({
    required this.id,
    required this.complaintId,
    required this.actionTaken,
    required this.resolutionSummary,
    required this.resolvedBy,
    this.doctorFeedback,
    this.doctorRating,
    this.reopenRequested = false,
    this.reopenReason,
    required this.resolvedAt,
    this.resolverName,
  });

  factory Resolution.fromJson(Map<String, dynamic> json) {
    return Resolution(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      complaintId: json['complaint_id'] != null
          ? int.parse(json['complaint_id'].toString())
          : 0,
      actionTaken: json['action_taken'] ?? '',
      resolutionSummary: json['resolution_summary'] ?? '',
      resolvedBy: json['resolved_by'] != null
          ? int.parse(json['resolved_by'].toString())
          : 0,
      doctorFeedback: json['doctor_feedback'],
      doctorRating: json['doctor_rating'] != null
          ? int.tryParse(json['doctor_rating'].toString())
          : null,
      reopenRequested: json['reopen_requested'] ?? false,
      reopenReason: json['reopen_reason'],
      resolvedAt: json['resolved_at'] ?? '',
      resolverName: json['resolver_name'],
    );
  }
}
