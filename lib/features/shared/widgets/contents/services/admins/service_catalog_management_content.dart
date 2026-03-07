import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/service_catalog_model.dart';
import '../../../../providers/service_catalog_provider.dart';
import '../../../sub_widgets/service_catalog/service_card_widget.dart';
import '../../../sub_widgets/service_catalog/service_details_widget.dart';
import '../../../sub_widgets/service_catalog/service_form_widget.dart';
import '../../../sub_widgets/service_catalog/service_stats_widget.dart';


class ServiceCatalogManagementContent extends ConsumerStatefulWidget {
  const ServiceCatalogManagementContent({super.key});

  @override
  ConsumerState<ServiceCatalogManagementContent> createState() => _ServiceCatalogManagementContentState();
}

class _ServiceCatalogManagementContentState extends ConsumerState<ServiceCatalogManagementContent> {
  final _searchController = TextEditingController();
  ServiceCatalog? _selectedService;
  bool _showCreateForm = false;
  bool _showEditForm = false;
  String _viewMode = 'grid'; // 'grid' or 'list'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceCatalogProvider.notifier).fetchServices();
      ref.read(serviceCatalogProvider.notifier).fetchStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final serviceState = ref.watch(serviceCatalogProvider);
    final serviceProvider = ref.read(serviceCatalogProvider.notifier);

    // Check if user has management permissions
    if (!authState.isAdmin && !authState.isManager) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You need admin or manager privileges to access this section.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return _selectedService != null && !_showEditForm
        ? ServiceDetailsWidget(
      service: _selectedService,
      showEditButton: true,
      showBackButton: true,
      onEdit: () => setState(() => _showEditForm = true),
      onBack: () => setState(() => _selectedService = null),
    )
        : _showCreateForm || _showEditForm
        ? _buildFormView()
        : _buildManagementView();
  }

  Widget _buildManagementView() {
    final serviceState = ref.watch(serviceCatalogProvider);
    final serviceProvider = ref.read(serviceCatalogProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Catalog Management'),
        actions: [
          IconButton(
            icon: Icon(_viewMode == 'grid' ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _viewMode = _viewMode == 'grid' ? 'list' : 'grid'),
            tooltip: 'Switch view',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => serviceProvider.fetchServices(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            serviceProvider.clearFilters();
                          },
                        ),
                      ),
                      onChanged: (value) {
                        final filters = Map<String, dynamic>.from(serviceState.filters);
                        if (value.isNotEmpty) {
                          filters['search'] = value;
                        } else {
                          filters.remove('search');
                        }
                        serviceProvider.applyFilters(filters);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                    child: VerticalDivider(),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.filter_list),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.filter_alt),
                          title: const Text('Active Only'),
                          onTap: () {
                            Navigator.pop(context);
                            serviceProvider.applyFilters({'status': 'active'});
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.filter_alt_off),
                          title: const Text('Inactive Only'),
                          onTap: () {
                            Navigator.pop(context);
                            serviceProvider.applyFilters({'status': 'inactive'});
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.clear_all),
                          title: const Text('Clear Filters'),
                          onTap: () {
                            Navigator.pop(context);
                            serviceProvider.clearFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ServiceStatsWidget(
              stats: serviceState.stats,
              totalServices: serviceState.services.length,
              activeServices: serviceState.services
                  .where((s) => s.status == ServiceStatus.active)
                  .length,
            ),
          ),

          // Service List/Grid
          Expanded(
            child: serviceState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : serviceState.filteredServices.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No services found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  if (_searchController.text.isNotEmpty || serviceState.filters.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        serviceProvider.clearFilters();
                        _searchController.clear();
                      },
                      child: Text('Clear search and filters'),
                    ),
                ],
              ),
            )
                : _viewMode == 'grid'
                ? _buildGridView(serviceState.filteredServices)
                : _buildListView(serviceState.filteredServices),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showCreateForm = true),
        icon: Icon(Icons.add),
        label: Text('New Service'),
      ),
    );
  }

  Widget _buildGridView(List<ServiceCatalog> services) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceCardWidget(
            service: service,
            showActions: true,
            onTap: () => setState(() => _selectedService = service),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<ServiceCatalog> services) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCardWidget(
          service: service,
          showActions: true,
          onTap: () => setState(() => _selectedService = service),
        );
      },
    );
  }

  Widget _buildFormView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showEditForm ? 'Edit Service' : 'Create New Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _showCreateForm = false;
            _showEditForm = false;
          }),
        ),
      ),
      body: ServiceFormWidget(
        initialData: _showEditForm ? _selectedService : null,
        onSubmit: (data) {
          final provider = ref.read(serviceCatalogProvider.notifier);
          if (_showEditForm && _selectedService != null) {
            provider.updateService(_selectedService!.id, data);
          } else {
            provider.createService(data);
          }
          setState(() {
            _showCreateForm = false;
            _showEditForm = false;
            _selectedService = null;
          });
        },
        onCancel: () => setState(() {
          _showCreateForm = false;
          _showEditForm = false;
        }),
      ),
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 700) return 2;
    return 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}