import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  ReportSummary? _reportSummary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    try {
      final summary = await ReportService.getReportSummary();
      setState(() => _reportSummary = summary);
    } catch (_) {}

    await Future.wait([
      complaintProvider.fetchComplaints(assignedOnly: false),
      notifProvider.fetchNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final user = authProvider.currentUser;

    final totalComplaints =
        _reportSummary?.totalComplaints ?? complaintProvider.complaints.length;
    final totalDoctors = _reportSummary?.totalDoctors ?? 8;
    final totalHospitals = _reportSummary?.totalHospitals ?? 10;
    final totalResolved = _reportSummary?.totalResolved ?? 1;

    final pendingVerification = complaintProvider.complaints
        .where(
            (c) => c.status == 'Submitted' || c.status == 'Under Verification')
        .length;
    final criticalCount = complaintProvider.complaints
        .where((c) => c.priority == 'Critical')
        .length;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Telangana Council Administration'),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Council Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.role.toUpperCase()} CONSOLE',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.fullName ?? 'Council Administrator',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Statewide oversight for doctor grievances, verification, inquiry assignments, hospital governance, and resolutions.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Grid Cards
              const Text(
                'Statewide Council Metrics',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: 'Total Grievances',
                    value: '$totalComplaints',
                    icon: Icons.folder_open_rounded,
                    color: AppColors.primary,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminComplaints),
                  ),
                  StatCard(
                    title: 'Pending Verification',
                    value: '$pendingVerification',
                    icon: Icons.verified_user_outlined,
                    color: AppColors.statusVerification,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminComplaints),
                  ),
                  StatCard(
                    title: 'Critical Priority',
                    value: '$criticalCount',
                    icon: Icons.priority_high_rounded,
                    color: AppColors.priorityCritical,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminComplaints),
                  ),
                  StatCard(
                    title: 'Resolved',
                    value: '$totalResolved',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.statusResolved,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminComplaints),
                  ),
                  StatCard(
                    title: 'Registered Doctors',
                    value: '$totalDoctors',
                    icon: Icons.medical_services_outlined,
                    color: AppColors.secondary,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminDoctors),
                  ),
                  StatCard(
                    title: 'Hospitals Connected',
                    value: '$totalHospitals',
                    icon: Icons.apartment_rounded,
                    color: Colors.indigo,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminHospitals),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Management Actions
              const Text(
                'Management Shortcuts',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'All Grievances',
                      icon: Icons.list_alt,
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.adminComplaints),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Officers',
                      icon: Icons.badge_outlined,
                      color: AppColors.secondary,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.adminOfficers),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Reports',
                      icon: Icons.bar_chart_rounded,
                      color: Colors.deepPurple,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.adminReports),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Complaints
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Statewide Grievances',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.adminComplaints),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (complaintProvider.isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator()))
              else if (complaintProvider.complaints.isEmpty)
                const Center(child: Text('No complaints found.'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaintProvider.complaints.take(5).length,
                  itemBuilder: (context, index) {
                    final c = complaintProvider.complaints[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.complaintDetails,
                            arguments: c.id),
                        title: Row(
                          children: [
                            Text(c.complaintNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 8),
                            PriorityBadge(priority: c.priority, fontSize: 10),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(c.subject,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5),
                                maxLines: 1),
                            const SizedBox(height: 2),
                            Text(
                                'Doctor: ${c.doctorName ?? 'Doctor'} • ${c.hospitalName ?? 'Hospital'}',
                                style: const TextStyle(
                                    fontSize: 11.5, color: Colors.grey)),
                            const SizedBox(height: 6),
                            StatusBadge(status: c.status, fontSize: 10.5),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
