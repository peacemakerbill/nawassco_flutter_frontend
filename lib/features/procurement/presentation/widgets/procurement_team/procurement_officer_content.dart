import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/procurement_officer.dart';
import '../../../providers/procurement_officer_provider.dart';
import '../sub_screens/procurement_officer/procurement_officer_detail_screen.dart';
import '../sub_screens/procurement_officer/procurement_officer_form_screen.dart';


class ProcurementOfficerContent extends ConsumerStatefulWidget {
  const ProcurementOfficerContent({super.key});

  @override
  ConsumerState<ProcurementOfficerContent> createState() => _ProcurementOfficerContentState();
}

class _ProcurementOfficerContentState extends ConsumerState<ProcurementOfficerContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  ProcurementRole? _selectedRole;
  EmploymentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(procurementOfficerProvider.notifier).getProcurementOfficers();
      ref.read(procurementOfficerProvider.notifier).getProcurementOfficerStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final officerState = ref.watch(procurementOfficerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Officers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProcurementOfficerFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),

          // Stats Section
          _buildStatsSection(officerState),

          // Officer List
          Expanded(
            child: _buildOfficerList(officerState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProcurementOfficerFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search officers...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(procurementOfficerProvider.notifier).getProcurementOfficers();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              if (value.length >= 3 || value.isEmpty) {
                ref.read(procurementOfficerProvider.notifier).getProcurementOfficers(
                  filters: {'search': value.isEmpty ? null : value},
                );
              }
            },
          ),
          const SizedBox(height: 12),
          // Filter Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ProcurementRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ProcurementRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_formatRole(role)),
                    );
                  }).toList(),
                  onChanged: (role) {
                    setState(() {
                      _selectedRole = role;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<EmploymentStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: EmploymentStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_formatStatus(status)),
                    );
                  }).toList(),
                  onChanged: (status) {
                    setState(() {
                      _selectedStatus = status;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ProcurementOfficerState state) {
    final stats = state.stats;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Officers', stats?['totalOfficers']?.toString() ?? '0', Icons.people),
                _buildStatItem('Active',
                    state.officers.where((o) => o.employmentStatus == EmploymentStatus.active).length.toString(),
                    Icons.check_circle,
                    color: Colors.green
                ),
                _buildStatItem('Managers',
                    state.officers.where((o) => o.jobTitle == ProcurementRole.procurement_manager).length.toString(),
                    Icons.manage_accounts,
                    color: Colors.blue
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color color = Colors.blue}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildOfficerList(ProcurementOfficerState state) {
    if (state.isLoading && state.officers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.officers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(procurementOfficerProvider.notifier).getProcurementOfficers();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.officers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No procurement officers found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(procurementOfficerProvider.notifier).getProcurementOfficers();
      },
      child: ListView.builder(
        itemCount: state.officers.length + 1, // +1 for load more
        itemBuilder: (context, index) {
          if (index == state.officers.length) {
            if (state.currentPage < state.totalPages) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(procurementOfficerProvider.notifier).getProcurementOfficers(
                      page: state.currentPage + 1,
                    );
                  },
                  child: const Text('Load More'),
                ),
              );
            } else {
              return const SizedBox();
            }
          }

          final officer = state.officers[index];
          return _buildOfficerListItem(officer);
        },
      ),
    );
  }

  Widget _buildOfficerListItem(ProcurementOfficer officer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getRoleColor(officer.jobTitle),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getRoleIcon(officer.jobTitle),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          officer.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(officer.employeeNumber),
            Text(
              _formatRole(officer.jobTitle),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                _buildStatusChip(officer.employmentStatus),
                const SizedBox(width: 4),
                if (officer.performance.overallRating > 0)
                  Chip(
                    label: Text(
                      '⭐ ${officer.performance.overallRating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.amber.withValues(alpha: 0.1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              officer.department,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (officer.vendorManagementExperience > 0)
              Text(
                '${officer.vendorManagementExperience} yrs',
                style: const TextStyle(fontSize: 11, color: Colors.green),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcurementOfficerDetailScreen(officerId: officer.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(EmploymentStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Chip(
      label: Text(
        statusInfo['label'],
        style: TextStyle(fontSize: 10, color: statusInfo['color']),
      ),
      backgroundColor: statusInfo['color'].withValues(alpha: 0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_selectedRole != null) {
      filters['jobTitle'] = _selectedRole!.name;
    }
    if (_selectedStatus != null) {
      filters['employmentStatus'] = _selectedStatus!.name;
    }
    ref.read(procurementOfficerProvider.notifier).getProcurementOfficers(filters: filters);
  }

  String _formatRole(ProcurementRole role) {
    return role.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatStatus(EmploymentStatus status) {
    return status.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getRoleColor(ProcurementRole role) {
    switch (role) {
      case ProcurementRole.procurement_manager:
        return Colors.purple;
      case ProcurementRole.senior_procurement_officer:
        return Colors.blue;
      case ProcurementRole.procurement_officer:
        return Colors.green;
      case ProcurementRole.junior_procurement_officer:
        return Colors.orange;
      case ProcurementRole.buyer:
        return Colors.teal;
      case ProcurementRole.contracts_officer:
        return Colors.indigo;
      case ProcurementRole.tender_officer:
        return Colors.red;
      case ProcurementRole.supplier_relationship_manager:
        return Colors.pink;
      case ProcurementRole.inventory_controller:
        return Colors.brown;
    }
  }

  IconData _getRoleIcon(ProcurementRole role) {
    switch (role) {
      case ProcurementRole.procurement_manager:
        return Icons.manage_accounts;
      case ProcurementRole.senior_procurement_officer:
        return Icons.supervisor_account;
      case ProcurementRole.procurement_officer:
        return Icons.badge;
      case ProcurementRole.junior_procurement_officer:
        return Icons.work_outline;
      case ProcurementRole.buyer:
        return Icons.shopping_cart;
      case ProcurementRole.contracts_officer:
        return Icons.description;
      case ProcurementRole.tender_officer:
        return Icons.gavel;
      case ProcurementRole.supplier_relationship_manager:
        return Icons.handshake;
      case ProcurementRole.inventory_controller:
        return Icons.inventory;
    }
  }

  Map<String, dynamic> _getStatusInfo(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.active:
        return {'label': 'Active', 'color': Colors.green};
      case EmploymentStatus.inactive:
        return {'label': 'Inactive', 'color': Colors.grey};
      case EmploymentStatus.suspended:
        return {'label': 'Suspended', 'color': Colors.orange};
      case EmploymentStatus.terminated:
        return {'label': 'Terminated', 'color': Colors.red};
      case EmploymentStatus.retired:
        return {'label': 'Retired', 'color': Colors.blue};
      case EmploymentStatus.on_leave:
        return {'label': 'On Leave', 'color': Colors.purple};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}