import 'package:flutter/material.dart';

class FilterPanel extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;
  final bool isManagementView;

  const FilterPanel({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
    required this.onClearFilters,
    required this.isManagementView,
  });

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late TextEditingController _searchController;
  late TextEditingController _meterNumberController;
  late TextEditingController _customerEmailController;
  late TextEditingController _billingMonthController;
  late TextEditingController _serviceRegionController;
  late String _status;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late double? _minAmount;
  late double? _maxAmount;

  @override
  void initState() {
    super.initState();

    _searchController =
        TextEditingController(text: widget.currentFilters['search'] ?? '');
    _meterNumberController =
        TextEditingController(text: widget.currentFilters['meterNumber'] ?? '');
    _customerEmailController = TextEditingController(
        text: widget.currentFilters['customerEmail'] ?? '');
    _billingMonthController = TextEditingController(
        text: widget.currentFilters['billingMonth'] ?? '');
    _serviceRegionController = TextEditingController(
        text: widget.currentFilters['serviceRegion'] ?? '');
    _status = widget.currentFilters['status'] ?? '';
    _startDate = widget.currentFilters['startDate'];
    _endDate = widget.currentFilters['endDate'];
    _minAmount = widget.currentFilters['minAmount'];
    _maxAmount = widget.currentFilters['maxAmount'];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _meterNumberController.dispose();
    _customerEmailController.dispose();
    _billingMonthController.dispose();
    _serviceRegionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }
    if (_meterNumberController.text.isNotEmpty) {
      filters['meterNumber'] = _meterNumberController.text;
    }
    if (widget.isManagementView && _customerEmailController.text.isNotEmpty) {
      filters['customerEmail'] = _customerEmailController.text;
    }
    if (_billingMonthController.text.isNotEmpty) {
      filters['billingMonth'] = _billingMonthController.text;
    }
    if (_serviceRegionController.text.isNotEmpty) {
      filters['serviceRegion'] = _serviceRegionController.text;
    }
    if (_status.isNotEmpty) {
      filters['status'] = _status;
    }
    if (_startDate != null) {
      filters['startDate'] = _startDate!.toIso8601String();
    }
    if (_endDate != null) {
      filters['endDate'] = _endDate!.toIso8601String();
    }
    if (_minAmount != null) {
      filters['minAmount'] = _minAmount;
    }
    if (_maxAmount != null) {
      filters['maxAmount'] = _maxAmount;
    }

    widget.onApplyFilters(filters);
  }

  void _clearFilters() {
    _searchController.clear();
    _meterNumberController.clear();
    _customerEmailController.clear();
    _billingMonthController.clear();
    _serviceRegionController.clear();
    setState(() {
      _status = '';
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
    });
    widget.onClearFilters();
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
            const Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Filter Bills',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search by meter, name, email, or bill number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Basic filters in a row
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _meterNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Meter Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                if (widget.isManagementView)
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _billingMonthController,
                    decoration: const InputDecoration(
                      labelText: 'Billing Month (YYYY-MM)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _status.isEmpty ? null : _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('All Status',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(
                          value: 'overdue', child: Text('Overdue')),
                      DropdownMenuItem(
                          value: 'partially_paid',
                          child: Text('Partially Paid')),
                      DropdownMenuItem(
                          value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date Range
            const Text(
              'Date Range',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount Range
            const Text(
              'Amount Range',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'TZS ',
                    ),
                    onChanged: (value) {
                      _minAmount = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'TZS ',
                    ),
                    onChanged: (value) {
                      _maxAmount = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.clear, size: 18),
                        SizedBox(width: 8),
                        Text('CLEAR FILTERS'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_alt, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('APPLY FILTERS',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
