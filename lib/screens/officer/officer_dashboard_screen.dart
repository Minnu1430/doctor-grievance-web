import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
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
    await Future.wait([
      complaintProvider.fetchComplaints(assignedOnly: true),
      notifProvider.fetchNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final user = authProvider.currentUser;

    final assignedCount = complaintProvider.complaints.length;
    final activeInquiries = complaintProvider.complaints
        .where(
            (c) => c.status == 'Under Investigation' || c.status == 'Assigned')
        .length;
    final actionRequired = complaintProvider.complaints
        .where((c) => c.status == 'Action Required')
        .length;
    final resolvedCases = complaintProvider.complaints
        .where((c) => c.status == 'Resolved')
        .length;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Officer Inquiry Portal'),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Officer Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complaint Officer Workspace',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.fullName ?? 'Complaint Officer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Review assigned grievances, record inquiry findings, communicate with doctors, and submit resolution recommendations.',
                      style: TextStyle(color: Colors.white, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Cards
              const Text(
                'Assigned Case Load',
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
                    title: 'Total Assigned',
                    value: '$assignedCount',
                    icon: Icons.assignment_turned_in_outlined,
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.assignedComplaints),
                  ),
                  StatCard(
                    title: 'Active Inquiries',
                    value: '$activeInquiries',
                    icon: Icons.search,
                    color: AppColors.statusInvestigation,
                    onTap: () {
                      complaintProvider.setStatusFilter('Under Investigation');
                      Navigator.pushNamed(
                          context, AppRoutes.assignedComplaints);
                    },
                  ),
                  StatCard(
                    title: 'Action Required',
                    value: '$actionRequired',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.statusActionRequired,
                    onTap: () {
                      complaintProvider.setStatusFilter('Action Required');
                      Navigator.pushNamed(
                          context, AppRoutes.assignedComplaints);
                    },
                  ),
                  StatCard(
                    title: 'Resolved Cases',
                    value: '$resolvedCases',
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusResolved,
                    onTap: () {
                      complaintProvider.setStatusFilter('Resolved');
                      Navigator.pushNamed(
                          context, AppRoutes.assignedComplaints);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Queue Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Investigation Queue',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.assignedComplaints),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                        'No active grievances currently assigned to your queue.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaintProvider.complaints.take(5).length,
                  itemBuilder: (context, index) {
                    final c = complaintProvider.complaints[index];
                    return _OfficerComplaintCard(complaint: c);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficerComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const _OfficerComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(complaint.createdAt);
    } catch (_) {}

    final formattedDate =
        parsedDate != null ? DateFormat('dd MMM yyyy').format(parsedDate) : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  complaint.complaintNumber,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                Text(formattedDate,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              complaint.subject,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Doctor: ${complaint.doctorName ?? 'Doctor'} (${complaint.doctorRegNo ?? 'TSMC'})',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary),
            ),
            Text(
              'Hospital: ${complaint.hospitalName ?? 'N/A'} • Dept: ${complaint.department ?? 'N/A'}',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: complaint.status),
                PriorityBadge(priority: complaint.priority),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.complaintDetails,
                          arguments: complaint.id);
                    },
                    child: const Text('View Case'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.investigation,
                          arguments: complaint.id);
                    },
                    child: const Text('Investigate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
