import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nawassco/features/shared/widgets/sub_widgets/service_area/common/empty_state.dart';
import '../../../../../../core/utils/toast_utils.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/service_area_model.dart';
import '../../../../providers/service_area_provider.dart';
import '../../../sub_widgets/service_area/common/responsive_layout.dart';
import '../../../sub_widgets/service_area/common/search_filter_bar.dart';
import '../../../sub_widgets/service_area/service_area_card.dart';
import '../../../sub_widgets/service_area/service_area_details.dart';
import '../../../sub_widgets/service_area/service_area_form.dart';
import '../../../sub_widgets/service_area/service_area_stats.dart';

class ServiceAreaManagementContent extends ConsumerStatefulWidget {
  const ServiceAreaManagementContent({super.key});

  @override
  _ServiceAreaManagementContentState createState() =>
      _ServiceAreaManagementContentState();
}

class _ServiceAreaManagementContentState
    extends ConsumerState<ServiceAreaManagementContent> {
  ServiceArea? _selectedArea;
  bool _showForm = false;
  bool _isEditing = false;

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

  void _handleEdit() {
    setState(() {
      _showForm = true;
      _isEditing = true;
    });
  }

  void _handleDelete() async {
    if (_selectedArea == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Area'),
        content: Text(
            'Are you sure you want to delete "${_selectedArea!.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(serviceAreaProvider.notifier)
          .deleteServiceArea(_selectedArea!.id);
      if (success && mounted) {
        setState(() {
          _selectedArea = null;
          _showForm = false;
        });
        ToastUtils.showSuccessToast('Service area deleted successfully');
      }
    }
  }

  void _handleAddNew() {
    setState(() {
      _selectedArea = null;
      _showForm = true;
      _isEditing = false;
    });
  }

  void _handleFormSuccess() {
    setState(() {
      _showForm = false;
      _isEditing = false;
    });
    ToastUtils.showSuccessToast(
      _isEditing
          ? 'Service area updated successfully'
          : 'Service area created successfully',
    );
  }

  Widget _buildMobileLayout() {
    final state = ref.watch(serviceAreaProvider);

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

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Service Area Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: _handleAddNew,
                icon: const Icon(Icons.add),
                tooltip: 'Add New Service Area',
              ),
            ],
          ),
        ),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ServiceAreaStats(),
        ),
        // Content
        Expanded(
          child: _showForm
              ? ServiceAreaForm(
                  initialData: _isEditing ? _selectedArea : null,
                  onSuccess: _handleFormSuccess,
                )
              : _buildServiceAreaList(),
        ),
        // Selected Area Actions (if any)
        if (_selectedArea != null && !_showForm)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor)),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _handleEdit,
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _handleDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    final state = ref.watch(serviceAreaProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Service Area Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _handleAddNew,
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
              ),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: Row(
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ServiceAreaStats(),
                    ),
                    // List
                    Expanded(
                      child: _buildServiceAreaList(),
                    ),
                  ],
                ),
              ),
              // Right Panel - Details/Form
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                        left:
                            BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: _showForm
                      ? ServiceAreaForm(
                          initialData: _isEditing ? _selectedArea : null,
                          onSuccess: _handleFormSuccess,
                        )
                      : (_selectedArea != null
                          ? ServiceAreaDetails(
                              serviceArea: _selectedArea!,
                              onEdit: _handleEdit,
                              onDelete: _handleDelete,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_city,
                                    size: 64,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Manage Service Areas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select a service area or add a new one',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final state = ref.watch(serviceAreaProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Service Area Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _handleAddNew,
                icon: const Icon(Icons.add),
                label: const Text('Add New Service Area'),
              ),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: Row(
            children: [
              // Left Panel - Stats
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                        right:
                            BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: const ServiceAreaStats(),
                ),
              ),
              // Middle Panel - List
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
                    // List
                    Expanded(
                      child: _buildServiceAreaList(),
                    ),
                  ],
                ),
              ),
              // Right Panel - Details/Form
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                        left:
                            BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: _showForm
                      ? ServiceAreaForm(
                          initialData: _isEditing ? _selectedArea : null,
                          onSuccess: _handleFormSuccess,
                        )
                      : (_selectedArea != null
                          ? ServiceAreaDetails(
                              serviceArea: _selectedArea!,
                              onEdit: _handleEdit,
                              onDelete: _handleDelete,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.engineering,
                                    size: 96,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Management Dashboard',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select a service area to manage, or create a new one',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _handleAddNew,
                                    icon: const Icon(Icons.add_circle),
                                    label:
                                        const Text('Create New Service Area'),
                                  ),
                                ],
                              ),
                            )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceAreaList() {
    final state = ref.watch(serviceAreaProvider);

    if (state.filteredServiceAreas.isEmpty) {
      return EmptyState(
        icon: Icons.location_city,
        title: 'No service areas found',
        subtitle: 'Try adjusting your filters or create a new service area',
        action: () {
          ref.read(serviceAreaProvider.notifier).clearFilters();
          _handleAddNew();
        },
        actionLabel: 'Create New',
      );
    }

    return ListView.builder(
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
                _selectedArea = area;
                _showForm = false;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Check authorization
    if (!authState.hasAnyRole(['Admin', 'Manager', 'Technician'])) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You need administrator, manager, or technician privileges to access this section.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
}
