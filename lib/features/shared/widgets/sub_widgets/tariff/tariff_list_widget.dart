import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../public/auth/providers/auth_provider.dart';
import '../../../models/tariff_model.dart';
import '../../../providers/tariff_provider.dart';
import 'tariff_filter_widget.dart';
import 'tariff_detail_widget.dart';
import 'tariff_form_widget.dart';
import 'tariff_calculator_widget.dart';

class TariffListWidget extends ConsumerStatefulWidget {
  final VoidCallback? onTariffSelected;
  final bool showActions;

  const TariffListWidget({
    super.key,
    this.onTariffSelected,
    this.showActions = true,
  });

  @override
  ConsumerState<TariffListWidget> createState() => _TariffListWidgetState();
}

class _TariffListWidgetState extends ConsumerState<TariffListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  List<String> _selectedTariffs = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tariffProvider.notifier).fetchTariffs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tariffProvider);
    final notifier = ref.read(tariffProvider.notifier);
    final authState = ref.watch(authProvider);
    final canManage = notifier.canManageTariffs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildHeader(context, canManage, state, notifier),

        // Filters Section
        if (_showFilters) ...[
          const SizedBox(height: 12),
          TariffFilterWidget(
            onFilterApplied: () {
              notifier.fetchTariffs();
              setState(() => _showFilters = false);
            },
            onFilterCleared: () {
              notifier.clearFilter();
              notifier.fetchTariffs();
              setState(() => _showFilters = false);
            },
          ),
        ],

        // Bulk Actions
        if (_isSelecting && _selectedTariffs.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildBulkActions(context, notifier),
        ],

        const SizedBox(height: 16),

        // Content
        Expanded(
          child: _buildContent(state, notifier, authState),
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context,
      bool canManage,
      TariffState state,
      TariffProvider notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      MdiIcons.currencyUsd,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tariff Management',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage water service tariffs, rates, and billing cycles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Statistics Button
              IconButton(
                onPressed: () {
                  notifier.getStatistics();
                  _showStatisticsDialog(context, state);
                },
                icon: Icon(MdiIcons.chartBar, color: Colors.blue.shade700),
                tooltip: 'View Statistics',
              ),

              // Filter Button
              IconButton(
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
                icon: Icon(
                  _showFilters ? MdiIcons.filterRemove : MdiIcons.filter,
                  color: _showFilters
                      ? Theme.of(context).colorScheme.error
                      : Colors.orange.shade700,
                ),
                tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
              ),

              // Select Mode Button
              if (canManage)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSelecting = !_isSelecting;
                      if (!_isSelecting) _selectedTariffs.clear();
                    });
                  },
                  icon: Icon(
                    _isSelecting ? MdiIcons.close : MdiIcons.selectAll,
                    color: _isSelecting
                        ? Colors.red
                        : Colors.green.shade700,
                  ),
                  tooltip: _isSelecting ? 'Cancel Selection' : 'Select Multiple',
                ),

              // Refresh Button
              IconButton(
                onPressed: () => notifier.fetchTariffs(),
                icon: Icon(MdiIcons.refresh, color: Colors.green.shade700),
                tooltip: 'Refresh',
              ),

              // Create Button
              if (canManage) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    _showCreateDialog(context);
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Tariff'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions(BuildContext context, TariffProvider notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedTariffs.length} tariff(s) selected',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final success = await notifier.bulkUpdateStatus(
                    _selectedTariffs,
                    true,
                  );
                  if (success) _selectedTariffs.clear();
                },
                icon: Icon(Icons.check_circle, color: Colors.green.shade700),
                label: Text(
                  'Activate',
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final success = await notifier.bulkUpdateStatus(
                    _selectedTariffs,
                    false,
                  );
                  if (success) _selectedTariffs.clear();
                },
                icon: Icon(Icons.remove_circle, color: Colors.orange.shade700),
                label: Text(
                  'Deactivate',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedTariffs.clear();
                    _isSelecting = false;
                  });
                },
                icon: const Icon(Icons.clear, size: 20),
                label: const Text('Clear Selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      TariffState state,
      TariffProvider notifier,
      AuthState authState,
      ) {
    if (state.isLoading && state.tariffs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.tariffs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_alert,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading tariffs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => notifier.fetchTariffs(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.tariffs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.money,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tariffs found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first tariff to get started',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            if (notifier.canManageTariffs)
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Tariff'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetchTariffs(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: state.tariffs.length + 1,
        itemBuilder: (context, index) {
          if (index == state.tariffs.length) {
            return _buildPagination(state, notifier);
          }
          final tariff = state.tariffs[index];
          return _buildTariffCard(tariff, notifier, authState);
        },
      ),
    );
  }

  Widget _buildTariffCard(
      Tariff tariff,
      TariffProvider notifier,
      AuthState authState,
      ) {
    final isSelected = _selectedTariffs.contains(tariff.id);
    final isCurrent = tariff.isCurrent;
    final canManage = notifier.canManageTariffs;
    final canApprove = notifier.canApproveTariffs;

    return GestureDetector(
      onTap: () {
        if (_isSelecting && tariff.id != null) {
          setState(() {
            if (isSelected) {
              _selectedTariffs.remove(tariff.id);
            } else {
              _selectedTariffs.add(tariff.id!);
            }
          });
        } else {
          _showTariffDetails(tariff);
        }
      },
      onLongPress: canManage && tariff.id != null
          ? () {
        setState(() {
          _isSelecting = true;
          if (!isSelected) {
            _selectedTariffs.add(tariff.id!);
          }
        });
      }
          : null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isCurrent
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Indicator
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4, right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? Colors.green
                            : !tariff.isActive
                            ? Colors.red
                            : !tariff.isApproved
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),

                    // Title and Code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tariff.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tariff.code,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tariff.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    if (widget.showActions && !_isSelecting)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => _buildPopupMenuItems(
                          tariff,
                          canManage,
                          canApprove,
                        ),
                        onSelected: (value) => _handlePopupAction(
                          value,
                          tariff,
                          notifier,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details Grid
                _buildDetailsGrid(tariff),

                const SizedBox(height: 12),

                // Footer Actions
                if (widget.showActions && !_isSelecting)
                  _buildFooterActions(tariff, notifier, authState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(
      Tariff tariff,
      bool canManage,
      bool canApprove,
      ) {
    final items = <PopupMenuEntry<String>>[];

    items.add(
      const PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility, size: 20, color: Colors.blue),
            SizedBox(width: 8),
            Text('View Details'),
          ],
        ),
      ),
    );

    if (tariff.isCurrent) {
      items.add(
        const PopupMenuItem(
          value: 'calculate',
          child: Row(
            children: [
              Icon(Icons.calculate, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('Calculate Bill'),
            ],
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider());

    if (canManage) {
      items.add(
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
      );

      if (!tariff.isApproved) {
        items.add(
          PopupMenuItem(
            value: 'approve',
            enabled: canApprove,
            child: const Row(
              children: [
                Icon(Icons.verified, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text('Approve'),
              ],
            ),
          ),
        );
      }

      if (tariff.isApproved && tariff.isActive) {
        items.add(
          const PopupMenuItem(
            value: 'new_version',
            child: Row(
              children: [
                Icon(Icons.upgrade, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text('Create New Version'),
              ],
            ),
          ),
        );
      }

      if (tariff.isActive) {
        items.add(
          const PopupMenuItem(
            value: 'deactivate',
            child: Row(
              children: [
                Icon(Icons.pause_circle, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Deactivate'),
              ],
            ),
          ),
        );
      } else {
        items.add(
          const PopupMenuItem(
            value: 'activate',
            child: Row(
              children: [
                Icon(Icons.play_circle, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text('Activate'),
              ],
            ),
          ),
        );
      }

      items.add(const PopupMenuDivider());

      items.add(
        const PopupMenuItem(
          value: 'history',
          child: Row(
            children: [
              Icon(Icons.history, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text('View History'),
            ],
          ),
        ),
      );
    }

    if (canManage && tariff.id != null) {
      items.add(
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildDetailsGrid(Tariff tariff) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildDetailItem(
          icon: Icons.calendar_today,
          label: 'Billing Cycle',
          value: tariff.billingCycle.displayName,
          color: Colors.blue.shade700,
        ),
        _buildDetailItem(
          icon: Icons.map,
          label: 'Regions',
          value: '${tariff.serviceRegions.length}',
          color: Colors.green.shade700,
        ),
        _buildDetailItem(
          icon: Icons.alarm,
          label: 'Effective',
          value: tariff.formattedEffectivePeriod,
          color: Colors.orange.shade700,
        ),
        _buildDetailItem(
          icon: Icons.tag,
          label: 'Status',
          value: tariff.isCurrent
              ? 'Current'
              : !tariff.isActive
              ? 'Inactive'
              : !tariff.isApproved
              ? 'Pending Approval'
              : 'Future',
          color: tariff.isCurrent
              ? Colors.green
              : !tariff.isActive
              ? Colors.red
              : !tariff.isApproved
              ? Colors.orange
              : Colors.grey,
        ),
        if (tariff.version > 1)
          _buildDetailItem(
            icon: Icons.backup,
            label: 'Version',
            value: 'v${tariff.version}',
            color: Colors.purple.shade700,
          ),
        _buildDetailItem(
          icon: Icons.person,
          label: 'Created By',
          value: tariff.createdByUser?['firstName'] ?? 'N/A',
          color: Colors.brown.shade700,
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(
      Tariff tariff,
      TariffProvider notifier,
      AuthState authState,
      ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showTariffDetails(tariff),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (tariff.isCurrent && authState.isAuthenticated)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCalculatorDialog(tariff),
              icon: const Icon(Icons.calculate, size: 16),
              label: const Text('Calculate'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.green,
              ),
            ),
          ),
        if (notifier.canManageTariffs) ...[
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _showEditDialog(tariff),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.orange.shade600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPagination(TariffState state, TariffProvider notifier) {
    if (state.totalPages <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: state.filter.page > 1
                ? () {
              notifier.setPage(state.filter.page - 1);
              notifier.fetchTariffs();
            }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...List.generate(
            state.totalPages.clamp(1, 5),
                (index) {
              final pageNumber = index + 1;
              final isCurrent = state.filter.page == pageNumber;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextButton(
                  onPressed: isCurrent
                      ? null
                      : () {
                    notifier.setPage(pageNumber);
                    notifier.fetchTariffs();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                    isCurrent ? Theme.of(context).primaryColor : null,
                    foregroundColor: isCurrent ? Colors.white : null,
                  ),
                  child: Text(pageNumber.toString()),
                ),
              );
            },
          ),
          IconButton(
            onPressed: state.filter.page < state.totalPages
                ? () {
              notifier.setPage(state.filter.page + 1);
              notifier.fetchTariffs();
            }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _handlePopupAction(
      String value,
      Tariff tariff,
      TariffProvider notifier,
      ) {
    switch (value) {
      case 'view':
        _showTariffDetails(tariff);
        break;
      case 'calculate':
        _showCalculatorDialog(tariff);
        break;
      case 'edit':
        _showEditDialog(tariff);
        break;
      case 'approve':
        _approveTariff(tariff, notifier);
        break;
      case 'new_version':
        _createNewVersion(tariff, notifier);
        break;
      case 'activate':
        _toggleTariffStatus(tariff, notifier, true);
        break;
      case 'deactivate':
        _toggleTariffStatus(tariff, notifier, false);
        break;
      case 'history':
        _showHistory(tariff, notifier);
        break;
      case 'delete':
        _deleteTariff(tariff, notifier);
        break;
    }
  }

  void _showTariffDetails(Tariff tariff) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TariffDetailWidget(tariff: tariff),
        ),
      ),
    );
  }

  void _showCalculatorDialog(Tariff tariff) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TariffCalculatorWidget(tariff: tariff),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: TariffFormWidget(
            onSuccess: () {
              Navigator.pop(context);
              ref.read(tariffProvider.notifier).fetchTariffs();
            },
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Tariff tariff) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: TariffFormWidget(
            tariff: tariff,
            onSuccess: () {
              Navigator.pop(context);
              ref.read(tariffProvider.notifier).fetchTariffs();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _approveTariff(Tariff tariff, TariffProvider notifier) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Tariff'),
        content: const Text('Are you sure you want to approve this tariff?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.approveTariff(tariff.id!);
    }
  }

  Future<void> _createNewVersion(
      Tariff tariff,
      TariffProvider notifier,
      ) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Version'),
        content: const Text(
          'Are you sure you want to create a new version of this tariff?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.createNewVersion(tariff.id!);
    }
  }

  Future<void> _toggleTariffStatus(
      Tariff tariff,
      TariffProvider notifier,
      bool activate,
      ) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activate ? 'Activate Tariff' : 'Deactivate Tariff'),
        content: Text(
          activate
              ? 'Are you sure you want to activate this tariff?'
              : 'Are you sure you want to deactivate this tariff?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: activate ? Colors.green : Colors.red,
            ),
            child: Text(activate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.toggleTariffStatus(tariff.id!, activate);
    }
  }

  void _showHistory(Tariff tariff, TariffProvider notifier) async {
    await notifier.getTariffHistory(tariff.code);

    final history = ref.read(tariffProvider).tariffHistory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history),
            const SizedBox(width: 12),
            Text('Version History - ${tariff.code}'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
          child: history == null || history.isEmpty
              ? const Center(child: Text('No history available'))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (context, index) {
              final version = history[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('v${version.version}'),
                ),
                title: Text(version.name),
                subtitle: Text(
                  'Effective: ${version.formattedEffectivePeriod}',
                ),
                trailing: version.isApproved
                    ? const Icon(Icons.verified, color: Colors.green)
                    : null,
                onTap: () => _showTariffDetails(version),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTariff(Tariff tariff, TariffProvider notifier) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tariff'),
        content: const Text(
          'Are you sure you want to delete this tariff? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteTariff(tariff.id!);
    }
  }

  void _showStatisticsDialog(BuildContext context, TariffState state) {
    final stats = state.statistics;
    if (stats == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bar_chart),
            SizedBox(width: 12),
            Text('Tariff Statistics'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(
                'Total Tariffs',
                stats.totalTariffs.toString(),
                Colors.blue,
              ),
              _buildStatItem(
                'Active Tariffs',
                stats.activeTariffs.toString(),
                Colors.green,
              ),
              _buildStatItem(
                'Approved Tariffs',
                stats.approvedTariffs.toString(),
                Colors.purple,
              ),
              _buildStatItem(
                'Expiring This Month',
                stats.expiringThisMonth.toString(),
                Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'By Billing Cycle',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...stats.byBillingCycle.entries.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}