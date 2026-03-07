import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../models/leave/leave_application.dart';
import '../../../../../providers/leave_provider.dart';

class LeaveFilterWidget extends ConsumerStatefulWidget {
  const LeaveFilterWidget({super.key});

  @override
  ConsumerState<LeaveFilterWidget> createState() => _LeaveFilterWidgetState();
}

class _LeaveFilterWidgetState extends ConsumerState<LeaveFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  LeaveType? _selectedLeaveType;
  LeaveStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedDepartment;
  String? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    final state = ref.read(leaveProvider);
    _selectedLeaveType = state.selectedLeaveType;
    _selectedStatus = state.selectedStatus;
    _startDate = state.startDateFilter;
    _endDate = state.endDateFilter;
    _selectedDepartment = state.selectedDepartment;
    _selectedEmployee = state.selectedEmployee;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(leaveProvider.notifier).setFilter(
          searchQuery: _searchController.text.trim(),
          leaveType: _selectedLeaveType,
          status: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          department: _selectedDepartment,
          employee: _selectedEmployee,
        );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLeaveType = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _selectedDepartment = null;
      _selectedEmployee = null;
    });
    ref.read(leaveProvider.notifier).clearFilters();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate ?? DateTime.now();
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                const Icon(
                  Icons.filter_list,
                  size: 20,
                  color: Color(0xFF1A237E),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(height: 20),

            // Search
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                ),
              ),
              onChanged: (_) => _applyFilters(),
            ),

            const SizedBox(height: 16),

            // Leave Type Filter
            const Text(
              'Leave Type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedLeaveType == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLeaveType = null;
                    });
                    _applyFilters();
                  },
                ),
                ...LeaveType.values.map((type) {
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon, size: 16),
                        const SizedBox(width: 4),
                        Text(type.displayName),
                      ],
                    ),
                    selected: _selectedLeaveType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLeaveType = selected ? type : null;
                      });
                      _applyFilters();
                    },
                  );
                }).toList(),
              ],
            ),

            const SizedBox(height: 16),

            // Status Filter
            const Text(
              'Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = null;
                    });
                    _applyFilters();
                  },
                ),
                ...LeaveStatus.values.map((status) {
                  return FilterChip(
                    label: Text(status.displayName),
                    selected: _selectedStatus == status,
                    backgroundColor: status.color.withValues(alpha: 0.1),
                    selectedColor: status.color.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });
                      _applyFilters();
                    },
                  );
                }),
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
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _startDate != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(_startDate!)
                                  : 'Start Date',
                              style: TextStyle(
                                color: _startDate != null
                                    ? Colors.black
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _endDate != null
                                  ? DateFormat('dd MMM yyyy').format(_endDate!)
                                  : 'End Date',
                              style: TextStyle(
                                color: _endDate != null
                                    ? Colors.black
                                    : Colors.grey[400],
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

            const SizedBox(height: 16),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
