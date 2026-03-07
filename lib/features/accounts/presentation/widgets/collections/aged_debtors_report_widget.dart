import 'package:flutter/material.dart';

class AgedDebtorsReportWidget extends StatefulWidget {
  final Function(String) onExport;
  final Function(String) onContactCustomer;

  const AgedDebtorsReportWidget({
    super.key,
    required this.onExport,
    required this.onContactCustomer,
  });

  @override
  State<AgedDebtorsReportWidget> createState() => _AgedDebtorsReportWidgetState();
}

class _AgedDebtorsReportWidgetState extends State<AgedDebtorsReportWidget> {
  final List<Map<String, dynamic>> _debtors = [
    {
      'accountNumber': 'ACC001234',
      'customerName': 'John Kamau',
      'totalDue': 12500.00,
      'current': 4500.00,
      'days30': 3500.00,
      'days60': 2500.00,
      'days90': 2000.00,
      'daysOverdue': 45,
      'lastPayment': '2024-01-15',
      'status': 'Overdue',
    },
    {
      'accountNumber': 'ACC001237',
      'customerName': 'Grace Nyong\'o',
      'totalDue': 8900.00,
      'current': 0.00,
      'days30': 0.00,
      'days60': 4500.00,
      'days90': 4400.00,
      'daysOverdue': 75,
      'lastPayment': '2023-12-10',
      'status': 'Delinquent',
    },
    {
      'accountNumber': 'ACC001238',
      'customerName': 'Robert Kipchoge',
      'totalDue': 15600.00,
      'current': 0.00,
      'days30': 0.00,
      'days60': 0.00,
      'days90': 15600.00,
      'daysOverdue': 120,
      'lastPayment': '2023-10-20',
      'status': 'Critical',
    },
  ];

  String _filterStatus = 'all';
  String _sortBy = 'totalDue';

  List<Map<String, dynamic>> get _filteredDebtors {
    var filtered = _debtors;

    if (_filterStatus != 'all') {
      filtered = filtered.where((debtor) => debtor['status'] == _filterStatus).toList();
    }

    filtered.sort((a, b) {
      return switch (_sortBy) {
        'totalDue' => b['totalDue'].compareTo(a['totalDue']),
        'daysOverdue' => b['daysOverdue'].compareTo(a['daysOverdue']),
        'customerName' => a['customerName'].compareTo(b['customerName']),
        _ => b['totalDue'].compareTo(a['totalDue']),
      };
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final totalDebt = _debtors.fold(0.0, (sum, debtor) => sum + debtor['totalDue']);

    return Column(
      children: [
        // Summary Cards
        _buildSummaryCards(totalDebt),
        const SizedBox(height: 16),

        // Filters and Controls
        _buildControls(),
        const SizedBox(height: 16),

        // Debtors List
        Expanded(
          child: _buildDebtorsList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(double totalDebt) {
    final summaryData = {
      'totalDebt': 'KES ${totalDebt.toStringAsFixed(2)}',
      'totalAccounts': _debtors.length.toString(),
      'averageDebt': 'KES ${(totalDebt / _debtors.length).toStringAsFixed(2)}',
      'recoveryRate': '68.5%',
    };

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildSummaryCard('Total Debt', summaryData['totalDebt']!, Colors.red, Icons.money_off),
        _buildSummaryCard('Accounts', summaryData['totalAccounts']!, Colors.orange, Icons.people),
        _buildSummaryCard('Average Debt', summaryData['averageDebt']!, Colors.blue, Icons.trending_up),
        _buildSummaryCard('Recovery Rate', summaryData['recoveryRate']!, Colors.green, Icons.thumb_up),
      ],
    );
  }

  Widget _buildControls() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: _filterStatus,
                decoration: const InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'Overdue', child: Text('Overdue (1-30 days)')),
                  DropdownMenuItem(value: 'Delinquent', child: Text('Delinquent (31-90 days)')),
                  DropdownMenuItem(value: 'Critical', child: Text('Critical (90+ days)')),
                ],
                onChanged: (value) => setState(() => _filterStatus = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField(
                value: _sortBy,
                decoration: const InputDecoration(
                  labelText: 'Sort By',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'totalDue', child: Text('Total Due (High to Low)')),
                  DropdownMenuItem(value: 'daysOverdue', child: Text('Days Overdue')),
                  DropdownMenuItem(value: 'customerName', child: Text('Customer Name')),
                ],
                onChanged: (value) => setState(() => _sortBy = value!),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => widget.onExport('aged_debtors'),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtorsList() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Current', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('1-30 Days', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('31-60 Days', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('61-90+ Days', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Total Due', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Days Due', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Debtors List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDebtors.length,
              itemBuilder: (context, index) => _buildDebtorRow(_filteredDebtors[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtorRow(Map<String, dynamic> debtor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debtor['customerName'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  debtor['accountNumber'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text('KES ${debtor['current']}')),
          Expanded(flex: 1, child: Text('KES ${debtor['days30']}')),
          Expanded(flex: 1, child: Text('KES ${debtor['days60']}')),
          Expanded(flex: 1, child: Text('KES ${debtor['days90']}')),
          Expanded(
            flex: 1,
            child: Text(
              'KES ${debtor['totalDue']}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getDaysOverdueColor(debtor['daysOverdue']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${debtor['daysOverdue']} days',
                style: TextStyle(
                  color: _getDaysOverdueColor(debtor['daysOverdue']),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16),
              onSelected: (value) => _handleMenuAction(value, debtor),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'contact', child: Text('Contact Customer')),
                const PopupMenuItem(value: 'payment', child: Text('Payment Arrangement')),
                const PopupMenuItem(value: 'disconnect', child: Text('Schedule Disconnection')),
                const PopupMenuItem(value: 'writeoff', child: Text('Write Off Debt')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> debtor) {
    switch (action) {
      case 'contact':
        widget.onContactCustomer(debtor['accountNumber']);
        break;
      case 'payment':
        _setupPaymentArrangement(debtor);
        break;
      case 'disconnect':
        _scheduleDisconnection(debtor);
        break;
      case 'writeoff':
        _writeOffDebt(debtor);
        break;
    }
  }

  void _setupPaymentArrangement(Map<String, dynamic> debtor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Arrangement - ${debtor['customerName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Due: KES ${debtor['totalDue']}'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Monthly Payment Amount (KES)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Number of Months',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment arrangement set for ${debtor['customerName']}')),
              );
            },
            child: const Text('SET ARRANGEMENT'),
          ),
        ],
      ),
    );
  }

  void _scheduleDisconnection(Map<String, dynamic> debtor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Disconnection - ${debtor['customerName']}'),
        content: const Text('This account will be scheduled for disconnection due to overdue payments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Disconnection scheduled for ${debtor['customerName']}')),
              );
            },
            child: const Text('SCHEDULE'),
          ),
        ],
      ),
    );
  }

  void _writeOffDebt(Map<String, dynamic> debtor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Write Off Debt - ${debtor['customerName']}'),
        content: Text('Are you sure you want to write off KES ${debtor['totalDue']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Debt written off for ${debtor['customerName']}')),
              );
            },
            child: const Text('WRITE OFF'),
          ),
        ],
      ),
    );
  }

  Color _getDaysOverdueColor(int days) {
    if (days <= 30) return Colors.orange;
    if (days <= 90) return Colors.red;
    return Colors.purple;
  }
}