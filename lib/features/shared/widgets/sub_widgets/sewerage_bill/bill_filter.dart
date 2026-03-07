import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillFilter extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFilterChanged;
  final Map<String, dynamic> initialFilters;

  const BillFilter({
    super.key,
    this.onFilterChanged,
    this.initialFilters = const {},
  });

  @override
  State<BillFilter> createState() => _BillFilterState();
}

class _BillFilterState extends State<BillFilter> {
  late String _statusFilter;
  late String _dateRangeFilter;
  late TextEditingController _searchController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialFilters['status'] ?? 'all';
    _dateRangeFilter = widget.initialFilters['dateRange'] ?? 'all';
    _searchController = TextEditingController(
      text: widget.initialFilters['search'] ?? '',
    );
    _startDate = widget.initialFilters['startDate'];
    _endDate = widget.initialFilters['endDate'];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_statusFilter != 'all') {
      filters['status'] = _statusFilter;
    }

    if (_dateRangeFilter != 'all') {
      filters['dateRange'] = _dateRangeFilter;
    }

    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }

    if (_startDate != null) {
      filters['startDate'] = _startDate;
    }

    if (_endDate != null) {
      filters['endDate'] = _endDate;
    }

    widget.onFilterChanged?.call(filters);
  }

  void _resetFilters() {
    setState(() {
      _statusFilter = 'all';
      _dateRangeFilter = 'all';
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
    widget.onFilterChanged?.call({});
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  // Moved outside of build method
  Widget _buildFilterChip(String label, String value, String selectedValue, String type) {
    final isSelected = selectedValue == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (type == 'status') {
              _statusFilter = selected ? value : 'all';
            } else {
              _dateRangeFilter = selected ? value : 'all';
            }
          });
          _applyFilters();
        },
        selectedColor: Colors.blue[100],
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[700],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Filter Bills',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  tooltip: 'Reset filters',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or service number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
                    : null,
              ),
              onChanged: (_) => _applyFilters(),
            ),

            const SizedBox(height: 16),

            // Status Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', _statusFilter, 'status'),
                      _buildFilterChip('Pending', 'pending', _statusFilter, 'status'),
                      _buildFilterChip('Paid', 'paid', _statusFilter, 'status'),
                      _buildFilterChip('Overdue', 'overdue', _statusFilter, 'status'),
                      _buildFilterChip('Cancelled', 'cancelled', _statusFilter, 'status'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date Range Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', _dateRangeFilter, 'dateRange'),
                      _buildFilterChip('Today', 'today', _dateRangeFilter, 'dateRange'),
                      _buildFilterChip('This Week', 'week', _dateRangeFilter, 'dateRange'),
                      _buildFilterChip('This Month', 'month', _dateRangeFilter, 'dateRange'),
                      _buildFilterChip('This Year', 'year', _dateRangeFilter, 'dateRange'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Custom Date Range
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Date Range',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _startDate != null
                                      ? dateFormat.format(_startDate!)
                                      : 'Start Date',
                                  style: TextStyle(
                                    color: _startDate != null ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('to', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _endDate != null
                                      ? dateFormat.format(_endDate!)
                                      : 'End Date',
                                  style: TextStyle(
                                    color: _endDate != null ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Apply Button
            ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}