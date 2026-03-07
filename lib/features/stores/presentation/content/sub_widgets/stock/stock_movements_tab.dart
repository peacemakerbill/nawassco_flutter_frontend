import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/stock/stock_movement_model.dart';
import '../../../../providers/stock_movement_provider.dart';
import 'movement_details_dialog.dart';
import 'edit_movement_dialog.dart';

class StockMovementsTab extends ConsumerWidget {
  const StockMovementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementState = ref.watch(stockMovementProvider);
    final authState = ref.watch(authProvider);

    if (movementState.isLoading && movementState.movements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movementState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading movements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              movementState.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(stockMovementProvider.notifier).getStockMovements(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (movementState.movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.move_to_inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No stock movements found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(
              'Create your first stock movement to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stockMovementProvider.notifier).getStockMovements();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: movementState.movements.length,
        itemBuilder: (context, index) {
          final movement = movementState.movements[index];
          return _MovementCard(movement: movement, authState: authState);
        },
      ),
    );
  }
}

class _MovementCard extends ConsumerWidget {
  final StockMovement movement;
  final AuthState authState;

  const _MovementCard({
    required this.movement,
    required this.authState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _MovementTypeChip(movementType: movement.movementType),
                const Spacer(),
                _StatusChip(status: movement.status),
                const SizedBox(width: 8),
                _ApprovalChip(approvalStatus: movement.approvalStatus),
              ],
            ),
            const SizedBox(height: 12),

            // Movement Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movement.movementNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reference: ${movement.referenceNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KES ${movement.totalValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${movement.totalQuantity} items',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dates and Locations
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${movement.fromLocation.warehouse ?? movement.fromLocation.type}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'To: ${movement.toLocation.warehouse ?? movement.toLocation.type}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(movement.movementDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            if (movement.canEdit || movement.canApprove || movement.canComplete)
              Row(
                children: [
                  if (movement.canEdit && (authState.isAdmin || authState.isStoreManager))
                    OutlinedButton(
                      onPressed: () => _showEditDialog(context, ref, movement),
                      child: const Text('Edit'),
                    ),
                  const SizedBox(width: 8),
                  if (movement.canApprove && (authState.isAdmin || authState.isStoreManager))
                    ElevatedButton(
                      onPressed: () => _approveMovement(ref, movement.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Approve', style: TextStyle(color: Colors.white)),
                    ),
                  const SizedBox(width: 8),
                  if (movement.canComplete)
                    ElevatedButton(
                      onPressed: () => _completeMovement(ref, movement.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Complete', style: TextStyle(color: Colors.white)),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showDetailsDialog(context, movement),
                    tooltip: 'View Details',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, StockMovement movement) {
    showDialog(
      context: context,
      builder: (context) => EditMovementDialog(
        movement: movement,
        onMovementUpdated: () {
          ref.read(stockMovementProvider.notifier).getStockMovements();
        },
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, StockMovement movement) {
    showDialog(
      context: context,
      builder: (context) => MovementDetailsDialog(movement: movement),
    );
  }

  void _approveMovement(WidgetRef ref, String movementId) {
    ref.read(stockMovementProvider.notifier).approveStockMovement(
      movementId,
      ref.read(authProvider).user?['_id'] ?? '',
    );
  }

  void _completeMovement(WidgetRef ref, String movementId) {
    ref.read(stockMovementProvider.notifier).completeStockMovement(
      movementId,
      ref.read(authProvider).user?['_id'] ?? '',
    );
  }
}

class _MovementTypeChip extends StatelessWidget {
  final String movementType;

  const _MovementTypeChip({required this.movementType});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getMovementTypeInfo(movementType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getMovementTypeInfo(String type) {
    switch (type) {
      case 'receipt':
        return (Colors.green, 'Receipt');
      case 'issue':
        return (Colors.orange, 'Issue');
      case 'transfer':
        return (Colors.blue, 'Transfer');
      case 'return':
        return (Colors.purple, 'Return');
      case 'adjustment':
        return (Colors.red, 'Adjustment');
      case 'write_off':
        return (Colors.grey, 'Write Off');
      case 'cycle_count':
        return (Colors.teal, 'Cycle Count');
      default:
        return (Colors.grey, 'Unknown');
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo(String status) {
    switch (status) {
      case 'draft':
        return (Colors.grey, 'Draft');
      case 'pending':
        return (Colors.orange, 'Pending');
      case 'in_progress':
        return (Colors.blue, 'In Progress');
      case 'completed':
        return (Colors.green, 'Completed');
      case 'cancelled':
        return (Colors.red, 'Cancelled');
      case 'rejected':
        return (Colors.red, 'Rejected');
      default:
        return (Colors.grey, 'Unknown');
    }
  }
}

class _ApprovalChip extends StatelessWidget {
  final String approvalStatus;

  const _ApprovalChip({required this.approvalStatus});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getApprovalInfo(approvalStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getApprovalInfo(String status) {
    switch (status) {
      case 'not_required':
        return (Colors.grey, 'Not Required');
      case 'pending':
        return (Colors.orange, 'Pending Approval');
      case 'approved':
        return (Colors.green, 'Approved');
      case 'rejected':
        return (Colors.red, 'Rejected');
      default:
        return (Colors.grey, 'Unknown');
    }
  }
}