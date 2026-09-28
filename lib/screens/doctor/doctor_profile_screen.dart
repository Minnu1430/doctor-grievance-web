import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/hospital_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/master_data_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _specController;
  late TextEditingController _deptController;
  late TextEditingController _districtController;
  late TextEditingController _qualController;
  late TextEditingController _expController;

  int? _selectedHospitalId;
  List<Hospital> _hospitals = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final doc = user?.doctorProfile;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _specController = TextEditingController(text: doc?.specialization ?? '');
    _deptController = TextEditingController(text: doc?.department ?? '');
    _districtController = TextEditingController(text: doc?.district ?? '');
    _qualController = TextEditingController(text: doc?.qualification ?? '');
    _expController =
        TextEditingController(text: doc?.experienceYears?.toString() ?? '0');
    _selectedHospitalId = doc?.hospitalId;

    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final list = await MasterDataService.getHospitals();
      if (mounted) setState(() => _hospitals = list);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specController.dispose();
    _deptController.dispose();
    _districtController.dispose();
    _qualController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await AuthService.updateDoctorProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization: _specController.text.trim(),
        hospitalId: _selectedHospitalId,
        department: _deptController.text.trim(),
        district: _districtController.text.trim(),
        qualification: _qualController.text.trim(),
        experienceYears: int.tryParse(_expController.text.trim()),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshProfile();

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor profile updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final doc = user?.doctorProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancel Edit' : 'Edit Profile',
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Top Profile Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: const Icon(Icons.person,
                        size: 45, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Doctor',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TSMC Reg: ${doc?.registrationNumber ?? 'Verified Doctor'}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_isEditing) ...[
              // Read-only Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _ProfileRow(
                          label: 'Email',
                          value: user?.email ?? 'N/A',
                          icon: Icons.email_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'Phone',
                          value: user?.phone ?? 'Not provided',
                          icon: Icons.phone_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'Specialization',
                          value: doc?.specialization ?? 'N/A',
                          icon: Icons.medical_services_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'Hospital',
                          value: doc?.hospitalName ?? 'Government Hospital',
                          icon: Icons.local_hospital_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'Department',
                          value: doc?.department ?? 'N/A',
                          icon: Icons.business_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'District',
                          value: doc?.district ?? 'Telangana',
                          icon: Icons.location_on_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'Qualification',
                          value: doc?.qualification ?? 'MBBS',
                          icon: Icons.school_outlined),
                      const Divider(),
                      _ProfileRow(
                          label: 'Experience',
                          value: '${doc?.experienceYears ?? 0} Years',
                          icon: Icons.work_outline),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Editable Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _specController,
                      decoration:
                          const InputDecoration(labelText: 'Specialization'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedHospitalId,
                      decoration: const InputDecoration(labelText: 'Hospital'),
                      items: _hospitals.map((h) {
                        return DropdownMenuItem<int>(
                          value: h.id,
                          child: Text(h.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedHospitalId = val),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deptController,
                      decoration:
                          const InputDecoration(labelText: 'Department'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(labelText: 'District'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _qualController,
                      decoration:
                          const InputDecoration(labelText: 'Qualification'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _expController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Experience (Years)'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
