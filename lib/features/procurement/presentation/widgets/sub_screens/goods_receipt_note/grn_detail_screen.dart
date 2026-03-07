import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/goods_receipt_note.dart';
import '../../../../providers/goods_receipt_note_provider.dart';

class GRNDetailScreen extends ConsumerWidget {
  final String grnId;

  const GRNDetailScreen({super.key, required this.grnId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grnAsync = ref.watch(goodsReceiptNoteProvider(grnId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('GRN Details'),
      ),
      body: grnAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(goodsReceiptNoteProvider(grnId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (grn) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard('Basic Information', [
                  _buildDetailRow('GRN Number', grn.grnNumber),
                  _buildDetailRow('Purchase Order', grn.purchaseOrderNumber),
                  _buildDetailRow('Supplier', grn.supplierName),
                  _buildDetailRow('Status', grn.status.toUpperCase()),
                  _buildDetailRow('Quality Status', grn.qualityStatus.toUpperCase()),
                ]),
                _buildDetailCard('Receipt Details', [
                  _buildDetailRow('Receipt Date', _formatDate(grn.receiptDate)),
                  _buildDetailRow('Received By', grn.receivedByName),
                  _buildDetailRow('Storage Location', grn.storageLocation),
                  _buildDetailRow('Storekeeper', grn.storekeeperName),
                  if (grn.deliveryNoteNumber != null)
                    _buildDetailRow('Delivery Note', grn.deliveryNoteNumber!),
                  if (grn.vehicleNumber != null)
                    _buildDetailRow('Vehicle Number', grn.vehicleNumber!),
                ]),
                _buildDetailCard('Quality Inspection', [
                  if (grn.inspectedByName != null)
                    _buildDetailRow('Inspected By', grn.inspectedByName!),
                  if (grn.inspectionDate != null)
                    _buildDetailRow('Inspection Date', _formatDate(grn.inspectionDate!)),
                  if (grn.qualityRemarks != null)
                    _buildDetailRow('Remarks', grn.qualityRemarks!),
                ]),
                _buildDetailCard('Financial Information', [
                  _buildDetailRow('Total Quantity', grn.totalQuantity.toString()),
                  _buildDetailRow('Total Value', 'KES ${grn.totalValue.toStringAsFixed(2)}'),
                  _buildDetailRow('Has Returns', grn.hasReturns ? 'Yes' : 'No'),
                  if (grn.returnReference != null)
                    _buildDetailRow('Return Reference', grn.returnReference!),
                ]),
                _buildItemsCard(grn),
                _buildDetailCard('Timestamps', [
                  _buildDetailRow('Created', _formatDateTime(grn.createdAt)),
                  _buildDetailRow('Last Updated', _formatDateTime(grn.updatedAt)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemsCard(GoodsReceiptNote grn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${grn.items.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...grn.items.map((item) => _buildItemRow(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(GRNItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildItemDetail('Ordered', '${item.orderedQuantity} ${item.unit}'),
              _buildItemDetail('Received', '${item.receivedQuantity} ${item.unit}'),
              _buildItemDetail('Accepted', '${item.acceptedQuantity} ${item.unit}'),
              _buildItemDetail('Rejected', '${item.rejectedQuantity} ${item.unit}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getItemStatusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    color: _getItemStatusColor(item.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'KES ${item.totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (item.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text(
              'Rejection Reason: ${item.rejectionReason}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getItemStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'partially_accepted':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}