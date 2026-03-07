import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/work_order_provider.dart';
import 'work_order_materials.dart';
import 'work_order_tasks.dart';
import 'work_order_timeline.dart';

class WorkOrderDetailsScreen extends ConsumerStatefulWidget {
  final String workOrderId;
  final Function() onEdit;
  final Function() onBack;

  const WorkOrderDetailsScreen({
    super.key,
    required this.workOrderId,
    required this.onEdit,
    required this.onBack,
  });

  @override
  ConsumerState<WorkOrderDetailsScreen> createState() =>
      _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends ConsumerState<WorkOrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWorkOrder();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWorkOrder() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workOrderProvider.notifier).getWorkOrderById(widget.workOrderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workOrderState = ref.watch(workOrderProvider);
    final workOrder = workOrderState.selectedWorkOrder;
    final isLoading = workOrderState.isLoading;

    if (isLoading && workOrder == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (workOrder == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: const Text('Work Order Not Found'),
        ),
        body: const Center(
          child: Text('Work order not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workOrder.workOrderNumber,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              workOrder.title,
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: widget.onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(workOrder),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            Tab(icon: Icon(Icons.inventory), text: 'Materials'),
            Tab(icon: Icon(Icons.history), text: 'Timeline'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(workOrder),
          WorkOrderTasks(workOrder: workOrder),
          WorkOrderMaterials(workOrder: workOrder),
          WorkOrderTimeline(workOrder: workOrder),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(workOrder),
    );
  }

  Widget _buildOverviewTab(WorkOrder workOrder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(workOrder.priority),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workOrder.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workOrder.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(workOrder.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(workOrder.status)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(workOrder.status),
                              size: 14,
                              color: _getStatusColor(workOrder.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workOrder.isOverdue
                                  ? 'OVERDUE'
                                  : workOrder.status.displayName.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(workOrder.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${workOrder.progress}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: workOrder.progress / 100,
                        backgroundColor: Colors.grey[200],
                        color: _getProgressColor(workOrder.progress),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${workOrder.tasks.where((t) => t.status == TaskStatus.completed).length}'
                        ' of ${workOrder.tasks.length} tasks completed',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildStatItem(
                        Icons.calendar_today,
                        'Scheduled',
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(workOrder.scheduledDate),
                      ),
                      _buildStatItem(
                        Icons.access_time,
                        'Est. Duration',
                        '${workOrder.estimatedDuration} min',
                      ),
                      _buildStatItem(
                        Icons.assignment,
                        'Type',
                        workOrder.type.displayName,
                      ),
                      _buildStatItem(
                        Icons.priority_high,
                        'Priority',
                        workOrder.priority.displayName,
                      ),
                      if (workOrder.actualStartDate != null)
                        _buildStatItem(
                          Icons.play_arrow,
                          'Started',
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(workOrder.actualStartDate!),
                        ),
                      if (workOrder.actualEndDate != null)
                        _buildStatItem(
                          Icons.check_circle,
                          'Completed',
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(workOrder.actualEndDate!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.blue, size: 20),
                    ),
                    title: Text(
                      workOrder.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('Customer ID: ${workOrder.customerId}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on,
                          color: Colors.green, size: 20),
                    ),
                    title: Text(workOrder.location.address),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${workOrder.location.city}, ${workOrder.location.zone}'),
                        if (workOrder.location.landmark != null)
                          Text('Landmark: ${workOrder.location.landmark}'),
                        if (workOrder.location.accessInstructions != null)
                          Text(
                              'Access: ${workOrder.location.accessInstructions}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openMaps(workOrder),
                          icon: const Icon(Icons.map),
                          label: const Text('Open in Maps'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _getDirections(workOrder),
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (workOrder.assignedTechnicianNames.isNotEmpty) ...[
                    const Text(
                      'Assigned Technicians:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...workOrder.assignedTechnicianNames
                        .map((tech) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                radius: 16,
                                child: Icon(Icons.person, size: 16),
                              ),
                              title: Text(tech),
                              trailing: workOrder.teamLeadName == tech
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Team Lead',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ))
                        .toList(),
                  ] else ...[
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_outline, color: Colors.grey),
                      title: Text(
                        'No technicians assigned',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _assignTechnicians(workOrder),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Assign Technicians'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cost Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCostItem('Estimated Cost',
                      _formatCurrency(workOrder.estimatedCost)),
                  _buildCostItem(
                      'Actual Cost', _formatCurrency(workOrder.actualCost)),
                  _buildCostItem(
                      'Labor Cost', _formatCurrency(workOrder.laborCost)),
                  _buildCostItem(
                      'Material Cost', _formatCurrency(workOrder.materialCost)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildCostItem(
                    'Variance',
                    _formatCurrency(
                        workOrder.actualCost - workOrder.estimatedCost),
                    color: workOrder.actualCost > workOrder.estimatedCost
                        ? Colors.red
                        : Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
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

  Widget _buildCostItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(WorkOrder workOrder) {
    return FloatingActionButton.extended(
      onPressed: () => _handlePrimaryAction(workOrder),
      icon: Icon(_getPrimaryActionIcon(workOrder.status)),
      label: Text(_getPrimaryActionText(workOrder.status)),
      backgroundColor: _getPrimaryActionColor(workOrder.status),
    );
  }

  Color _getPriorityColor(WorkOrderPriority priority) {
    return switch (priority) {
      WorkOrderPriority.low => Colors.green,
      WorkOrderPriority.medium => Colors.orange,
      WorkOrderPriority.high => Colors.red,
      WorkOrderPriority.urgent => Colors.purple,
    };
  }

  Color _getStatusColor(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => Colors.orange,
      WorkOrderStatus.scheduled => Colors.blue,
      WorkOrderStatus.inProgress => Colors.blueAccent,
      WorkOrderStatus.onHold => Colors.purple,
      WorkOrderStatus.completed => Colors.green,
      WorkOrderStatus.cancelled => Colors.grey,
      WorkOrderStatus.failed => Colors.red,
    };
  }

  IconData _getStatusIcon(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => Icons.pending,
      WorkOrderStatus.scheduled => Icons.schedule,
      WorkOrderStatus.inProgress => Icons.play_arrow,
      WorkOrderStatus.onHold => Icons.pause,
      WorkOrderStatus.completed => Icons.check_circle,
      WorkOrderStatus.cancelled => Icons.cancel,
      WorkOrderStatus.failed => Icons.error,
    };
  }

  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }

  IconData _getPrimaryActionIcon(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => Icons.play_arrow,
      WorkOrderStatus.scheduled => Icons.play_arrow,
      WorkOrderStatus.inProgress => Icons.check,
      WorkOrderStatus.onHold => Icons.play_arrow,
      WorkOrderStatus.completed => Icons.visibility,
      WorkOrderStatus.cancelled => Icons.refresh,
      WorkOrderStatus.failed => Icons.refresh,
    };
  }

  String _getPrimaryActionText(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => 'Start',
      WorkOrderStatus.scheduled => 'Start',
      WorkOrderStatus.inProgress => 'Complete',
      WorkOrderStatus.onHold => 'Resume',
      WorkOrderStatus.completed => 'View',
      WorkOrderStatus.cancelled => 'Reopen',
      WorkOrderStatus.failed => 'Retry',
    };
  }

  Color _getPrimaryActionColor(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => Colors.blue,
      WorkOrderStatus.scheduled => Colors.blue,
      WorkOrderStatus.inProgress => Colors.green,
      WorkOrderStatus.onHold => Colors.orange,
      WorkOrderStatus.completed => Colors.grey,
      WorkOrderStatus.cancelled => Colors.blue,
      WorkOrderStatus.failed => Colors.blue,
    };
  }

  String _formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  void _handlePrimaryAction(WorkOrder workOrder) {
    final notifier = ref.read(workOrderProvider.notifier);

    switch (workOrder.status) {
      case WorkOrderStatus.pending:
      case WorkOrderStatus.scheduled:
        notifier.updateWorkOrderStatus(
            workOrder.id, WorkOrderStatus.inProgress, null);
        break;
      case WorkOrderStatus.inProgress:
        _showCompletionDialog(workOrder);
        break;
      case WorkOrderStatus.onHold:
        notifier.updateWorkOrderStatus(
            workOrder.id, WorkOrderStatus.inProgress, null);
        break;
      case WorkOrderStatus.completed:
        break;
      case WorkOrderStatus.cancelled:
      case WorkOrderStatus.failed:
        notifier.updateWorkOrderStatus(
            workOrder.id, WorkOrderStatus.pending, null);
        break;
    }
  }

  void _showCompletionDialog(WorkOrder workOrder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Work Order'),
        content: const Text(
            'Are you sure you want to mark this work order as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(workOrderProvider.notifier).updateWorkOrderStatus(
                    workOrder.id,
                    WorkOrderStatus.completed,
                    'Completed via mobile app',
                  );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(WorkOrder workOrder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Work Order'),
              onTap: () {
                Navigator.pop(context);
                _shareWorkOrder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print Details'),
              onTap: () {
                Navigator.pop(context);
                _printDetails();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                _duplicateWorkOrder();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Work Order',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteWorkOrder(workOrder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openMaps(WorkOrder workOrder) {}

  void _getDirections(WorkOrder workOrder) {}

  void _assignTechnicians(WorkOrder workOrder) {}

  void _shareWorkOrder() {}

  void _printDetails() {}

  void _duplicateWorkOrder() {}

  void _deleteWorkOrder(WorkOrder workOrder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Work Order'),
        content: Text(
            'Are you sure you want to delete ${workOrder.workOrderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(workOrderProvider.notifier)
                  .deleteWorkOrder(workOrder.id)
                  .then((success) {
                if (success) {
                  widget.onBack();
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
