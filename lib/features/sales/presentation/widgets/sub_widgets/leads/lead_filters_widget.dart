import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/lead_models.dart';
import '../../../../providers/lead_provider.dart';

class LeadFiltersWidget extends ConsumerStatefulWidget {
  const LeadFiltersWidget({super.key});

  @override
  ConsumerState<LeadFiltersWidget> createState() => _LeadFiltersWidgetState();
}

class _LeadFiltersWidgetState extends ConsumerState<LeadFiltersWidget> {
  late Map<String, dynamic> _currentFilters;
  String? _selectedStatus;
  String? _selectedSource;
  String? _selectedPriority;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(leadProvider);
    _currentFilters = Map.from(state.filters);
    _selectedStatus = _currentFilters['status'];
    _selectedSource = _currentFilters['source'];
    _selectedPriority = _currentFilters['priority'];

    if (_currentFilters['dateFrom'] != null) {
      _dateFrom = DateTime.parse(_currentFilters['dateFrom']);
    }
    if (_currentFilters['dateTo'] != null) {
      _dateTo = DateTime.parse(_currentFilters['dateTo']);
    }

    _searchController.text = _currentFilters['search'] ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedStatus != null) {
      filters['status'] = _selectedStatus;
    }

    if (_selectedSource != null) {
      filters['source'] = _selectedSource;
    }

    if (_selectedPriority != null) {
      filters['priority'] = _selectedPriority;
    }

    if (_dateFrom != null) {
      filters['dateFrom'] = _dateFrom!.toIso8601String();
    }

    if (_dateTo != null) {
      filters['dateTo'] = _dateTo!.toIso8601String();
    }

    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }

    ref.read(leadProvider.notifier).filterLeads(filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedSource = null;
      _selectedPriority = null;
      _dateFrom = null;
      _dateTo = null;
      _searchController.clear();
    });
    ref.read(leadProvider.notifier).clearFilters();
    Navigator.pop(context);
  }

  Future<void> _selectDate(
      BuildContext context,
      bool isFromDate,
      ) async {
    final initialDate = isFromDate ? _dateFrom : _dateTo;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_alt,
                  color: Color(0xFF1E3A8A),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filter Leads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  Text(
                    'Search',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in leads...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status Filter
                  Text(
                    'Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...LeadStatus.values.map((status) {
                        final isSelected = _selectedStatus == status.name;
                        return ChoiceChip(
                          label: Text(status.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status.name : null;
                            });
                          },
                          selectedColor: status.color.withOpacity(0.2),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? status.color : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? status.color.withOpacity(0.5)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Source Filter
                  Text(
                    'Source',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...LeadSource.values.map((source) {
                        final isSelected = _selectedSource == source.name;
                        return ChoiceChip(
                          label: Text(source.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSource = selected ? source.name : null;
                            });
                          },
                          selectedColor: Colors.blue.withOpacity(0.2),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Priority Filter
                  Text(
                    'Priority',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...PriorityLevel.values.map((priority) {
                        final isSelected = _selectedPriority == priority.name;
                        return ChoiceChip(
                          label: Text(priority.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPriority =
                              selected ? priority.name : null;
                            });
                          },
                          selectedColor: priority.color.withOpacity(0.2),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color:
                            isSelected ? priority.color : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? priority.color.withOpacity(0.5)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Date Range
                  Text(
                    'Date Range',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _dateFrom != null
                                        ? dateFormat.format(_dateFrom!)
                                        : 'From Date',
                                    style: TextStyle(
                                      color: _dateFrom != null
                                          ? Colors.black
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _dateTo != null
                                        ? dateFormat.format(_dateTo!)
                                        : 'To Date',
                                    style: TextStyle(
                                      color: _dateTo != null
                                          ? Colors.black
                                          : Colors.grey.shade500,
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}