import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../providers/complaint_provider.dart';
import '../../services/master_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final _searchController = TextEditingController();
  List<User> _officers = [];

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
    complaintProvider.fetchComplaints(assignedOnly: false);

    try {
      final off = await MasterDataService.getOfficers();
      setState(() => _officers = off);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAssignOfficerDialog(Complaint complaint) {
    int? selectedOfficerId = complaint.assignedOfficerId ??
        (_officers.isNotEmpty ? _officers.first.id : null);
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Assign Officer: #${complaint.complaintNumber}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Inquiry Officer:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedOfficerId,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Inquiry Officer'),
                    items: _officers.map((o) {
                      return DropdownMenuItem<int>(
                        value: o.id,
                        child: Text(o.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedOfficerId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Instructions',
                      hintText:
                          'e.g., Conduct urgent on-site verification within 48 hours...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedOfficerId == null) return;
                    final provider =
                        Provider.of<ComplaintProvider>(context, listen: false);
                    await provider.assignOfficer(
                      complaint.id,
                      selectedOfficerId!,
                      comments: commentsController.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Case assigned to Inquiry Officer.')),
                    );
                  },
                  child: const Text('Confirm Assignment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeStatusDialog(Complaint complaint) {
    String newStatus = complaint.status;
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Update Status: #${complaint.complaintNumber}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: newStatus,
                    decoration:
                        const InputDecoration(labelText: 'Target Status'),
                    items: AppConstants.statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => newStatus = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: remarksController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason / Official Remarks',
                      hintText: 'Enter justification for this status update...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final provider =
                        Provider.of<ComplaintProvider>(context, listen: false);
                    await provider.updateStatus(
                      complaint.id,
                      newStatus,
                      comments: remarksController.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status changed to $newStatus')),
                    );
                  },
                  child: const Text('Apply Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Statewide Grievance Management'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search by complaint no, subject, doctor, hospital...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          complaintProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (val) => complaintProvider.setSearchQuery(val),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  complaintProvider.fetchComplaints(assignedOnly: false),
              child: complaintProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : complaintProvider.complaints.isEmpty
                      ? const EmptyStateView(
                          title: 'No Complaints Found',
                          message: 'No complaints match the query criteria.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: complaintProvider.complaints.length,
                          itemBuilder: (context, index) {
                            final c = complaintProvider.complaints[index];
                            return _AdminComplaintCard(
                              complaint: c,
                              onAssign: () => _showAssignOfficerDialog(c),
                              onStatusChange: () => _showChangeStatusDialog(c),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onAssign;
  final VoidCallback onStatusChange;

  const _AdminComplaintCard({
    required this.complaint,
    required this.onAssign,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
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
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: AppColors.primary),
                ),
                PriorityBadge(priority: complaint.priority),
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
            ),
            const SizedBox(height: 6),
            Text(
              'Doctor: ${complaint.doctorName ?? 'Doctor'} (${complaint.doctorRegNo ?? ''})',
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary),
            ),
            Text(
              'Hospital: ${complaint.hospitalName ?? 'N/A'} • District: ${complaint.hospitalDistrict ?? 'Telangana'}',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            if (complaint.assignedOfficerName != null)
              Text(
                'Assigned Officer: ${complaint.assignedOfficerName}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: complaint.status),
                Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1_outlined,
                          color: AppColors.primary, size: 20),
                      tooltip: 'Assign Inquiry Officer',
                      onPressed: onAssign,
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync_alt_rounded,
                          color: AppColors.secondary, size: 20),
                      tooltip: 'Change Status',
                      onPressed: onStatusChange,
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new,
                          color: Colors.grey, size: 20),
                      tooltip: 'View Details',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.complaintDetails,
                            arguments: complaint.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
