import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/field_technician_provider.dart';
import '../sub_widgets/field_technician/create_technician_dialog.dart';
import '../sub_widgets/field_technician/technician_filters.dart';
import '../sub_widgets/field_technician/technician_list_view.dart';
import '../sub_widgets/field_technician/technician_stats_card.dart';

class FieldTechnicianContent extends ConsumerStatefulWidget {
  const FieldTechnicianContent({super.key});

  @override
  ConsumerState<FieldTechnicianContent> createState() =>
      _FieldTechnicianContentState();
}

class _FieldTechnicianContentState extends ConsumerState<FieldTechnicianContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();

    // Load technicians on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldTechnicianProvider.notifier).loadFieldTechnicians();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showCreateTechnicianDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateTechnicianDialog(),
    );
  }

  void _refreshTechnicians() {
    ref.read(fieldTechnicianProvider.notifier).loadFieldTechnicians();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldTechnicianProvider);
    final notifier = ref.read(fieldTechnicianProvider.notifier);
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.background,
                title: Text(
                  'Field Technicians',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _refreshTechnicians,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    onPressed: _showCreateTechnicianDialog,
                    icon: const Icon(Icons.person_add_rounded),
                    tooltip: 'Add Technician',
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Stats Overview
              if (!isMobile)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TechnicianStatsCard(technicians: state.technicians),
                  ),
                ),

              // Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TechnicianFilters(
                    searchQuery: state.searchQuery,
                    statusFilter: state.statusFilter,
                    roleFilter: state.roleFilter,
                    onSearchChanged: notifier.setSearchQuery,
                    onStatusFilterChanged: notifier.setStatusFilter,
                    onRoleFilterChanged: notifier.setRoleFilter,
                    onClearFilters: notifier.clearFilters,
                  ),
                ),
              ),

              // Loading State
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Error State
              if (state.error != null && !state.isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load technicians',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshTechnicians,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Empty State
              if (state.filteredTechnicians.isEmpty &&
                  !state.isLoading &&
                  state.error == null)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_rounded,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No technicians found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add a new technician to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

              // Technicians List
              if (state.filteredTechnicians.isNotEmpty)
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: TechnicianListView(
                      technicians: state.filteredTechnicians),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
