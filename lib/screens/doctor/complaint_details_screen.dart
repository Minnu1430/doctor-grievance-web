import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../services/document_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/document_tile.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/timeline_widget.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    await Provider.of<ComplaintProvider>(context, listen: false)
        .fetchComplaintDetails(widget.complaintId);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingMessage = true);
    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);
    final success =
        await complaintProvider.sendMessage(widget.complaintId, text);

    if (mounted) {
      setState(() => _isSendingMessage = false);
      if (success) {
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  complaintProvider.errorMessage ?? 'Failed to send message')),
        );
      }
    }
  }

  Future<void> _uploadNewDocument() async {
    final file = await DocumentService.pickDocument();
    if (file != null) {
      try {
        await DocumentService.uploadDocument(widget.complaintId, file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully')),
          );
          _loadDetails();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      }
    }
  }

  void _showFeedbackDialog(Resolution resolution) {
    final feedbackController =
        TextEditingController(text: resolution.doctorFeedback ?? '');
    int rating = resolution.doctorRating ?? 5;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Resolution Feedback'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rate Council Resolution Action:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        icon: Icon(
                          starVal <= rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () => setModalState(() => rating = starVal),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Your Remarks & Confirmation',
                      hintText:
                          'Provide your feedback regarding this resolution...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final provider =
                        Provider.of<ComplaintProvider>(context, listen: false);
                    await provider.submitFeedback(
                      widget.complaintId,
                      feedback: feedbackController.text.trim(),
                      rating: rating,
                    );
                    Navigator.pop(ctx);
                    _loadDetails();
                  },
                  child: const Text('Submit Feedback'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReopenDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Request Grievance Reopening'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'If the resolution did not adequately resolve your workplace issue, you can request Council review for reopening.',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for Reopening *',
                  hintText:
                      'Explain why the resolution is incomplete or pending...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700),
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) return;
                final provider =
                    Provider.of<ComplaintProvider>(context, listen: false);
                await provider.submitFeedback(
                  widget.complaintId,
                  reopenRequested: true,
                  reopenReason: reasonController.text.trim(),
                );
                Navigator.pop(ctx);
                _loadDetails();
              },
              child: const Text('Submit Reopen Request'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final complaint = complaintProvider.activeComplaint;
    final currentUserId = authProvider.currentUser?.id;

    if (complaintProvider.isLoadingDetails && complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body:
            const Center(child: Text('Grievance not found or access denied.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint.complaintNumber,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(complaint.categoryName ?? 'Grievance',
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(
                text: 'Overview', icon: Icon(Icons.info_outline, size: 18)),
            Tab(
                text: 'Timeline (${complaintProvider.activeHistory.length})',
                icon: const Icon(Icons.timeline, size: 18)),
            Tab(
                text: 'Docs (${complaintProvider.activeDocuments.length})',
                icon: const Icon(Icons.attach_file, size: 18)),
            Tab(
                text: 'Messages (${complaintProvider.activeMessages.length})',
                icon: const Icon(Icons.forum_outlined, size: 18)),
            const Tab(
                text: 'Resolution',
                icon: Icon(Icons.verified_outlined, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. OVERVIEW TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Status',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          StatusBadge(status: complaint.status),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Priority Level',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          PriorityBadge(priority: complaint.priority),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subject & Description Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Subject',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.subject,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Detailed Statement',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          complaint.description,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Incident & Hospital Metadata
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incident & Location Details',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                            label: 'Incident Date',
                            value: complaint.incidentDate),
                        _DetailRow(
                            label: 'Hospital',
                            value: complaint.hospitalName ?? 'N/A'),
                        _DetailRow(
                            label: 'District',
                            value: complaint.hospitalDistrict ?? 'Telangana'),
                        _DetailRow(
                            label: 'Department',
                            value: complaint.department ?? 'N/A'),
                        _DetailRow(
                            label: 'Person Involved',
                            value: complaint.involvedPerson ?? 'N/A'),
                        if (complaint.additionalInfo != null)
                          _DetailRow(
                              label: 'Additional Info',
                              value: complaint.additionalInfo!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Inquiry Officer Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assigned Inquiry Officer',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 10),
                        if (complaint.assignedOfficerName != null) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      complaint.assignedOfficerName!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      complaint.assignedOfficerEmail ?? '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else
                          const Text(
                            'Pending assignment by Council Admin.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. TIMELINE TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: TimelineWidget(history: complaintProvider.activeHistory),
          ),

          // 3. DOCUMENTS TAB
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attached Evidence (${complaintProvider.activeDocuments.length})',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: _uploadNewDocument,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Document'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: complaintProvider.activeDocuments.isEmpty
                      ? const Center(
                          child: Text('No supporting documents attached.'))
                      : ListView.builder(
                          itemCount: complaintProvider.activeDocuments.length,
                          itemBuilder: (context, index) {
                            final doc =
                                complaintProvider.activeDocuments[index];
                            return DocumentTile(
                              document: doc,
                              canDelete: doc.uploadedBy == currentUserId,
                              onDelete: () async {
                                await DocumentService.deleteDocument(doc.id);
                                _loadDetails();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // 4. MESSAGES TAB
          Column(
            children: [
              Expanded(
                child: complaintProvider.activeMessages.isEmpty
                    ? const Center(
                        child: Text(
                            'No messages exchanged yet.\nUse the input below to reply or provide requested information.',
                            textAlign: TextAlign.center),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: complaintProvider.activeMessages.length,
                        itemBuilder: (context, index) {
                          final msg = complaintProvider.activeMessages[index];
                          return ChatBubble(
                            message: msg,
                            isMe: msg.senderId == currentUserId,
                          );
                        },
                      ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type response / provide information...',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isSendingMessage ? null : _sendMessage,
                      icon: _isSendingMessage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 5. RESOLUTION TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: complaintProvider.activeResolution == null
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.hourglass_empty_rounded,
                            size: 48, color: Colors.orange.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Grievance In Progress',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Official Council resolution will be published here once the inquiry and actions are completed by the Complaint Officer and Council Registrar.',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resolution Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.task_alt_rounded,
                                    color: Colors.green.shade800, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Official Council Resolution',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Action Taken:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaintProvider.activeResolution!.actionTaken,
                              style:
                                  const TextStyle(fontSize: 13.5, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Resolution Summary:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaintProvider
                                  .activeResolution!.resolutionSummary,
                              style:
                                  const TextStyle(fontSize: 13.5, height: 1.4),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Resolved by: ${complaintProvider.activeResolution!.resolverName ?? 'Council Admin'}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Doctor Feedback & Rating Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Doctor Feedback & Acknowledgement',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(height: 10),
                              if (complaintProvider
                                      .activeResolution!.doctorRating !=
                                  null) ...[
                                Row(
                                  children: [
                                    const Text('Rating: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    ...List.generate(5, (index) {
                                      return Icon(
                                        index <
                                                complaintProvider
                                                    .activeResolution!
                                                    .doctorRating!
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (complaintProvider
                                        .activeResolution!.doctorFeedback !=
                                    null)
                                  Text(
                                      'Remarks: ${complaintProvider.activeResolution!.doctorFeedback!}'),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showFeedbackDialog(
                                          complaintProvider.activeResolution!),
                                      icon: const Icon(Icons.rate_review,
                                          size: 16),
                                      label: Text(complaintProvider
                                                  .activeResolution!
                                                  .doctorRating !=
                                              null
                                          ? 'Edit Feedback'
                                          : 'Provide Feedback'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red.shade700),
                                      onPressed: _showReopenDialog,
                                      icon: const Icon(Icons.replay_rounded,
                                          size: 16),
                                      label: const Text('Request Reopen'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
