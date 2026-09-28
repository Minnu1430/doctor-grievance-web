import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';

class AssignedComplaintsScreen extends StatefulWidget {
  const AssignedComplaintsScreen({super.key});

  @override
  State<AssignedComplaintsScreen> createState() =>
      _AssignedComplaintsScreenState();
}

class _AssignedComplaintsScreenState extends State<AssignedComplaintsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false)
          .fetchComplaints(assignedOnly: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Assigned Complaints Queue'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search assigned cases...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          complaintProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => complaintProvider.setSearchQuery(val),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  complaintProvider.fetchComplaints(assignedOnly: true),
              child: complaintProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : complaintProvider.complaints.isEmpty
                      ? const EmptyStateView(
                          title: 'No Assigned Complaints',
                          message:
                              'There are no active grievances assigned to your profile.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: complaintProvider.complaints.length,
                          itemBuilder: (context, index) {
                            final c = complaintProvider.complaints[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          c.complaintNumber,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.5),
                                        ),
                                        PriorityBadge(priority: c.priority),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.subject,
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Doctor: ${c.doctorName ?? 'Doctor'} • Hospital: ${c.hospitalName ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        StatusBadge(status: c.status),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                    AppRoutes.complaintDetails,
                                                    arguments: c.id);
                                              },
                                              child: const Text('Details'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                    AppRoutes.investigation,
                                                    arguments: c.id);
                                              },
                                              child: const Text('Inquiry'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
