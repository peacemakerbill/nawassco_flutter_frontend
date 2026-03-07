import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_request_model.dart';
import '../../../providers/service_request_provider.dart';

class ServiceRequestFilter extends ConsumerStatefulWidget {
  const ServiceRequestFilter({super.key});

  @override
  ConsumerState<ServiceRequestFilter> createState() =>
      _ServiceRequestFilterState();
}

class _ServiceRequestFilterState extends ConsumerState<ServiceRequestFilter> {
  late Map<String, dynamic> _filters;
  final List<String> _statuses =
      RequestStatus.values.map((e) => e.name).toList();
  final List<String> _priorities =
      PriorityLevel.values.map((e) => e.name).toList();
  final List<String> _serviceCategories =
      ServiceCategory.values.map((e) => e.name).toList();

  @override
  void initState() {
    super.initState();
    _filters = ref.read(serviceRequestProvider).filters;
  }

  void _applyFilters() {
    ref.read(serviceRequestProvider.notifier).setFilters(_filters);
  }

  void _clearFilters() {
    setState(() {
      _filters = {};
    });
    ref.read(serviceRequestProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_filters.isNotEmpty)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Row(
                      children: [
                        Icon(Icons.clear, size: 16),
                        SizedBox(width: 4),
                        Text('Clear'),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Filter
            DropdownButtonFormField<String?>(
              value: _filters['status'],
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ..._statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.replaceAll('_', ' ').toTitleCase()),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == null) {
                    _filters.remove('status');
                  } else {
                    _filters['status'] = value;
                  }
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),

            // Priority Filter
            DropdownButtonFormField<String?>(
              value: _filters['priority'],
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ..._priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(
                          _getPriorityIcon(PriorityLevel.values
                              .firstWhere((e) => e.name == priority)),
                          size: 16,
                          color: _getPriorityColor(PriorityLevel.values
                              .firstWhere((e) => e.name == priority)),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.replaceAll('_', ' ').toTitleCase()),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == null) {
                    _filters.remove('priority');
                  } else {
                    _filters['priority'] = value;
                  }
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),

            // Service Category Filter
            DropdownButtonFormField<String?>(
              value: _filters['serviceCategory'],
              decoration: const InputDecoration(
                labelText: 'Service Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._serviceCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.replaceAll('_', ' ').toTitleCase()),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == null) {
                    _filters.remove('serviceCategory');
                  } else {
                    _filters['serviceCategory'] = value;
                  }
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),

            // Unassigned Requests Filter
            Row(
              children: [
                Checkbox(
                  value: _filters['unassigned'] == 'true',
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _filters['unassigned'] = 'true';
                      } else {
                        _filters.remove('unassigned');
                      }
                    });
                    _applyFilters();
                  },
                ),
                const Text('Show Only Unassigned Requests'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.emergency:
        return Colors.red[900]!;
      case PriorityLevel.urgent:
        return Colors.red;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.medium:
        return Colors.blue;
      case PriorityLevel.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.emergency:
      case PriorityLevel.urgent:
        return Icons.warning;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.medium:
        return Icons.horizontal_rule;
      case PriorityLevel.low:
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
