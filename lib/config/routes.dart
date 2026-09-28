import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_doctor_screen.dart';
import '../screens/doctor/doctor_dashboard_screen.dart';
import '../screens/doctor/submit_grievance_screen.dart';
import '../screens/doctor/my_complaints_screen.dart';
import '../screens/doctor/complaint_details_screen.dart';
import '../screens/doctor/doctor_profile_screen.dart';
import '../screens/officer/officer_dashboard_screen.dart';
import '../screens/officer/assigned_complaints_screen.dart';
import '../screens/officer/investigation_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_complaints_screen.dart';
import '../screens/admin/admin_doctors_screen.dart';
import '../screens/admin/admin_officers_screen.dart';
import '../screens/admin/admin_hospitals_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/admin_audit_logs_screen.dart';
import '../screens/admin/admin_sla_settings_screen.dart';
import '../screens/shared/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Doctor routes
  static const String doctorDashboard = '/doctor/dashboard';
  static const String submitGrievance = '/doctor/submit-grievance';
  static const String myComplaints = '/doctor/my-complaints';
  static const String complaintDetails = '/complaint/details';
  static const String doctorProfile = '/doctor/profile';

  // Officer routes
  static const String officerDashboard = '/officer/dashboard';
  static const String assignedComplaints = '/officer/assigned-complaints';
  static const String investigation = '/officer/investigation';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminComplaints = '/admin/complaints';
  static const String adminDoctors = '/admin/doctors';
  static const String adminOfficers = '/admin/officers';
  static const String adminHospitals = '/admin/hospitals';
  static const String adminCategories = '/admin/categories';
  static const String adminReports = '/admin/reports';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminSlaSettings = '/admin/sla-settings';

  // Shared routes
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterDoctorScreen());

      // Doctor
      case doctorDashboard:
        return MaterialPageRoute(builder: (_) => const DoctorDashboardScreen());
      case submitGrievance:
        return MaterialPageRoute(builder: (_) => const SubmitGrievanceScreen());
      case myComplaints:
        return MaterialPageRoute(builder: (_) => const MyComplaintsScreen());
      case doctorProfile:
        return MaterialPageRoute(builder: (_) => const DoctorProfileScreen());

      // Officer
      case officerDashboard:
        return MaterialPageRoute(
            builder: (_) => const OfficerDashboardScreen());
      case assignedComplaints:
        return MaterialPageRoute(
            builder: (_) => const AssignedComplaintsScreen());
      case investigation:
        final complaintId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => InvestigationScreen(complaintId: complaintId ?? 0),
        );

      // Admin
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminComplaints:
        return MaterialPageRoute(builder: (_) => const AdminComplaintsScreen());
      case adminDoctors:
        return MaterialPageRoute(builder: (_) => const AdminDoctorsScreen());
      case adminOfficers:
        return MaterialPageRoute(builder: (_) => const AdminOfficersScreen());
      case adminHospitals:
        return MaterialPageRoute(builder: (_) => const AdminHospitalsScreen());
      case adminCategories:
        return MaterialPageRoute(builder: (_) => const AdminCategoriesScreen());
      case adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      case adminAuditLogs:
        return MaterialPageRoute(builder: (_) => const AdminAuditLogsScreen());
      case adminSlaSettings:
        return MaterialPageRoute(
            builder: (_) => const AdminSlaSettingsScreen());

      // Shared
      case complaintDetails:
        final complaintId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ComplaintDetailsScreen(complaintId: complaintId),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
