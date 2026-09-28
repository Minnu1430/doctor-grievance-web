import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: 'doctor.rahul@tch.telangana.gov.in');
  final _passwordController = TextEditingController(text: 'Password@123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(String email, String role) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'Password@123';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filled demo credentials for $role'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showServerConfigDialog() {
    final urlController = TextEditingController(text: AppConfig.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Backend URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify the backend server address (e.g., http://10.0.2.2:5000/api for Android emulator, or http://localhost:5000/api for web/desktop):',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base API URL',
                hintText: 'http://10.0.2.2:5000/api',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AppConfig.customBaseUrl = urlController.text.trim();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Base URL set to ${AppConfig.baseUrl}')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success && authProvider.currentUser != null) {
      final role = authProvider.currentUser!.role;
      if (role == 'Doctor') {
        Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
      } else if (role == 'Complaint Officer') {
        Navigator.pushReplacementNamed(context, AppRoutes.officerDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ??
              'Login failed. Please check credentials.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authProvider.status == AuthStatus.authenticating,
        message: 'Authenticating with Telangana Council portal...',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Insignia
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primaryLight, width: 2),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Telangana Council of Hospitals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Doctor Grievance Resolution Portal',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Login Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Official Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!val.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                child: const Text(
                                  'Sign In to Council Portal',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Demo Quick-Fill Shortcuts
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.flash_on,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'DEMO ACCOUNTS (Click to quick-fill)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Doctor Rahul',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.medical_services,
                                    size: 14),
                                onPressed: () => _fillDemo(
                                    'doctor.rahul@tch.telangana.gov.in',
                                    'Doctor (Rahul)'),
                              ),
                              ActionChip(
                                label: const Text('Doctor Sneha',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.medical_services,
                                    size: 14),
                                onPressed: () => _fillDemo(
                                    'doctor.sneha@tch.telangana.gov.in',
                                    'Doctor (Sneha)'),
                              ),
                              ActionChip(
                                label: const Text('Officer Ananya',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.badge, size: 14),
                                onPressed: () => _fillDemo(
                                    'officer.hyderabad@tch.telangana.gov.in',
                                    'Complaint Officer'),
                              ),
                              ActionChip(
                                label: const Text('Council Admin',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.admin_panel_settings,
                                    size: 14),
                                onPressed: () => _fillDemo(
                                    'admin@tch.telangana.gov.in',
                                    'Council Admin'),
                              ),
                              ActionChip(
                                label: const Text('Super Admin',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.security, size: 14),
                                onPressed: () => _fillDemo(
                                    'superadmin@tch.telangana.gov.in',
                                    'Super Admin'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Register Doctor Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New TSMC Doctor? ',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text(
                          'Register Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Server Settings link
                  TextButton.icon(
                    onPressed: _showServerConfigDialog,
                    icon: const Icon(Icons.settings_ethernet,
                        size: 14, color: AppColors.textMuted),
                    label: Text(
                      'API Host: ${AppConfig.baseUrl}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
