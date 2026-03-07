import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/purchase_order.dart';
import '../../../providers/purchase_provider.dart';
import '../sub_screens/purchase/purchase_order_detail_page.dart';
import '../sub_screens/purchase/purchase_order_form_page.dart';

class PurchaseOrdersContent extends ConsumerStatefulWidget {
  const PurchaseOrdersContent({super.key});

  @override
  ConsumerState<PurchaseOrdersContent> createState() => _PurchaseOrdersContentState();
}

class _PurchaseOrdersContentState extends ConsumerState<PurchaseOrdersContent> {
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
      ref.read(purchaseOrderProvider.notifier).loadPurchaseOrders();
    }
  }

  void _searchPurchaseOrders() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(purchaseOrderProvider.notifier).loadPurchaseOrders(
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
    final purchaseOrdersAsync = ref.watch(purchaseOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(purchaseOrderProvider.notifier).loadPurchaseOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: purchaseOrdersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(purchaseOrderProvider.notifier).loadPurchaseOrders(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (purchaseOrders) {
                final filteredPOs = _filterStatus == 'All'
                    ? purchaseOrders
                    : purchaseOrders.where((po) => po.status == _filterStatus).toList();

                if (filteredPOs.isEmpty) {
                  return const Center(
                    child: Text('No purchase orders found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPOs.length,
                  itemBuilder: (context, index) => _buildPOCard(filteredPOs[index]),
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
              builder: (context) => const PurchaseOrderFormPage(),
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
                    hintText: 'Search by PO number or supplier...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(purchaseOrderProvider.notifier).loadPurchaseOrders();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _searchPurchaseOrders(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _searchPurchaseOrders,
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
                _buildFilterChip('pending_approval'),
                _buildFilterChip('approved'),
                _buildFilterChip('issued'),
                _buildFilterChip('partially_received'),
                _buildFilterChip('fully_received'),
                _buildFilterChip('cancelled'),
                _buildFilterChip('closed'),
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

  Widget _buildPOCard(PurchaseOrder po) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseOrderDetailPage(purchaseOrderId: po.id),
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
                    po.poNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(po.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatStatus(po.status),
                      style: TextStyle(
                        color: _getStatusColor(po.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Supplier: ${po.supplierName}'),
              Text('Order Date: ${_formatDate(po.orderDate)}'),
              Text('Expected Delivery: ${_formatDate(po.expectedDeliveryDate)}'),
              Text('Created by: ${po.createdByName}'),
              const SizedBox(height: 8),
              ...po.items.take(2).map((item) => Padding(
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
              if (po.items.length > 2)
                Text('+ ${po.items.length - 2} more items...'),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'KES ${po.totalAmount.toStringAsFixed(0)}',
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
                            builder: (context) => PurchaseOrderDetailPage(purchaseOrderId: po.id),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (po.status == 'pending_approval')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processPOAction(po.id, 'approve'),
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

  void _processPOAction(String poId, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${StringExtension(action).capitalize()} Purchase Order'),
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
                await ref.read(purchaseOrderDetailProvider(poId).notifier).processPOAction(action);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Purchase order ${action}ed successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to ${action} purchase order: $e')),
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
      case 'pending_approval':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'issued':
        return Colors.blue;
      case 'partially_received':
        return Colors.purple;
      case 'fully_received':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      case 'closed':
        return Colors.green;
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