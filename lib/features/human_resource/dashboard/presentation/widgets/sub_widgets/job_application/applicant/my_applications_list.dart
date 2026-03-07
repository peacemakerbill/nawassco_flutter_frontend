import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../models/job_application_model.dart';
import '../../../../../../providers/job_application_provider.dart';
import '../common/application_card.dart';

class MyApplicationsList extends ConsumerStatefulWidget {
  final VoidCallback? onApplicationSelected;
  final bool showFilters;
  final bool showStats;

  const MyApplicationsList({
    super.key,
    this.onApplicationSelected,
    this.showFilters = true,
    this.showStats = true,
  });

  @override
  ConsumerState<MyApplicationsList> createState() => _MyApplicationsListState();
}

class _MyApplicationsListState extends ConsumerState<MyApplicationsList> {
  ApplicationStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  void _loadApplications() {
    ref.read(jobApplicationProvider.notifier).getMyApplications();
  }

  void _filterApplications() {
    ref.read(jobApplicationProvider.notifier).filterApplications(
      status: _selectedStatus,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  void _withdrawApplication(String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: const Text(
          'Are you sure you want to withdraw this application? This action cannot be undone.',
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
              final success = await ref
                  .read(jobApplicationProvider.notifier)
                  .withdrawApplication(applicationId, 'User withdrew');
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application withdrawn successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              'Withdraw',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobApplicationProvider);
    final applications = state.filteredApplications;
    final isLoading = state.isLoading;

    return Column(
      children: [
        // Header with Stats
        if (widget.showStats) ...[
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    'Total',
                    '${state.applications.length}',
                    Icons.list_alt,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    context,
                    'Active',
                    '${state.applications.where((a) => a.isActive).length}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildStatItem(
                    context,
                    'Interviews',
                    '${state.applications.where((a) => a.hasInterviewScheduled).length}',
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                  _buildStatItem(
                    context,
                    'Selected',
                    '${state.applications.where((a) => a.isSelected).length}',
                    Icons.star,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Filters
        if (widget.showFilters) ...[
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search applications...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _filterApplications();
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedStatus == null,
                          onSelected: (selected) {
                            setState(() => _selectedStatus = null);
                            _filterApplications();
                          },
                        ),
                        const SizedBox(width: 8),
                        ...ApplicationStatus.values
                            .where((status) =>
                        status != ApplicationStatus.DRAFT &&
                            status != ApplicationStatus.ARCHIVED)
                            .map((status) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                status.name
                                    .split('_')
                                    .map((word) =>
                                word[0].toUpperCase() +
                                    word.substring(1))
                                    .join(' '),
                              ),
                              selected: _selectedStatus == status,
                              onSelected: (selected) {
                                setState(() => _selectedStatus =
                                selected ? status : null);
                                _filterApplications();
                              },
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
        ],

        // Applications List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : applications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: () async {
              _loadApplications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return ApplicationCard(
                  application: application,
                  showJobDetails: true,
                  showActions: true,
                  onTap: () {
                    ref
                        .read(jobApplicationProvider.notifier)
                        .selectApplication(application);
                    widget.onApplicationSelected?.call();
                  },
                  onViewDetails: () {
                    ref
                        .read(jobApplicationProvider.notifier)
                        .selectApplication(application);
                    widget.onApplicationSelected?.call();
                  },
                  onWithdraw: application.canWithdraw
                      ? () => _withdrawApplication(application.id)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'No Applications Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You haven\'t applied for any jobs yet. Browse available jobs and submit your first application!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to job listings
            },
            icon: const Icon(Icons.search),
            label: const Text('Browse Jobs'),
          ),
        ],
      ),
    );
  }
}