import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_manager_model.dart';
import '../../../../providers/store_manager_admin_provider.dart';

class StoreManagerList extends ConsumerWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(String) onViewDetails;
  final Function(String) onEdit;

  const StoreManagerList({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onViewDetails,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeManagerState = ref.watch(storeManagerAdminProvider);

    return Column(
      children: [
        // Search and Filter Section
        _buildSearchFilterSection(context, ref),

        // Stats Overview
        _buildStatsOverview(storeManagerState),

        // Store Managers List
        Expanded(
          child: storeManagerState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : storeManagerState.error != null
              ? _buildErrorState(storeManagerState.error!, ref)
              : storeManagerState.storeManagers.isEmpty
              ? _buildEmptyState()
              : _buildStoreManagersList(storeManagerState, context, ref),
        ),
      ],
    );
  }

  Widget _buildSearchFilterSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, employee number...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showFilterDialog(context, ref),
                ),
              ),
              onChanged: onSearch,
            ),
          ),
          const SizedBox(height: 12),

          // Active Filters
          _buildActiveFilters(ref),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(WidgetRef ref) {
    final filters = ref.watch(storeManagerAdminProvider).filters;
    final hasActiveFilters = filters.values.any((value) => value != null && value.toString().isNotEmpty);

    if (!hasActiveFilters) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...filters.entries.where((entry) => entry.value != null && entry.value.toString().isNotEmpty).map((entry) {
          return Chip(
            label: Text('${_formatFilterKey(entry.key)}: ${entry.value}'),
            onDeleted: () => _removeFilter(entry.key, ref),
          );
        }),
        if (hasActiveFilters)
          TextButton(
            onPressed: () => _clearAllFilters(ref),
            child: const Text('Clear All'),
          ),
      ],
    );
  }

  Widget _buildStatsOverview(StoreManagerAdminState state) {
    final activeManagers = state.storeManagers.where((m) => m.isActive).length;
    final inactiveManagers = state.storeManagers.length - activeManagers;
    final executiveCount = state.storeManagers.where((m) => m.managementLevel == StoreManagementLevel.EXECUTIVE).length;
    final totalValue = state.totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          _buildStatCard(
            'Total Managers',
            totalValue.toString(),
            Icons.people,
            Colors.blue,
          ),
          _buildStatCard(
            'Active',
            activeManagers.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatCard(
            'Inactive',
            inactiveManagers.toString(),
            Icons.pause_circle,
            Colors.orange,
          ),
          _buildStatCard(
            'Executives',
            executiveCount.toString(),
            Icons.leaderboard,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreManagersList(StoreManagerAdminState state, BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: state.storeManagers.length,
      itemBuilder: (context, index) {
        final storeManager = state.storeManagers[index];
        return _buildStoreManagerCard(storeManager, context, ref);
      },
    );
  }

  Widget _buildStoreManagerCard(StoreManager storeManager, BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Icon(
            Icons.person,
            color: Colors.blue[700],
            size: 24,
          ),
        ),
        title: Text(
          '${storeManager.personalDetails.firstName} ${storeManager.personalDetails.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${storeManager.jobInformation.jobTitle} • ${storeManager.employeeNumber}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(storeManager.isActive),
                const SizedBox(width: 8),
                _buildRoleChip(storeManager.storeManagerRole),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handlePopupMenuSelection(value, storeManager.id, context, ref),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(storeManager.isActive ? 'Deactivate' : 'Activate'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => onViewDetails(storeManager.id),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 10,
        ),
      ),
      backgroundColor: isActive ? Colors.green[50] : Colors.red[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRoleChip(StoreManagerRole role) {
    return Chip(
      label: Text(
        role.name.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: Colors.blue[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _handlePopupMenuSelection(String value, String managerId, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'view':
        onViewDetails(managerId);
        break;
      case 'edit':
        onEdit(managerId);
        break;
      case 'toggle':
        final storeManager = ref.read(storeManagerAdminProvider).storeManagers
            .firstWhere((m) => m.id == managerId);
        ref.read(storeManagerAdminProvider.notifier).toggleActiveStatus(
            managerId,
            !storeManager.isActive
        );
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, managerId, ref);
        break;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String managerId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store Manager'),
        content: const Text('Are you sure you want to delete this store manager? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(storeManagerAdminProvider.notifier).deleteStoreManager(managerId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load store managers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(storeManagerAdminProvider.notifier).getStoreManagers(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Store Managers Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No store managers match your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.read(storeManagerAdminProvider).filters;

    showDialog(
      context: context,
      builder: (context) => StoreManagerFilterDialog(
        currentFilters: currentFilters,
        onApplyFilters: (filters) {
          ref.read(storeManagerAdminProvider.notifier).getStoreManagers(
            role: filters['role'],
            managementLevel: filters['managementLevel'],
            department: filters['department'],
          );
        },
      ),
    );
  }

  void _removeFilter(String key, WidgetRef ref) {
    final currentFilters = Map<String, dynamic>.from(ref.read(storeManagerAdminProvider).filters);
    currentFilters[key] = null;

    ref.read(storeManagerAdminProvider.notifier).getStoreManagers(
      role: currentFilters['role'],
      managementLevel: currentFilters['managementLevel'],
      department: currentFilters['department'],
    );
  }

  void _clearAllFilters(WidgetRef ref) {
    ref.read(storeManagerAdminProvider.notifier).getStoreManagers();
  }

  String _formatFilterKey(String key) {
    switch (key) {
      case 'role': return 'Role';
      case 'managementLevel': return 'Management Level';
      case 'department': return 'Department';
      default: return key;
    }
  }
}

class StoreManagerFilterDialog extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const StoreManagerFilterDialog({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<StoreManagerFilterDialog> createState() => _StoreManagerFilterDialogState();
}

class _StoreManagerFilterDialogState extends State<StoreManagerFilterDialog> {
  late String? _selectedRole;
  late String? _selectedManagementLevel;
  late String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentFilters['role'];
    _selectedManagementLevel = widget.currentFilters['managementLevel'];
    _selectedDepartment = widget.currentFilters['department'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Store Managers'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Role Filter
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Roles')),
                ...StoreManagerRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role.name,
                    child: Text(role.name.replaceAll('_', ' ')),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            const SizedBox(height: 16),

            // Management Level Filter
            DropdownButtonFormField<String>(
              value: _selectedManagementLevel,
              decoration: const InputDecoration(
                labelText: 'Management Level',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Levels')),
                ...StoreManagementLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level.name,
                    child: Text(level.name.replaceAll('_', ' ')),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedManagementLevel = value),
            ),
            const SizedBox(height: 16),

            // Department Filter
            TextFormField(
              initialValue: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                hintText: 'e.g., Stores, Warehouse',
              ),
              onChanged: (value) => setState(() => _selectedDepartment = value.isEmpty ? null : value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }

  void _applyFilters() {
    final filters = {
      'role': _selectedRole,
      'managementLevel': _selectedManagementLevel,
      'department': _selectedDepartment,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedRole = null;
      _selectedManagementLevel = null;
      _selectedDepartment = null;
    });
  }
}