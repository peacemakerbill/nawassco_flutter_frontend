import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/purchase_order.dart';
import '../../../../providers/purchase_provider.dart';
import 'purchase_order_form_page.dart';

class PurchaseOrderDetailPage extends ConsumerWidget {
  final String purchaseOrderId;

  const PurchaseOrderDetailPage({super.key, required this.purchaseOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseOrderAsync = ref.watch(purchaseOrderDetailProvider(purchaseOrderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(purchaseOrderDetailProvider(purchaseOrderId).notifier).loadPurchaseOrder(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'approve', child: Text('Approve')),
              const PopupMenuItem(value: 'reject', child: Text('Reject')),
              const PopupMenuItem(value: 'issue', child: Text('Issue')),
              const PopupMenuItem(value: 'close', child: Text('Close')),
            ],
          ),
        ],
      ),
      body: purchaseOrderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(purchaseOrderDetailProvider(purchaseOrderId).notifier).loadPurchaseOrder(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (purchaseOrder) {
          if (purchaseOrder == null) {
            return const Center(child: Text('Purchase order not found'));
          }
          return _buildPurchaseOrderDetails(purchaseOrder, context, ref);
        },
      ),
    );
  }

  Widget _buildPurchaseOrderDetails(PurchaseOrder po, BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        po.poNumber,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Supplier: ${po.supplierName}'),
                      Text('Status: ${_formatStatus(po.status)}'),
                      Text('Approval: ${_formatStatus(po.approvalStatus)}'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KES ${po.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Order Date: ${_formatDate(po.orderDate)}'),
                      Text('Expected: ${_formatDate(po.expectedDeliveryDate)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Items Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...po.items.map((item) => _buildItemTile(item)).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('KES ${po.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('KES ${po.taxAmount.toStringAsFixed(0)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('KES ${po.shippingCost.toStringAsFixed(0)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        'KES ${po.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Invoices Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (po.invoices.isEmpty)
                    const Center(child: Text('No invoices attached')),
                  ...po.invoices.map((invoice) => _buildInvoiceTile(invoice)).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('KES ${po.totalPaid.toStringAsFixed(0)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Balance Due:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'KES ${po.balanceDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: po.balanceDue > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(POItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.description),
      subtitle: Text('Code: ${item.itemCode} | Qty: ${item.quantity} ${item.unit}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('KES ${item.unitPrice.toStringAsFixed(0)}/unit'),
          Text(
            'KES ${item.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTile(POInvoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(invoice.invoiceNumber),
        subtitle: Text('Date: ${_formatDate(invoice.invoiceDate)} | Status: ${_formatStatus(invoice.status)}'),
        trailing: Text(
          'KES ${invoice.amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context, WidgetRef ref) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseOrderFormPage(existingPO: _getCurrentPO(ref)),
          ),
        );
        break;
      case 'delete':
        _deletePurchaseOrder(context, ref);
        break;
      case 'approve':
      case 'reject':
      case 'issue':
      case 'close':
        _processPOAction(action, context, ref);
        break;
    }
  }

  PurchaseOrder? _getCurrentPO(WidgetRef ref) {
    return ref.read(purchaseOrderDetailProvider(purchaseOrderId)).valueOrNull;
  }

  void _deletePurchaseOrder(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Order'),
        content: const Text('Are you sure you want to delete this purchase order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(purchaseOrderProvider.notifier).deletePurchaseOrder(purchaseOrderId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase order deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete purchase order: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _processPOAction(String action, BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} Purchase Order'),
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
                await ref.read(purchaseOrderDetailProvider(purchaseOrderId).notifier).processPOAction(action);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Purchase order ${action}ed successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to ${action} purchase order: $e')),
                  );
                }
              }
            },
            child: Text(action.capitalize()),
          ),
        ],
      ),
    );
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