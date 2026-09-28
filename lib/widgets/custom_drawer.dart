import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final isDoctor = user?.isDoctor ?? false;
    final isOfficer = user?.isOfficer ?? false;
    final isAdmin = user?.isAnyAdmin ?? false;

    return Drawer(
      child: Column(
        children: [
          // Council Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TELANGANA COUNCIL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Doctor Grievance System',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user?.role ?? 'Doctor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drawer Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // DOCTOR LINKS
                if (isDoctor) ...[
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.doctorDashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Submit Grievance',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.submitGrievance),
                  ),
                  _DrawerItem(
                    icon: Icons.list_alt_rounded,
                    title: 'My Complaints',
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.myComplaints),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Doctor Profile',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.doctorProfile),
                  ),
                ],

                // OFFICER LINKS
                if (isOfficer) ...[
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Officer Dashboard',
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.officerDashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.assignment_outlined,
                    title: 'Assigned Complaints',
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.assignedComplaints),
                  ),
                ],

                // ADMIN & SUPER ADMIN LINKS
                if (isAdmin) ...[
                  _DrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Council Dashboard',
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.adminDashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.folder_open_rounded,
                    title: 'All Complaints',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminComplaints),
                  ),
                  _DrawerItem(
                    icon: Icons.medical_services_outlined,
                    title: 'Doctor Registry',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminDoctors),
                  ),
                  _DrawerItem(
                    icon: Icons.badge_outlined,
                    title: 'Complaint Officers',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminOfficers),
                  ),
                  _DrawerItem(
                    icon: Icons.apartment_rounded,
                    title: 'Hospitals Directory',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminHospitals),
                  ),
                  _DrawerItem(
                    icon: Icons.category_outlined,
                    title: 'Complaint Categories',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminCategories),
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports & Analytics',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminReports),
                  ),
                  _DrawerItem(
                    icon: Icons.history_edu_rounded,
                    title: 'Audit Logs',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminAuditLogs),
                  ),
                  _DrawerItem(
                    icon: Icons.timer_outlined,
                    title: 'SLA Configuration',
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.adminSlaSettings),
                  ),
                ],

                const Divider(),
                _DrawerItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.notifications),
                ),
              ],
            ),
          ),

          // Bottom Logout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                minimumSize: const Size(double.infinity, 45),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (r) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryLight, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () {
        Navigator.pop(context); // close drawer
        onTap();
      },
    );
  }
}
