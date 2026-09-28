import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/sla_model.dart';
import '../../services/master_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/priority_badge.dart';

class AdminSlaSettingsScreen extends StatefulWidget {
  const AdminSlaSettingsScreen({super.key});

  @override
  State<AdminSlaSettingsScreen> createState() => _AdminSlaSettingsScreenState();
}

class _AdminSlaSettingsScreenState extends State<AdminSlaSettingsScreen> {
  List<SlaSettingItem> _slaList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSla();
  }

  Future<void> _loadSla() async {
    setState(() => _isLoading = true);
    try {
      final list = await MasterDataService.getSlaSettings();
      setState(() => _slaList = list);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showEditSlaDialog(SlaSettingItem item) {
    final respController =
        TextEditingController(text: '${item.targetResponseHours}');
    final resolController =
        TextEditingController(text: '${item.targetResolutionHours}');
    final descController = TextEditingController(text: item.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Configure SLA: ${item.priority} Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: respController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Target Response Time (Hours)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: resolController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Target Resolution Time (Hours)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Scope / Priority Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final respHours = int.tryParse(respController.text.trim());
              final resolHours = int.tryParse(resolController.text.trim());
              if (respHours == null || resolHours == null) return;

              try {
                await MasterDataService.updateSlaSetting(
                  item.priority,
                  respHours,
                  resolHours,
                  descController.text.trim(),
                );
                Navigator.pop(ctx);
                _loadSla();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'SLA settings for ${item.priority} priority updated.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: $e')),
                );
              }
            },
            child: const Text('Save Target'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configurable SLA Settings'),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Configurable application SLA targets. These response and resolution targets govern automated deadline tracking and escalation queues.',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _slaList.length,
                    itemBuilder: (context, index) {
                      final item = _slaList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  PriorityBadge(
                                      priority: item.priority, fontSize: 13),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18, color: AppColors.primary),
                                    onPressed: () => _showEditSlaDialog(item),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SlaStat(
                                      label: 'Initial Response Target',
                                      value:
                                          '${item.targetResponseHours} Hours',
                                    ),
                                  ),
                                  Expanded(
                                    child: _SlaStat(
                                      label: 'Full Resolution Target',
                                      value:
                                          '${item.targetResolutionHours} Hours (${(item.targetResolutionHours / 24).toStringAsFixed(1)} Days)',
                                    ),
                                  ),
                                ],
                              ),
                              if (item.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  item.description!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _SlaStat extends StatelessWidget {
  final String label;
  final String value;

  const _SlaStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
