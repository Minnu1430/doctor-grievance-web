import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/user_model.dart';
import '../../services/master_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class AdminOfficersScreen extends StatefulWidget {
  const AdminOfficersScreen({super.key});

  @override
  State<AdminOfficersScreen> createState() => _AdminOfficersScreenState();
}

class _AdminOfficersScreenState extends State<AdminOfficersScreen> {
  List<User> _officers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOfficers();
  }

  Future<void> _loadOfficers() async {
    setState(() => _isLoading = true);
    try {
      final list = await MasterDataService.getOfficers();
      setState(() => _officers = list);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showAddOfficerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: 'Password@123');
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Inquiry Officer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Full Name (e.g., Dr. Name)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: 'Official Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration:
                      const InputDecoration(labelText: 'Temporary Password'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty) return;
                try {
                  await MasterDataService.createOfficer(
                    emailController.text.trim(),
                    passwordController.text,
                    nameController.text.trim(),
                    phoneController.text.trim(),
                  );
                  Navigator.pop(ctx);
                  _loadOfficers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Officer account created successfully.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              },
              child: const Text('Create Account'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Complaint Officers Directory'),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _officers.isEmpty
              ? const Center(child: Text('No complaint officers configured.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _officers.length,
                  itemBuilder: (context, index) {
                    final officer = _officers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.secondary.withOpacity(0.15),
                          child: const Icon(Icons.badge,
                              color: AppColors.secondary),
                        ),
                        title: Text(
                          officer.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.5),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(officer.email,
                                style: const TextStyle(fontSize: 12)),
                            if (officer.phone != null)
                              Text('Phone: ${officer.phone}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddOfficerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Officer'),
      ),
    );
  }
}
