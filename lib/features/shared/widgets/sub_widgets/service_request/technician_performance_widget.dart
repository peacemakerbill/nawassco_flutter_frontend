import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../providers/service_request_provider.dart';

class TechnicianPerformanceWidget extends ConsumerStatefulWidget {
  const TechnicianPerformanceWidget({super.key});

  @override
  ConsumerState<TechnicianPerformanceWidget> createState() =>
      _TechnicianPerformanceWidgetState();
}

class _TechnicianPerformanceWidgetState
    extends ConsumerState<TechnicianPerformanceWidget> {
  String _selectedTimeframe = 'month';
  final List<Map<String, dynamic>> _technicians = [
    {'id': '1', 'name': 'John Doe'},
    {'id': '2', 'name': 'Jane Smith'},
    {'id': '3', 'name': 'Mike Johnson'},
  ];
  String? _selectedTechnicianId;

  @override
  void initState() {
    super.initState();
    _selectedTechnicianId = _technicians.first['id'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedTechnicianId != null) {
        ref.read(serviceRequestProvider.notifier).fetchTechnicianPerformance(
          _selectedTechnicianId!,
          _selectedTimeframe,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final performance = ref.watch(serviceRequestProvider).technicianPerformance;

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
                    'Technician Performance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Technician Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Technician',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedTechnicianId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.engineering),
                        ),
                        items: _technicians.map((tech) {
                          return DropdownMenuItem(
                            value: tech['id'] as String,
                            child: Text(tech['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTechnicianId = value);
                          ref
                              .read(serviceRequestProvider.notifier)
                              .fetchTechnicianPerformance(value!, _selectedTimeframe);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Timeframe:'),
                          const SizedBox(width: 12),
                          ...['week', 'month', 'quarter'].map((timeframe) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(timeframe.toTitleCase()),
                                selected: _selectedTimeframe == timeframe,
                                onSelected: (selected) {
                                  setState(() => _selectedTimeframe = timeframe);
                                  if (_selectedTechnicianId != null) {
                                    ref
                                        .read(serviceRequestProvider.notifier)
                                        .fetchTechnicianPerformance(
                                      _selectedTechnicianId!,
                                      timeframe,
                                    );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Performance Metrics
              if (performance != null && performance.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Metrics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildMetricCard(
                              'Completed Requests',
                              performance['totalCompleted']?.toString() ?? '0',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildMetricCard(
                              'Avg Resolution Time',
                              '${performance['avgResolutionTime']?.toStringAsFixed(1) ?? '0'} hrs',
                              Icons.timer,
                              Colors.blue,
                            ),
                            _buildMetricCard(
                              'On-Time Completion',
                              '${performance['onTimeCompletionRate']?.toStringAsFixed(1) ?? '0'}%',
                              Icons.schedule,
                              Colors.orange,
                            ),
                            _buildMetricCard(
                              'Avg Customer Rating',
                              performance['avgCustomerRating']?.toStringAsFixed(1) ?? '0.0',
                              Icons.star,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No performance data available'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}