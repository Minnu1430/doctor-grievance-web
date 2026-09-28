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

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
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
      complaintProvider.fetchComplaints(),
      notifProvider.fetchNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Doctor Portal'),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Doctor Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome,',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              Text(
                                user?.fullName ?? 'Doctor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user?.doctorProfile?.specialization != null)
                                Text(
                                  user!.doctorProfile!.specialization,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12.5),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined,
                              color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.submitGrievance),
                      icon: const Icon(Icons.add_circle, size: 18),
                      label: const Text('Raise Professional Grievance',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status Summary Section Header
              const Text(
                'My Grievance Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // KPI Grid Cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: 'Total Raised',
                    value: '${complaintProvider.countTotal}',
                    icon: Icons.folder_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      complaintProvider.clearFilters();
                      Navigator.pushNamed(context, AppRoutes.myComplaints);
                    },
                  ),
                  StatCard(
                    title: 'Under Investigation',
                    value: '${complaintProvider.countUnderInvestigation}',
                    icon: Icons.search,
                    color: AppColors.statusInvestigation,
                    onTap: () {
                      complaintProvider.setStatusFilter('Under Investigation');
                      Navigator.pushNamed(context, AppRoutes.myComplaints);
                    },
                  ),
                  StatCard(
                    title: 'Action Required',
                    value: '${complaintProvider.countActionRequired}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.statusActionRequired,
                    onTap: () {
                      complaintProvider.setStatusFilter('Action Required');
                      Navigator.pushNamed(context, AppRoutes.myComplaints);
                    },
                  ),
                  StatCard(
                    title: 'Resolved',
                    value: '${complaintProvider.countResolved}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusResolved,
                    onTap: () {
                      complaintProvider.setStatusFilter('Resolved');
                      Navigator.pushNamed(context, AppRoutes.myComplaints);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Complaints Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Complaints',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      complaintProvider.clearFilters();
                      Navigator.pushNamed(context, AppRoutes.myComplaints);
                    },
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
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'No Grievances Submitted',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You haven’t raised any workplace or professional complaints yet.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaintProvider.complaints.take(4).length,
                  itemBuilder: (context, index) {
                    final complaint = complaintProvider.complaints[index];
                    return _ComplaintCard(complaint: complaint);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.submitGrievance),
        icon: const Icon(Icons.add),
        label: const Text('New Grievance'),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintCard({required this.complaint});

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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.complaintDetails,
            arguments: complaint.id,
          );
        },
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
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                complaint.subject,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${complaint.categoryName ?? 'General'} • Hospital: ${complaint.hospitalName ?? 'Government Hospital'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: complaint.status),
                  PriorityBadge(priority: complaint.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
