import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/service_catalog_model.dart';
import '../../../../providers/service_catalog_provider.dart';
import '../../../sub_widgets/service_catalog/availability_checker_widget.dart';
import '../../../sub_widgets/service_catalog/service_card_widget.dart';
import '../../../sub_widgets/service_catalog/service_details_widget.dart';
import '../../../sub_widgets/service_catalog/service_filter_widget.dart';
import '../../../sub_widgets/service_catalog/service_form_widget.dart';
import '../../../sub_widgets/service_catalog/service_stats_widget.dart';

class ServiceCatalogContent extends ConsumerStatefulWidget {
  const ServiceCatalogContent({super.key});

  @override
  ConsumerState<ServiceCatalogContent> createState() => _ServiceCatalogContentState();
}

class _ServiceCatalogContentState extends ConsumerState<ServiceCatalogContent> {
  final _searchController = TextEditingController();
  bool _showFilters = false;
  ServiceCatalog? _selectedService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceCatalogProvider.notifier).fetchServices();
      ref.read(serviceCatalogProvider.notifier).fetchStatistics();
      ref.read(serviceCatalogProvider.notifier).fetchPopularServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final serviceState = ref.watch(serviceCatalogProvider);
    final serviceProvider = ref.read(serviceCatalogProvider.notifier);

    return _selectedService != null
        ? ServiceDetailsWidget(
      service: _selectedService,
      showBackButton: true,
      onBack: () => setState(() => _selectedService = null),
    )
        : Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Service Catalog',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search services...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.filter_list),
                              onPressed: _showFilterPanel,
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
                      const SizedBox(height: 12),
                      // Quick Stats
                      Row(
                        children: [
                          Chip(
                            label: Text('${serviceState.services.length} Services'),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${serviceState.popularServices.length} Popular'),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Filter Panel
          if (_showFilters)
            SliverToBoxAdapter(
              child: ServiceFilterWidget(
                initialFilters: serviceState.filters,
                onApply: (filters) {
                  serviceProvider.applyFilters(filters);
                  setState(() => _showFilters = false);
                },
                onClear: () {
                  serviceProvider.clearFilters();
                  setState(() => _showFilters = false);
                },
              ),
            ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Statistics
                ServiceStatsWidget(
                  stats: serviceState.stats,
                  totalServices: serviceState.services.length,
                  activeServices: serviceState.services
                      .where((s) => s.status == ServiceStatus.active)
                      .length,
                ),

                const SizedBox(height: 24),

                // Availability Checker
                const AvailabilityCheckerWidget(),

                const SizedBox(height: 24),

                // Popular Services
                if (serviceState.popularServices.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Popular Services',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ServiceCardGridWidget(
                        services: serviceState.popularServices,
                        crossAxisCount: _getCrossAxisCount(context),
                        onTap: (service) => setState(() => _selectedService = service),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // All Services
                Row(
                  children: [
                    Icon(Icons.grid_view, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'All Services',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${serviceState.filteredServices.length} services',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Service Grid
                if (serviceState.filteredServices.isNotEmpty)
                  ServiceCardGridWidget(
                    services: serviceState.filteredServices,
                    crossAxisCount: _getCrossAxisCount(context),
                    onTap: (service) => setState(() => _selectedService = service),
                  )
                else if (serviceState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No services found',
                            style: TextStyle(color: Colors.grey),
                          ),
                          if (serviceState.filters.isNotEmpty)
                            TextButton(
                              onPressed: () => serviceProvider.clearFilters(),
                              child: const Text('Clear filters'),
                            ),
                        ],
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: authState.isAdmin || authState.isManager
          ? FloatingActionButton.extended(
        onPressed: () => _showCreateServiceDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Service'),
      )
          : null,
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _showFilterPanel() {
    setState(() => _showFilters = !_showFilters);
  }

  void _showCreateServiceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ServiceFormWidget(
          onSubmit: (data) {
            ref.read(serviceCatalogProvider.notifier).createService(data);
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}