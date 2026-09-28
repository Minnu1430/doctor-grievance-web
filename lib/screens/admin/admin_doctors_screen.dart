import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/master_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final list = await MasterDataService.getDoctors(
          search: _searchController.text.trim());
      setState(() => _doctors = list);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleStatus(int doctorId, bool currentStatus) async {
    try {
      await MasterDataService.toggleDoctorStatus(doctorId, !currentStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Doctor account ${!currentStatus ? 'activated' : 'deactivated'} successfully.')),
      );
      _loadDoctors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Statewide Doctor Registry'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search by doctor name, TSMC reg no, specialization...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _loadDoctors,
                ),
              ),
              onSubmitted: (_) => _loadDoctors(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? const Center(child: Text('No doctors found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) {
                          final doc = _doctors[index];
                          final isActive = doc['is_active'] == true;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                child: Icon(Icons.medical_services,
                                    color:
                                        isActive ? Colors.green : Colors.red),
                              ),
                              title: Text(
                                doc['full_name'] ?? 'Doctor',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'TSMC Reg: ${doc['registration_number'] ?? 'N/A'} • ${doc['specialization'] ?? 'General'}'),
                                  Text(
                                      'Hospital: ${doc['hospital_name'] ?? 'N/A'} • District: ${doc['district'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 11)),
                                  Text(
                                      'Email: ${doc['email'] ?? 'N/A'} • Phone: ${doc['phone'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                              trailing: Switch(
                                value: isActive,
                                activeColor: AppColors.primary,
                                onChanged: (_) =>
                                    _toggleStatus(doc['user_id'], isActive),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
