import 'package:flutter/material.dart';
import '../../../models/outage.dart';

class CustomerUpdatesWidget extends StatefulWidget {
  final Outage outage;
  final Function(String) onAddUpdate;

  const CustomerUpdatesWidget({
    super.key,
    required this.outage,
    required this.onAddUpdate,
  });

  @override
  State<CustomerUpdatesWidget> createState() => _CustomerUpdatesWidgetState();
}

class _CustomerUpdatesWidgetState extends State<CustomerUpdatesWidget> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Update Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Customer Update',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter update message for customers...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _addUpdate,
                      child: const Text('Publish Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Updates List
        Expanded(
          child: widget.outage.customerUpdates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text('No updates yet'),
                      const SizedBox(height: 8),
                      Text(
                        'Add the first update for customers',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.outage.customerUpdates.length,
                  itemBuilder: (context, index) {
                    final update = widget.outage.customerUpdates[index];
                    return _buildUpdateCard(update);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUpdateCard(CustomerUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(update.postedBy[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        update.postedBy,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDateTime(update.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: update.status == UpdateStatus.PUBLISHED
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    update.status.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 11,
                      color: update.status == UpdateStatus.PUBLISHED
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(update.message),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Published to ${widget.outage.estimatedAffectedCustomers} customers',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _addUpdate() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onAddUpdate(message);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update published successfully')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
