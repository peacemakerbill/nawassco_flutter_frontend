import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/reports/management_report_model.dart';
import '../../../../providers/management_report_provider.dart';

class ReportFilterSheet extends ConsumerStatefulWidget {
  const ReportFilterSheet({super.key});

  @override
  ConsumerState<ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends ConsumerState<ReportFilterSheet> {
  late ReportStatus? _selectedStatus;
  late ReportType? _selectedType;
  late ReportFrequency? _selectedFrequency;
  late ConfidentialityLevel? _selectedConfidentiality;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filters = ref.read(managementReportProvider).filters;
    _selectedStatus = filters['status'] != null
        ? ReportStatus.values.firstWhere(
            (e) => e.name == filters['status'],
            orElse: () => ReportStatus.draft,
          )
        : null;
    _selectedType = filters['reportType'] != null
        ? ReportType.values.firstWhere(
            (e) => e.name == filters['reportType'],
            orElse: () => ReportType.operational,
          )
        : null;
    _selectedFrequency = filters['frequency'] != null
        ? ReportFrequency.values.firstWhere(
            (e) => e.name == filters['frequency'],
            orElse: () => ReportFrequency.monthly,
          )
        : null;
    _selectedConfidentiality = filters['confidentiality'] != null
        ? ConfidentialityLevel.values.firstWhere(
            (e) => e.name == filters['confidentiality'],
            orElse: () => ConfidentialityLevel.internal,
          )
        : null;
    _searchController.text = filters['search'] ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedStatus != null) {
      filters['status'] = _selectedStatus!.name;
    }
    if (_selectedType != null) {
      filters['reportType'] = _selectedType!.name;
    }
    if (_selectedFrequency != null) {
      filters['frequency'] = _selectedFrequency!.name;
    }
    if (_selectedConfidentiality != null) {
      filters['confidentiality'] = _selectedConfidentiality!.name;
    }
    if (_startDate != null) {
      filters['startDate'] = _startDate!.toIso8601String().split('T')[0];
    }
    if (_endDate != null) {
      filters['endDate'] = _endDate!.toIso8601String().split('T')[0];
    }
    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }

    ref.read(managementReportProvider.notifier).updateFilters(filters);
    ref.read(managementReportProvider.notifier).loadReports();
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _selectedFrequency = null;
      _selectedConfidentiality = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    ref.read(managementReportProvider.notifier).clearFilters();
    ref.read(managementReportProvider.notifier).loadReports();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Reports',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ReportStatus.values.map((status) {
                          return FilterChip(
                            label: Text(status.displayName),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: status.color.withValues(alpha: 0.2),
                            checkmarkColor: status.color,
                            labelStyle: TextStyle(
                              color: _selectedStatus == status
                                  ? status.color
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Report Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ReportType.values.map((type) {
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(type.icon, size: 16),
                                const SizedBox(width: 4),
                                Text(type.displayName),
                              ],
                            ),
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? type : null;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.blue.withValues(alpha: 0.2),
                            checkmarkColor: Colors.blue,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          _startDate != null
                                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                              : 'Select date',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          _endDate != null
                                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                              : 'Select date',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearFilters,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Clear Filters'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
