import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/warehouse_model.dart';
import '../../providers/warehouse_provider.dart';
import 'sub_widgets/warehouse/utilization_chart.dart';
import 'sub_widgets/warehouse/warehouse_card.dart';
import 'sub_widgets/warehouse/warehouse_details_view.dart';
import 'sub_widgets/warehouse/warehouse_filters.dart';
import 'sub_widgets/warehouse/warehouse_form_view.dart';

class WarehouseScreen extends ConsumerStatefulWidget {
  const WarehouseScreen({super.key});

  @override
  ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await ref.read(warehouseProvider.notifier).getWarehouses();
      _animationController.forward();
    } catch (e) {
      // Error handled by provider
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadInitialData();
    setState(() => _isRefreshing = false);
  }

  void _handleSearch(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(warehouseProvider.notifier).setSearchQuery(query);
      _loadInitialData();
    });
  }

  void _handleBack() {
    ref.read(warehouseProvider.notifier).showListView();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentView(state, theme),
      ),
    );
  }

  Widget _buildCurrentView(WarehouseState state, ThemeData theme) {
    switch (state.currentView) {
      case WarehouseView.list:
        return _buildListView(state, theme);
      case WarehouseView.details:
        return _buildDetailsView(state, theme);
      case WarehouseView.create:
        return _buildCreateView(state, theme);
      case WarehouseView.edit:
        return _buildEditView(state, theme);
      case WarehouseView.utilization:
        return _buildUtilizationView(state, theme);
    }
  }

  Widget _buildListView(WarehouseState state, ThemeData theme) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;

    return Column(
      children: [
        _buildAppBar(theme, showBackButton: false),
        Expanded(
          child: state.isLoading && state.warehouses.isEmpty
              ? _buildShimmerLoader(isLargeScreen)
              : state.error != null && state.warehouses.isEmpty
                  ? _buildErrorState(state.error!, _refreshData)
                  : _buildWarehouseContent(state, theme, isLargeScreen),
        ),
      ],
    );
  }

  Widget _buildDetailsView(WarehouseState state, ThemeData theme) {
    return Column(
      children: [
        _buildAppBar(theme, showBackButton: true),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: WarehouseDetailsView(
                warehouse: state.selectedWarehouse!,
                onEdit: () => ref
                    .read(warehouseProvider.notifier)
                    .showEditView(state.selectedWarehouse!),
                onViewUtilization: () => ref
                    .read(warehouseProvider.notifier)
                    .showUtilizationView(state.selectedWarehouse!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateView(WarehouseState state, ThemeData theme) {
    return Column(
      children: [
        _buildAppBar(theme, showBackButton: true),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: WarehouseFormView(
                onSave: () =>
                    ref.read(warehouseProvider.notifier).showListView(),
                onCancel: () =>
                    ref.read(warehouseProvider.notifier).showListView(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(WarehouseState state, ThemeData theme) {
    return Column(
      children: [
        _buildAppBar(theme, showBackButton: true),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: WarehouseFormView(
                warehouse: state.selectedWarehouse,
                onSave: () => ref
                    .read(warehouseProvider.notifier)
                    .showDetailsView(state.selectedWarehouse!),
                onCancel: () => ref
                    .read(warehouseProvider.notifier)
                    .showDetailsView(state.selectedWarehouse!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilizationView(WarehouseState state, ThemeData theme) {
    return Column(
      children: [
        _buildAppBar(theme, showBackButton: true),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: UtilizationView(warehouse: state.selectedWarehouse!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(ThemeData theme, {required bool showBackButton}) {
    final state = ref.read(warehouseProvider);

    return AppBar(
      title: _buildAppBarTitle(state),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: theme.colorScheme.primary,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _handleBack,
              tooltip: 'Back',
            )
          : null,
      actions: _buildAppBarActions(state, theme),
    );
  }

  Widget _buildAppBarTitle(WarehouseState state) {
    switch (state.currentView) {
      case WarehouseView.list:
        return const Text('Warehouse Management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
      case WarehouseView.details:
        return Text(
            state.selectedWarehouse?.warehouseName ?? 'Warehouse Details',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
      case WarehouseView.create:
        return const Text('Create Warehouse',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
      case WarehouseView.edit:
        return const Text('Edit Warehouse',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
      case WarehouseView.utilization:
        return const Text('Utilization Overview',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
    }
  }

  List<Widget> _buildAppBarActions(WarehouseState state, ThemeData theme) {
    switch (state.currentView) {
      case WarehouseView.list:
        return [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () =>
                ref.read(warehouseProvider.notifier).showCreateView(),
            tooltip: 'Add Warehouse',
          ),
        ];
      case WarehouseView.details:
        return [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => ref
                .read(warehouseProvider.notifier)
                .showEditView(state.selectedWarehouse!),
            tooltip: 'Edit Warehouse',
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildWarehouseContent(
      WarehouseState state, ThemeData theme, bool isLargeScreen) {
    return Column(
      children: [
        _buildSearchHeader(state, theme),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              slivers: [
                if (state.warehouses.isNotEmpty) ...[
                  _buildStatsSection(state, theme),
                  _buildWarehouseList(state, theme, isLargeScreen),
                ] else ...[
                  _buildEmptyState(theme),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(WarehouseState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Search warehouses...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list_rounded,
                      color: Colors.white, size: 20),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: WarehouseFilters(
                      onStatusChanged: (status) {
                        ref
                            .read(warehouseProvider.notifier)
                            .setStatusFilter(status);
                        _loadInitialData();
                      },
                      onCityChanged: (city) {
                        ref
                            .read(warehouseProvider.notifier)
                            .setCityFilter(city);
                        _loadInitialData();
                      },
                      onClearFilters: () {
                        ref.read(warehouseProvider.notifier).clearFilters();
                        _loadInitialData();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (state.searchQuery.isNotEmpty ||
              state.statusFilter != null ||
              state.cityFilter != null) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(state, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters(WarehouseState state, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (state.searchQuery.isNotEmpty)
          Chip(
            label: Text('Search: ${state.searchQuery}'),
            onDeleted: () {
              _searchController.clear();
              ref.read(warehouseProvider.notifier).setSearchQuery('');
              _loadInitialData();
            },
          ),
        if (state.statusFilter != null)
          Chip(
            label: Text('Status: ${state.statusFilter!.name}'),
            onDeleted: () {
              ref.read(warehouseProvider.notifier).setStatusFilter(null);
              _loadInitialData();
            },
          ),
        if (state.cityFilter != null && state.cityFilter!.isNotEmpty)
          Chip(
            label: Text('City: ${state.cityFilter}'),
            onDeleted: () {
              ref.read(warehouseProvider.notifier).setCityFilter(null);
              _loadInitialData();
            },
          ),
      ],
    );
  }

  Widget _buildStatsSection(WarehouseState state, ThemeData theme) {
    final operationalCount = state.warehouses
        .where((w) => w.status == WarehouseStatus.OPERATIONAL)
        .length;
    final totalCapacity = state.warehouses
        .fold<double>(0, (sum, w) => sum + w.capacity.totalArea);
    final avgUtilization = state.warehouses
            .fold<double>(0, (sum, w) => sum + w.capacity.currentUtilization) /
        state.warehouses.length;

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                  'Total Warehouses',
                  state.warehouses.length.toString(),
                  Icons.warehouse_rounded,
                  theme),
              _buildStatCard('Operational', operationalCount.toString(),
                  Icons.check_circle_rounded, theme,
                  color: Colors.green),
              _buildStatCard(
                  'Total Capacity',
                  '${totalCapacity.toStringAsFixed(0)} m²',
                  Icons.space_dashboard_rounded,
                  theme),
              _buildStatCard(
                  'Avg Utilization',
                  '${avgUtilization.toStringAsFixed(1)}%',
                  Icons.trending_up_rounded,
                  theme,
                  color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, ThemeData theme,
      {Color? color}) {
    return Card(
      elevation: 4,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (color ?? theme.colorScheme.primary).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: color ?? theme.colorScheme.primary, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseList(
      WarehouseState state, ThemeData theme, bool isLargeScreen) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isLargeScreen ? 1.6 : 1.4,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final warehouse = state.warehouses[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: WarehouseCard(
                warehouse: warehouse,
                onTap: () => ref
                    .read(warehouseProvider.notifier)
                    .showDetailsView(warehouse),
                onEdit: () => ref
                    .read(warehouseProvider.notifier)
                    .showEditView(warehouse),
                onViewUtilization: () => ref
                    .read(warehouseProvider.notifier)
                    .showUtilizationView(warehouse),
              ),
            );
          },
          childCount: state.warehouses.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse_outlined,
                size: 80, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No Warehouses Found',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first warehouse to get started',
              style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(warehouseProvider.notifier).showCreateView(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Warehouse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(bool isLargeScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
                Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
                Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
                Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLargeScreen ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isLargeScreen ? 1.6 : 1.4,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load warehouses',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Utilization View
class UtilizationView extends StatelessWidget {
  final Warehouse warehouse;

  const UtilizationView({super.key, required this.warehouse});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: UtilizationChart(warehouse: warehouse),
    );
  }
}
