import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sales_representative_model.dart';
import '../../providers/sales_rep_provider.dart';
import 'sub_widgets/sales_rep/custom_widgets.dart';
import 'sub_widgets/sales_rep/sales_rep_detail_widget.dart';
import 'sub_widgets/sales_rep/sales_rep_form_widget.dart';
import 'sub_widgets/sales_rep/sales_rep_list_widget.dart';

class SalesRepManagementContent extends ConsumerStatefulWidget {
  const SalesRepManagementContent({super.key});

  @override
  ConsumerState<SalesRepManagementContent> createState() =>
      _SalesRepManagementContentState();
}

class _SalesRepManagementContentState
    extends ConsumerState<SalesRepManagementContent> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesRepProvider.notifier).fetchSalesReps();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesRepProvider);
    final notifier = ref.read(salesRepProvider.notifier);
    final selectedSalesRep = state.selectedSalesRep;

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            // Filters and Search
            _buildFilters(notifier),
            const SizedBox(height: 16),

            // Content Area
            Expanded(
              child: _buildContent(state, notifier, selectedSalesRep),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Representatives',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Consumer(
                  builder: (context, ref, _) {
                    final total = ref.watch(salesRepProvider).totalItems;
                    return Text(
                      '$total team members',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(salesRepProvider.notifier).clearSelectedSalesRep();
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'ADD SALES REP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(SalesRepProvider notifier) {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            hintText: 'Search by name, email, or employee number...',
            onSearchChanged: (query) {
              if (query.isEmpty) {
                notifier.clearFilters();
              } else {
                notifier.searchSalesReps(query);
              }
            },
            onClear: () {
              _searchController.clear();
              notifier.clearFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                hint: const Text('Filter by Status'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Status'),
                  ),
                  ...SalesRepStatus.values.map((status) {
                    final statusStr =
                        SalesRepresentative.getStatusDisplayName(status);
                    return DropdownMenuItem(
                      value: status.toString().split('.').last,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SalesRepresentative.getStatusColor(status),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(statusStr),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  notifier.filterByStatus(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(SalesRepState state, SalesRepProvider notifier,
      SalesRepresentative? selectedSalesRep) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List View
        Expanded(
          flex: selectedSalesRep != null ? 2 : 1,
          child: SalesRepListWidget(
            salesReps: state.salesReps,
            onSelect: (salesRep) {
              notifier.fetchSalesRepById(salesRep.id);
            },
            onDelete: (id) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                      'Are you sure you want to delete this sales representative?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await notifier.deleteSalesRep(id);
              }
            },
          ),
        ),

        // Detail/Form View
        if (selectedSalesRep != null) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SalesRepDetailWidget(
              salesRep: selectedSalesRep,
              onEdit: () {
                // Show edit form
              },
              onClose: () {
                notifier.clearSelectedSalesRep();
              },
            ),
          ),
        ] else if (state.selectedSalesRep == null) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SalesRepFormWidget(
              onSubmit: (data) async {
                final success = await notifier.createSalesRep(data);
                if (success) {
                  notifier.clearSelectedSalesRep();
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}
