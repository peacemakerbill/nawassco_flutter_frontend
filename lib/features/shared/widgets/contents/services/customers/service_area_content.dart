import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nawassco/features/shared/widgets/sub_widgets/service_area/common/empty_state.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/service_area_model.dart';
import '../../../../providers/service_area_provider.dart';
import '../../../sub_widgets/service_area/common/responsive_layout.dart';
import '../../../sub_widgets/service_area/common/search_filter_bar.dart';
import '../../../sub_widgets/service_area/service_area_card.dart';
import '../../../sub_widgets/service_area/service_area_details.dart';
import '../../../sub_widgets/service_area/service_area_stats.dart';

class ServiceAreaContent extends ConsumerStatefulWidget {
  const ServiceAreaContent({super.key});

  @override
  _ServiceAreaContentState createState() => _ServiceAreaContentState();
}

class _ServiceAreaContentState extends ConsumerState<ServiceAreaContent> {
  ServiceArea? _selectedArea;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceAreaProvider.notifier).loadServiceAreas();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    final state = ref.watch(serviceAreaProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  ref.read(serviceAreaProvider.notifier).clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Area Type', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: AreaType.values.map((type) {
              final isSelected = state.filterType == type;
              return FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(serviceAreaProvider.notifier)
                      .setFilterType(selected ? type : null);
                },
                backgroundColor:
                    isSelected ? type.color.withValues(alpha: 0.1) : null,
                selectedColor: type.color.withValues(alpha: 0.2),
                checkmarkColor: type.color,
                labelStyle: TextStyle(
                  color: isSelected ? type.color : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: ServiceStatus.values.map((status) {
              final isSelected = state.filterStatus == status;
              return FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(serviceAreaProvider.notifier)
                      .setFilterStatus(selected ? status : null);
                },
                backgroundColor:
                    isSelected ? status.color.withValues(alpha: 0.1) : null,
                selectedColor: status.color.withValues(alpha: 0.2),
                checkmarkColor: status.color,
                labelStyle: TextStyle(
                  color: isSelected ? status.color : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final state = ref.watch(serviceAreaProvider);
    final authState = ref.watch(authProvider);

    if (state.isLoading && state.serviceAreas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.serviceAreas.isEmpty) {
      return EmptyState(
        icon: Icons.error,
        title: 'Something went wrong',
        subtitle: state.error!,
        action: () => ref.read(serviceAreaProvider.notifier).loadServiceAreas(),
      );
    }

    if (state.filteredServiceAreas.isEmpty) {
      return EmptyState(
        icon: Icons.location_city,
        title: 'No service areas found',
        subtitle: 'Try adjusting your filters or search query',
        action: () => ref.read(serviceAreaProvider.notifier).clearFilters(),
        actionLabel: 'Clear Filters',
      );
    }

    return Column(
      children: [
        // Search and Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchFilterBar(
            searchQuery: state.searchQuery,
            onSearchChanged: (query) =>
                ref.read(serviceAreaProvider.notifier).setSearchQuery(query),
            onFilterPressed: _showFilterDialog,
          ),
        ),
        // Stats
        if (authState.hasAnyRole(['Admin', 'Manager', 'Technician']))
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ServiceAreaStats(),
          ),
        const SizedBox(height: 16),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Areas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Chip(
                label: Text('${state.filteredServiceAreas.length} areas'),
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Service Areas List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.filteredServiceAreas.length,
            itemBuilder: (context, index) {
              final area = state.filteredServiceAreas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ServiceAreaCard(
                  serviceArea: area,
                  isSelected: _selectedArea?.id == area.id,
                  onTap: () {
                    setState(() {
                      _selectedArea =
                          _selectedArea?.id == area.id ? null : area;
                    });
                  },
                ),
              );
            },
          ),
        ),
        // Selected Area Details
        if (_selectedArea != null)
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedArea!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => setState(() => _selectedArea = null),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ServiceAreaDetails(
                    serviceArea: _selectedArea!,
                    showActions: false,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    final state = ref.watch(serviceAreaProvider);
    final authState = ref.watch(authProvider);

    return Row(
      children: [
        // Left Panel - List
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchFilterBar(
                  searchQuery: state.searchQuery,
                  onSearchChanged: (query) => ref
                      .read(serviceAreaProvider.notifier)
                      .setSearchQuery(query),
                  onFilterPressed: _showFilterDialog,
                ),
              ),
              // Stats
              if (authState.hasAnyRole(['Admin', 'Manager', 'Technician']))
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ServiceAreaStats(),
                ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Areas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Chip(
                      label: Text('${state.filteredServiceAreas.length} areas'),
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Service Areas List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredServiceAreas.length,
                  itemBuilder: (context, index) {
                    final area = state.filteredServiceAreas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ServiceAreaCard(
                        serviceArea: area,
                        isSelected: _selectedArea?.id == area.id,
                        onTap: () => setState(() => _selectedArea = area),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Right Panel - Details
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: _selectedArea != null
                ? ServiceAreaDetails(
                    serviceArea: _selectedArea!,
                    showActions: false,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.select_all,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a service area',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose a service area from the list to view details',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final state = ref.watch(serviceAreaProvider);
    final authState = ref.watch(authProvider);

    return Row(
      children: [
        // Left Panel - Stats
        if (authState.hasAnyRole(['Admin', 'Manager', 'Technician']))
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: const ServiceAreaStats(),
            ),
          ),
        // Middle Panel - List
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchFilterBar(
                  searchQuery: state.searchQuery,
                  onSearchChanged: (query) => ref
                      .read(serviceAreaProvider.notifier)
                      .setSearchQuery(query),
                  onFilterPressed: _showFilterDialog,
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Areas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Chip(
                      label: Text('${state.filteredServiceAreas.length} areas'),
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Service Areas List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredServiceAreas.length,
                  itemBuilder: (context, index) {
                    final area = state.filteredServiceAreas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ServiceAreaCard(
                        serviceArea: area,
                        isSelected: _selectedArea?.id == area.id,
                        onTap: () => setState(() => _selectedArea = area),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Right Panel - Details
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: _selectedArea != null
                ? ServiceAreaDetails(
                    serviceArea: _selectedArea!,
                    showActions: false,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 96,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Service Area Details',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a service area from the list to view comprehensive details',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
}
