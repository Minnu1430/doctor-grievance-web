import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/hospital_model.dart';
import '../../services/master_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class AdminHospitalsScreen extends StatefulWidget {
  const AdminHospitalsScreen({super.key});

  @override
  State<AdminHospitalsScreen> createState() => _AdminHospitalsScreenState();
}

class _AdminHospitalsScreenState extends State<AdminHospitalsScreen> {
  List<Hospital> _hospitals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoading = true);
    try {
      final list = await MasterDataService.getHospitals();
      setState(() => _hospitals = list);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showAddHospitalDialog() {
    final nameController = TextEditingController();
    final districtController = TextEditingController(text: 'Hyderabad');
    final addressController = TextEditingController();
    final typeController =
        TextEditingController(text: 'Government Medical College Hospital');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Hospital'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Hospital Name *')),
                const SizedBox(height: 10),
                TextField(
                    controller: districtController,
                    decoration: const InputDecoration(labelText: 'District *')),
                const SizedBox(height: 10),
                TextField(
                    controller: typeController,
                    decoration:
                        const InputDecoration(labelText: 'Hospital Type')),
                const SizedBox(height: 10),
                TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address')),
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
                    districtController.text.trim().isEmpty) return;
                try {
                  await MasterDataService.createHospital(
                    nameController.text.trim(),
                    districtController.text.trim(),
                    addressController.text.trim(),
                    typeController.text.trim(),
                  );
                  Navigator.pop(ctx);
                  _loadHospitals();
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              },
              child: const Text('Add Hospital'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Connected Hospitals Directory'),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                final h = _hospitals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Icon(Icons.apartment_rounded,
                          color: Colors.indigo.shade700),
                    ),
                    title: Text(h.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'District: ${h.district} • ${h.hospitalType ?? 'Government'}',
                            style: const TextStyle(fontSize: 12)),
                        if (h.address != null)
                          Text(h.address!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              maxLines: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddHospitalDialog,
        icon: const Icon(Icons.add_business),
        label: const Text('Add Hospital'),
      ),
    );
  }
}
