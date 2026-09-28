import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';

class InvestigationScreen extends StatefulWidget {
  final int complaintId;

  const InvestigationScreen({super.key, required this.complaintId});

  @override
  State<InvestigationScreen> createState() => _InvestigationScreenState();
}

class _InvestigationScreenState extends State<InvestigationScreen> {
  final _inquiryNoteController = TextEditingController();
  final _actionTakenController = TextEditingController();
  final _resolutionSummaryController = TextEditingController();
  final _internalNoteController = TextEditingController();

  String _selectedStatusUpdate = 'Under Investigation';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  @override
  void dispose() {
    _inquiryNoteController.dispose();
    _actionTakenController.dispose();
    _resolutionSummaryController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    await provider.fetchComplaintDetails(widget.complaintId);
    if (provider.activeComplaint != null) {
      setState(() {
        _selectedStatusUpdate = provider.activeComplaint!.status;
      });
    }
  }

  Future<void> _handleStatusUpdate() async {
    setState(() => _isProcessing = true);
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.updateStatus(
      widget.complaintId,
      _selectedStatusUpdate,
      comments: _inquiryNoteController.text.trim(),
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        _inquiryNoteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Status updated to $_selectedStatusUpdate successfully.')),
        );
      }
    }
  }

  Future<void> _addInternalNote() async {
    final note = _internalNoteController.text.trim();
    if (note.isEmpty) return;

    setState(() => _isProcessing = true);
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.sendMessage(widget.complaintId, note,
        isInternalNote: true);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        _internalNoteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Internal inquiry note recorded.')),
        );
      }
    }
  }

  Future<void> _submitResolution() async {
    final action = _actionTakenController.text.trim();
    final summary = _resolutionSummaryController.text.trim();

    if (action.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Action taken and resolution summary are required.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success =
        await provider.recordResolution(widget.complaintId, action, summary);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Resolution successfully recorded. Case marked as Resolved.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final complaint = complaintProvider.activeComplaint;

    if (complaintProvider.isLoadingDetails && complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inquiry & Investigation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inquiry & Investigation')),
        body: const Center(child: Text('Complaint not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Inquiry: ${complaint.complaintNumber}'),
      ),
      body: LoadingOverlay(
        isLoading: _isProcessing,
        message: 'Updating inquiry records...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(complaint.complaintNumber,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          PriorityBadge(priority: complaint.priority),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(complaint.subject,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          'Doctor: ${complaint.doctorName ?? 'Doctor'} (${complaint.doctorRegNo ?? ''})',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                      Text(
                          'Hospital: ${complaint.hospitalName ?? 'N/A'} • Dept: ${complaint.department ?? 'N/A'}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 10),
                      StatusBadge(status: complaint.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 1. Status Update Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Investigation Status',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStatusUpdate,
                        decoration:
                            const InputDecoration(labelText: 'Case Status'),
                        items: [
                          'Under Investigation',
                          'Action Required',
                          'More Information Required',
                          'Resolved',
                          'Rejected',
                        ]
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedStatusUpdate = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _inquiryNoteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Inquiry Log / Status Remarks',
                          hintText:
                              'e.g., Notice issued to Hospital Superintendent on 29th Aug...',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleStatusUpdate,
                          child: const Text('Update Status & Notify Doctor'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Internal Confidential Note Section
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock,
                              size: 18, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Text(
                            'Add Confidential Council Note (Not visible to Doctor)',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _internalNoteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Confidential Note',
                          hintText:
                              'e.g., Vigilance team verified CCTV logs. Roster non-compliance established.',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800),
                        onPressed: _addInternalNote,
                        child: const Text('Save Internal Note'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Final Resolution Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Record Final Resolution & Action Taken',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _actionTakenController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Action Taken by Council / Hospital *',
                          hintText:
                              'e.g., Council issued directive to Medical Superintendent to restructure emergency roster to 12-hour max shifts.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _resolutionSummaryController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Resolution Summary *',
                          hintText:
                              'Summarize the final outcome communicated to the Doctor...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700),
                          onPressed: _submitResolution,
                          child: const Text('Complete & Resolve Case',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
