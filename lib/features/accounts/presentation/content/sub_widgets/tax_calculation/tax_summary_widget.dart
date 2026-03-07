import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/tax_calculation_provider.dart';

class TaxSummaryWidget extends ConsumerStatefulWidget {
  const TaxSummaryWidget({super.key});

  @override
  ConsumerState<TaxSummaryWidget> createState() => _TaxSummaryWidgetState();
}

class _TaxSummaryWidgetState extends ConsumerState<TaxSummaryWidget> {
  final Map<String, String> _filters = {
    'startDate': '',
    'endDate': '',
    'taxType': '',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxCalculationProvider.notifier).getTaxSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxCalculationProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          // Filter Card
          SliverToBoxAdapter(
            child: _buildFilterCard(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Summary Cards
          if (state.summary != null && state.summary!['totals'] != null)
            SliverToBoxAdapter(
              child: _buildSummaryCards(state.summary!),
            ),

          // Charts Section
          if (state.summary != null &&
              (state.summary!['byTaxType'] != null ||
                  state.summary!['byPaymentStatus'] != null)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: _buildChartsSection(state.summary!),
            ),
          ],

          // Loading State
          if (state.isLoading && state.summary == null)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),

          // Empty State
          if (state.summary == null && !state.isLoading)
            SliverToBoxAdapter(
              child: _buildEmptyState(),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF0D47A1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Tax Summary Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? Column(
                  children: [
                    _buildDateField('startDate', 'Start Date'),
                    const SizedBox(height: 12),
                    _buildDateField('endDate', 'End Date'),
                    const SizedBox(height: 12),
                    _buildTaxTypeFilter(),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(child: _buildDateField('startDate', 'Start Date')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDateField('endDate', 'End Date')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTaxTypeFilter()),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applySummaryFilters,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Update Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String field, String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.calendar_today),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      readOnly: true,
      onTap: () => _selectDate(field),
      controller: TextEditingController(text: _filters[field]),
    );
  }

  Widget _buildTaxTypeFilter() {
    return DropdownButtonFormField<String>(
      value: _filters['taxType']?.isEmpty ?? true ? '' : _filters['taxType'],
      decoration: InputDecoration(
        labelText: 'Tax Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(value: '', child: Text('All Types')),
        DropdownMenuItem(value: 'vat', child: Text('VAT')),
        DropdownMenuItem(value: 'income_tax', child: Text('Income Tax')),
        DropdownMenuItem(value: 'withholding_tax', child: Text('Withholding Tax')),
        DropdownMenuItem(value: 'excise_duty', child: Text('Excise Duty')),
        DropdownMenuItem(value: 'stamp_duty', child: Text('Stamp Duty')),
      ],
      onChanged: (value) => setState(() => _filters['taxType'] = value ?? ''),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    final totals = summary['totals'] as Map<String, dynamic>;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 2 : 4;
        final aspectRatio = isMobile ? 1.2 : 1.0;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSummaryCard(
              'Total Calculations',
              (totals['totalCalculations'] ?? 0).toString(),
              Icons.calculate,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Total Taxable',
              'KES ${((totals['totalTaxableAmount'] ?? 0) as num).toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              'Total Tax',
              'KES ${((totals['totalTaxAmount'] ?? 0) as num).toStringAsFixed(2)}',
              Icons.percent,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Net Payable',
              'KES ${((totals['totalNetPayable'] ?? 0) as num).toStringAsFixed(2)}',
              Icons.payment,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection(Map<String, dynamic> summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? Column(
                  children: [
                    _buildTaxTypeChart(summary['byTaxType']),
                    const SizedBox(height: 20),
                    _buildPaymentStatusChart(summary['byPaymentStatus']),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTaxTypeChart(summary['byTaxType'])),
                    const SizedBox(width: 20),
                    Expanded(child: _buildPaymentStatusChart(summary['byPaymentStatus'])),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxTypeChart(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return _buildEmptyChart('No tax type data available');
    }

    final entries = data.entries.toList();

    return _buildChart(
      'By Tax Type',
      entries.map((e) => _buildChartItem(
        e.key.toUpperCase().replaceAll('_', ' '),
        (e.value['amount'] ?? 0).toDouble(),
        _getColorForIndex(entries.indexOf(e)),
      )),
    );
  }

  Widget _buildPaymentStatusChart(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return _buildEmptyChart('No payment status data available');
    }

    final entries = data.entries.toList();

    return _buildChart(
      'By Payment Status',
      entries.map((e) => _buildChartItem(
        e.key.toUpperCase().replaceAll('_', ' '),
        (e.value['amount'] ?? 0).toDouble(),
        _getStatusColor(e.key),
      )),
    );
  }

  Widget _buildChart(String title, Iterable<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildChartItem(String label, double value, Color color) {
    // Calculate percentage based on max value
    final maxValue = 10000.0; // For demonstration
    final percentage = value > 0 ? (value / maxValue).clamp(0, 1) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'KES ${value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage.toDouble(),
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Column(
      children: [
        Text(
          message,
          style: TextStyle(color: Colors.grey[500]),
        ),
        const SizedBox(height: 20),
        Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.analytics, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Tax Summary Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tax summary will appear here once you have filed tax calculations',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(taxCalculationProvider.notifier).getTaxSummary();
              },
              child: const Text('Load Summary'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF0D47A1),
      const Color(0xFF1976D2),
      const Color(0xFF42A5F5),
      const Color(0xFF64B5F6),
      const Color(0xFF90CAF9),
    ];
    return colors[index % colors.length];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'partially_paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate(String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _filters[field] = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _applySummaryFilters() {
    ref.read(taxCalculationProvider.notifier).getTaxSummary(
      startDate: _filters['startDate']!.isEmpty ? null : _filters['startDate'],
      endDate: _filters['endDate']!.isEmpty ? null : _filters['endDate'],
      taxType: _filters['taxType']!.isEmpty ? null : _filters['taxType'],
    );
  }
}