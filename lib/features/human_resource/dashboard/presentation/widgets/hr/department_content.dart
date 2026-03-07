import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/department.dart';
import '../../../../providers/department_provider.dart';
import '../sub_widgets/department/department_card.dart';
import '../sub_widgets/department/department_details.dart';
import '../sub_widgets/department/department_form.dart';
import '../sub_widgets/department/department_hierarchy.dart';
import '../sub_widgets/department/department_stats.dart';

enum DepartmentView {
  list,
  form,
  details,
  stats,
  hierarchy,
}

class DepartmentContent extends ConsumerStatefulWidget {
  const DepartmentContent({Key? key}) : super(key: key);

  @override
  ConsumerState<DepartmentContent> createState() => _DepartmentContentState();
}

class _DepartmentContentState extends ConsumerState<DepartmentContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DepartmentView _currentView = DepartmentView.list;
  Department? _selectedDepartment;
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _locationFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    ref.read(departmentProvider.notifier).initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToView(DepartmentView view, {Department? department}) {
    setState(() {
      _currentView = view;
      _selectedDepartment = department;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_statusFilter != 'all') {
      filters['isActive'] = _statusFilter == 'active';
    }

    if (_locationFilter != 'all') {
      filters['location'] = _locationFilter;
    }

    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }

    ref.read(departmentProvider.notifier).setFilter(filters);
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    _searchController.clear();
    _statusFilter = 'all';
    _locationFilter = 'all';
    ref.read(departmentProvider.notifier).clearFilter();
    setState(() => _showFilters = false);
  }

  Widget _buildListView() {
    final state = ref.watch(departmentProvider);
    final provider = ref.read(departmentProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Departments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () => setState(() => _showFilters = !_showFilters),
                          tooltip: 'Show filters',
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToView(DepartmentView.stats),
                          icon: const Icon(Icons.insights),
                          label: const Text('Statistics'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToView(DepartmentView.hierarchy),
                          icon: const Icon(Icons.account_tree),
                          label: const Text('Hierarchy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToView(DepartmentView.form),
                          icon: const Icon(Icons.add),
                          label: const Text('New Department'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search departments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.clearFilter();
                      },
                    )
                        : null,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      provider.searchDepartments(value);
                    }
                  },
                ),
              ],
            ),
          ),

          // Filters
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Status')),
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                          ],
                          onChanged: (value) =>
                              setState(() => _statusFilter = value ?? 'all'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _locationFilter,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Locations')),
                            DropdownMenuItem(
                              value: 'Nairobi Head Office',
                              child: Text('Nairobi Head Office'),
                            ),
                            DropdownMenuItem(
                              value: 'Mombasa Branch',
                              child: Text('Mombasa Branch'),
                            ),
                            DropdownMenuItem(
                              value: 'Kisumu Branch',
                              child: Text('Kisumu Branch'),
                            ),
                            DropdownMenuItem(
                              value: 'Remote',
                              child: Text('Remote'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _locationFilter = value ?? 'all'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Departments list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.departments.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No departments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first department to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _navigateToView(DepartmentView.form),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Department'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                await provider.initialize();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.departments.length,
                itemBuilder: (context, index) {
                  final department = state.departments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DepartmentCard(
                      department: department,
                      isSelected: _selectedDepartment?.id == department.id,
                      onTap: () => _navigateToView(
                        DepartmentView.details,
                        department: department,
                      ),
                      onEdit: () => _navigateToView(
                        DepartmentView.form,
                        department: department,
                      ),
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Department'),
                            content: const Text(
                              'Are you sure you want to delete this department? '
                                  'This will also remove all employees from this department.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await provider.deleteDepartment(department.id);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Pagination
          if (state.totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: state.currentPage > 1
                        ? () => provider.setPage(state.currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Page ${state.currentPage} of ${state.totalPages}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: state.currentPage < state.totalPages
                        ? () => provider.setPage(state.currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentView == DepartmentView.list
          ? _buildListView()
          : _currentView == DepartmentView.form
          ? DepartmentForm(
        department: _selectedDepartment,
        onSuccess: () => _navigateToView(
          DepartmentView.details,
          department: _selectedDepartment ??
              ref.read(departmentProvider).selectedDepartment,
        ),
      )
          : _currentView == DepartmentView.details && _selectedDepartment != null
          ? DepartmentDetails(
        department: _selectedDepartment!,
        onEdit: () => _navigateToView(
          DepartmentView.form,
          department: _selectedDepartment,
        ),
      )
          : _currentView == DepartmentView.stats
          ? const DepartmentStatsWidget()
          : const DepartmentHierarchyWidget(),
      floatingActionButton: _currentView == DepartmentView.list
          ? FloatingActionButton.extended(
        onPressed: () => _navigateToView(DepartmentView.form),
        icon: const Icon(Icons.add),
        label: const Text('New Department'),
      )
          : FloatingActionButton(
        onPressed: () => _navigateToView(DepartmentView.list),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}