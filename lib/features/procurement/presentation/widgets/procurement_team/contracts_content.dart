import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/contract.dart';
import '../../../providers/contract_provider.dart';
import '../sub_screens/contracts/contract_detail_screen.dart';
import '../sub_screens/contracts/create_contract_screen.dart';
import '../sub_screens/contracts/renew_contract_screen.dart';

class ContractsContent extends ConsumerStatefulWidget {
  const ContractsContent({super.key});

  @override
  ConsumerState<ContractsContent> createState() => _ContractsContentState();
}

class _ContractsContentState extends ConsumerState<ContractsContent> {
  final List<String> _filterStatuses = ['All', 'DRAFT', 'ACTIVE', 'SUSPENDED', 'TERMINATED', 'EXPIRED'];
  String _filterStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load contracts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contractsProvider.notifier).getContracts();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteContract(String contractId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contract'),
        content: const Text('Are you sure you want to delete this contract? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(contractsProvider.notifier).deleteContract(contractId);
        _showSuccessSnackbar('Contract deleted successfully');
      } catch (e) {
        _showErrorSnackbar('Failed to delete contract: $e');
      }
    }
  }

  Future<void> _approveContract(String contractId) async {
    try {
      await ref.read(contractsProvider.notifier).approveContract(contractId);
      _showSuccessSnackbar('Contract approved successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to approve contract: $e');
    }
  }

  void _refreshContracts() {
    ref.read(contractsProvider.notifier).getContracts(
      status: _filterStatus == 'All' ? null : _filterStatus,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsProvider);

    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _refreshContracts(),
            child: contractsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshContracts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (contracts) {
                if (contracts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No contracts found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contracts.length,
                  itemBuilder: (context, index) => _buildContractCard(contracts[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Contract Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateContract(),
            icon: const Icon(Icons.add),
            label: const Text('New Contract'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search contracts...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _refreshContracts();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterStatuses.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status),
                selected: _filterStatus == status,
                onSelected: (selected) {
                  setState(() {
                    _filterStatus = selected ? status : 'All';
                  });
                  _refreshContracts();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContractCard(Contract contract) {
    final daysRemaining = contract.endDate.difference(DateTime.now()).inDays;
    final isActive = contract.status == 'ACTIVE';
    final isDraft = contract.status == 'DRAFT';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    contract.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(contract.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contract.status,
                    style: TextStyle(
                      color: _getStatusColor(contract.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Contract No: ${contract.contractNumber}'),
            Text('Supplier: ${contract.supplierName}'),
            if (contract.category != null) Text('Category: ${contract.category}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Start: ${_formatDate(contract.startDate)}'),
                const SizedBox(width: 16),
                Icon(Icons.event_busy, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('End: ${_formatDate(contract.endDate)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contract Value:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${contract.currency} ${contract.contractValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _calculateProgress(contract.startDate, contract.endDate),
                backgroundColor: Colors.grey[200],
                color: daysRemaining < 30 ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 4),
              Text(
                '$daysRemaining days remaining',
                style: TextStyle(
                  color: daysRemaining < 30 ? Colors.orange : Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToContractDetails(contract),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (isActive && contract.renewalAllowed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToRenewContract(contract),
                      child: const Text('Renew'),
                    ),
                  ),
                if (isDraft) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveContract(contract.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteContract(contract.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXPIRED':
        return Colors.red;
      case 'TERMINATED':
        return Colors.orange;
      case 'DRAFT':
        return Colors.blue;
      case 'SUSPENDED':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _calculateProgress(DateTime start, DateTime end) {
    final totalDays = end.difference(start).inDays;
    final daysPassed = DateTime.now().difference(start).inDays;
    return daysPassed / totalDays;
  }

  void _navigateToContractDetails(Contract contract) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractDetailScreen(contractId: contract.id),
      ),
    );
  }

  void _navigateToCreateContract() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateContractScreen()),
    ).then((_) => _refreshContracts());
  }

  void _navigateToRenewContract(Contract contract) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RenewContractScreen(contract: contract),
      ),
    ).then((_) => _refreshContracts());
  }
}