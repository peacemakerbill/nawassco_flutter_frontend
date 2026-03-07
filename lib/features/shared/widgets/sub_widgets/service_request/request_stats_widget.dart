import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../providers/service_request_provider.dart';

class RequestStatsWidget extends ConsumerStatefulWidget {
  const RequestStatsWidget({super.key});

  @override
  ConsumerState<RequestStatsWidget> createState() => _RequestStatsWidgetState();
}

class _RequestStatsWidgetState extends ConsumerState<RequestStatsWidget> {
  String _selectedTimeframe = 'month';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestProvider.notifier).fetchRequestStats(_selectedTimeframe);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(serviceRequestProvider).stats;
    final byStatus = stats['byStatus'] as List? ?? [];
    final slaPerformance = stats['slaPerformance'] as List? ?? [];
    final technicianPerformance = stats['technicianPerformance'] as List? ?? [];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Request Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedTimeframe,
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('Today')),
                      DropdownMenuItem(value: 'week', child: Text('This Week')),
                      DropdownMenuItem(value: 'month', child: Text('This Month')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedTimeframe = value!);
                      ref.read(serviceRequestProvider.notifier).fetchRequestStats(value!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Distribution Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Distribution',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: const CategoryAxis(),
                          series: <CartesianSeries>[
                            ColumnSeries<Map<String, dynamic>, String>(
                              // dataSource: byStatus,
                              xValueMapper: (Map<String, dynamic> data, _) => data['_id']?.toString() ?? '',
                              yValueMapper: (Map<String, dynamic> data, _) => data['count']?.toDouble() ?? 0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SLA Performance
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLA Performance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (slaPerformance.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: SfCircularChart(
                            series: <CircularSeries>[
                              PieSeries<Map<String, dynamic>, String>(
                                // dataSource: slaPerformance,
                                xValueMapper: (data, _) => data['_id']?.toString() ?? '',
                                yValueMapper: (data, _) => data['count']?.toDouble() ?? 0,
                                dataLabelMapper: (data, _) => '${data['_id']}: ${data['count']}',
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Center(child: Text('No SLA data available')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Top Technicians
              if (technicianPerformance.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Technicians',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: technicianPerformance.take(5).length,
                          itemBuilder: (context, index) {
                            final tech = technicianPerformance[index];
                            final completionRate = tech['completionRate']?.toDouble() ?? 0;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  tech['technicianName']?.toString().substring(0, 1) ?? 'T',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(tech['technicianName'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigned: ${tech['assignedCount']} | Completed: ${tech['completedCount']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: completionRate / 100,
                                    backgroundColor: Colors.grey[200],
                                    color: completionRate >= 80
                                        ? Colors.green
                                        : completionRate >= 60
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                  Text(
                                    '${completionRate.toStringAsFixed(1)}% Completion Rate',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}