import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/fixed_asset_model.dart';
import '../../../../providers/fixed_asset_provider.dart';

class FixedAssetFilters extends ConsumerStatefulWidget {
  const FixedAssetFilters({super.key});

  @override
  ConsumerState<FixedAssetFilters> createState() => _FixedAssetFiltersState();
}

class _FixedAssetFiltersState extends ConsumerState<FixedAssetFilters> {
  final _searchController = TextEditingController();
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    ref.read(fixedAssetsProvider.notifier).updateFilters(searchQuery: query);
  }

  void _applyFilters() {
    ref.read(fixedAssetsProvider.notifier).fetchAssets(page: 1);
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(fixedAssetsProvider.notifier).updateFilters(
      searchQuery: '',
      category: null,
      status: null,
      department: null,
    );
    ref.read(fixedAssetsProvider.notifier).fetchAssets(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixedAssetsProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search and Expand Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by asset name, number, or location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _filtersExpanded = !_filtersExpanded;
                  });
                },
                icon: Icon(
                  _filtersExpanded
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color: const Color(0xFF0D47A1),
                ),
                tooltip: 'Show/Hide Filters',
              ),
            ],
          ),

          // Advanced Filters
          if (_filtersExpanded) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Column(
                    children: [
                      _buildCategoryFilter(state),
                      const SizedBox(height: 12),
                      _buildStatusFilter(state),
                      const SizedBox(height: 12),
                      _buildDepartmentFilter(state),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: _buildCategoryFilter(state)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatusFilter(state)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDepartmentFilter(state)),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Active Filters Summary
          if (_hasActiveFilters(state)) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(state),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(FixedAssetsState state) {
    return DropdownButtonFormField<AssetCategory>(
      value: state.categoryFilter,
      decoration: const InputDecoration(
        labelText: 'Asset Category',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: AssetCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(_getCategoryDisplayName(category)),
        );
      }).toList(),
      onChanged: (category) {
        ref
            .read(fixedAssetsProvider.notifier)
            .updateFilters(category: category);
      },
    );
  }

  Widget _buildStatusFilter(FixedAssetsState state) {
    return DropdownButtonFormField<AssetStatus>(
      value: state.statusFilter,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: AssetStatus.values.map((status) {
        final asset = FixedAsset(
          id: '',
          assetNumber: '',
          assetName: '',
          description: '',
          assetCategory: AssetCategory.equipment,
          acquisitionDate: DateTime.now(),
          acquisitionCost: 0,
          depreciationMethod: DepreciationMethod.straight_line,
          usefulLife: 0,
          salvageValue: 0,
          currentBookValue: 0,
          accumulatedDepreciation: 0,
          location: '',
          department: '',
          status: status,
          insured: false,
          createdById: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: asset.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(asset.statusDisplayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (status) {
        ref.read(fixedAssetsProvider.notifier).updateFilters(status: status);
      },
    );
  }

  Widget _buildDepartmentFilter(FixedAssetsState state) {
    // In a real app, you'd fetch this from your backend
    final departments = [
      'Finance',
      'Operations',
      'IT',
      'HR',
      'Procurement',
      'Maintenance'
    ];

    return DropdownButtonFormField<String>(
      value: state.departmentFilter,
      decoration: const InputDecoration(
        labelText: 'Department',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Departments')),
        ...departments
            .map((dept) => DropdownMenuItem(value: dept, child: Text(dept))),
      ],
      onChanged: (department) {
        ref
            .read(fixedAssetsProvider.notifier)
            .updateFilters(department: department);
      },
    );
  }

  Widget _buildActiveFilters(FixedAssetsState state) {
    final activeFilters = <String>[];

    if (state.searchQuery.isNotEmpty) {
      activeFilters.add('Search: "${state.searchQuery}"');
    }
    if (state.categoryFilter != null) {
      activeFilters
          .add('Category: ${_getCategoryDisplayName(state.categoryFilter!)}');
    }
    if (state.statusFilter != null) {
      final tempAsset = FixedAsset(
        id: '',
        assetNumber: '',
        assetName: '',
        description: '',
        assetCategory: AssetCategory.equipment,
        acquisitionDate: DateTime.now(),
        acquisitionCost: 0,
        depreciationMethod: DepreciationMethod.straight_line,
        usefulLife: 0,
        salvageValue: 0,
        currentBookValue: 0,
        accumulatedDepreciation: 0,
        location: '',
        department: '',
        status: state.statusFilter!,
        insured: false,
        createdById: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      activeFilters.add('Status: ${tempAsset.statusDisplayName}');
    }
    if (state.departmentFilter != null) {
      activeFilters.add('Department: ${state.departmentFilter}');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const Text(
          'Active Filters:',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        ...activeFilters.map((filter) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border:
            Border.all(color: const Color(0xFF0D47A1).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filter,
                style:
                const TextStyle(fontSize: 12, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _clearFilters,
                child: const Icon(Icons.close,
                    size: 14, color: Color(0xFF0D47A1)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  bool _hasActiveFilters(FixedAssetsState state) {
    return state.searchQuery.isNotEmpty ||
        state.categoryFilter != null ||
        state.statusFilter != null ||
        state.departmentFilter != null;
  }

  String _getCategoryDisplayName(AssetCategory category) {
    switch (category) {
      case AssetCategory.land:
        return 'Land';
      case AssetCategory.buildings:
        return 'Buildings';
      case AssetCategory.vehicles:
        return 'Vehicles';
      case AssetCategory.equipment:
        return 'Equipment';
      case AssetCategory.furniture:
        return 'Furniture';
      case AssetCategory.computers:
        return 'Computers';
      case AssetCategory.office_equipment:
        return 'Office Equipment';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}