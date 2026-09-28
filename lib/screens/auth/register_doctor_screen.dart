import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/hospital_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/master_data_service.dart';
import '../../widgets/loading_overlay.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNoController = TextEditingController();
  final _specializationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _qualificationController = TextEditingController(text: 'MBBS, MD');
  final _experienceController = TextEditingController(text: '3');

  String _selectedDistrict = 'Hyderabad';
  int? _selectedHospitalId;
  List<Hospital> _hospitals = [];
  bool _isLoadingHospitals = false;
  bool _obscurePassword = true;

  final List<String> _districts = [
    'Hyderabad',
    'Secunderabad',
    'Warangal',
    'Nizamabad',
    'Karimnagar',
    'Khammam',
    'Mahabubnagar',
    'Nalgonda',
    'Adilabad',
    'Medak',
    'Siddipet',
    'Suryapet',
    'Mancherial',
    'Jagtial',
  ];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _regNoController.dispose();
    _specializationController.dispose();
    _departmentController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoadingHospitals = true);
    try {
      final list = await MasterDataService.getHospitals();
      setState(() {
        _hospitals = list;
        if (_hospitals.isNotEmpty) {
          _selectedHospitalId = _hospitals.first.id;
        }
      });
    } catch (_) {}
    setState(() => _isLoadingHospitals = false);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.registerDoctor(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      registrationNumber: _regNoController.text.trim(),
      specialization: _specializationController.text.trim(),
      hospitalId: _selectedHospitalId,
      department: _departmentController.text.trim(),
      district: _selectedDistrict,
      qualification: _qualificationController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Doctor profile registered successfully! Welcome to the Council portal.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.doctorDashboard, (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
      ),
      body: LoadingOverlay(
        isLoading: authProvider.status == AuthStatus.authenticating,
        message: 'Creating verified doctor account...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Register with your official State Medical Council (TSMC) credentials for grievance management.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Personal & Account Details',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 12),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Full Name (with title Dr.) *'),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Official Email *'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty)
                      return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Mobile Phone Number'),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Professional & Hospital Details',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 12),

                // TSMC Reg No
                TextFormField(
                  controller: _regNoController,
                  decoration: const InputDecoration(
                    labelText: 'TSMC / Medical Council Reg No *',
                    hintText: 'e.g., TSMC/2022/12345',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Registration number is required'
                      : null,
                ),
                const SizedBox(height: 12),

                // Specialization
                TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization *',
                    hintText:
                        'e.g., General Medicine, Anesthesiology, General Surgery',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Specialization is required'
                      : null,
                ),
                const SizedBox(height: 12),

                // Department
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    hintText: 'e.g., Department of Internal Medicine',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Department is required'
                      : null,
                ),
                const SizedBox(height: 12),

                // Hospital Dropdown
                _isLoadingHospitals
                    ? const Center(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator()))
                    : DropdownButtonFormField<int>(
                        value: _selectedHospitalId,
                        decoration: const InputDecoration(
                            labelText: 'Attached Hospital / Medical College'),
                        items: _hospitals.map((h) {
                          return DropdownMenuItem<int>(
                            value: h.id,
                            child: Text(
                              '${h.name} (${h.district})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedHospitalId = val),
                      ),
                const SizedBox(height: 12),

                // District Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(labelText: 'District *'),
                  items: _districts.map((d) {
                    return DropdownMenuItem<String>(
                      value: d,
                      child: Text(d),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDistrict = val);
                  },
                ),
                const SizedBox(height: 12),

                // Qualification & Experience
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _qualificationController,
                        decoration:
                            const InputDecoration(labelText: 'Qualification'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Exp (Years)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('Complete Doctor Registration',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
