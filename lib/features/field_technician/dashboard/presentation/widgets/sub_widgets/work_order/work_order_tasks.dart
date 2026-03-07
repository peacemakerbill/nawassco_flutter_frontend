import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/work_order_provider.dart';

class WorkOrderTasks extends ConsumerStatefulWidget {
  final WorkOrder workOrder;

  const WorkOrderTasks({super.key, required this.workOrder});

  @override
  ConsumerState<WorkOrderTasks> createState() => _WorkOrderTasksState();
}

class _WorkOrderTasksState extends ConsumerState<WorkOrderTasks> {
  @override
  Widget build(BuildContext context) {
    final tasks = widget.workOrder.tasks;
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalTasks = tasks.length;
    final progress =
        totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tasks Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks of $totalTasks tasks completed',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      color: _getProgressColor(progress),
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) =>
                      _buildTaskItem(tasks[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: ElevatedButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
            label: const Text('Add New Task'),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(WorkOrderTask task, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
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
                    color: _getTaskStatusColor(task.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.task,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            _getTaskStatusColor(task.status).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTaskStatusIcon(task.status),
                        size: 12,
                        color: _getTaskStatusColor(task.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.status.displayName.toUpperCase(),
                        style: TextStyle(
                          color: _getTaskStatusColor(task.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  Icons.access_time,
                  'Estimated: ${task.estimatedTime} min',
                ),
                if (task.actualTime != null)
                  _buildDetailChip(
                    Icons.timer,
                    'Actual: ${task.actualTime} min',
                  ),
                if (task.completedBy != null)
                  _buildDetailChip(
                    Icons.person,
                    'Completed by: ${task.completedBy}',
                  ),
                if (task.completedAt != null)
                  _buildDetailChip(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy').format(task.completedAt!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (task.status != TaskStatus.completed) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateTaskStatus(index, TaskStatus.inProgress),
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _completeTask(task, index),
                      child: const Text('Complete'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateTaskStatus(index, TaskStatus.pending),
                      child: const Text('Reopen'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTask(task, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Tasks Added',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add tasks to break down the work order into manageable steps',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }

  Color _getTaskStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Colors.orange,
      TaskStatus.inProgress => Colors.blue,
      TaskStatus.completed => Colors.green,
      TaskStatus.skipped => Colors.grey,
    };
  }

  IconData _getTaskStatusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Icons.pending,
      TaskStatus.inProgress => Icons.play_arrow,
      TaskStatus.completed => Icons.check_circle,
      TaskStatus.skipped => Icons.skip_next,
    };
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        onSave: (taskData) {
          ref.read(workOrderProvider.notifier).addTask(
                widget.workOrder.id,
                taskData,
              );
        },
      ),
    );
  }

  void _editTask(WorkOrderTask task, int index) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (taskData) {
          _showEditNotAvailable();
        },
      ),
    );
  }

  void _showEditNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task editing will be available in the next update'),
      ),
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteNotAvailable();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deletion will be available in the next update'),
      ),
    );
  }

  void _updateTaskStatus(int taskIndex, TaskStatus newStatus) {
    ref.read(workOrderProvider.notifier).updateTaskStatus(
          widget.workOrder.id,
          taskIndex,
          newStatus,
          'current_user_id',
          null,
        );
  }

  void _completeTask(WorkOrderTask task, int index) {
    showDialog(
      context: context,
      builder: (context) => CompleteTaskDialog(
        task: task,
        onComplete: (actualTime) {
          ref.read(workOrderProvider.notifier).updateTaskStatus(
                widget.workOrder.id,
                index,
                TaskStatus.completed,
                'current_user_id',
                actualTime,
              );
        },
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final WorkOrderTask? task;
  final Function(Map<String, dynamic>) onSave;

  const TaskDialog({super.key, this.task, required this.onSave});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskController.text = widget.task!.task;
      _descriptionController.text = widget.task!.description;
      _estimatedTimeController.text = widget.task!.estimatedTime.toString();
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedTimeController,
              decoration: const InputDecoration(
                labelText: 'Estimated Time (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter estimated time';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save Task'),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskData = {
        'task': _taskController.text,
        'description': _descriptionController.text,
        'estimatedTime': int.parse(_estimatedTimeController.text),
      };

      widget.onSave(taskData);
      Navigator.pop(context);
    }
  }
}

class CompleteTaskDialog extends StatefulWidget {
  final WorkOrderTask task;
  final Function(int) onComplete;

  const CompleteTaskDialog({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends State<CompleteTaskDialog> {
  final _actualTimeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _actualTimeController.text = widget.task.estimatedTime.toString();
  }

  @override
  void dispose() {
    _actualTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.task,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(widget.task.description),
          const SizedBox(height: 16),
          TextFormField(
            controller: _actualTimeController,
            decoration: const InputDecoration(
              labelText: 'Actual Time (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Completion Notes (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _completeTask,
          child: const Text('Mark Complete'),
        ),
      ],
    );
  }

  void _completeTask() {
    final actualTime =
        int.tryParse(_actualTimeController.text) ?? widget.task.estimatedTime;
    widget.onComplete(actualTime);
    Navigator.pop(context);
  }
}
