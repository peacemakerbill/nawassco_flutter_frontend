import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/tariff_model.dart';

class TariffFilterWidget extends ConsumerStatefulWidget {
  final VoidCallback onFilterApplied;
  final VoidCallback onFilterCleared;

  const TariffFilterWidget({
    super.key,
    required this.onFilterApplied,
    required this.onFilterCleared,
  });

  @override
  ConsumerState<TariffFilterWidget> createState() => _TariffFilterWidgetState();
}

class _TariffFilterWidgetState extends ConsumerState<TariffFilterWidget> {
  final _searchController = TextEditingController();
  bool? _isActive;
  bool? _isApproved;
  NakuruServiceRegion? _serviceRegion;
  BillingCycle? _billingCycle;
  DateTime? _effectiveFrom;
  DateTime? _effectiveTo;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Tariffs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _clearFilters();
                        widget.onFilterCleared();
                      },
                      child: const Text('Clear All'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        _applyFilters();
                        widget.onFilterApplied();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search and Quick Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, code, or description...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                        icon: const Icon(Icons.clear),
                      )
                          : null,
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<bool>(
                  value: _isActive,
                  hint: const Text('Status'),
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _isActive = value);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<bool>(
                  value: _isApproved,
                  hint: const Text('Approval'),
                  items: [
                    const DropdownMenuItem(
                      value: true,
                      child: Text('Approved'),
                    ),
                    const DropdownMenuItem(
                      value: false,
                      child: Text('Pending'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _isApproved = value);
                    _applyFilters();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Advanced Filters
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Service Region
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<NakuruServiceRegion>(
                    value: _serviceRegion,
                    decoration: const InputDecoration(
                      labelText: 'Service Region',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Regions'),
                      ),
                      ...NakuruServiceRegion.values.map((region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Text(region.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _serviceRegion = value);
                      _applyFilters();
                    },
                  ),
                ),

                // Billing Cycle
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<BillingCycle>(
                    value: _billingCycle,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Cycles'),
                      ),
                      ...BillingCycle.values.map((cycle) {
                        return DropdownMenuItem(
                          value: cycle,
                          child: Text(cycle.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _billingCycle = value);
                      _applyFilters();
                    },
                  ),
                ),

                // Effective From
                SizedBox(
                  width: 180,
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _effectiveFrom != null
                          ? DateFormat('dd/MM/yyyy').format(_effectiveFrom!)
                          : '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Effective From',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _effectiveFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setState(() => _effectiveFrom = date);
                        _applyFilters();
                      }
                    },
                  ),
                ),

                // Effective To
                SizedBox(
                  width: 180,
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _effectiveTo != null
                          ? DateFormat('dd/MM/yyyy').format(_effectiveTo!)
                          : '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Effective To',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _effectiveTo ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                      );
                      if (date != null) {
                        setState(() => _effectiveTo = date);
                        _applyFilters();
                      }
                    },
                  ),
                ),

                // Sort By
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'createdAt',
                        child: Text('Created Date'),
                      ),
                      DropdownMenuItem(
                        value: 'effectiveFrom',
                        child: Text('Effective From'),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Name'),
                      ),
                      DropdownMenuItem(
                        value: 'code',
                        child: Text('Code'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      _applyFilters();
                    },
                  ),
                ),

                // Sort Order
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _sortOrder,
                    decoration: const InputDecoration(
                      labelText: 'Sort Order',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'desc',
                        child: Text('Descending'),
                      ),
                      DropdownMenuItem(
                        value: 'asc',
                        child: Text('Ascending'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _sortOrder = value!);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),

            // Clear Individual Filters
            if (_hasActiveFilters())
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_isActive != null)
                      FilterChip(
                        label: Text(_isActive! ? 'Active' : 'Inactive'),
                        onSelected: (_) {
                          setState(() => _isActive = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    if (_isApproved != null)
                      FilterChip(
                        label: Text(_isApproved! ? 'Approved' : 'Pending'),
                        onSelected: (_) {
                          setState(() => _isApproved = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    if (_serviceRegion != null)
                      FilterChip(
                        label: Text(_serviceRegion!.displayName),
                        onSelected: (_) {
                          setState(() => _serviceRegion = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    if (_billingCycle != null)
                      FilterChip(
                        label: Text(_billingCycle!.displayName),
                        onSelected: (_) {
                          setState(() => _billingCycle = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    if (_effectiveFrom != null)
                      FilterChip(
                        label: Text('From: ${DateFormat('dd/MM/yyyy').format(_effectiveFrom!)}'),
                        onSelected: (_) {
                          setState(() => _effectiveFrom = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    if (_effectiveTo != null)
                      FilterChip(
                        label: Text('To: ${DateFormat('dd/MM/yyyy').format(_effectiveTo!)}'),
                        onSelected: (_) {
                          setState(() => _effectiveTo = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _isActive != null ||
        _isApproved != null ||
        _serviceRegion != null ||
        _billingCycle != null ||
        _effectiveFrom != null ||
        _effectiveTo != null;
  }

  void _applyFilters() {
    final filter = TariffFilter(
      isActive: _isActive,
      isApproved: _isApproved,
      serviceRegion: _serviceRegion,
      billingCycle: _billingCycle,
      effectiveFrom: _effectiveFrom,
      effectiveTo: _effectiveTo,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    // Update provider filter (you'll need to connect this to your provider)
    // ref.read(tariffProvider.notifier).updateFilter(filter);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _isActive = null;
      _isApproved = null;
      _serviceRegion = null;
      _billingCycle = null;
      _effectiveFrom = null;
      _effectiveTo = null;
      _sortBy = 'createdAt';
      _sortOrder = 'desc';
    });
  }
}