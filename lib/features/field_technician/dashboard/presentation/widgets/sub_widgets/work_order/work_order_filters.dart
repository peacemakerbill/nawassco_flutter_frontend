import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/work_order.dart';

class WorkOrderFilters extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;

  const WorkOrderFilters({super.key, required this.onFiltersChanged});

  @override
  ConsumerState<WorkOrderFilters> createState() => _WorkOrderFiltersState();
}

class _WorkOrderFiltersState extends ConsumerState<WorkOrderFilters> {
  final Map<String, dynamic> _filters = {};
  bool _showAdvancedFilters = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null, 'status'),
                const SizedBox(width: 8),
                ...WorkOrderStatus.values
                    .map((status) => _buildFilterChip(
                        status.displayName, status.apiValue, 'status'))
                    .toList(),
                const SizedBox(width: 16),
                _buildFilterChip('All', null, 'priority'),
                const SizedBox(width: 8),
                ...WorkOrderPriority.values
                    .map((priority) => _buildFilterChip(
                        priority.displayName, priority.apiValue, 'priority'))
                    .toList(),
                const SizedBox(width: 16),
                _buildFilterChip('All', null, 'type'),
                const SizedBox(width: 8),
                ...WorkOrderType.values
                    .map((type) => _buildFilterChip(
                        type.displayName, type.apiValue, 'workOrderType'))
                    .toList(),
              ],
            ),
          ),
          if (_showAdvancedFilters)
            Column(
              children: [
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date Range',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate('startDate'),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _filters['startDate'] != null
                                  ? _formatDate(
                                      DateTime.parse(_filters['startDate']))
                                  : 'Start Date',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate('endDate'),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _filters['endDate'] != null
                                  ? _formatDate(
                                      DateTime.parse(_filters['endDate']))
                                  : 'End Date',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Technician',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search technician...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _filters['assignedTo'] = value;
                        } else {
                          _filters.remove('assignedTo');
                        }
                        widget.onFiltersChanged(_filters);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search customer...',
                        prefixIcon: const Icon(Icons.person_search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _filters['customer'] = value;
                        } else {
                          _filters.remove('customer');
                        }
                        widget.onFiltersChanged(_filters);
                      },
                    ),
                  ],
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
                icon: Icon(
                  _showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  _showAdvancedFilters ? 'Hide Filters' : 'More Filters',
                ),
              ),
              if (_filters.isNotEmpty) ...[
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, String filterKey) {
    final isSelected = _filters[filterKey] == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _filters[filterKey] = value;
          } else {
            _filters.remove(filterKey);
          }
        });
        widget.onFiltersChanged(_filters);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.1),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
        ),
      ),
    );
  }

  Future<void> _selectDate(String dateType) async {
    final initialDate = _filters[dateType] != null
        ? DateTime.parse(_filters[dateType])
        : DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _filters[dateType] = pickedDate.toIso8601String();
      });
      widget.onFiltersChanged(_filters);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged(_filters);
  }
}
