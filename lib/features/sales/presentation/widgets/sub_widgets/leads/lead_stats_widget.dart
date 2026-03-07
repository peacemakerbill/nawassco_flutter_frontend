import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../../models/lead_models.dart';
import '../../../../providers/lead_provider.dart';

class LeadStatsWidget extends ConsumerWidget {
  const LeadStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStats = ref.watch(leadStatsProvider);
    final leadState = ref.watch(leadProvider);
    final notifier = ref.read(leadProvider.notifier);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lead Statistics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => notifier.showLeadList(),
          color: const Color(0xFF1E3A8A),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(leadStatsProvider.future),
            color: const Color(0xFF1E3A8A),
          ),
        ],
      ),
      body: asyncStats.when(
        data: (stats) {
          if (stats == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No statistics available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate stats based on available data
          final activeLeads = stats.total - stats.converted;
          final conversionRate = stats.total > 0 ? (stats.converted / stats.total) * 100 : 0;
          final qualifiedLeads = _getCountByStatus(stats.byStatus, ['qualified', 'proposal_sent', 'negotiation']);
          final newLeads = _getCountByStatus(stats.byStatus, ['new']);
          final contactedLeads = _getCountByStatus(stats.byStatus, ['contacted']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      title: 'Total Leads',
                      value: stats.total.toString(),
                      icon: Icons.group,
                      color: Colors.blue,
                      subtitle: 'All time',
                    ),
                    _buildStatCard(
                      title: 'Converted',
                      value: stats.converted.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                      subtitle: '${conversionRate.toStringAsFixed(1)}% rate',
                    ),
                    _buildStatCard(
                      title: 'Active Leads',
                      value: activeLeads.toString(),
                      icon: Icons.work,
                      color: Colors.orange,
                      subtitle: 'In pipeline',
                    ),
                    _buildStatCard(
                      title: 'Qualified',
                      value: qualifiedLeads.toString(),
                      icon: Icons.star,
                      color: Colors.purple,
                      subtitle: 'Ready for proposal',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Performance Metrics
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.insights, color: Color(0xFF1E3A8A)),
                            SizedBox(width: 8),
                            Text(
                              'Performance Metrics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildMetricItem(
                              label: 'New Leads',
                              value: newLeads.toString(),
                              color: Colors.blue,
                            ),
                            _buildMetricItem(
                              label: 'Contacted',
                              value: contactedLeads.toString(),
                              color: Colors.orange,
                            ),
                            _buildMetricItem(
                              label: 'High Priority',
                              value: _getHighPriorityCount(stats.byPriority).toString(),
                              color: Colors.red,
                            ),
                            _buildMetricItem(
                              label: 'Top Source',
                              value: _getTopSourceName(stats.bySource),
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Status Distribution Chart
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.pie_chart, color: Color(0xFF1E3A8A)),
                            const SizedBox(width: 8),
                            const Text(
                              'Lead Status Distribution',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text('${stats.total} total'),
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: SfCircularChart(
                            series: <CircularSeries>[
                              DoughnutSeries<Map<String, dynamic>, String>(
                                dataSource: stats.byStatus,
                                xValueMapper: (data, _) => _getStatusDisplayName(data['status']),
                                yValueMapper: (data, _) => data['count'] ?? 0,
                                dataLabelMapper: (data, _) => '${data['count'] ?? 0}',
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  textStyle: TextStyle(fontSize: 12),
                                ),
                                pointColorMapper: (data, _) => _getStatusColor(data['status']),
                                innerRadius: '60%',
                              ),
                            ],
                            legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              overflowMode: LegendItemOverflowMode.wrap,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Source Distribution Chart
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.source, color: Color(0xFF1E3A8A)),
                            const SizedBox(width: 8),
                            const Text(
                              'Lead Sources',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const Spacer(),
                            Chip(
                              label: const Text('Performance'),
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(text: 'Number of Leads'),
                            ),
                            series: <CartesianSeries>[
                              BarSeries<Map<String, dynamic>, String>(
                                dataSource: stats.bySource,
                                xValueMapper: (data, _) => _getSourceDisplayName(data['source']),
                                yValueMapper: (data, _) => data['count'] ?? 0,
                                color: const Color(0xFF1E3A8A),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Priority Distribution
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flag, color: Color(0xFF1E3A8A)),
                            SizedBox(width: 8),
                            Text(
                              'Lead Priority Distribution',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: stats.byPriority.map((entry) {
                            final priority = _getPriorityFromString(entry['priority']);
                            final count = entry['count'] ?? 0;
                            final percentage = stats.total > 0
                                ? (count / stats.total) * 100
                                : 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: priority.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            priority.displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$count (${percentage.toStringAsFixed(1)}%)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: priority.color,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => notifier.showLeadList(),
                    icon: const Icon(Icons.list),
                    label: const Text('Back to Leads List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1E3A8A),
              ),
              SizedBox(height: 16),
              Text(
                'Loading statistics...',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => notifier.showLeadList(),
                    child: const Text('Back to Leads'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(leadStatsProvider.future),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _getCountByStatus(List<Map<String, dynamic>> byStatus, List<String> targetStatuses) {
    int count = 0;
    for (var statusData in byStatus) {
      final status = statusData['status']?.toString() ?? '';
      if (targetStatuses.contains(status)) {
        count += statusData['count'] as int? ?? 0;
      }
    }
    return count;
  }

  int _getHighPriorityCount(List<Map<String, dynamic>> byPriority) {
    int count = 0;
    for (var priorityData in byPriority) {
      final priority = priorityData['priority']?.toString() ?? '';
      if (priority == 'high' || priority == 'urgent') {
        count += priorityData['count'] as int? ?? 0;
      }
    }
    return count;
  }

  String _getTopSourceName(List<Map<String, dynamic>> bySource) {
    if (bySource.isEmpty) return 'N/A';

    // Find the source with maximum count
    bySource.sort((a, b) => (b['count'] as int? ?? 0).compareTo(a['count'] as int? ?? 0));
    final topSource = bySource.first['source']?.toString() ?? '';

    // Convert to display name
    return _getSourceDisplayName(topSource);
  }

  String _getStatusDisplayName(String? status) {
    if (status == null) return 'Unknown';
    try {
      return LeadStatus.fromString(status).displayName;
    } catch (e) {
      return status;
    }
  }

  String _getSourceDisplayName(String? source) {
    if (source == null) return 'Unknown';
    try {
      return LeadSource.fromString(source).displayName;
    } catch (e) {
      return source;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    try {
      return LeadStatus.fromString(status).color;
    } catch (e) {
      return Colors.grey;
    }
  }

  PriorityLevel _getPriorityFromString(String? priority) {
    if (priority == null) return PriorityLevel.medium;
    try {
      return PriorityLevel.fromString(priority);
    } catch (e) {
      return PriorityLevel.medium;
    }
  }
}