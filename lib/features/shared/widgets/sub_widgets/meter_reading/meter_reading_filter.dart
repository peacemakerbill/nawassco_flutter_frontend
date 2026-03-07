import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/meter_reading_model.dart';
import '../../../providers/meter_reading_provider.dart';

class MeterReadingFilter extends ConsumerStatefulWidget {
  const MeterReadingFilter({super.key});

  @override
  ConsumerState<MeterReadingFilter> createState() => _MeterReadingFilterState();
}

class _MeterReadingFilterState extends ConsumerState<MeterReadingFilter> {
  final _meterNumberController = TextEditingController();
  final _searchController = TextEditingController();

  ReadingStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final state = ref.read(meterReadingProvider);
    _meterNumberController.text = state.filterMeterNumber;
    _searchController.text = state.searchQuery;
    _selectedStatus = state.filterStatus;
    _startDate = state.filterStartDate;
    _endDate = state.filterEndDate;
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyFilters() {
    final provider = ref.read(meterReadingProvider.notifier);

    provider.setFilterMeterNumber(_meterNumberController.text);
    provider.setFilterStatus(_selectedStatus);
    provider.setDateRange(_startDate, _endDate);
    provider.setSearchQuery(_searchController.text);

    Navigator.pop(context);
  }

  void _clearFilters() {
    final provider = ref.read(meterReadingProvider.notifier);

    provider.clearFilters();
    setState(() {
      _meterNumberController.clear();
      _searchController.clear();
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Readings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Search by meter, reader, or bill number',
              ),
            ),

            const SizedBox(height: 16),

            // Meter Number Filter
            TextField(
              controller: _meterNumberController,
              decoration: InputDecoration(
                labelText: 'Meter Number',
                prefixIcon: const Icon(Icons.speed),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Filter by specific meter',
              ),
            ),

            const SizedBox(height: 16),

            // Status Filter
            DropdownButtonFormField<ReadingStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.info),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ReadingStatus.values.map((status) {
                return DropdownMenuItem<ReadingStatus>(
                  value: status,
                  child: Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      color: status == ReadingStatus.pending ? Colors.orange :
                      status == ReadingStatus.verified ? Colors.green :
                      status == ReadingStatus.rejected ? Colors.red :
                      Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Date Range Filter
            const Text(
              'Date Range',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? dateFormat.format(_startDate!)
                                : 'Start Date',
                            style: TextStyle(
                              color: _startDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate != null
                                ? dateFormat.format(_endDate!)
                                : 'End Date',
                            style: TextStyle(
                              color: _endDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}