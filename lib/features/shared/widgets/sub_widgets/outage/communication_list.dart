import 'package:flutter/material.dart';
import '../../../models/outage.dart';

class CommunicationListWidget extends StatefulWidget {
  final Outage outage;
  final Function(String, List<String>, PriorityLevel) onAddCommunication;

  const CommunicationListWidget({
    super.key,
    required this.outage,
    required this.onAddCommunication,
  });

  @override
  State<CommunicationListWidget> createState() =>
      _CommunicationListWidgetState();
}

class _CommunicationListWidgetState extends State<CommunicationListWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _selectedRecipients = [];
  PriorityLevel _selectedPriority = PriorityLevel.MEDIUM;
  bool _showNewMessage = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // New Message Button
        if (!_showNewMessage)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('New Message'),
                onPressed: () {
                  setState(() => _showNewMessage = true);
                },
              ),
            ),
          ),

        // New Message Form
        if (_showNewMessage)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Internal Communication',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _showNewMessage = false);
                            _messageController.clear();
                            _selectedRecipients.clear();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Priority:'),
                        const SizedBox(width: 8),
                        DropdownButton<PriorityLevel>(
                          value: _selectedPriority,
                          items: PriorityLevel.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(priority),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(priority.toString().split('.').last),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPriority = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Recipients:'),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Team Lead',
                        'Technicians',
                        'Management',
                        'Customer Service',
                      ].map((recipient) {
                        final isSelected =
                            _selectedRecipients.contains(recipient);
                        return FilterChip(
                          label: Text(recipient),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedRecipients.add(recipient);
                              } else {
                                _selectedRecipients.remove(recipient);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() => _showNewMessage = false);
                            _messageController.clear();
                            _selectedRecipients.clear();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _sendMessage,
                          child: const Text('Send Message'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Communications List
        Expanded(
          child: widget.outage.internalCommunications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text('No communications yet'),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation about this outage',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.outage.internalCommunications.length,
                  itemBuilder: (context, index) {
                    final comm = widget.outage.internalCommunications[index];
                    return _buildCommunicationCard(comm);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCommunicationCard(InternalCommunication comm) {
    final isUnread = comm.readBy.isEmpty; // Simplified logic
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
                  backgroundColor:
                      isUnread ? Colors.blue[100] : Colors.grey[200],
                  child: Text(comm.from[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comm.from,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUnread
                                  ? Colors.blue[800]
                                  : Colors.grey[800],
                            ),
                          ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _formatDateTime(comm.sentAt),
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
                    color: _getPriorityColor(comm.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comm.priority.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getPriorityColor(comm.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(comm.message),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.group, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'To: ${comm.to.join(', ')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${comm.readBy.length}/${comm.to.length} read',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.LOW:
        return Colors.green;
      case PriorityLevel.MEDIUM:
        return Colors.blue;
      case PriorityLevel.HIGH:
        return Colors.orange;
      case PriorityLevel.CRITICAL:
        return Colors.red;
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && _selectedRecipients.isNotEmpty) {
      widget.onAddCommunication(
          message, _selectedRecipients, _selectedPriority);
      _messageController.clear();
      _selectedRecipients.clear();
      setState(() => _showNewMessage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message and select recipients'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
