import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_catalog_model.dart';
import '../../../utils/service_catalog/service_constants.dart';

class ServiceFilterWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClear;

  const ServiceFilterWidget({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<ServiceFilterWidget> createState() =>
      _ServiceFilterWidgetState();
}

class _ServiceFilterWidgetState extends ConsumerState<ServiceFilterWidget> {
  late Map<String, dynamic> _filters;
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  RangeValues _priceRange = const RangeValues(0, 100000);
  String _selectedCustomerType = 'All';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);

    _selectedCategory = _filters['category'] ?? 'All';
    _selectedStatus = _filters['status'] ?? 'All';
    _selectedCustomerType = _filters['customerType'] ?? 'All';
    _priceRange = RangeValues(
      (_filters['minPrice'] as num?)?.toDouble() ?? 0,
      (_filters['maxPrice'] as num?)?.toDouble() ?? 100000,
    );
    _searchController.text = _filters['search'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.filter_list, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Filter Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search by name, description, or code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _filters['search'] = value.isNotEmpty ? value : null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Categories
          _buildFilterSection(
            title: 'Categories',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _selectedCategory == 'All',
                  onSelected: (selected) =>
                      _updateCategory(selected ? 'All' : null),
                ),
                ...ServiceCategory.values.map((category) {
                  return _buildFilterChip(
                    label: category.displayName,
                    selected: _selectedCategory == category.name,
                    onSelected: (selected) =>
                        _updateCategory(selected ? category.name : null),
                    color: category.color,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status
          _buildFilterSection(
            title: 'Status',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _selectedStatus == 'All',
                  onSelected: (selected) =>
                      _updateStatus(selected ? 'All' : null),
                ),
                ...ServiceConstants.serviceStatusOptions.map((status) {
                  return _buildFilterChip(
                    label: status,
                    selected: _selectedStatus == status,
                    onSelected: (selected) =>
                        _updateStatus(selected ? status : null),
                    color: ServiceConstants.getStatusColor(status),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Price Range
          _buildFilterSection(
            title: 'Price Range',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 100000,
                  divisions: 10,
                  labels: RangeLabels(
                    ServiceConstants.formatCurrency(_priceRange.start),
                    ServiceConstants.formatCurrency(_priceRange.end),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                      _filters['minPrice'] = values.start;
                      _filters['maxPrice'] = values.end;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ServiceConstants.formatCurrency(_priceRange.start),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      ServiceConstants.formatCurrency(_priceRange.end),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Customer Type
          _buildFilterSection(
            title: 'Customer Type',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _selectedCustomerType == 'All',
                  onSelected: (selected) =>
                      _updateCustomerType(selected ? 'All' : null),
                ),
                ...ServiceConstants.customerTypeOptions.map((type) {
                  return _buildFilterChip(
                    label: type,
                    selected: _selectedCustomerType == type,
                    onSelected: (selected) =>
                        _updateCustomerType(selected ? type : null),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _clearFilters();
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.clear_all),
                  label: Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _applyFilters();
                    widget.onApply(_filters);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check),
                  label: Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade100,
      selectedColor:
          (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.2),
      checkmarkColor: color ?? Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected
            ? (color ?? Theme.of(context).primaryColor)
            : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected
              ? (color ?? Theme.of(context).primaryColor)
              : Colors.grey.shade300,
          width: selected ? 1.5 : 1,
        ),
      ),
    );
  }

  void _updateCategory(String? category) {
    setState(() {
      _selectedCategory = category ?? 'All';
      _filters['category'] = category == 'All' ? null : category;
    });
  }

  void _updateStatus(String? status) {
    setState(() {
      _selectedStatus = status ?? 'All';
      _filters['status'] = status == 'All' ? null : status;
    });
  }

  void _updateCustomerType(String? type) {
    setState(() {
      _selectedCustomerType = type ?? 'All';
      _filters['customerType'] = type == 'All' ? null : type;
    });
  }

  void _applyFilters() {
    // Apply all filters
    if (_filters['search'] == '') _filters.remove('search');
    if (_priceRange.start == 0) _filters.remove('minPrice');
    if (_priceRange.end == 100000) _filters.remove('maxPrice');
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _selectedCategory = 'All';
      _selectedStatus = 'All';
      _selectedCustomerType = 'All';
      _priceRange = const RangeValues(0, 100000);
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
