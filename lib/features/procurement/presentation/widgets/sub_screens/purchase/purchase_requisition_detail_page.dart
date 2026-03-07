import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/purchase_requisition.dart';
import '../../../../providers/purchase_provider.dart';
import 'purchase_requisition_form_page.dart';

class PurchaseRequisitionDetailPage extends ConsumerWidget {
  final String requisitionId;

  const PurchaseRequisitionDetailPage({super.key, required this.requisitionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requisitionAsync = ref.watch(purchaseRequisitionDetailProvider(requisitionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requisition Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(purchaseRequisitionDetailProvider(requisitionId).notifier).loadRequisition(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'submit', child: Text('Submit for Approval')),
              const PopupMenuItem(value: 'approve', child: Text('Approve')),
              const PopupMenuItem(value: 'reject', child: Text('Reject')),
            ],
          ),
        ],
      ),
      body: requisitionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(purchaseRequisitionDetailProvider(requisitionId).notifier).loadRequisition(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (requisition) {
          if (requisition == null) {
            return const Center(child: Text('Requisition not found'));
          }
          return _buildRequisitionDetails(requisition, context, ref);
        },
      ),
    );
  }

  Widget _buildRequisitionDetails(PurchaseRequisition req, BuildContext context, WidgetRef ref) {
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
                        req.requisitionNumber,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Title: ${req.title}'),
                      Text('Department: ${req.department}'),
                      Text('Status: ${_formatStatus(req.status)}'),
                      if (req.currentApproverName != null)
                        Text('Current Approver: ${req.currentApproverName}'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KES ${req.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Required Date: ${_formatDate(req.requiredDate)}'),
                      Text('Urgency: ${_formatUrgency(req.urgency)}'),
                      Text('Type: ${_formatProcurementType(req.procurementType)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description & Justification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Description: ${req.description}'),
                  const SizedBox(height: 8),
                  Text('Justification: ${req.justification}'),
                  const SizedBox(height: 8),
                  Text('Expected Outcomes: ${req.expectedOutcomes}'),
                  const SizedBox(height: 8),
                  Text('Alternatives Considered: ${req.alternativeConsidered}'),
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
                  ...req.items.map((item) => _buildItemTile(item)).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        'KES ${req.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Approval History Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Approval History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (req.approvalHistory.isEmpty)
                    const Center(child: Text('No approval history')),
                  ...req.approvalHistory.map((step) => _buildApprovalStepTile(step)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(RequisitionItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.description),
      subtitle: Text('Code: ${item.itemCode} | Qty: ${item.quantity} ${item.unit} | Delivery: ${_formatDate(item.deliveryDate)}'),
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

  Widget _buildApprovalStepTile(ApprovalStep step) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getApprovalStatusIcon(step.status),
          color: _getApprovalStatusColor(step.status),
        ),
        title: Text(step.approverName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${step.role}'),
            Text('Status: ${_formatStatus(step.status)}'),
            if (step.comments != null) Text('Comments: ${step.comments}'),
            if (step.approvedAt != null) Text('Date: ${_formatDate(step.approvedAt!)}'),
          ],
        ),
        trailing: Text('Step ${step.sequence}'),
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context, WidgetRef ref) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseRequisitionFormPage(existingRequisition: _getCurrentRequisition(ref)),
          ),
        );
        break;
      case 'delete':
        _deleteRequisition(context, ref);
        break;
      case 'submit':
        _submitForApproval(context, ref);
        break;
      case 'approve':
      case 'reject':
        _processApproval(action, context, ref);
        break;
    }
  }

  PurchaseRequisition? _getCurrentRequisition(WidgetRef ref) {
    return ref.read(purchaseRequisitionDetailProvider(requisitionId)).valueOrNull;
  }

  void _deleteRequisition(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Requisition'),
        content: const Text('Are you sure you want to delete this requisition?'),
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
                await ref.read(purchaseRequisitionProvider.notifier).deleteRequisition(requisitionId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Requisition deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete requisition: $e')),
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

  void _submitForApproval(BuildContext context, WidgetRef ref) {
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
                await ref.read(purchaseRequisitionDetailProvider(requisitionId).notifier).submitForApproval();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Requisition submitted for approval')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit requisition: $e')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _processApproval(String action, BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} Requisition'),
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
                await ref.read(purchaseRequisitionDetailProvider(requisitionId).notifier).processApproval(action);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Requisition ${action}ed successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to ${action} requisition: $e')),
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

  IconData _getApprovalStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  Color _getApprovalStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatUrgency(String urgency) {
    return urgency[0].toUpperCase() + urgency.substring(1);
  }

  String _formatProcurementType(String type) {
    return type.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
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