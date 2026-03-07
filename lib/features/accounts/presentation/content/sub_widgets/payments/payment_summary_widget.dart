import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/payment_model.dart';
import '../../../../providers/payment_provider.dart';

class PaymentSummaryWidget extends ConsumerStatefulWidget {
  const PaymentSummaryWidget({super.key});

  @override
  ConsumerState<PaymentSummaryWidget> createState() => _PaymentSummaryWidgetState();
}

class _PaymentSummaryWidgetState extends ConsumerState<PaymentSummaryWidget> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Load summary when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        final state = ref.read(paymentProvider);
        if (state.summary == null) {
          ref.read(paymentProvider.notifier).fetchPaymentSummary();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final summary = paymentState.summary;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12.0 : 24.0,
        vertical: 16.0,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight - 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  const Icon(Icons.analytics, color: Color(0xFF0D47A1), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Payment Summary',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Overview of all payments',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Loading State
              if (paymentState.isLoading && summary == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                )

              // Error State (if any)
              else if (paymentState.error != null && summary == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load summary',
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          paymentState.error!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(paymentProvider.notifier).fetchPaymentSummary(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )

              // Empty State
              else if (summary == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 24),
                          Text(
                            'No summary data available',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Payments may not have been recorded yet.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )

                // Actual Summary Content
                else ...[
                    // Summary Cards
                    _buildSummaryCards(summary, screenWidth),
                    const SizedBox(height: 24),

                    // Breakdown Tables
                    _buildBreakdownTables(summary, screenWidth),

                    const SizedBox(height: 24),

                    // Stats Card
                    _buildStatsCard(summary),
                  ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(PaymentSummary summary, double screenWidth) {
    final totals = summary.totals;
    final isSmall = screenWidth < 700;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmall ? 2 : 4,
      childAspectRatio: isSmall ? 1.4 : 1.6,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Payments',
          totals['totalPayments'].toString(),
          Icons.format_list_numbered,
          Colors.purple,
        ),
        _buildMetricCard(
          'Total Amount',
          'KES ${(totals['totalAmount'] ?? 0).toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          const Color(0xFF0D47A1),
        ),
        _buildMetricCard(
          'Total Tax',
          'KES ${(totals['totalTax'] ?? 0).toStringAsFixed(2)}',
          Icons.receipt_long,
          Colors.orange,
        ),
        _buildMetricCard(
          'Average Payment',
          'KES ${((totals['totalAmount'] ?? 0) / (totals['totalPayments'] ?? 1).toDouble().clamp(1, double.infinity)).toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownTables(PaymentSummary summary, double screenWidth) {
    final isSmall = screenWidth < 800;

    return Column(
      children: [
        _buildBreakdownTable(
          'By Payment Type',
          summary.byPaymentType,
          isSmall,
        ),
        const SizedBox(height: 24),
        _buildBreakdownTable(
          'By Payment Method',
          summary.byPaymentMethod,
          isSmall,
        ),
        const SizedBox(height: 24),
        _buildBreakdownTable(
          'By Payee Type',
          summary.byPayeeType,
          isSmall,
        ),
      ],
    );
  }

  Widget _buildBreakdownTable(String title, Map<String, dynamic> data, bool isSmall) {
    final entries = data.entries.toList();
    final totalAmount = entries.fold<double>(0, (sum, e) => sum + (e.value['amount'] as num).toDouble());

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: const Color(0xFF0D47A1), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('No data available', style: TextStyle(color: Colors.grey))
            else
              Table(
                columnWidths: isSmall
                    ? const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                }
                    : null,
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Count', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                  ...entries.map((entry) {
                    final amount = (entry.value['amount'] as num).toDouble();
                    final count = entry.value['count'] as int;
                    final percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0.0;
                    final label = _formatEnumValue(entry.key);

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(label),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(count.toString(), textAlign: TextAlign.right),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('KES ${amount.toStringAsFixed(2)}'),
                              Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(PaymentSummary summary) {
    final period = summary.period;
    final totals = summary.totals;

    final avgPayment = (totals['totalAmount'] ?? 0) / (totals['totalPayments'] ?? 1).toDouble().clamp(1, double.infinity);
    final taxRate = totals['totalAmount'] != null && totals['totalAmount'] > 0
        ? ((totals['totalTax'] ?? 0) / totals['totalAmount'] * 100)
        : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.insights, color: Color(0xFF0D47A1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Key Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightRow('Period Start', period['startDate'].toString()),
            _buildInsightRow('Period End', period['endDate'].toString()),
            const Divider(height: 24),
            _buildInsightRow('Average Payment', 'KES ${avgPayment.toStringAsFixed(2)}'),
            _buildInsightRow('Effective Tax Rate', '${taxRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  String _formatEnumValue(String value) {
    return value.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}