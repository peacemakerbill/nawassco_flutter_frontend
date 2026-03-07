import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/purchase_requisition.dart';
import '../../../providers/purchase_provider.dart';
import '../sub_screens/purchase/purchase_requisition_detail_page.dart';
import '../sub_screens/purchase/purchase_requisition_form_page.dart';


class PurchaseRequisitionsPage extends ConsumerStatefulWidget {
  const PurchaseRequisitionsPage({super.key});

  @override
  ConsumerState<PurchaseRequisitionsPage> createState() => _PurchaseRequisitionsPageState();
}

class _PurchaseRequisitionsPageState extends ConsumerState<PurchaseRequisitionsPage> {
  String _filterStatus = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ref.read(purchaseRequisitionProvider.notifier).loadRequisitions();
    }
  }

  void _searchRequisitions() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(purchaseRequisitionProvider.notifier).loadRequisitions(
        queryParams: {'search': query},
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requisitionsAsync = ref.watch(purchaseRequisitionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Requisitions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(purchaseRequisitionProvider.notifier).loadRequisitions(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: requisitionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(purchaseRequisitionProvider.notifier).loadRequisitions(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (requisitions) {
                final filteredReqs = _filterStatus == 'All'
                    ? requisitions
                    : requisitions.where((req) => req.status == _filterStatus).toList();

                if (filteredReqs.isEmpty) {
                  return const Center(
                    child: Text('No purchase requisitions found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReqs.length,
                  itemBuilder: (context, index) => _buildRequisitionCard(filteredReqs[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PurchaseRequisitionFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by requisition number or title...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(purchaseRequisitionProvider.notifier).loadRequisitions();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _searchRequisitions(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _searchRequisitions,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('draft'),
                _buildFilterChip('submitted'),
                _buildFilterChip('under_review'),
                _buildFilterChip('approved'),
                _buildFilterChip('rejected'),
                _buildFilterChip('converted_to_po'),
                _buildFilterChip('cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final displayStatus = status == 'All' ? 'All' : _formatStatus(status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(displayStatus),
        selected: _filterStatus == status,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? status : 'All';
          });
        },
      ),
    );
  }

  Widget _buildRequisitionCard(PurchaseRequisition req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseRequisitionDetailPage(requisitionId: req.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    req.requisitionNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(req.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatStatus(req.status),
                      style: TextStyle(
                        color: _getStatusColor(req.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Title: ${req.title}'),
              Text('Department: ${req.department}'),
              Text('Required Date: ${_formatDate(req.requiredDate)}'),
              Text('Requested by: ${req.requestedByName}'),
              const SizedBox(height: 8),
              ...req.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${item.description} (${item.quantity} ${item.unit})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('KES ${item.totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
              )).toList(),
              if (req.items.length > 2)
                Text('+ ${req.items.length - 2} more items...'),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'KES ${req.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseRequisitionDetailPage(requisitionId: req.id),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (req.status == 'draft')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitForApproval(req.id),
                        child: const Text('Submit'),
                      ),
                    ),
                  if (req.status == 'under_review' && req.currentApproverName != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processApproval(req.id, 'approve'),
                        child: const Text('Approve'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForApproval(String reqId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit for Approval'),
        content: const Text('Are you sure you want to submit this requisition for approval?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(purchaseRequisitionDetailProvider(reqId).notifier).submitForApproval();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Requisition submitted for approval')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit requisition: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _processApproval(String reqId, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${StringExtension(action).capitalize()} Requisition'),
        content: const Text('Are you sure you want to proceed with this action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(purchaseRequisitionDetailProvider(reqId).notifier).processApproval(action);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Requisition ${action}ed successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to ${action} requisition: $e')),
                );
              }
            },
            child: Text(StringExtension(action).capitalize()),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'under_review':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'converted_to_po':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}