import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../models/audit_model.dart';
import '../../services/master_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  List<AuditLogItem> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoading = true);
    try {
      final list = await MasterDataService.getAuditLogs();
      setState(() => _logs = list);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showLogDetails(AuditLogItem log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Audit Record: ${log.action}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoText('Action', log.action),
              _infoText('User',
                  '${log.userName ?? 'System'} (${log.userEmail ?? ''})'),
              _infoText('Role', log.role ?? 'N/A'),
              _infoText(
                  'Entity', '${log.entityType ?? ''} #${log.entityId ?? ''}'),
              _infoText('Timestamp', log.createdAt),
              _infoText('IP Address', log.ipAddress ?? '127.0.0.1'),
              const SizedBox(height: 10),
              const Text('Metadata JSON:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log.metadata != null ? jsonEncode(log.metadata) : 'None',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 12.5),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Security & Audit Logs'),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No audit logs recorded.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final item = _logs[index];
                    DateTime? dt;
                    try {
                      dt = DateTime.parse(item.createdAt);
                    } catch (_) {}
                    final formattedDate = dt != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(dt)
                        : item.createdAt;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        onTap: () => _showLogDetails(item),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history,
                              color: AppColors.primary, size: 20),
                        ),
                        title: Text(item.action,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: Text(
                          '${item.userName ?? 'User'} (${item.role ?? ''}) • $formattedDate',
                          style: const TextStyle(
                              fontSize: 11.5, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.info_outline,
                            size: 18, color: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }
}
