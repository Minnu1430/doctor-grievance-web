import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../../config/constants.dart';
import '../../models/category_model.dart';
import '../../models/hospital_model.dart';
import '../../providers/complaint_provider.dart';
import '../../services/complaint_service.dart';
import '../../services/document_service.dart';
import '../../services/master_data_service.dart';
import '../../widgets/loading_overlay.dart';

class SubmitGrievanceScreen extends StatefulWidget {
  const SubmitGrievanceScreen({super.key});

  @override
  State<SubmitGrievanceScreen> createState() => _SubmitGrievanceScreenState();
}

class _SubmitGrievanceScreenState extends State<SubmitGrievanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _involvedPersonController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  DateTime _incidentDate = DateTime.now();
  String _selectedPriority = 'Medium';
  int? _selectedCategoryId;
  int? _selectedHospitalId;

  List<ComplaintCategory> _categories = [];
  List<Hospital> _hospitals = [];
  final List<File> _attachedFiles = [];

  bool _isLoadingMasterData = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _involvedPersonController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoadingMasterData = true);
    try {
      final cats = await MasterDataService.getCategories();
      final hosps = await MasterDataService.getHospitals();
      setState(() {
        _categories = cats;
        _hospitals = hosps;
        if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
        if (_hospitals.isNotEmpty) _selectedHospitalId = _hospitals.first.id;
      });
    } catch (_) {}
    setState(() => _isLoadingMasterData = false);
  }

  Future<void> _pickFile() async {
    final file = await DocumentService.pickDocument();
    if (file != null) {
      setState(() => _attachedFiles.add(file));
    }
  }

  Future<void> _pickImage() async {
    final file = await DocumentService.pickImage();
    if (file != null) {
      setState(() => _attachedFiles.add(file));
    }
  }

  Future<void> _selectIncidentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _incidentDate = picked);
    }
  }

  Future<void> _handleSubmit({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a grievance category.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final complaint = await ComplaintService.submitComplaint(
        categoryId: _selectedCategoryId!,
        priority: _selectedPriority,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        incidentDate: DateFormat('yyyy-MM-dd').format(_incidentDate),
        hospitalId: _selectedHospitalId,
        department: _departmentController.text.trim(),
        involvedPerson: _involvedPersonController.text.trim(),
        additionalInfo: _additionalInfoController.text.trim(),
        isDraft: isDraft,
      );

      // Upload attached files if any
      if (_attachedFiles.isNotEmpty) {
        for (final file in _attachedFiles) {
          try {
            await DocumentService.uploadDocument(complaint.id, file);
          } catch (uploadErr) {
            debugPrint('Failed to upload file: $uploadErr');
          }
        }
      }

      if (!mounted) return;

      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);
      await complaintProvider.fetchComplaints();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft
              ? 'Grievance #${complaint.complaintNumber} saved as draft.'
              : 'Grievance #${complaint.complaintNumber} successfully submitted to Telangana Council.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Grievance'),
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting || _isLoadingMasterData,
        message: _isSubmitting
            ? 'Submitting grievance to Telangana Council...'
            : 'Loading master data...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Strict Confidentiality: Your submission is protected under Council privacy safeguards. Only assigned officers and authorized Council admins can review it.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category selection
                const Text(
                  'Grievance Category *',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(hintText: 'Select Category'),
                  items: _categories.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (val) =>
                      val == null ? 'Category is required' : null,
                ),
                const SizedBox(height: 16),

                // Priority Selection Chips
                const Text(
                  'Priority Level *',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: AppConstants.priorities.map((prio) {
                    final isSelected = _selectedPriority == prio;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(prio),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        onSelected: (selected) {
                          if (selected)
                            setState(() => _selectedPriority = prio);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Subject
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject / Title *',
                    hintText: 'Brief summary of the professional grievance',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty)
                      return 'Subject is required';
                    if (val.trim().length < 5)
                      return 'Subject must be at least 5 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Description *',
                    hintText:
                        'Provide comprehensive facts, dates, events, and evidence summary...',
                    alignLabelWithHint: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty)
                      return 'Detailed description is required';
                    if (val.trim().length < 15)
                      return 'Description must be at least 15 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Incident Date
                InkWell(
                  onTap: _selectIncidentDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Incident Date *',
                      suffixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(_incidentDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Hospital Dropdown
                const Text(
                  'Involved Hospital / Institution',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: _selectedHospitalId,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(hintText: 'Select Hospital'),
                  items: _hospitals.map((h) {
                    return DropdownMenuItem<int>(
                      value: h.id,
                      child: Text('${h.name} (${h.district})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedHospitalId = val),
                ),
                const SizedBox(height: 16),

                // Department
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Involved Department',
                    hintText: 'e.g., Casualty, ICU, Surgery, Administration',
                  ),
                ),
                const SizedBox(height: 16),

                // Person / Authority Involved
                TextFormField(
                  controller: _involvedPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Involved Person / Designation',
                    hintText:
                        'e.g., Medical Superintendent, Unit Head, Security Agency',
                  ),
                ),
                const SizedBox(height: 16),

                // Additional Info
                TextFormField(
                  controller: _additionalInfoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Additional Context / Requests',
                    hintText:
                        'Any other relevant context or urgent support needed',
                  ),
                ),
                const SizedBox(height: 20),

                // Attachments Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Supporting Documents & Evidence',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.attach_file_rounded,
                          color: AppColors.primary),
                      onSelected: (val) {
                        if (val == 'doc') _pickFile();
                        if (val == 'img') _pickImage();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'doc',
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Add Document (PDF/Doc)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'img',
                          child: Row(
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Add Photo Evidence'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_attachedFiles.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file,
                            color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Attach roster copies, memos, duty charts or photos (PDF, PNG, JPG)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attachedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _attachedFiles[index];
                      final name = p.basename(file.path);
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file,
                              color: AppColors.primary),
                          title: Text(name,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red, size: 18),
                            onPressed: () =>
                                setState(() => _attachedFiles.removeAt(index)),
                          ),
                          dense: true,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 28),

                // Submit Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleSubmit(isDraft: true),
                        child: const Text('Save as Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(isDraft: false),
                        child: const Text('Submit Grievance',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
