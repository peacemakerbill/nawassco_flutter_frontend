import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/employee_model.dart';
import '../../../../providers/employee_provider.dart';
import '../sub_widgets/employee/employee_card.dart';
import '../sub_widgets/employee/employee_detail_screen.dart';
import '../sub_widgets/employee/employee_filters.dart';
import '../sub_widgets/employee/employee_form_screen.dart';

class EmployeeManagementContent extends ConsumerStatefulWidget {
  const EmployeeManagementContent({super.key});

  @override
  ConsumerState<EmployeeManagementContent> createState() =>
      _EmployeeManagementContentState();
}

class _EmployeeManagementContentState
    extends ConsumerState<EmployeeManagementContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeProvider.notifier).loadEmployees();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreEmployees();
    }
  }

  Future<void> _loadMoreEmployees() async {
    if (_isLoadingMore) return;

    final state = ref.read(employeeProvider);
    if (!state.hasMore) return;

    setState(() => _isLoadingMore = true);
    await ref.read(employeeProvider.notifier).loadEmployees(loadMore: true);
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshEmployees() async {
    await ref.read(employeeProvider.notifier).loadEmployees();
  }

  void _showDeleteDialog(String employeeId, String employeeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Are you sure you want to delete $employeeName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEmployee(employeeId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(String id) async {
    final success =
        await ref.read(employeeProvider.notifier).deleteEmployee(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showStatusDialog(Employee employee) {
    final currentStatus = employee.employmentStatus;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String? selectedStatus;
          final reasonController = TextEditingController();

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Employment Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Status: ${currentStatus.toString().split('.').last.replaceAll('_', ' ')}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'New Status',
                      border: OutlineInputBorder(),
                    ),
                    items: EmploymentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status.toString().split('.').last,
                        child: Text(status
                            .toString()
                            .split('.')
                            .last
                            .replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedStatus = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Status Change',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedStatus == null
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await _updateEmployeeStatus(
                                    employee.id,
                                    selectedStatus!,
                                    reasonController.text,
                                  );
                                },
                          child: const Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateEmployeeStatus(
      String id, String status, String reason) async {
    final provider = ref.read(employeeProvider.notifier);
    final success = await provider.updateEmploymentStatus(id, status, reason);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _refreshEmployees();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading employees...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load employees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshEmployees,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Employees Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first employee to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmployeeFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Employee'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final canManage = ref.read(authProvider).isAdmin ||
        ref.read(authProvider).isHR ||
        ref.read(authProvider).isManager;

    if (!canManage) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You need HR, Admin, or Manager privileges to access employee management.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (employeeState.isLoading && employeeState.employees.isEmpty) {
      return _buildLoadingState();
    }

    if (employeeState.error != null && employeeState.employees.isEmpty) {
      return _buildErrorState(employeeState.error!);
    }

    if (employeeState.filteredEmployees.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Search and Filters Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: EmployeeFilters(
            searchController: _searchController,
            selectedDepartment: employeeState.selectedDepartment,
            selectedStatus: employeeState.selectedStatus,
            departments: ref.read(employeeProvider.notifier).departments,
            statuses: ref.read(employeeProvider.notifier).statuses,
            onSearchChanged: (query) {
              ref
                  .read(employeeProvider.notifier)
                  .filterEmployees(searchQuery: query);
            },
            onDepartmentChanged: (dept) {
              ref
                  .read(employeeProvider.notifier)
                  .filterEmployees(department: dept);
            },
            onStatusChanged: (status) {
              ref
                  .read(employeeProvider.notifier)
                  .filterEmployees(status: status);
            },
            onClearFilters: () {
              _searchController.clear();
              ref.read(employeeProvider.notifier).clearFilters();
            },
          ),
        ),

        // Employees List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshEmployees,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: employeeState.filteredEmployees.length +
                  (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == employeeState.filteredEmployees.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }

                final employee = employeeState.filteredEmployees[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: EmployeeCard(
                    employee: employee,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EmployeeDetailScreen(employee: employee),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EmployeeFormScreen(employee: employee),
                        ),
                      );
                    },
                    onDelete: () =>
                        _showDeleteDialog(employee.id, employee.fullName),
                    onStatusChange: () => _showStatusDialog(employee),
                  ),
                );
              },
            ),
          ),
        ),

        // Add Employee FAB
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EmployeeFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Employee'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        ),
      ],
    );
  }
}
