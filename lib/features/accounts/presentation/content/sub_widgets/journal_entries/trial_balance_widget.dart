import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/journal_entry_model.dart';
import '../../../../providers/journal_entry_provider.dart';

class TrialBalanceWidget extends ConsumerStatefulWidget {
  const TrialBalanceWidget({super.key});

  @override
  ConsumerState<TrialBalanceWidget> createState() => _TrialBalanceWidgetState();
}

class _TrialBalanceWidgetState extends ConsumerState<TrialBalanceWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadTrialBalance();
  }

  void _loadTrialBalance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(journalEntryProvider.notifier).fetchTrialBalance(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadTrialBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalEntryProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Filter Card
          _buildFilterCard(),
          const SizedBox(height: 20),
          // Content
          state.isLoading && state.trialBalance == null
              ? const Center(child: CircularProgressIndicator())
              : state.trialBalance == null
              ? _buildEmptyState()
              : _buildTrialBalanceContent(state),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trial Balance Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    children: [
                      _buildDateFilter(true),
                      const SizedBox(height: 12),
                      _buildDateFilter(false),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loadTrialBalance,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                          ),
                          child: const Text('Generate'),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _buildDateFilter(true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDateFilter(false)),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: FilledButton(
                        onPressed: _loadTrialBalance,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                        ),
                        child: const Text('Generate'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter(bool isStartDate) {
    final date = isStartDate ? _startDate : _endDate;
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: isStartDate ? 'From Date' : 'To Date',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Select date',
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: date != null
            ? IconButton(
          icon: const Icon(Icons.clear, size: 16),
          onPressed: () {
            setState(() {
              if (isStartDate) {
                _startDate = null;
              } else {
                _endDate = null;
              }
            });
            _loadTrialBalance();
          },
        )
            : null,
      ),
      controller: TextEditingController(
        text: date != null
            ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
            : '',
      ),
      onTap: () => _selectDate(context, isStartDate),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.balance, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Trial Balance Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a date range and generate trial balance',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialBalanceContent(JournalEntryState state) {
    final trialBalance = state.trialBalance!;

    return Column(
      children: [
        // Summary Card
        _buildSummaryCard(trialBalance),
        const SizedBox(height: 20),
        // Trial Balance Table
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Trial Balance Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Account Code')),
                      DataColumn(label: Text('Account Name')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Debit'), numeric: true),
                      DataColumn(label: Text('Credit'), numeric: true),
                      DataColumn(label: Text('Balance'), numeric: true),
                    ],
                    rows: trialBalance.items.map((item) {
                      final balance = item.balance;
                      return DataRow(cells: [
                        DataCell(Text(item.accountCode)),
                        DataCell(Text(item.accountName)),
                        DataCell(Text(item.accountType)),
                        DataCell(Text(
                          'KES ${item.debit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: item.debit > 0 ? Colors.green : Colors.grey,
                            fontWeight:
                            item.debit > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        )),
                        DataCell(Text(
                          'KES ${item.credit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: item.credit > 0 ? Colors.red : Colors.grey,
                            fontWeight:
                            item.credit > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        )),
                        DataCell(Text(
                          'KES ${balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: balance > 0
                                ? Colors.green
                                : balance < 0
                                ? Colors.red
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(TrialBalance trialBalance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Period Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Period: ${trialBalance.startDate} to ${trialBalance.endDate}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _exportTrialBalance(trialBalance),
                  icon: const Icon(Icons.download),
                  tooltip: 'Export to CSV',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Totals
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Debit',
                    'KES ${trialBalance.totalDebit.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryItem(
                    'Total Credit',
                    'KES ${trialBalance.totalCredit.toStringAsFixed(2)}',
                    Colors.red,
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryItem(
                    'Difference',
                    'KES ${trialBalance.difference.toStringAsFixed(2)}',
                    trialBalance.difference.abs() <= 0.01
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryItem(
                    'Balance',
                    trialBalance.difference.abs() <= 0.01
                        ? 'Balanced'
                        : 'Out of Balance',
                    trialBalance.difference.abs() <= 0.01
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  void _exportTrialBalance(TrialBalance trialBalance) {
    // TODO: Implement CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
        backgroundColor: Colors.green,
      ),
    );
  }
}