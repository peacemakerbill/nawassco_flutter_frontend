import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/employee_model.dart';
import '../../../../../providers/department_provider.dart';

class DepartmentEmployees extends ConsumerStatefulWidget {
  final String departmentId;
  final String departmentName;

  const DepartmentEmployees({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  ConsumerState<DepartmentEmployees> createState() => _DepartmentEmployeesState();
}

class _DepartmentEmployeesState extends ConsumerState<DepartmentEmployees> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  bool _showAddForm = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final provider = ref.read(departmentProvider.notifier);
    await provider.loadDepartmentEmployees(widget.departmentId);
  }

  Future<void> _addEmployee() async {
    if (_employeeIdController.text.isEmpty) return;

    try {
      final provider = ref.read(departmentProvider.notifier);
      await provider.addEmployeeToDepartment(
        widget.departmentId,
        _employeeIdController.text,
      );

      setState(() {
        _showAddForm = false;
        _employeeIdController.clear();
      });
    } catch (e) {
      // Error handled by provider
    }
  }

  Future<void> _removeEmployee(String employeeId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Employee'),
        content: const Text('Are you sure you want to remove this employee from the department?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = ref.read(departmentProvider.notifier);
                await provider.removeEmployeeFromDepartment(widget.departmentId, employeeId);
              } catch (e) {
                // Error handled by provider
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 24,
              child: Text(
                employee.personalDetails.firstName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Employee Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Employee #: ${employee.employeeNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${employee.jobTitle} • ${employee.department}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        employee.workEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(employee.employmentStatus),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                employee.employmentStatus.toString().split('.').last.replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeEmployee(employee.id),
              tooltip: 'Remove from department',
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EmploymentStatus status) {
    return switch (status) {
      EmploymentStatus.active => Colors.green,
      EmploymentStatus.on_leave => Colors.orange,
      EmploymentStatus.suspended => Colors.red,
      EmploymentStatus.terminated => Colors.grey,
      EmploymentStatus.retired => Colors.purple,
    };
  }

  List<Employee> _getFilteredEmployees(List<Employee> employees) {
    if (_searchQuery.isEmpty) return employees;

    return employees.where((employee) {
      return employee.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.employeeNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.workEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.jobTitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(departmentProvider);
    final employees = _getFilteredEmployees(state.departmentEmployees);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Department Employees (${employees.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                // Search Button
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Search Employees'),
                        content: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search by name, employee number, or email...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Search employees',
                ),

                // Add Employee Button
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showAddForm = !_showAddForm),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Employee'),
                ),
              ],
            ),
          ],
        ),

        // Search Query Display
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Chip(
                  label: Text('Search: "$_searchQuery"'),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  child: const Text('Clear Search'),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Add Employee Form
        if (_showAddForm)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Employee to ${widget.departmentName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _employeeIdController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID or Email',
                      hintText: 'Enter employee ID, email, or search by name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person_search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _showAddForm = false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addEmployee,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Add Employee'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Employees List
        if (state.isLoadingEmployees)
          const Center(child: CircularProgressIndicator())
        else if (employees.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No employees in this department'
                      : 'No employees found matching "$_searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Add employees using the "Add Employee" button'
                      : 'Try a different search term',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          RefreshIndicator(
            onRefresh: _loadEmployees,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employees.length,
              itemBuilder: (context, index) => _buildEmployeeCard(employees[index]),
            ),
          ),

        // Employee Count Summary
        if (employees.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Employees: ${employees.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Active: ${employees.where((e) => e.employmentStatus == EmploymentStatus.active).length}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}