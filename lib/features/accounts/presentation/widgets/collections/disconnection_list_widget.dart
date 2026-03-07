import 'package:flutter/material.dart';

class DisconnectionListWidget extends StatefulWidget {
  final Function(String, DateTime, String) onScheduleDisconnection;
  final Function(String) onCancelDisconnection;

  const DisconnectionListWidget({
    super.key,
    required this.onScheduleDisconnection,
    required this.onCancelDisconnection,
  });

  @override
  State<DisconnectionListWidget> createState() => _DisconnectionListWidgetState();
}

class _DisconnectionListWidgetState extends State<DisconnectionListWidget> {
  final List<Map<String, dynamic>> _pendingDisconnections = [
    {
      'accountNumber': 'ACC001234',
      'customerName': 'John Kamau',
      'amountDue': 12500.00,
      'daysOverdue': 45,
      'disconnectionDate': '2024-02-20',
      'reason': 'Overdue Payment',
      'status': 'Scheduled',
    },
    {
      'accountNumber': 'ACC001237',
      'customerName': 'Grace Nyong\'o',
      'amountDue': 8900.00,
      'daysOverdue': 75,
      'disconnectionDate': '2024-02-18',
      'reason': 'Overdue Payment',
      'status': 'Pending',
    },
  ];

  final List<Map<String, dynamic>> _recentDisconnections = [
    {
      'accountNumber': 'ACC001200',
      'customerName': 'Michael Omondi',
      'amountDue': 6700.00,
      'disconnectionDate': '2024-02-15',
      'reconnectionDate': '2024-02-16',
      'reason': 'Overdue Payment',
      'status': 'Reconnected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Schedule New Disconnection
        _buildScheduleSection(),
        const SizedBox(height: 20),

        // Pending Disconnections
        _buildPendingDisconnections(),
        const SizedBox(height: 20),

        // Recent Disconnections
        _buildRecentDisconnections(),
      ],
    );
  }

  Widget _buildScheduleSection() {
    final TextEditingController accountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule New Disconnection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: accountController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Disconnection Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                        text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    ),
                    onTap: () => _selectDate(context, (date) => selectedDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Disconnection Reason',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (accountController.text.isNotEmpty && reasonController.text.isNotEmpty) {
                    widget.onScheduleDisconnection(
                      accountController.text,
                      selectedDate,
                      reasonController.text,
                    );
                    accountController.clear();
                    reasonController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Disconnection scheduled successfully')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('SCHEDULE DISCONNECTION'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDisconnections() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Disconnections',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._pendingDisconnections.map((disconnection) =>
                _buildDisconnectionItem(disconnection, true)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDisconnections() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Disconnections',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._recentDisconnections.map((disconnection) =>
                _buildDisconnectionItem(disconnection, false)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectionItem(Map<String, dynamic> disconnection, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPending ? Colors.orange[100]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPending ? Icons.warning : Icons.history,
            color: isPending ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disconnection['customerName'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('Account: ${disconnection['accountNumber']}'),
                Text('Due: KES ${disconnection['amountDue']} • ${disconnection['daysOverdue'] ?? 0} days overdue'),
                Text('Date: ${disconnection['disconnectionDate']} • ${disconnection['reason']}'),
                if (!isPending) Text('Status: ${disconnection['status']}'),
              ],
            ),
          ),
          if (isPending) ...[
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                widget.onCancelDisconnection(disconnection['accountNumber']);
                setState(() {
                  _pendingDisconnections.remove(disconnection);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Disconnection cancelled for ${disconnection['customerName']}')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                // Mark as completed
                setState(() {
                  _pendingDisconnections.remove(disconnection);
                  _recentDisconnections.add({
                    ...disconnection,
                    'status': 'Completed',
                    'reconnectionDate': DateTime.now().toString().split(' ')[0],
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Disconnection completed for ${disconnection['customerName']}')),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }
}