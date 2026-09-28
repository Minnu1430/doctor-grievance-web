import 'package:flutter/material.dart';

class AppColors {
  // Primary Healthcare Blues & Teals
  static const Color primary = Color(0xFF0D47A1); // Deep Telangana Navy Blue
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF002171);
  static const Color secondary = Color(0xFF00897B); // Medical Teal
  static const Color secondaryLight = Color(0xFF4EBaaa);
  static const Color accent = Color(0xFF0288D1);

  // Surface & Background
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Status Colors
  static const Color statusDraft = Color(0xFF78909C);
  static const Color statusSubmitted = Color(0xFF1E88E5);
  static const Color statusVerification = Color(0xFF8E24AA);
  static const Color statusAccepted = Color(0xFF00897B);
  static const Color statusRejected = Color(0xFFE53935);
  static const Color statusAssigned = Color(0xFFFB8C00);
  static const Color statusInvestigation = Color(0xFFFF6F00);
  static const Color statusActionRequired = Color(0xFFD81B60);
  static const Color statusMoreInfo = Color(0xFF5E35B1);
  static const Color statusResolved = Color(0xFF2E7D32);
  static const Color statusClosed = Color(0xFF455A64);
  static const Color statusReopened = Color(0xFFC2185B);

  // Priority Colors
  static const Color priorityLow = Color(0xFF43A047);
  static const Color priorityMedium = Color(0xFFFB8C00);
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityCritical = Color(0xFFB71C1C);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
}

class AppConstants {
  static const List<String> priorities = ['Low', 'Medium', 'High', 'Critical'];

  static const List<String> statuses = [
    'Draft',
    'Submitted',
    'Under Verification',
    'Accepted',
    'Rejected',
    'Assigned',
    'Under Investigation',
    'Action Required',
    'More Information Required',
    'Resolved',
    'Closed',
    'Reopened',
  ];

  static const List<String> roles = [
    'Doctor',
    'Complaint Officer',
    'Council Admin',
    'Super Admin',
  ];
}
