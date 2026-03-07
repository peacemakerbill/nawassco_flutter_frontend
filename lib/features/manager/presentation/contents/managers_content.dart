import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/manager_model.dart';
import '../../providers/manager_provider.dart';
import 'sub_widgets/manager_profile/delete_confirmation_dialog.dart';
import 'sub_widgets/manager_profile/manager_details.dart';
import 'sub_widgets/manager_profile/manager_form.dart';
import 'sub_widgets/manager_profile/manager_list_item.dart';
import 'sub_widgets/manager_profile/manager_stats.dart';

class ManagersContent extends ConsumerStatefulWidget {
  const ManagersContent({super.key});

  @override
  ConsumerState<ManagersContent> createState() => _ManagersContentState();
}

class _ManagersContentState extends ConsumerState<ManagersContent> {
  final _searchController = TextEditingController();
  ViewMode _viewMode = ViewMode.list;
  String? _filterDepartment;
  String? _filterLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(managerProvider.notifier).loadManagers();
    ref.read(managerProvider.notifier).loadManagerStats();
  }

  void _handleSearch(String query) {
    ref.read(managerProvider.notifier).setSearchQuery(query);
  }

  void _handleFilter({
    String? department,
    String? level,
  }) {
    setState(() {
      _filterDepartment = department;
      _filterLevel = level;
    });
    ref.read(managerProvider.notifier).setFilters(
          department: department,
          level: level,
        );
  }

  void _clearFilters() {
    setState(() {
      _filterDepartment = null;
      _filterLevel = null;
    });
    _searchController.clear();
    ref.read(managerProvider.notifier).setFilters();
  }

  void _showCreateForm() {
    setState(() {
      _viewMode = ViewMode.create;
    });
  }

  void _showEditForm() {
    setState(() {
      _viewMode = ViewMode.edit;
    });
  }

  void _showDetails() {
    setState(() {
      _viewMode = ViewMode.details;
    });
  }

  void _backToList() {
    setState(() {
      _viewMode = ViewMode.list;
    });
    ref.read(managerProvider.notifier).selectManager(null);
  }

  Future<void> _handleDeleteManager(String id) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Delete Manager',
      content: 'Are you sure you want to delete this manager? '
          'This will deactivate their account but preserve the data.',
    );

    if (confirmed == true) {
      await ref.read(managerProvider.notifier).deleteManager(id);
    }
  }

  Future<void> _handleCreateManager(Map<String, dynamic> data) async {
    final success =
        await ref.read(managerProvider.notifier).createManager(data);
    if (success) {
      _backToList();
    }
  }

  Future<void> _handleUpdateManager(
      String id, Map<String, dynamic> data) async {
    final success =
        await ref.read(managerProvider.notifier).updateManager(id, data);
    if (success) {
      _backToList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerProvider);
    final selectedManager = state.selectedManager;

    return Scaffold(
      body: _buildContent(state, selectedManager),
      floatingActionButton: _viewMode == ViewMode.list
          ? FloatingActionButton.extended(
              onPressed: _showCreateForm,
              icon: const Icon(Icons.add),
              label: const Text('New Manager'),
            )
          : null,
    );
  }

  Widget _buildContent(ManagerState state, ManagerModel? selectedManager) {
    switch (_viewMode) {
      case ViewMode.create:
        return ManagerForm(
          onSubmit: _handleCreateManager,
          onCancel: _backToList,
        );
      case ViewMode.edit:
        return selectedManager == null
            ? _buildList(state)
            : ManagerForm(
                manager: selectedManager,
                isEditing: true,
                onSubmit: (data) =>
                    _handleUpdateManager(selectedManager.id, data),
                onCancel: _backToList,
              );
      case ViewMode.details:
        return selectedManager == null
            ? _buildList(state)
            : ManagerDetails(
                manager: selectedManager,
                onEdit: _showEditForm,
                onBack: _backToList,
              );
      default:
        return _buildList(state);
    }
  }

  Widget _buildList(ManagerState state) {
    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          snap: true,
          title: const Text(
            'Managers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_filterDepartment != null ||
                _filterLevel != null ||
                _searchController.text.isNotEmpty)
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                tooltip: 'Clear filters',
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or employee number...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All Departments',
                          selected: _filterDepartment == null,
                          onSelected: (selected) =>
                              _handleFilter(department: null),
                        ),
                        ...Department.all.map((dept) {
                          return _buildFilterChip(
                            label: Department.display(dept),
                            selected: _filterDepartment == dept,
                            onSelected: (selected) => _handleFilter(
                              department: selected ? dept : null,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Stats
        if (state.stats != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ManagerStats(stats: state.stats),
            ),
          ),
        // Loading indicator
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        // Empty state
        if (!state.isLoading && state.managers.isEmpty)
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No managers found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                if (_filterDepartment != null ||
                    _filterLevel != null ||
                    _searchController.text.isNotEmpty)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          ),
        // Managers list
        if (!state.isLoading && state.managers.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final manager = state.managers[index];
                return ManagerListItem(
                  manager: manager,
                  isSelected: state.selectedManager?.id == manager.id,
                  onTap: () {
                    ref.read(managerProvider.notifier).selectManager(manager);
                    _showDetails();
                  },
                  onEdit: () {
                    ref.read(managerProvider.notifier).selectManager(manager);
                    _showEditForm();
                  },
                  onDelete: () => _handleDeleteManager(manager.id),
                );
              },
              childCount: state.managers.length,
            ),
          ),
        // Pagination
        if (!state.isLoading &&
            state.managers.isNotEmpty &&
            state.totalPages > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: state.currentPage > 1
                        ? () => ref
                            .read(managerProvider.notifier)
                            .goToPage(state.currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Page ${state.currentPage} of ${state.totalPages}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: state.currentPage < state.totalPages
                        ? () => ref
                            .read(managerProvider.notifier)
                            .goToPage(state.currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: selected ? Colors.blue.shade800 : Colors.grey.shade700,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.blue.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

enum ViewMode {
  list,
  create,
  edit,
  details,
}
