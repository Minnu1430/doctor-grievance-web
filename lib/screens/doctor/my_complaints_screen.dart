import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Grievances',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          complaintProvider.clearFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('Status',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ['All', ...AppConstants.statuses].map((st) {
                      final isSelected = complaintProvider.selectedStatus == st;
                      return ChoiceChip(
                        label: Text(st, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            complaintProvider.setStatusFilter(st);
                            setModalState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: ['All', ...AppConstants.priorities].map((pr) {
                      final isSelected =
                          complaintProvider.selectedPriority == pr;
                      return ChoiceChip(
                        label: Text(pr, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            complaintProvider.setPriorityFilter(pr);
                            setModalState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
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
      appBar: CustomAppBar(
        title: 'My Grievances',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            tooltip: 'Filter Complaints',
            onPressed: _showFilterModal,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Search & Filter header bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by complaint number, subject...',
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
                if (complaintProvider.selectedStatus != 'All' ||
                    complaintProvider.selectedPriority != 'All') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Active Filters: ',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      if (complaintProvider.selectedStatus != 'All')
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(
                                'Status: ${complaintProvider.selectedStatus}',
                                style: const TextStyle(fontSize: 10)),
                            onDeleted: () =>
                                complaintProvider.setStatusFilter('All'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      if (complaintProvider.selectedPriority != 'All')
                        Chip(
                          label: Text(
                              'Priority: ${complaintProvider.selectedPriority}',
                              style: const TextStyle(fontSize: 10)),
                          onDeleted: () =>
                              complaintProvider.setPriorityFilter('All'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // List of Complaints
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => complaintProvider.fetchComplaints(),
              child: complaintProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : complaintProvider.complaints.isEmpty
                      ? EmptyStateView(
                          title: 'No Grievances Found',
                          message:
                              'You have not raised any grievances matching the selected filters.',
                          actionLabel: 'Raise New Grievance',
                          onAction: () => Navigator.pushNamed(
                              context, AppRoutes.submitGrievance),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: complaintProvider.complaints.length,
                          itemBuilder: (context, index) {
                            final c = complaintProvider.complaints[index];
                            return _DoctorComplaintItem(complaint: c);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.submitGrievance),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DoctorComplaintItem extends StatelessWidget {
  final Complaint complaint;

  const _DoctorComplaintItem({required this.complaint});

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
                      fontSize: 13.5,
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
              const SizedBox(height: 6),
              Text(
                'Category: ${complaint.categoryName ?? 'General'}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              if (complaint.hospitalName != null)
                Text(
                  'Hospital: ${complaint.hospitalName}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
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
