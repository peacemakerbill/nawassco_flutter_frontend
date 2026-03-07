import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/maintenance_schedule.dart';
import '../../../../providers/maintenance_schedule_provider.dart';
import 'maintenance_schedule_form.dart';

class MaintenanceScheduleDetails extends ConsumerStatefulWidget {
  final MaintenanceSchedule schedule;
  final Function(MaintenanceSchedule) onUpdate;

  const MaintenanceScheduleDetails({
    super.key,
    required this.schedule,
    required this.onUpdate,
  });

  @override
  ConsumerState<MaintenanceScheduleDetails> createState() =>
      _MaintenanceScheduleDetailsState();
}

class _MaintenanceScheduleDetailsState
    extends ConsumerState<MaintenanceScheduleDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(maintenanceScheduleProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.schedule.targetType.icon,
                    color: widget.schedule.targetType.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.schedule.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.schedule.scheduleNumber,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editSchedule(notifier),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Status and Priority Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.schedule.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.schedule.status.icon,
                          size: 14, color: widget.schedule.status.color),
                      const SizedBox(width: 4),
                      Text(
                        widget.schedule.status.displayName,
                        style: TextStyle(
                          color: widget.schedule.status.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.schedule.priority.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.schedule.priority.icon,
                          size: 14, color: widget.schedule.priority.color),
                      const SizedBox(width: 4),
                      Text(
                        widget.schedule.priority.displayName,
                        style: TextStyle(
                          color: widget.schedule.priority.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.schedule.dueStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${widget.schedule.dueStatus} • ${widget.schedule.daysUntilDue.abs()} days',
                    style: TextStyle(
                      color: widget.schedule.dueStatusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Tasks'),
                Tab(text: 'Resources'),
                Tab(text: 'History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTasksTab(),
                _buildResourcesTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: _buildActionButtons(notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Description', widget.schedule.description),
                  _buildInfoRow('Target',
                      '${widget.schedule.targetType.displayName}: ${widget.schedule.targetName}'),
                  _buildInfoRow('Schedule Type',
                      widget.schedule.scheduleType.displayName),
                  _buildInfoRow(
                      'Frequency', widget.schedule.frequency.displayName),
                  _buildInfoRow(
                      'Start Date', _formatDate(widget.schedule.startDate)),
                  _buildInfoRow('Next Due Date',
                      _formatDate(widget.schedule.nextDueDate)),
                  if (widget.schedule.endDate != null)
                    _buildInfoRow(
                        'End Date', _formatDate(widget.schedule.endDate!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Cost Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cost Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCostRow('Estimated Cost',
                      '\$${widget.schedule.estimatedCost.toStringAsFixed(2)}'),
                  _buildCostRow('Actual Cost',
                      '\$${widget.schedule.actualCost.toStringAsFixed(2)}'),
                  _buildCostRow(
                    'Variance',
                    '\$${widget.schedule.costVariance.abs().toStringAsFixed(2)}',
                    isOverBudget: widget.schedule.isCostOverBudget,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: widget.schedule.completionRate / 100,
                    backgroundColor: Colors.grey[200],
                    color: _getProgressColor(widget.schedule.completionRate),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.schedule.completionRate.toStringAsFixed(1)}% Complete',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        // Progress Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTaskStat('Total', widget.schedule.tasks.length.toString()),
              _buildTaskStat(
                  'Completed',
                  widget.schedule.tasks
                      .where((t) => t.status == TaskStatus.completed)
                      .length
                      .toString()),
              _buildTaskStat(
                  'In Progress',
                  widget.schedule.tasks
                      .where((t) => t.status == TaskStatus.inProgress)
                      .length
                      .toString()),
              _buildTaskStat(
                  'Pending',
                  widget.schedule.tasks
                      .where((t) => t.status == TaskStatus.pending)
                      .length
                      .toString()),
            ],
          ),
        ),
        // Tasks List
        Expanded(
          child: widget.schedule.tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Tasks Defined',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.schedule.tasks.length,
                  itemBuilder: (context, index) =>
                      _buildTaskListItem(widget.schedule.tasks[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildResourcesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Required Tools
          if (widget.schedule.requiredTools.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Tools',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.schedule.requiredTools
                          .map((toolId) => Chip(label: Text(toolId)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Required Materials
          if (widget.schedule.requiredMaterials.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Materials',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...widget.schedule.requiredMaterials
                        .map((material) => ListTile(
                              title: Text(material.material),
                              subtitle:
                                  Text('${material.quantity} ${material.unit}'),
                              trailing: material.specifications != null
                                  ? Tooltip(
                                      message: material.specifications!,
                                      child: const Icon(Icons.info_outline,
                                          size: 16),
                                    )
                                  : null,
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
          // Assigned Technicians
          if (widget.schedule.assignedTo.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Technicians',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.schedule.assignedTo
                          .map((techId) => Chip(label: Text(techId)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return widget.schedule.history.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Maintenance History',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'History will appear here after maintenance is completed',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.schedule.history.length,
            itemBuilder: (context, index) =>
                _buildHistoryItem(widget.schedule.history[index]),
          );
  }

  // Helper Widgets
  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildCostRow(String label, String value,
      {bool isOverBudget = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isOverBudget ? Colors.red : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTaskListItem(MaintenanceTask task, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.task,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.status.displayName,
                    style: TextStyle(
                      color: task.status.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text('${task.estimatedTime}h estimated'),
                  visualDensity: VisualDensity.compact,
                ),
                if (task.actualTime != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${task.actualTime}h actual'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                if (task.completedAt != null) ...[
                  const Spacer(),
                  Text(
                    'Completed ${_formatDate(task.completedAt!)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(MaintenanceHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _formatDate(history.maintenanceDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '\$${history.cost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Completed by: ${history.completedBy}'),
            const SizedBox(height: 8),
            Text('Tasks completed: ${history.tasksCompleted.length}'),
            if (history.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${history.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Next due: ${_formatDate(history.nextDueDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(MaintenanceScheduleProvider notifier) {
    final buttons = <Widget>[];

    switch (widget.schedule.status) {
      case MaintenanceStatus.pending:
      case MaintenanceStatus.scheduled:
        buttons.addAll([
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _updateStatus(notifier, MaintenanceStatus.inProgress),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _updateStatus(notifier, MaintenanceStatus.cancelled),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
            ),
          ),
        ]);
        break;
      case MaintenanceStatus.inProgress:
        buttons.addAll([
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _completeMaintenance(notifier),
              icon: const Icon(Icons.check),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _updateStatus(notifier, MaintenanceStatus.pending),
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),
          ),
        ]);
        break;
      case MaintenanceStatus.completed:
        buttons.add(
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _updateStatus(notifier, MaintenanceStatus.pending),
              icon: const Icon(Icons.refresh),
              label: const Text('Reopen'),
            ),
          ),
        );
        break;
      case MaintenanceStatus.overdue:
        buttons.addAll([
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _updateStatus(notifier, MaintenanceStatus.inProgress),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Now'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _rescheduleMaintenance(notifier),
              icon: const Icon(Icons.schedule),
              label: const Text('Reschedule'),
            ),
          ),
        ]);
        break;
      case MaintenanceStatus.cancelled:
        buttons.add(
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _updateStatus(notifier, MaintenanceStatus.pending),
              icon: const Icon(Icons.refresh),
              label: const Text('Reactivate'),
            ),
          ),
        );
        break;
    }

    return buttons;
  }

  // Action Methods
  void _editSchedule(MaintenanceScheduleProvider notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaintenanceScheduleForm(
        schedule: widget.schedule,
        onSubmit: (data) async {
          final success = await notifier.updateMaintenanceSchedule(
              widget.schedule.id, data);
          if (success && context.mounted) {
            final updatedSchedule = widget.schedule.copyWith(
              title: data['title'],
              description: data['description'],
              // Update other fields as needed
            );
            widget.onUpdate(updatedSchedule);
            Navigator.pop(context);
          }
          return success;
        },
      ),
    );
  }

  void _updateStatus(
      MaintenanceScheduleProvider notifier, MaintenanceStatus newStatus) async {
    final success =
        await notifier.updateMaintenanceStatus(widget.schedule.id, newStatus);
    if (success && context.mounted) {
      final updatedSchedule = widget.schedule.copyWith(status: newStatus);
      widget.onUpdate(updatedSchedule);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${newStatus.displayName}')),
      );
    }
  }

  void _completeMaintenance(MaintenanceScheduleProvider notifier) {
    showDialog(
      context: context,
      builder: (context) => CompletionDialog(
        onComplete: (notes, actualCost) async {
          final success = await notifier.updateMaintenanceStatus(
            widget.schedule.id,
            MaintenanceStatus.completed,
            notes: notes,
          );
          if (success && actualCost != null) {
            await notifier.recordActualCost(widget.schedule.id, actualCost);
          }
          if (success && context.mounted) {
            final updatedSchedule = widget.schedule.copyWith(
              status: MaintenanceStatus.completed,
              actualCost: actualCost ?? widget.schedule.actualCost,
              lastCompletedDate: DateTime.now(),
            );
            widget.onUpdate(updatedSchedule);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Maintenance completed successfully')),
            );
          }
          return success;
        },
      ),
    );
  }

  void _rescheduleMaintenance(MaintenanceScheduleProvider notifier) {
    // Implementation for rescheduling
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }
}

class CompletionDialog extends StatefulWidget {
  final Function(String, double?) onComplete;

  const CompletionDialog({super.key, required this.onComplete});

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog> {
  final _notesController = TextEditingController();
  final _actualCostController = TextEditingController();
  bool _includeCost = false;

  @override
  void dispose() {
    _notesController.dispose();
    _actualCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Maintenance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Completion Notes',
              border: OutlineInputBorder(),
              hintText: 'Add any notes about the maintenance work...',
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Record actual cost'),
            value: _includeCost,
            onChanged: (value) => setState(() => _includeCost = value!),
          ),
          if (_includeCost) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _actualCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual Cost',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _complete,
          child: const Text('Complete'),
        ),
      ],
    );
  }

  void _complete() {
    final actualCost = _includeCost && _actualCostController.text.isNotEmpty
        ? double.tryParse(_actualCostController.text)
        : null;

    widget.onComplete(_notesController.text, actualCost);
    Navigator.pop(context);
  }
}
