import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/outage.dart';
import '../../../../providers/outage_provider.dart';
import '../../../sub_widgets/outage/communication_list.dart';
import '../../../sub_widgets/outage/customer_updates.dart';
import '../../../sub_widgets/outage/outage_card.dart';
import '../../../sub_widgets/outage/outage_detail.dart';
import '../../../sub_widgets/outage/outage_filter.dart';
import '../../../sub_widgets/outage/outage_form.dart';


class OutageManagementContent extends ConsumerStatefulWidget {
  const OutageManagementContent({super.key});

  @override
  ConsumerState<OutageManagementContent> createState() => _OutageManagementContentState();
}

class _OutageManagementContentState extends ConsumerState<OutageManagementContent> {
  final _searchController = TextEditingController();
  bool _showCreateForm = false;
  Outage? _editingOutage;
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(outageProvider.notifier).fetchOutages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final outageState = ref.watch(outageProvider);
    final notifier = ref.read(outageProvider.notifier);

    return _showCreateForm
        ? OutageFormWidget(
      outage: _editingOutage,
      onSave: (outage) async {
        if (_editingOutage == null) {
          await notifier.createOutage(outage);
        } else {
          await notifier.updateOutage(_editingOutage!.id!, outage);
        }
        setState(() {
          _showCreateForm = false;
          _editingOutage = null;
        });
      },
      onCancel: () {
        setState(() {
          _showCreateForm = false;
          _editingOutage = null;
        });
      },
    )
        : Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outage Management',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and monitor all water outage incidents',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Outage'),
                onPressed: () {
                  setState(() {
                    _showCreateForm = true;
                    _editingOutage = null;
                  });
                },
              ),
            ],
          ),
        ),

        // Search and Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[50],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search outages...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        // Implement search
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterDialog(context, notifier);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton('All', 'all', outageState.outages.length),
                    _buildTabButton('Active', 'active',
                        outageState.outages.where((o) => [OutageStatus.REPORTED, OutageStatus.CONFIRMED, OutageStatus.IN_PROGRESS].contains(o.status)).length),
                    _buildTabButton('Planned', 'planned',
                        outageState.outages.where((o) => o.type == OutageType.PLANNED).length),
                    _buildTabButton('Emergency', 'emergency',
                        outageState.outages.where((o) => o.type == OutageType.EMERGENCY).length),
                    _buildTabButton('Resolved', 'resolved',
                        outageState.outages.where((o) => [OutageStatus.RESOLVED, OutageStatus.VERIFIED, OutageStatus.CLOSED].contains(o.status)).length),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Statistics Bar
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.report, 'Reported',
                  outageState.outages.where((o) => o.status == OutageStatus.REPORTED).length.toString()),
              _buildStatItem(Icons.build, 'In Progress',
                  outageState.outages.where((o) => o.status == OutageStatus.IN_PROGRESS).length.toString()),
              _buildStatItem(Icons.warning, 'High Priority',
                  outageState.outages.where((o) => o.priority == PriorityLevel.HIGH || o.priority == PriorityLevel.CRITICAL).length.toString()),
              _buildStatItem(Icons.groups, 'Affected',
                  outageState.outages.fold(0, (sum, o) => sum + o.estimatedAffectedCustomers).toString()),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _buildContent(outageState, notifier),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, String value, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _selectedTab == value
                    ? Colors.white
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _selectedTab == value
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        selected: _selectedTab == value,
        onSelected: (selected) {
          setState(() {
            _selectedTab = value;
          });
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(OutageState state, OutageProvider notifier) {
    List<Outage> filteredOutages = state.outages;

    // Apply tab filter
    switch (_selectedTab) {
      case 'active':
        filteredOutages = state.outages.where((o) =>
            [OutageStatus.REPORTED, OutageStatus.CONFIRMED, OutageStatus.IN_PROGRESS]
                .contains(o.status)).toList();
        break;
      case 'planned':
        filteredOutages = state.outages.where((o) =>
        o.type == OutageType.PLANNED).toList();
        break;
      case 'emergency':
        filteredOutages = state.outages.where((o) =>
        o.type == OutageType.EMERGENCY).toList();
        break;
      case 'resolved':
        filteredOutages = state.outages.where((o) =>
            [OutageStatus.RESOLVED, OutageStatus.VERIFIED, OutageStatus.CLOSED]
                .contains(o.status)).toList();
        break;
    }

    if (state.isLoading && filteredOutages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredOutages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No outages found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 'all'
                  ? 'Create your first outage report'
                  : 'No ${_selectedTab} outages available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOutages.length,
      itemBuilder: (context, index) {
        final outage = filteredOutages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutageCard(
            outage: outage,
            showActions: true,
            onTap: () => _showManagementDetails(context, outage, notifier),
            onEdit: () {
              setState(() {
                _editingOutage = outage;
                _showCreateForm = true;
              });
            },
            onUpdateStatus: (status) async {
              await notifier.updateOutageStatus(outage.id!, status);
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, OutageProvider notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Outages',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: OutageFilterWidget(
                  onFilterChanged: (filters) {
                    notifier.fetchOutages(filters: filters);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManagementDetails(
      BuildContext context, Outage outage, OutageProvider notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Outage #${outage.outageNumber}'),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.info), text: 'Details'),
                    Tab(icon: Icon(Icons.update), text: 'Updates'),
                    Tab(icon: Icon(Icons.chat), text: 'Communications'),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _editingOutage = outage;
                        _showCreateForm = true;
                      });
                    },
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  OutageDetailWidget(outage: outage, showActions: true),
                  CustomerUpdatesWidget(
                    outage: outage,
                    onAddUpdate: (message) async {
                      await notifier.addCustomerUpdate(
                        outage.id!,
                        message,
                        'Current User', // Replace with actual user
                      );
                    },
                  ),
                  CommunicationListWidget(
                    outage: outage,
                    onAddCommunication: (message, to, priority) async {
                      await notifier.addInternalCommunication(
                        outage.id!,
                        message,
                        'Current User', // Replace with actual user
                        to,
                        priority,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}