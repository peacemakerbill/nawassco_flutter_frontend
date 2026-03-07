import 'package:flutter/material.dart';

import '../../../models/outage.dart';

class OutageFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const OutageFilterWidget({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<OutageFilterWidget> createState() => _OutageFilterWidgetState();
}

class _OutageFilterWidgetState extends State<OutageFilterWidget> {
  OutageStatus? _selectedStatus;
  OutageType? _selectedType;
  PriorityLevel? _selectedPriority;
  String? _selectedZone;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter Outages',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Filter
          _buildFilterSection(
            'Status',
            OutageStatus.values,
            _selectedStatus,
            (status) {
              setState(() => _selectedStatus = status);
              _applyFilters();
            },
            (status) => status.toString().split('.').last.replaceAll('_', ' '),
          ),

          const SizedBox(height: 16),

          // Type Filter
          _buildFilterSection(
            'Type',
            OutageType.values,
            _selectedType,
            (type) {
              setState(() => _selectedType = type);
              _applyFilters();
            },
            (type) => type.toString().split('.').last.replaceAll('_', ' '),
          ),

          const SizedBox(height: 16),

          // Priority Filter
          _buildFilterSection(
            'Priority',
            PriorityLevel.values,
            _selectedPriority,
            (priority) {
              setState(() => _selectedPriority = priority);
              _applyFilters();
            },
            (priority) => priority.toString().split('.').last,
          ),

          const SizedBox(height: 16),

          // Date Range Filter
          _buildDateRangeFilter(),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection<T>(
    String label,
    List<T> options,
    T? selectedValue,
    Function(T?) onChanged,
    String Function(T) displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return FilterChip(
              label: Text(displayText(option)),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(selected ? option : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
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
              child: OutlinedButton(
                onPressed: () => _pickDate(context, true),
                child: Text(
                  _startDate == null
                      ? 'Start Date'
                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(context, false),
                child: Text(
                  _endDate == null
                      ? 'End Date'
                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedStatus != null) {
      filters['status'] =
          _selectedStatus!.toString().split('.').last.toLowerCase();
    }

    if (_selectedType != null) {
      filters['type'] = _selectedType!.toString().split('.').last.toLowerCase();
    }

    if (_selectedPriority != null) {
      filters['priority'] =
          _selectedPriority!.toString().split('.').last.toLowerCase();
    }

    if (_selectedZone != null) {
      filters['zone'] = _selectedZone;
    }

    if (_startDate != null) {
      filters['startDate'] = _startDate!.toIso8601String();
    }

    if (_endDate != null) {
      filters['endDate'] = _endDate!.toIso8601String();
    }

    widget.onFilterChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _selectedPriority = null;
      _selectedZone = null;
      _startDate = null;
      _endDate = null;
    });
    widget.onFilterChanged({});
  }
}
