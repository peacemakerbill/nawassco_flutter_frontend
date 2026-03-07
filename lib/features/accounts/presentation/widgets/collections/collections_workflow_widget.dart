import 'package:flutter/material.dart';

class CollectionsWorkflowWidget extends StatefulWidget {
  final Function(String, String) onAssignRoute;
  final Function(String, String) onUpdateStatus;

  const CollectionsWorkflowWidget({
    super.key,
    required this.onAssignRoute,
    required this.onUpdateStatus,
  });

  @override
  State<CollectionsWorkflowWidget> createState() => _CollectionsWorkflowWidgetState();
}

class _CollectionsWorkflowWidgetState extends State<CollectionsWorkflowWidget> {
  final List<Map<String, dynamic>> _collectionAgents = [
    {
      'id': 'agent1',
      'name': 'John Mwangi',
      'assignedRoutes': 3,
      'successRate': '85%',
      'status': 'Active',
      'currentLocation': 'Nakuru East',
    },
    {
      'id': 'agent2',
      'name': 'Mary Wambui',
      'assignedRoutes': 2,
      'successRate': '92%',
      'status': 'Active',
      'currentLocation': 'Bahati',
    },
    {
      'id': 'agent3',
      'name': 'Peter Ochieng',
      'assignedRoutes': 4,
      'successRate': '78%',
      'status': 'On Break',
      'currentLocation': 'Molo',
    },
  ];

  final List<Map<String, dynamic>> _collectionTasks = [
    {
      'id': 'task1',
      'accountNumber': 'ACC001234',
      'customerName': 'John Kamau',
      'amountDue': 12500.00,
      'agent': 'John Mwangi',
      'assignedDate': '2024-02-15',
      'status': 'In Progress',
      'priority': 'High',
    },
    {
      'id': 'task2',
      'accountNumber': 'ACC001237',
      'customerName': 'Grace Nyong\'o',
      'amountDue': 8900.00,
      'agent': 'Mary Wambui',
      'assignedDate': '2024-02-14',
      'status': 'Completed',
      'priority': 'Medium',
    },
  ];

  // Track selected accounts for route assignment
  final List<Map<String, dynamic>> _selectableAccounts = [
    {
      'account': 'ACC001234',
      'name': 'John Kamau',
      'amount': 12500.00,
      'selected': false,
    },
    {
      'account': 'ACC001237',
      'name': 'Grace Nyong\'o',
      'amount': 8900.00,
      'selected': false,
    },
    {
      'account': 'ACC001238',
      'name': 'Robert Kipchoge',
      'amount': 15600.00,
      'selected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Collection Agents
        _buildAgentsSection(),
        const SizedBox(height: 20),

        // Assign New Route
        _buildAssignmentSection(),
        const SizedBox(height: 20),

        // Collection Tasks
        _buildTasksSection(),
      ],
    );
  }

  Widget _buildAgentsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collection Agents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _collectionAgents.map((agent) => _buildAgentCard(agent)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentSection() {
    String? selectedAgentId;
    String? selectedZone;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Collection Route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAgentId,
                    decoration: const InputDecoration(
                      labelText: 'Collection Agent',
                      border: OutlineInputBorder(),
                    ),
                    items: _collectionAgents.map((agent) {
                      return DropdownMenuItem<String>(
                        value: agent['id'] as String,
                        child: Text(agent['name'] as String),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedAgentId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedZone,
                    decoration: const InputDecoration(
                      labelText: 'Zone/Area',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'nakuru_east', child: Text('Nakuru East')),
                      DropdownMenuItem(value: 'nakuru_west', child: Text('Nakuru West')),
                      DropdownMenuItem(value: 'bahati', child: Text('Bahati')),
                      DropdownMenuItem(value: 'molo', child: Text('Molo')),
                      DropdownMenuItem(value: 'naivasha', child: Text('Naivasha')),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        selectedZone = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Select Accounts for this Route:'),
            const SizedBox(height: 8),
            _buildAccountSelection(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedAgentId != null && selectedZone != null) {
                    widget.onAssignRoute(selectedAgentId!, selectedZone!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Collection route assigned successfully')),
                    );
                    setState(() {
                      selectedAgentId = null;
                      selectedZone = null;
                      for (var acc in _selectableAccounts) {
                        acc['selected'] = false;
                      }
                    });
                  }
                },
                child: const Text('ASSIGN COLLECTION ROUTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Collection Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._collectionTasks.map((task) => _buildTaskItem(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1E3A8A),
              child: Text(
                (agent['name'] as String).substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              agent['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Routes: ${agent['assignedRoutes']}'),
            Text('Success: ${agent['successRate']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: agent['status'] == 'Active' ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                agent['status'] as String,
                style: TextStyle(
                  color: agent['status'] == 'Active' ? Colors.green : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: _selectableAccounts.length,
        itemBuilder: (context, index) {
          final account = _selectableAccounts[index];
          return CheckboxListTile(
            title: Text(account['name'] as String),
            subtitle: Text('${account['account']} - KES ${account['amount']}'),
            value: account['selected'] as bool,
            onChanged: (bool? value) {
              setState(() {
                _selectableAccounts[index]['selected'] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTaskColor(task['status'] as String).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getTaskColor(task['status'] as String)),
      ),
      child: Row(
        children: [
          Icon(
            _getTaskIcon(task['status'] as String),
            color: _getTaskColor(task['status'] as String),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['customerName'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('Account: ${task['accountNumber']} • Amount: KES ${task['amountDue']}'),
                Text('Agent: ${task['agent']} • Assigned: ${task['assignedDate']}'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(task['priority'] as String).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task['priority'] as String,
              style: TextStyle(
                color: _getPriorityColor(task['priority'] as String),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleTaskAction(value, task),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'update', child: Text('Update Status')),
              const PopupMenuItem(value: 'reassign', child: Text('Reassign Agent')),
              const PopupMenuItem(value: 'view', child: Text('View Details')),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(String status) {
    return switch (status) {
      'Completed' => Colors.green,
      'In Progress' => Colors.blue,
      'Pending' => Colors.orange,
      'Cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _getTaskIcon(String status) {
    return switch (status) {
      'Completed' => Icons.check_circle,
      'In Progress' => Icons.timer,
      'Pending' => Icons.pending,
      'Cancelled' => Icons.cancel,
      _ => Icons.help,
    };
  }

  Color _getPriorityColor(String priority) {
    return switch (priority) {
      'High' => Colors.red,
      'Medium' => Colors.orange,
      'Low' => Colors.blue,
      _ => Colors.grey,
    };
  }

  void _handleTaskAction(String action, Map<String, dynamic> task) {
    switch (action) {
      case 'update':
        _updateTaskStatus(task);
        break;
      case 'reassign':
        _reassignTask(task);
        break;
      case 'view':
        _viewTaskDetails(task);
        break;
    }
  }

  void _updateTaskStatus(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status - ${task['customerName']}'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'New Status'),
          items: const [
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
            DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
          ],
          onChanged: (String? value) {
            if (value != null) {
              widget.onUpdateStatus(task['id'] as String, value);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status updated to $value')),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _reassignTask(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reassign Task - ${task['customerName']}'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'New Agent'),
          items: _collectionAgents.map((agent) {
            return DropdownMenuItem<String>(
              value: agent['id'] as String,
              child: Text(agent['name'] as String),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              // Handle reassignment logic here if needed
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task reassigned to ${agentNameFromId(value)}')),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String agentNameFromId(String id) {
    try {
      return _collectionAgents.firstWhere((a) => a['id'] == id)['name'] as String;
    } catch (_) {
      return 'Unknown Agent';
    }
  }

  void _viewTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details - ${task['customerName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account: ${task['accountNumber']}'),
            Text('Amount Due: KES ${task['amountDue']}'),
            Text('Assigned Agent: ${task['agent']}'),
            Text('Assigned Date: ${task['assignedDate']}'),
            Text('Status: ${task['status']}'),
            Text('Priority: ${task['priority']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}