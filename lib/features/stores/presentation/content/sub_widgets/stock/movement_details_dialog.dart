import 'package:flutter/material.dart';
import '../../../../models/stock/movement_item_model.dart';
import '../../../../models/stock/movement_location_model.dart';
import '../../../../models/stock/stock_movement_model.dart';

class MovementDetailsDialog extends StatelessWidget {
  final StockMovement movement;

  const MovementDetailsDialog({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movement.movementNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getMovementTypeText(movement.movementType),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and Basic Info
                    _buildStatusSection(),
                    const SizedBox(height: 24),

                    // Locations
                    _buildLocationsSection(),
                    const SizedBox(height: 24),

                    // Items
                    _buildItemsSection(),
                    const SizedBox(height: 24),

                    // Additional Info
                    _buildAdditionalInfoSection(),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_formatDate(movement.createdAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Approval',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: _getStatusText(movement.status),
                  color: _getStatusColor(movement.status),
                ),
                _StatusChip(
                  label: _getApprovalText(movement.approvalStatus),
                  color: _getApprovalColor(movement.approvalStatus),
                ),
                if (movement.systemGenerated)
                  const _StatusChip(
                    label: 'System Generated',
                    color: Colors.purple,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoItem(
                  label: 'Movement Date',
                  value: _formatDate(movement.movementDate),
                ),
                const SizedBox(width: 24),
                _InfoItem(
                  label: 'Reference',
                  value: movement.referenceNumber,
                ),
                const SizedBox(width: 24),
                _InfoItem(
                  label: 'Reference Type',
                  value: _getReferenceTypeText(movement.referenceType),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Locations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LocationCard(
                    title: 'From Location',
                    location: movement.fromLocation,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LocationCard(
                    title: 'To Location',
                    location: movement.toLocation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${movement.totalQuantity} items • KES ${movement.totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...movement.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _ItemDetailRow(item: item, index: index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (movement.notes != null && movement.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(movement.notes!),
                  const SizedBox(height: 16),
                ],
              ),
            if (movement.batchNumber != null)
              _InfoItem(
                label: 'Batch Number',
                value: movement.batchNumber!,
              ),
            const SizedBox(height: 8),
            _InfoItem(
              label: 'Created',
              value: _formatDate(movement.createdAt),
            ),
            _InfoItem(
              label: 'Last Updated',
              value: _formatDate(movement.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  String _getMovementTypeText(String type) {
    switch (type) {
      case 'receipt':
        return 'Stock Receipt';
      case 'issue':
        return 'Stock Issue';
      case 'transfer':
        return 'Stock Transfer';
      case 'return':
        return 'Stock Return';
      case 'adjustment':
        return 'Stock Adjustment';
      case 'write_off':
        return 'Stock Write Off';
      case 'cycle_count':
        return 'Cycle Count';
      default:
        return 'Stock Movement';
    }
  }

  String _getStatusText(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _getApprovalText(String approvalStatus) {
    switch (approvalStatus) {
      case 'not_required':
        return 'Approval Not Required';
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return approvalStatus;
    }
  }

  String _getReferenceTypeText(String referenceType) {
    return referenceType.replaceAll('_', ' ').toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getApprovalColor(String approvalStatus) {
    switch (approvalStatus) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String title;
  final MovementLocation location;

  const _LocationCard({required this.title, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _LocationInfoItem(
              label: 'Type',
              value: location.type.toUpperCase(),
            ),
            if (location.warehouse != null)
              _LocationInfoItem(
                label: 'Warehouse',
                value: location.warehouse!,
              ),
            if (location.zone != null)
              _LocationInfoItem(
                label: 'Zone',
                value: location.zone!,
              ),
            if (location.binLocation != null)
              _LocationInfoItem(
                label: 'Bin Location',
                value: location.binLocation!,
              ),
            if (location.department != null)
              _LocationInfoItem(
                label: 'Department',
                value: location.department!,
              ),
            if (location.project != null)
              _LocationInfoItem(
                label: 'Project',
                value: location.project!,
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _LocationInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDetailRow extends StatelessWidget {
  final MovementItem item;
  final int index;

  const _ItemDetailRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item: ${item.itemId}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (item.batchNumber != null)
                  Text(
                    'Batch: ${item.batchNumber}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity} units',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'KES ${item.totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'KES ${item.unitCost.toStringAsFixed(2)}/unit',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
