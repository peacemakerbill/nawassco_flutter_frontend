import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/field_service_report_model.dart';

class ManagementFiltersPanel extends StatefulWidget {
  final Map<String, dynamic> filters;
  final DateTimeRange? dateRange;
  final Function(Map<String, dynamic>) onFiltersUpdated;
  final Function(DateTimeRange?) onDateRangeUpdated;
  final Function() onApplyFilters;
  final Function() onClearFilters;
  final Function() onClose;

  const ManagementFiltersPanel({
    super.key,
    required this.filters,
    required this.dateRange,
    required this.onFiltersUpdated,
    required this.onDateRangeUpdated,
    required this.onApplyFilters,
    required this.onClearFilters,
    required this.onClose,
  });

  @override
  State<ManagementFiltersPanel> createState() => _ManagementFiltersPanelState();
}

class _ManagementFiltersPanelState extends State<ManagementFiltersPanel> {
  final GlobalKey<FormState> _filterFormKey = GlobalKey<FormState>();
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _workOrderController = TextEditingController();
  final TextEditingController _minRatingController = TextEditingController();
  final TextEditingController _maxRatingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current filter values
    _technicianController.text = widget.filters['technician'] ?? '';
    _workOrderController.text = widget.filters['workOrder'] ?? '';
    _minRatingController.text = widget.filters['minRating']?.toString() ?? '';
    _maxRatingController.text = widget.filters['maxRating']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          Form(
            key: _filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Technician',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                TextFormField(
                  controller: _technicianController,
                  decoration: const InputDecoration(
                    hintText: 'Search technician...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _updateFilter(
                        'technician', value.isNotEmpty ? value : null);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Work Order',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                TextFormField(
                  controller: _workOrderController,
                  decoration: const InputDecoration(
                    hintText: 'Search work order...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _updateFilter('workOrder', value.isNotEmpty ? value : null);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Approval Status',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                ...ApprovalStatus.values.map((status) {
                  return CheckboxListTile(
                    title: Text(status.displayName),
                    value: widget.filters['approvalStatus'] == status.apiValue,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _updateFilter('approvalStatus', status.apiValue);
                        } else {
                          _removeFilter('approvalStatus');
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }),
                const SizedBox(height: 16),
                const Text('Date Range',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                OutlinedButton(
                  onPressed: _selectDateRange,
                  child: Text(
                    widget.dateRange == null
                        ? 'Select Date Range'
                        : '${DateFormat('MMM dd, yyyy').format(widget.dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(widget.dateRange!.end)}',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Customer Rating',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minRatingController,
                        decoration: const InputDecoration(
                          labelText: 'Min Rating',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateFilter('minRating',
                              value.isNotEmpty ? int.tryParse(value) : null);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _maxRatingController,
                        decoration: const InputDecoration(
                          labelText: 'Max Rating',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateFilter('maxRating',
                              value.isNotEmpty ? int.tryParse(value) : null);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onApplyFilters,
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _clearAllFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (range != null) {
      widget.onDateRangeUpdated(range);
    }
  }

  void _updateFilter(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(widget.filters);
    if (value != null) {
      newFilters[key] = value;
    } else {
      newFilters.remove(key);
    }
    widget.onFiltersUpdated(newFilters);
  }

  void _removeFilter(String key) {
    final newFilters = Map<String, dynamic>.from(widget.filters);
    newFilters.remove(key);
    widget.onFiltersUpdated(newFilters);
  }

  void _clearAllFilters() {
    _technicianController.clear();
    _workOrderController.clear();
    _minRatingController.clear();
    _maxRatingController.clear();
    widget.onClearFilters();
  }
}
