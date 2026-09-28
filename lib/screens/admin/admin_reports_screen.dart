import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/constants.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  ReportSummary? _summary;
  bool _isLoading = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await ReportService.getReportSummary();
      setState(() => _summary = data);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _export(String format) async {
    setState(() => _isExporting = true);
    try {
      await ReportService.exportReport(format);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Report exported as ${format.toUpperCase()} successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reports & Analytics'),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? const Center(child: Text('Failed to load report data.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Export Action Bar
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Export Official Reports',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting
                                        ? null
                                        : () => _export('csv'),
                                    icon: const Icon(Icons.table_chart_outlined,
                                        size: 16),
                                    label: const Text('CSV',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting
                                        ? null
                                        : () => _export('excel'),
                                    icon: const Icon(Icons.grid_on_outlined,
                                        size: 16, color: Colors.green),
                                    label: const Text('Excel',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.green)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting
                                        ? null
                                        : () => _export('pdf'),
                                    icon: const Icon(
                                        Icons.picture_as_pdf_outlined,
                                        size: 16,
                                        color: Colors.red),
                                    label: const Text('PDF',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.red)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Metrics Banner
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Total Raised',
                              value: '${_summary!.totalComplaints}',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              title: 'Resolved Cases',
                              value: '${_summary!.totalResolved}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              title: 'Avg Resolution',
                              value: '${_summary!.avgResolutionDays} Days',
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Priority Pie Chart
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Grievances by Priority Level',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 180,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 35,
                                    sections:
                                        _summary!.priorityBreakdown.map((p) {
                                      final color = p.priority == 'Critical'
                                          ? AppColors.priorityCritical
                                          : p.priority == 'High'
                                              ? AppColors.priorityHigh
                                              : p.priority == 'Medium'
                                                  ? AppColors.priorityMedium
                                                  : AppColors.priorityLow;

                                      return PieChartSectionData(
                                        color: color,
                                        value: p.count.toDouble(),
                                        title: '${p.count}',
                                        radius: 45,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: _summary!.priorityBreakdown.map((p) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: p.priority == 'Critical'
                                              ? AppColors.priorityCritical
                                              : p.priority == 'High'
                                                  ? AppColors.priorityHigh
                                                  : p.priority == 'Medium'
                                                      ? AppColors.priorityMedium
                                                      : AppColors.priorityLow,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text('${p.priority}: ${p.count}',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grievances by Category Breakdown
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Grievance Categories',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 12),
                              ..._summary!.categoryBreakdown.take(6).map((c) {
                                final pct = _summary!.totalComplaints > 0
                                    ? (c.count / _summary!.totalComplaints)
                                    : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(c.name,
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 1),
                                          ),
                                          Text('${c.count}',
                                              style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: pct,
                                        color: AppColors.primary,
                                        backgroundColor: AppColors.border,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grievances by District
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Grievances by District Distribution',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 12),
                              ..._summary!.districtBreakdown.take(5).map((d) {
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.location_city,
                                      color: AppColors.primary),
                                  title: Text(d.district,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  trailing: Text('${d.count} Cases',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary)),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
